import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../controllers/cart_controller.dart';
import '../../../core/network/auth_middleware.dart';

class CartRoutes {
  final CartController _controller = CartController();

  Router get router {
    final router = Router();

    router.get('/', _controller.getCart);
    router.post('/', _controller.addToCart);
    router.put('/<itemId>', _controller.updateCartItem);
    router.delete('/<itemId>', _controller.removeFromCart);

    return router;
  }

  // Create a handler with auth middleware applied
  Handler get handler {
    return const Pipeline()
        .addMiddleware(authMiddleware())
        .addHandler(router.call);
  }
}
