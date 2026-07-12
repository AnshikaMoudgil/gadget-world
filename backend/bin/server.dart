import 'dart:io';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

// Configure routes.
final _router = Router()
  ..get('/', _rootHandler)
  ..get('/api/status', _statusHandler);

Response _rootHandler(Request req) {
  return Response.ok('Welcome to Gadgets World API\n');
}

Response _statusHandler(Request request) {
  return Response.ok('{"status": "ok", "message": "Backend is running!"}', headers: {
    'Content-Type': 'application/json'
  });
}

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

  // Configure a pipeline that logs requests.
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router.call);

  final server = await io.serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
