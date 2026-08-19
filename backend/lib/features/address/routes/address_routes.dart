import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../controllers/address_controller.dart';
import '../../../core/network/auth_middleware.dart';

/// Route definitions for the address feature.
///
/// Mounted at `/api/addresses` in the [AppRouter].
class AddressRoutes {
  Router get router {
    final router = Router();
    final controller = AddressController();

    // List all addresses for the authenticated user
    router.get('/', controller.list);

    // Get a single address by ID
    router.get('/<id>', controller.get);

    // Create a new address
    router.post('/', controller.create);

    // Update an existing address (partial)
    router.put('/<id>', controller.update);

    // Delete an address
    router.delete('/<id>', controller.delete);

    // Set an address as the default
    router.patch('/<id>/set-default', controller.setDefault);

    return router;
  }

  // Create a handler with auth middleware applied
  Handler get handler {
    return const Pipeline()
        .addMiddleware(authMiddleware())
        .addHandler(router.call);
  }
}
