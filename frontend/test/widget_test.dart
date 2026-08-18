import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:gadget_world/features/auth/providers/auth_provider.dart';
import 'package:gadget_world/features/onboarding/screens/splash_screen.dart';
import 'package:gadget_world/features/cart/providers/cart_provider.dart';
import 'package:gadget_world/features/products/providers/catalog_provider.dart';
import 'package:gadget_world/features/profile/providers/profile_provider.dart';
import 'package:gadget_world/features/orders/providers/order_provider.dart';
import 'package:gadget_world/features/profile/providers/address_provider.dart';
import 'package:gadget_world/features/profile/providers/settings_provider.dart';
import 'package:gadget_world/features/more/providers/wishlist_provider.dart';
import 'package:gadget_world/features/more/providers/support_provider.dart';
import 'package:gadget_world/features/more/providers/notification_provider.dart';
import 'package:gadget_world/main.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://xyzcompany.supabase.co',
      publishableKey: 'public-anon-key',
    );
  });

  testWidgets('app displays the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
          ChangeNotifierProvider(create: (_) => CatalogProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => OrderProvider()),
          ChangeNotifierProvider(create: (_) => AddressProvider()),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => WishlistProvider()),
          ChangeNotifierProvider(create: (_) => SupportProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
  });
}
