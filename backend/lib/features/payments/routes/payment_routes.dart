import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../../core/network/auth_middleware.dart';
import '../controllers/payment_controller.dart';

class PaymentRoutes {
  final PaymentController _controller = PaymentController();

  Router get router {
    final router = Router();

    // Authenticated routes
    final authRouter = Router();
    authRouter.get('/', _controller.getOrders);
    authRouter.post('/create-order', _controller.createOrder);
    authRouter.post('/verify', _controller.verifyPayment);

    // Apply auth middleware
    final authHandler = Pipeline()
        .addMiddleware(authMiddleware())
        .addHandler(authRouter.call);
    router.mount('/', authHandler);

    return router;
  }
}
