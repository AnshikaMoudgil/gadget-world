import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as io;

void main() async {
  final appRouter = Router();

  final paymentRouter = Router();
  paymentRouter.get('/', (Request request) {
    return Response.ok('Matched slash');
  });

  appRouter.mount('/api/payments', paymentRouter.call);

  final server = await io.serve(appRouter.call, 'localhost', 8081);
  print('Server listening on ${server.port}');
}
