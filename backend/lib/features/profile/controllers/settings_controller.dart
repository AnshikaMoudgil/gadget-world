import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../../core/network/safe_error.dart';
import '../../../core/network/json_request.dart';
import '../services/settings_service.dart';
import '../models/update_settings_request.dart';

class SettingsController {
  final SettingsService _service = SettingsService();

  Future<Response> getSettings(Request request) async {
    final userId = request.context['userId'] as String;

    try {
      final settings = await _service.getSettings(userId);
      return Response.ok(jsonEncode(settings.toJson()),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return SafeError.response('settings.get', e);
    }
  }

  Future<Response> updateSettings(Request request) async {
    final userId = request.context['userId'] as String;

    try {
      final data = await readJsonObject(
        request,
        allowedKeys: {
          'order_updates_sms',
          'order_updates_email',
          'promotions_email',
          'preferred_theme',
          'preferred_language',
        },
      );
      final req = UpdateSettingsRequest.fromJson(data);
      final validationError = req.validate();
      if (validationError != null) {
        return Response.badRequest(
          body: jsonEncode({'error': validationError}),
          headers: SafeError.jsonHeaders,
        );
      }

      final settings = await _service.updateSettings(userId, req);
      return Response.ok(jsonEncode(settings.toJson()),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return SafeError.response(
        'settings.update',
        e,
        statusCode: 400,
        message: 'Unable to update settings.',
      );
    }
  }
}
