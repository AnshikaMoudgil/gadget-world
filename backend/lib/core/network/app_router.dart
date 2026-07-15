import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../features/auth/routes/auth_routes.dart';
import '../../features/address/routes/address_routes.dart';
import '../../features/products/routes/catalog_routes.dart';

class AppRouter {
  Router get router {
    final router = Router();

    // Health check route
    router.get('/health', (Request request) {
      return Response.ok('{"status": "ok", "message": "Backend is running!"}',
          headers: {'Content-Type': 'application/json'});
    });

    // Mount Feature Routes
    router.mount('/api/auth', AuthRoutes().router.call);
    router.mount('/api/addresses', AddressRoutes().router.call);
    router.mount('/api/catalog', CatalogRoutes().router.call);

    return router;
  }
}
