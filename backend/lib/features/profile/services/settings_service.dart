import '../../../core/database/supabase_db.dart';
import '../models/user_settings.dart';
import '../models/update_settings_request.dart';

class SettingsService {
  Future<UserSettings> getSettings(String userId) async {
    final result = await SupabaseDb.querySingle<Map<String, dynamic>>(() async {
      return await SupabaseDb.adminClient
          .from('user_settings')
          .select()
          .eq('user_id', userId)
          .single();
    });

    if (result.isError) {
      throw Exception('Failed to fetch settings: \${result.message}');
    }

    if (result.data == null) {
      throw Exception('Settings not found for user');
    }

    return UserSettings.fromJson(result.data!);
  }

  Future<UserSettings> updateSettings(
      String userId, UpdateSettingsRequest request) async {
    final data = request.toJson();
    if (data.isEmpty) {
      throw Exception('No fields to update');
    }

    final result = await SupabaseDb.querySingle<Map<String, dynamic>>(() async {
      return await SupabaseDb.adminClient
          .from('user_settings')
          .update(data)
          .eq('user_id', userId)
          .select()
          .single();
    });

    if (result.isError) {
      throw Exception('Failed to update settings: \${result.message}');
    }

    return UserSettings.fromJson(result.data!);
  }
}
