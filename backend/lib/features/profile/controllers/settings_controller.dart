import 'dart:convert';
import 'package:shelf/shelf.dart';
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
      return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'});
    }
  }

  Future<Response> updateSettings(Request request) async {
    final userId = request.context['userId'] as String;

    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final req = UpdateSettingsRequest.fromJson(data);

      final settings = await _service.updateSettings(userId, req);
      return Response.ok(jsonEncode(settings.toJson()),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.badRequest(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'});
    }
  }
}
