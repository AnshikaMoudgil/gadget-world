import 'dart:convert';
import 'dart:io';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import '../../../core/database/supabase_db.dart';

class NotificationService {
  static const _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
  static const _projectId = 'gadget-world-a1a2c';

  /// Fetch OAuth2 token using service account JSON
  Future<String?> _getAccessToken() async {
    try {
      final jsonFile = File('gadget-world-a1a2c-firebase-adminsdk-fbsvc-f13400dda4.json');
      if (!await jsonFile.exists()) {
        print('Firebase service account JSON not found.');
        return null;
      }
      final credentials = ServiceAccountCredentials.fromJson(await jsonFile.readAsString());
      final client = await clientViaServiceAccount(credentials, _scopes);
      final token = client.credentials.accessToken.data;
      client.close();
      return token;
    } catch (e) {
      print('Error getting Firebase access token: $e');
      return null;
    }
  }

  /// Send push notification via FCM HTTP v1 API
  Future<void> sendPushNotification({
    required String fcmToken,
    required String title,
    required String body,
    String? imageUrl,
    Map<String, String>? data,
  }) async {
    final accessToken = await _getAccessToken();
    if (accessToken == null) return;

    final url = Uri.parse('https://fcm.googleapis.com/v1/projects/$_projectId/messages:send');
    final payload = {
      'message': {
        'token': fcmToken,
        'notification': {
          'title': title,
          'body': body,
          if (imageUrl != null) 'image': imageUrl,
        },
        if (data != null) 'data': data,
      }
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200) {
        print('FCM send failed: ${response.body}');
      }
    } catch (e) {
      print('FCM HTTP request error: $e');
    }
  }

  /// Sends a notification to a specific user (saves to DB and pushes via FCM)
  Future<void> notifyUser({
    required String userId,
    required String title,
    required String body,
    String type = 'system',
    String? referenceType,
    String? referenceId,
    String? imageUrl,
  }) async {
    try {
      // 1. Insert into public.notifications
      await SupabaseDb.client.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'body': body,
        'type': type,
        if (referenceType != null) 'reference_type': referenceType,
        if (referenceId != null) 'reference_id': referenceId,
        if (imageUrl != null) 'image_url': imageUrl,
      });

      // 2. Fetch user's FCM tokens
      final tokensData = await SupabaseDb.client
          .from('user_fcm_tokens')
          .select('token')
          .eq('user_id', userId);

      // 3. Send push notifications
      for (final row in tokensData) {
        final token = row['token'] as String;
        await sendPushNotification(
          fcmToken: token,
          title: title,
          body: body,
          imageUrl: imageUrl,
          data: {
            'type': type,
            if (referenceType != null) 'referenceType': referenceType,
            if (referenceId != null) 'referenceId': referenceId,
          },
        );
      }
    } catch (e) {
      print('notifyUser Error: $e');
    }
  }
}
