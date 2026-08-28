import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart' as google;
import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const List<String> _identityScopes = <String>[
    'openid',
    'https://www.googleapis.com/auth/userinfo.email',
    'https://www.googleapis.com/auth/userinfo.profile',
  ];

  static Future<void>? _initialization;
  static StreamSubscription<google.GoogleSignInAuthenticationEvent>?
  _webAuthSubscription;
  static final StreamController<String> authErrorStream =
      StreamController<String>.broadcast();
  static final StreamController<void> authSuccessStream =
      StreamController<void>.broadcast();

  /// Call this once at app startup
  static Future<void> init() => _initialization ??= _initialize();

  static Future<void> _initialize() async {
    final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];
    if (webClientId == null || webClientId.trim().isEmpty) {
      throw StateError('GOOGLE_WEB_CLIENT_ID is not configured.');
    }

    await google.GoogleSignIn.instance.initialize(
      clientId: kIsWeb ? webClientId : null,
      serverClientId: kIsWeb ? null : webClientId,
    );

    if (kIsWeb) {
      await _webAuthSubscription?.cancel();
      _webAuthSubscription = google.GoogleSignIn.instance.authenticationEvents
          .listen((event) async {
            if (event is google.GoogleSignInAuthenticationEventSignIn) {
              final account = event.user;
              final googleAuth = account.authentication;
              final idToken = googleAuth.idToken;

              if (idToken != null) {
                final authz = await account.authorizationClient
                    .authorizationForScopes(_identityScopes);
                final accessToken = authz?.accessToken;

                try {
                  final res = await Supabase.instance.client.auth
                      .signInWithIdToken(
                        provider: OAuthProvider.google,
                        idToken: idToken,
                        accessToken: accessToken,
                      );
                  if (res.user != null) {
                    authSuccessStream.add(null);
                  }
                } catch (e, stackTrace) {
                  debugPrint('Supabase Google token exchange failed: $e');
                  debugPrintStack(stackTrace: stackTrace);
                  if (e is AuthException) {
                    authErrorStream.add(e.message);
                  } else {
                    authErrorStream.add(
                      'Google authentication could not be completed.',
                    );
                  }
                }
              } else {
                authErrorStream.add('Google did not return an identity token.');
              }
            }
          });
    }
  }

  /// Sign in with Google (supports Web, Android, iOS)
  Future<AuthResponse?> signInWithGoogle() async {
    // Startup intentionally does not block the first frame. A user can therefore
    // reach the button before initialization has completed, so always await it.
    await init();

    if (kIsWeb) {
      // On web, the renderButton overlay handles auth via the stream listener.
      // Returning null here; actual login completes through authenticationEvents.
      return null;
    }

    final google.GoogleSignInAccount googleUser;
    try {
      googleUser = await google.GoogleSignIn.instance.authenticate();
    } catch (e) {
      if (e is PlatformException &&
          (e.code == 'sign_in_canceled' || e.code == 'CANCELED')) {
        throw const GoogleSignInFailure('Google sign-in was cancelled.');
      } else if (e is google.GoogleSignInException &&
          e.code == google.GoogleSignInExceptionCode.canceled) {
        throw const GoogleSignInFailure('Google sign-in was cancelled.');
      } else if (e is google.GoogleSignInException) {
        throw GoogleSignInFailure(
          'Google sign-in failed (${e.code.name}). ${e.description ?? ''}',
        );
      }
      rethrow;
    }

    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw const GoogleSignInFailure(
        'Google did not return an identity token.',
      );
    }

    final authorizationClient = googleUser.authorizationClient;
    final authz =
        await authorizationClient.authorizationForScopes(_identityScopes) ??
        await authorizationClient.authorizeScopes(_identityScopes);
    final accessToken = authz.accessToken;

    final res = await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    return res;
  }
}

class GoogleSignInFailure implements Exception {
  const GoogleSignInFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
