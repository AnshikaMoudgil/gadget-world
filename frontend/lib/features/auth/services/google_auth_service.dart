import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart' as google;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../profile/models/profile_model.dart';
import '../../profile/services/profile_service.dart';

class GoogleAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ProfileService _profileService = ProfileService();
  
  static String? _currentNonce;
  static bool isSignUpIntent = false;
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
    const iosClientId = 'my-ios-client-id';

    _currentNonce = _generateNonce();
    final hashedNonce = _sha256ofString(_currentNonce!);

    // Initialize the singleton
    await google.GoogleSignIn.instance.initialize(
      clientId: kIsWeb ? webClientId : iosClientId,
      nonce: hashedNonce, // Google gets the hashed nonce
    );

    // On web, the renderButton automatically triggers this stream when the user logs in.
    if (kIsWeb) {
      google.GoogleSignIn.instance.authenticationEvents.listen((event) async {
        if (event is google.GoogleSignInAuthenticationEventSignIn) {
          final account = event.user;
          final googleAuth = await account.authentication;
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
              
              final user = res.user;
              if (user != null) {
                final profileService = ProfileService();
                final profile = await profileService.getProfile(user.id);
                
                if (profile == null) {
                  if (isSignUpIntent) {
                    await profileService.createProfile(Profile(
                      id: user.id,
                      fullName: account.displayName ?? 'Google User',
                      email: account.email,
                    ));
                    authSuccessStream.add(null);
                  } else {
                    await Supabase.instance.client.auth.signOut();
                    // We must signal the UI that login failed because no account exists
                    throw const AuthException('No account exists with this Google account. Please sign up first.');
                  }
                } else {
                  authSuccessStream.add(null);
                }
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

  // Sign in manually (used for Android/iOS primarily)
  Future<AuthResponse?> signInWithGoogle({bool isSignUp = false}) async {
    if (kIsWeb) {
      // On web, we don't manually call authenticate(). The renderButton does it.
      // Returning null here because the actual login happens in the stream listener above.
      return null;
    }

    google.GoogleSignInAccount? googleUser;
    try {
      googleUser = await google.GoogleSignIn.instance.authenticate();
    } catch (e) {
      debugPrint("Google Sign In Error: $e");
      return null;
    }

    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
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

    final user = res.user;
    if (user != null) {
      final profile = await _profileService.getProfile(user.id);
      if (profile == null) {
        if (isSignUp) {
          await _profileService.createProfile(Profile(
            id: user.id,
            fullName: googleUser.displayName ?? 'Google User',
            email: googleUser.email,
          ));
        } else {
          await _supabase.auth.signOut();
          throw const AuthException('No account exists with this Google account. Please sign up first.');
        }
      }
    }

    return res;
  }
}
