import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../../core/network/auth_middleware.dart';
import '../controllers/coupon_controller.dart';

class CouponRoutes {
  final CouponController _controller = CouponController();

  Handler get handler {
    final router = Router();

    Handler withAuth(Handler inner) =>
        const Pipeline().addMiddleware(authMiddleware()).addHandler(inner);

    router.get('/available', withAuth(_controller.getAvailableCoupons));
    router.post('/validate', withAuth(_controller.validateCoupon));

    return router.call;
  }
}
