import 'dart:io';

import 'package:shelf/shelf.dart';

typedef RequestLogSink = void Function(String message);

/// Logs only operational request metadata. Query strings, headers, request
/// bodies, exception messages, and stack traces are intentionally excluded.
Middleware safeRequestLoggingMiddleware({RequestLogSink? log}) {
  final sink = log ?? stdout.writeln;

  return (Handler innerHandler) => (Request request) async {
        final stopwatch = Stopwatch()..start();
        try {
          final response = await innerHandler(request);
          stopwatch.stop();
          sink(
            '${request.method} /${request.url.path} '
            '${response.statusCode} ${stopwatch.elapsedMilliseconds}ms',
          );
          return response;
        } catch (_) {
          stopwatch.stop();
          sink(
            '${request.method} /${request.url.path} '
            '500 ${stopwatch.elapsedMilliseconds}ms error',
          );
          rethrow;
        }
      };
}

Middleware securityHeadersMiddleware({
  required bool requireHttps,
  required bool trustProxy,
}) {
  const headers = {
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY',
    'Referrer-Policy': 'no-referrer',
    'Permissions-Policy': 'camera=(), microphone=(), geolocation=()',
    'Content-Security-Policy': "default-src 'none'; frame-ancestors 'none'",
    'Cache-Control': 'no-store',
  };

  return (Handler innerHandler) => (Request request) async {
        final scheme = trustProxy
            ? request.headers['x-forwarded-proto']?.split(',').first.trim()
            : request.requestedUri.scheme;
        if (requireHttps && scheme != 'https') {
          return Response.forbidden('HTTPS is required', headers: headers);
        }
        final response = await innerHandler(request);
        return response.change(headers: {...response.headers, ...headers});
      };
}

Middleware requestLimitsMiddleware({
  required int maxBodyBytes,
  required Duration timeout,
}) {
  return (Handler innerHandler) => (Request request) async {
        return (() async {
          final declaredLength = int.tryParse(
            request.headers[HttpHeaders.contentLengthHeader] ?? '',
          );
          if (declaredLength != null && declaredLength > maxBodyBytes) {
            return Response(413, body: 'Request body is too large');
          }

          var boundedRequest = request;
          if (request.method != 'GET' && request.method != 'HEAD') {
            final bytes = <int>[];
            await for (final chunk in request.read()) {
              bytes.addAll(chunk);
              if (bytes.length > maxBodyBytes) {
                return Response(413, body: 'Request body is too large');
              }
            }
            boundedRequest = request.change(body: bytes);
          }

          return innerHandler(boundedRequest);
        })()
            .timeout(
          timeout,
          onTimeout: () => Response(504, body: 'Request timed out'),
        );
      };
}

Middleware rateLimitMiddleware({
  required int requestsPerMinute,
  required bool trustProxy,
}) {
  final clients = <String, _RateWindow>{};

  return (Handler innerHandler) => (Request request) async {
        final now = DateTime.now().toUtc();
        final client = _clientAddress(request, trustProxy);
        final current = clients[client];
        final window =
            current == null || now.difference(current.started).inMinutes >= 1
                ? _RateWindow(now, 0)
                : current;
        window.count++;
        clients[client] = window;

        if (window.count > requestsPerMinute) {
          return Response(429,
              headers: {'Retry-After': '60'}, body: 'Rate limit exceeded');
        }

        if (clients.length > 10000) {
          clients.removeWhere(
            (_, value) => now.difference(value.started).inMinutes >= 2,
          );
        }
        return innerHandler(request);
      };
}

String _clientAddress(Request request, bool trustProxy) {
  if (trustProxy) {
    final forwarded = request.headers['x-forwarded-for'];
    if (forwarded != null && forwarded.isNotEmpty) {
      return forwarded.split(',').first.trim();
    }
  }
  final connection = request.context['shelf.io.connection_info'];
  return connection is HttpConnectionInfo
      ? connection.remoteAddress.address
      : 'unknown';
}

class _RateWindow {
  _RateWindow(this.started, this.count);

  final DateTime started;
  int count;
}
