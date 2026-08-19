import 'package:shelf_router/shelf_router.dart';

import '../controllers/catalog_controller.dart';

class CatalogRoutes {
  final CatalogController _controller = CatalogController();

  Router get router {
    final router = Router();

    router.get('/categories', _controller.getCategories);
    router.get('/products/slug/<slug>', _controller.getProductBySlug);
    router.get('/products/<id>', _controller.getProduct);
    router.get('/products', _controller.getProducts);

    return router;
  }
}
