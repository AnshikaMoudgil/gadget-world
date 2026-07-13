import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class AuthRoutes {
  Router get router {
    final router = Router();

    router.post('/login', _loginHandler);
    router.post('/register', _registerHandler);

    return router;
  }

  Response _loginHandler(Request request) {
    return Response.ok('{"message": "Login endpoint"}', headers: {'Content-Type': 'application/json'});
  }

  Response _registerHandler(Request request) {
    return Response.ok('{"message": "Register endpoint"}', headers: {'Content-Type': 'application/json'});
  }
}
