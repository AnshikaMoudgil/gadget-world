import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../../core/network/auth_middleware.dart';
import '../controllers/payment_controller.dart';

class PaymentRoutes {
  final PaymentController _controller = PaymentController();

  Router get router {
    final router = Router();

    // Webhook - Unauthenticated
    router.post('/webhook', _controller.handleWebhook);

    // Authenticated handler wrapper
    Handler withAuth(Handler inner) =>
        const Pipeline().addMiddleware(authMiddleware()).addHandler(inner);

    // Authenticated routes
    router.get('/', withAuth(_controller.getOrders));
    router.post('/create-order', withAuth(_controller.createOrder));
    router.post('/verify', withAuth(_controller.verifyPayment));

    return router;
  }
}
