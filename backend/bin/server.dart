import 'dart:io';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import '../lib/core/config/env.dart';
import '../lib/core/database/supabase_db.dart';
import '../lib/core/network/app_router.dart';

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

  // Use any available host or IPv4 localhost (127.0.0.1).
  final ip = InternetAddress.anyIPv4;

  // Initialize the App Router
  final appRouter = AppRouter();

  // Configure a pipeline that logs requests and supports the Flutter web client.
  final handler =
      Pipeline().addMiddleware(logRequests()).addMiddleware((innerHandler) {
    return (request) async {
      final response = await innerHandler(request);
      return response.change(headers: {
        ...response.headers,
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type, Accept',
      });
    };
  }).addHandler(appRouter.router.call);

  final server = await io.serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
