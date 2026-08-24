import 'dart:convert';

import 'package:shelf/shelf.dart';

Future<Map<String, dynamic>> readJsonObject(
  Request request, {
  Set<String> allowedKeys = const {},
  Set<String> requiredKeys = const {},
}) async {
  final contentType = request.headers['content-type'];
  if (contentType == null ||
      !contentType.toLowerCase().startsWith('application/json')) {
    throw const FormatException('Content-Type must be application/json');
  }

  final body = await request.readAsString();
  if (body.trim().isEmpty) {
    throw const FormatException('Request body cannot be empty');
  }

  final decoded = jsonDecode(body);
  if (decoded is! Map) {
    throw const FormatException('Request body must be a JSON object');
  }
  final data = Map<String, dynamic>.from(decoded);

  final unknown = allowedKeys.isEmpty
      ? const <String>[]
      : data.keys.where((key) => !allowedKeys.contains(key)).toList();
  if (unknown.isNotEmpty) {
    throw FormatException('Unknown field: ${unknown.first}');
  }
  final missing = requiredKeys.where((key) => !data.containsKey(key)).toList();
  if (missing.isNotEmpty) {
    throw FormatException('Missing required field: ${missing.first}');
  }
  return data;
}
