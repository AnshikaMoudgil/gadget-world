import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart' as google;

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign out
  Future<void> signOut() async {
    try {
      await google.GoogleSignIn.instance.signOut();
    } catch (_) {}
    await _supabase.auth.signOut();
  }

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Listen to auth changes
  Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;
}
