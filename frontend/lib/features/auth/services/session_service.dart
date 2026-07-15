import 'package:supabase_flutter/supabase_flutter.dart';

class SessionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool get hasSession => _supabase.auth.currentSession != null;

  Session? get currentSession => _supabase.auth.currentSession;

  User? get currentUser => _supabase.auth.currentUser;

  // Supabase automatically restores sessions from local storage when initialized.
  // This service can be expanded if additional custom session persistence logic is needed.
}
