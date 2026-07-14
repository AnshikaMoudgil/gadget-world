import 'package:shelf_router/shelf_router.dart';
import '../controllers/auth_controller.dart';

class AuthRoutes {
  Router get router {
    final router = Router();
    final authController = AuthController();

    router.post('/login', authController.login);
    router.post('/register', authController.register);

    return router;
  }
}
