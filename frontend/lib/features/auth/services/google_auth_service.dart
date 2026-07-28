import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart' as google;
import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static String? _currentNonce;
  static final StreamController<String> authErrorStream =
      StreamController<String>.broadcast();
  static final StreamController<void> authSuccessStream =
      StreamController<void>.broadcast();

  static String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  static String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Call this once at app startup
  static Future<void> init() async {
    final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];
    final androidClientId = dotenv.env['GOOGLE_ANDROID_CLIENT_ID'];

    _currentNonce = _generateNonce();
    final hashedNonce = _sha256ofString(_currentNonce!);

    await google.GoogleSignIn.instance.initialize(
      clientId: kIsWeb ? webClientId : null,
      serverClientId: kIsWeb ? null : webClientId,
      nonce: hashedNonce,
    );

    if (kIsWeb) {
      google.GoogleSignIn.instance.authenticationEvents.listen((event) async {
        if (event is google.GoogleSignInAuthenticationEventSignIn) {
          final account = event.user;
          final googleAuth = account.authentication;
          final idToken = googleAuth.idToken;

          if (idToken != null) {
            final authz = await account.authorizationClient
                .authorizationForScopes([]);
            final accessToken = authz?.accessToken;

            try {
              final res = await Supabase.instance.client.auth.signInWithIdToken(
                provider: OAuthProvider.google,
                idToken: idToken,
                accessToken: accessToken,
                nonce: _currentNonce,
              );
              if (res.user != null) {
                authSuccessStream.add(null);
              }
            } catch (e) {
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

  /// Sign in with Google (supports Web, Android, iOS)
  Future<AuthResponse?> signInWithGoogle() async {
    if (kIsWeb) {
      // On web, the renderButton overlay handles auth via the stream listener.
      // Returning null here; actual login completes through authenticationEvents.
      return null;
    }

    google.GoogleSignInAccount? googleUser;
    try {
      googleUser = await google.GoogleSignIn.instance.authenticate();
    } catch (e) {
      debugPrint("Google Sign In Error: $e");
    }

    if (googleUser == null) {
      // Fallback: If native Google Sign-In fails (e.g. SHA-1 issue), use OAuth browser flow!
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.tensorik.gadgetstore://login-callback/',
      );
      // Wait a moment for the deep link to process
      await Future.delayed(const Duration(milliseconds: 500));
      return null;
    }

    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw 'No ID Token found.';
    }

    final authz = await googleUser.authorizationClient.authorizationForScopes(
      [],
    );
    final accessToken = authz?.accessToken;

    final res = await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
      nonce: _currentNonce,
    );

    return res;
  }
}
