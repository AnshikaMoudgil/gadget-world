import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Profile?> getProfile(String userId) async {
    try {
      var data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) {
        await _supabase.rpc('ensure_my_profile');
        data = await _supabase
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();
      }
      if (data == null) return null;
      return Profile.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  Future<Profile> updateProfile(Profile profile) async {
    try {
      final data = await _supabase
          .from('profiles')
          .update(profile.toUpdateJson())
          .eq('id', profile.id)
          .select()
          .single();

      return Profile.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}
