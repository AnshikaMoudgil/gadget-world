import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gadget_world/features/profile/models/user_settings.dart';

class SettingsApiService {
  static String get baseUrl {
    final configured = dotenv.env['BACKEND_URL'] ?? dotenv.env['API_BASE_URL'];
    if (configured == null || configured.trim().isEmpty) {
      throw StateError('BACKEND_URL is not configured in .env file');
    }
    final base = configured.replaceFirst(RegExp(r'/$'), '');
    return '$base/api/settings';
  }

  Future<UserSettings> getSettings(String token) async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return UserSettings.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load settings');
    }
  }

  Future<UserSettings> updateSettings(
    String token,
    Map<String, dynamic> data,
  ) async {
    final response = await http.put(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return UserSettings.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body)['error'] ?? 'Unknown error';
      throw Exception('Failed to update settings: $error');
    }
  }
}
