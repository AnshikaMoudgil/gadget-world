import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../controllers/settings_controller.dart';
import '../../../core/network/auth_middleware.dart';

class SettingsRoutes {
  final SettingsController _controller = SettingsController();

  Router get router {
    final router = Router();
    router.get('/', _controller.getSettings);
    router.put('/', _controller.updateSettings);
    return router;
  }

  Handler get handler {
    return const Pipeline()
        .addMiddleware(authMiddleware())
        .addHandler(router.call);
  }
}
