import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:gadget_store/features/auth/providers/auth_provider.dart';
import 'package:gadget_store/features/onboarding/screens/splash_screen.dart';
import 'package:gadget_store/features/cart/providers/cart_provider.dart';
import 'package:gadget_store/features/products/providers/catalog_provider.dart';
import 'package:gadget_store/features/profile/providers/profile_provider.dart';
import 'package:gadget_store/features/orders/providers/order_provider.dart';
import 'package:gadget_store/main.dart';

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
