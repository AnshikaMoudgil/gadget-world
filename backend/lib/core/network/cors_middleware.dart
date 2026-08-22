import 'package:shelf/shelf.dart';

/// Adds CORS headers only for explicitly trusted browser origins.
Middleware corsMiddleware(Iterable<String> allowedOrigins) {
  final allowed = allowedOrigins.toSet();
  if (allowed.isEmpty || allowed.contains('*')) {
    throw StateError('ALLOWED_ORIGINS must contain explicit origins');
  }

  const preflightHeaders = {
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers':
        'Origin, Content-Type, Accept, Authorization',
    'Access-Control-Max-Age': '600',
    'Vary': 'Origin',
  };

  return (Handler innerHandler) {
    return (Request request) async {
      final origin = request.headers['origin'];
      final isAllowed = origin != null && allowed.contains(origin);

      if (request.method == 'OPTIONS') {
        if (!isAllowed) {
          return Response.forbidden('Origin is not allowed');
        }
        return Response(204, headers: {
          ...preflightHeaders,
          'Access-Control-Allow-Origin': origin,
        });
      }

      final response = await innerHandler(request);
      if (!isAllowed) return response;
      return response.change(headers: {
        ...preflightHeaders,
        'Access-Control-Allow-Origin': origin,
      });
    };
  };
}
