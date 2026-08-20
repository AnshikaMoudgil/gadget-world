import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static final StreamController<String> authErrorStream =
      StreamController<String>.broadcast();
  static final StreamController<void> authSuccessStream =
      StreamController<void>.broadcast();

  /// Call this once at app startup
  static Future<void> init() async {
    // Supabase native OAuth handles redirects automatically.
    // Auth state changes are generally listened to in auth_provider.dart
  }

  /// Sign in with Google (supports Web, Android, iOS via OAuth Webview/Redirect)
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      final success = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb
            ? null
            : 'com.tensorik.gadgetstore://login-callback/',
      );

      if (!success) {
        authErrorStream.add('Google sign in failed');
      }
      // Note: For native platforms (Android/iOS), signInWithOAuth opens a webview.
      // Upon successful login, the app receives a deep link, and Supabase automatically
      // handles the session creation.
      return null;
    } catch (e) {
      if (e is AuthException) {
        authErrorStream.add(e.message);
      } else {
        authErrorStream.add('Google sign in failed: $e');
      }
      return null;
    }
  }
}
