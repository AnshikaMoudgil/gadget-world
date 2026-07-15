import 'package:shelf_router/shelf_router.dart';

class AuthRoutes {
  Router get router {
    final router = Router();

    // Auth routes have been removed as authentication is handled directly
    // by Supabase on the client side via Google and Phone OTP.

    return router;
  }
}
