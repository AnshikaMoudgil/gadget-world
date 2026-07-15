import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart' as google;
import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  static String? _currentNonce;
  static final StreamController<String> authErrorStream = StreamController<String>.broadcast();
  static final StreamController<void> authSuccessStream = StreamController<void>.broadcast();

  static String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  static String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Call this once at app startup
  static Future<void> init() async {
    const webClientId = '1066748448834-ltr6bv67jk0oa6jdcs39sphdklqcfjj2.apps.googleusercontent.com';

    _currentNonce = _generateNonce();
    final hashedNonce = _sha256ofString(_currentNonce!);

    // Initialize the singleton.
    // Web: clientId identifies the app to Google Identity Services.
    // Android: serverClientId (the web client ID) is required to get an ID token.
    // iOS: not configured yet — needs its own clientId when iOS support is added.
    await google.GoogleSignIn.instance.initialize(
      clientId: kIsWeb ? webClientId : null,
      serverClientId: kIsWeb ? null : webClientId,
      nonce: hashedNonce, // Google gets the hashed nonce
    );

    // On web, the renderButton automatically triggers this stream when the user logs in.
    if (kIsWeb) {
      google.GoogleSignIn.instance.authenticationEvents.listen((event) async {
        if (event is google.GoogleSignInAuthenticationEventSignIn) {
          final account = event.user;
          final googleAuth = account.authentication;
          final idToken = googleAuth.idToken;
          
          if (idToken != null) {
            // We must retrieve the auth client for access token in v7
            final authz = await account.authorizationClient.authorizationForScopes([]);
            final accessToken = authz?.accessToken;

            try {
              final res = await Supabase.instance.client.auth.signInWithIdToken(
                provider: OAuthProvider.google,
                idToken: idToken,
                accessToken: accessToken,
                nonce: _currentNonce,
              );
              
              if (res.user != null) {
                // Profile row is auto-created by the DB trigger (handle_new_user_signup).
                authSuccessStream.add(null);
              }
            } catch (e) {
              debugPrint("Supabase sign in failed from stream: $e");
              if (e is AuthException) {
                authErrorStream.add(e.message);
              } else {
                authErrorStream.add('Google sign in failed');
              }
            }
          }
        }
      });
    }
  }

  // Sign in with Google (used for Android/iOS primarily)
  // On web, the renderButton handles it via the stream listener above.
  Future<AuthResponse?> signInWithGoogle() async {
    if (kIsWeb) {
      // On web, we don't manually call authenticate(). The renderButton does it.
      // Returning null here because the actual login happens in the stream listener above.
      return null;
    }

    google.GoogleSignInAccount googleUser;
    try {
      googleUser = await google.GoogleSignIn.instance.authenticate();
    } catch (e) {
      debugPrint("Google Sign In Error: $e");
      return null;
    }

    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) throw 'No ID Token found.';

    final authz = await googleUser.authorizationClient.authorizationForScopes([]);
    final accessToken = authz?.accessToken;

    final res = await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
      nonce: _currentNonce,
    );

    // Profile row is auto-created by the DB trigger (handle_new_user_signup).
    return res;
  }
}
