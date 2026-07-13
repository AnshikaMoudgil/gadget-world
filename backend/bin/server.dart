import 'dart:io';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import '../lib/core/network/app_router.dart';

void main(List<String> args) async {
  var parser = ArgParser()..addOption('port', abbr: 'p');
  var result = parser.parse(args);

  // Default port is 8080
  var portStr = result['port'] ?? Platform.environment['PORT'] ?? '8080';
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

  // Configure a pipeline that logs requests.
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(appRouter.router.call);

  final server = await io.serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
