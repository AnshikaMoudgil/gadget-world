import 'dart:io';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import '../lib/core/config/env.dart';
import '../lib/core/database/supabase_db.dart';
import '../lib/core/network/app_router.dart';
import '../lib/core/network/cors_middleware.dart';
import '../lib/core/network/security_middleware.dart';
import '../lib/core/network/safe_error.dart';

void main(List<String> args) async {
  // ── 1. Load environment variables & validate required keys ──
  try {
    Env.load();
  } catch (e) {
    stderr.writeln('Failed to load environment: $e');
    exitCode = 78; // EX_CONFIG
    return;
  }

  // ── 2. Initialize Supabase clients (anon + service-role) ──
  try {
    SupabaseDb.init();
    print('Supabase client initialized');
  } catch (e) {
    stderr.writeln('Failed to initialize Supabase: $e');
    exitCode = 69; // EX_UNAVAILABLE
    return;
  }

// ── 3. Resolve port ──
  var parser = ArgParser()..addOption('port', abbr: 'p');
  var result = parser.parse(args);

  var portStr = result['port'] ?? Platform.environment['PORT'] ?? '${Env.port}';
  var port = int.tryParse(portStr);

  if (port == null) {
    stdout.writeln('Could not parse port value "$portStr" into a number.');
    exitCode = 64;
    return;
  }

  final ip = InternetAddress(Env.bindAddress);

  // Initialize the App Router
  final appRouter = AppRouter();

  // Configure a pipeline that logs requests.
  final handler = Pipeline()
      .addMiddleware(safeErrorMiddleware())
      .addMiddleware(securityHeadersMiddleware(
        requireHttps: Env.requireHttps,
        trustProxy: Env.trustProxy,
      ))
      .addMiddleware(rateLimitMiddleware(
        requestsPerMinute: Env.rateLimitPerMinute,
        trustProxy: Env.trustProxy,
      ))
      .addMiddleware(requestLimitsMiddleware(
        maxBodyBytes: Env.maxRequestBodyBytes,
        timeout: Duration(seconds: Env.requestTimeoutSeconds),
      ))
      .addMiddleware(corsMiddleware(Env.allowedOrigins))
      .addMiddleware(logRequests())
      .addHandler(appRouter.router.call);

  final server = await io.serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
