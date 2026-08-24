import 'dart:async';

import 'package:backend/core/network/cors_middleware.dart';
import 'package:backend/core/network/security_middleware.dart';
import 'package:backend/core/network/safe_error.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  group('CORS middleware', () {
    final handler = corsMiddleware(['https://shop.example.com'])(
      (_) => Response.ok('ok'),
    );

    test('returns CORS headers for an allowed origin', () async {
      final response = await handler(
        Request(
          'GET',
          Uri.parse('http://localhost/test'),
          headers: {'Origin': 'https://shop.example.com'},
        ),
      );

      expect(response.headers['access-control-allow-origin'],
          'https://shop.example.com');
      expect(response.headers['vary'], 'Origin');
    });

    test('rejects a disallowed preflight origin', () async {
      final response = await handler(
        Request(
          'OPTIONS',
          Uri.parse('http://localhost/test'),
          headers: {'Origin': 'https://evil.example.com'},
        ),
      );

      expect(response.statusCode, 403);
      expect(response.headers['access-control-allow-origin'], isNull);
    });
  });

  test('security headers preserve headers added by inner middleware', () async {
    final handler = securityHeadersMiddleware(
      requireHttps: false,
      trustProxy: false,
    )(corsMiddleware(['https://shop.example.com'])(
      (_) => Response.ok('ok'),
    ));

    final response = await handler(Request(
      'GET',
      Uri.parse('http://localhost/test'),
      headers: {'Origin': 'https://shop.example.com'},
    ));

    expect(response.headers['access-control-allow-origin'],
        'https://shop.example.com');
    expect(response.headers['x-content-type-options'], 'nosniff');
  });

  test('HTTPS enforcement ignores forwarded protocol from direct clients',
      () async {
    final handler = securityHeadersMiddleware(
      requireHttps: true,
      trustProxy: false,
    )((_) => Response.ok('ok'));

    final response = await handler(Request(
      'GET',
      Uri.parse('http://localhost/test'),
      headers: {'X-Forwarded-Proto': 'https'},
    ));
    expect(response.statusCode, 403);
  });

  test('HTTPS enforcement trusts forwarded protocol when proxy is trusted',
      () async {
    final handler = securityHeadersMiddleware(
      requireHttps: true,
      trustProxy: true,
    )((_) => Response.ok('ok'));

    final response = await handler(Request(
      'GET',
      Uri.parse('http://localhost/test'),
      headers: {'X-Forwarded-Proto': 'https'},
    ));
    expect(response.statusCode, 200);
  });

  test('request limit rejects oversized bodies', () async {
    final handler = requestLimitsMiddleware(
      maxBodyBytes: 4,
      timeout: const Duration(seconds: 1),
    )((_) => Response.ok('ok'));

    final response = await handler(
      Request('POST', Uri.parse('http://localhost/test'), body: '12345'),
    );
    expect(response.statusCode, 413);
  });

  test('request timeout includes body stream consumption', () async {
    final body = StreamController<List<int>>();
    final handler = requestLimitsMiddleware(
      maxBodyBytes: 1024,
      timeout: const Duration(milliseconds: 20),
    )((_) => Response.ok('ok'));

    final response = await handler(Request(
      'POST',
      Uri.parse('http://localhost/test'),
      body: body.stream,
    ));
    await body.close();
    expect(response.statusCode, 504);
  });

  test('rate limit rejects requests over the configured window', () async {
    final handler = rateLimitMiddleware(
      requestsPerMinute: 1,
      trustProxy: true,
    )((_) => Response.ok('ok'));
    final request = Request(
      'GET',
      Uri.parse('http://localhost/test'),
      headers: {'X-Forwarded-For': '203.0.113.1'},
    );

    expect((await handler(request)).statusCode, 200);
    expect((await handler(request)).statusCode, 429);
  });

  test('safe error middleware never returns exception details', () async {
    final handler = safeErrorMiddleware()(
      (_) => throw Exception('razorpay_signature=secret-value'),
    );

    final response = await handler(
      Request('GET', Uri.parse('http://localhost/test')),
    );
    final body = await response.readAsString();

    expect(response.statusCode, 500);
    expect(body, contains('error_id'));
    expect(body, isNot(contains('secret-value')));
    expect(body, isNot(contains('razorpay_signature')));
  });
}
