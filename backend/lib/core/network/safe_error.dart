import 'dart:convert';
import 'dart:math';

import 'package:shelf/shelf.dart';

class SafeError {
  SafeError._();

  static final Random _random = Random.secure();
  static const jsonHeaders = {'Content-Type': 'application/json'};

  static String report(
    String operation,
    Object error, {
    int statusCode = 500,
  }) {
    final errorId = _newId();
    // Intentionally omit error.toString(), stack traces, request bodies, and
    // provider/database payloads. The exception type and operation are enough
    // to correlate failures without leaking secrets into centralized logs.
    print(jsonEncode({
      'level': 'error',
      'error_id': errorId,
      'operation': operation,
      'error_type': error.runtimeType.toString(),
      'status_code': statusCode,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    }));
    return errorId;
  }

  static Response response(
    String operation,
    Object error, {
    int statusCode = 500,
    String message = 'The request could not be completed.',
  }) {
    final errorId = report(operation, error, statusCode: statusCode);
    return Response(
      statusCode,
      body: jsonEncode({'error': message, 'error_id': errorId}),
      headers: jsonHeaders,
    );
  }

  static String _newId() {
    final time = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final random = List.generate(
      8,
      (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    return 'err_${time}_$random';
  }
}

Middleware safeErrorMiddleware() {
  return (Handler innerHandler) => (Request request) async {
        try {
          return await innerHandler(request);
        } catch (error) {
          return SafeError.response(
            '${request.method} ${request.url.path}',
            error,
          );
        }
      };
}
