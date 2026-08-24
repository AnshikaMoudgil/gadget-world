import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:gadget_store/core/theme.dart';
import 'package:gadget_store/features/onboarding/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gadget_store/features/auth/providers/auth_provider.dart';
import 'package:gadget_store/features/auth/screens/login_screen.dart';
import 'package:gadget_store/features/auth/services/google_auth_service.dart';
import 'package:gadget_store/features/profile/providers/profile_provider.dart';
import 'package:gadget_store/features/products/providers/catalog_provider.dart';

import 'package:gadget_store/features/cart/providers/cart_provider.dart';
import 'package:gadget_store/features/orders/providers/order_provider.dart';
import 'package:gadget_store/features/profile/providers/address_provider.dart';
import 'package:gadget_store/features/profile/providers/settings_provider.dart';
import 'package:gadget_store/features/more/providers/wishlist_provider.dart';
import 'package:gadget_store/features/more/providers/support_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseKey =
      dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? dotenv.env['SUPABASE_ANON_KEY'];
  final backendUrl = dotenv.env['BACKEND_URL'] ?? dotenv.env['API_BASE_URL'];
  if (kReleaseMode &&
      ([
        supabaseUrl,
        supabaseKey,
        backendUrl,
      ].any((value) => value == null || value.trim().isEmpty))) {
    throw StateError(
      'SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY, and BACKEND_URL are required.',
    );
  }

  // Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl ?? 'http://127.0.0.1:54321',
    publishableKey: supabaseKey ?? 'development-anon-key',
  );

  runApp(
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
      ],
      child: const MyApp(),
    ),
  );

  // Do not block the first frame on optional Google Sign-In setup.
  unawaited(_initializeGoogleSignIn());
}

Future<void> _initializeGoogleSignIn() async {
  try {
    await GoogleAuthService.init();
  } catch (error, stackTrace) {
    debugPrint('Google Sign-In initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      title: 'Gadget Store',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        return AuthGuard(child: child!);
      },
      home: const SplashScreen(),
      routes: {'/login': (context) => const LoginScreen()},
    );
  }
}

// Simple Auth Guard to handle routing based on authentication state
class AuthGuard extends StatefulWidget {
  final Widget child;
  const AuthGuard({super.key, required this.child});

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    // Listen to auth changes safely
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _authProvider.addListener(_handleAuthStateChange);

    // Explicitly handle the initial state in case the auth event fired before this listener was added
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_authProvider.isAuthenticated) {
        _handleAuthStateChange();
      }
    });
  }

  @override
  void dispose() {
    _authProvider.removeListener(_handleAuthStateChange);
    super.dispose();
  }

  void _handleAuthStateChange() {
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final wishlistProvider = Provider.of<WishlistProvider>(
      context,
      listen: false,
    );
    final supportProvider = Provider.of<SupportProvider>(
      context,
      listen: false,
    );

    if (authProvider.isAuthenticated) {
      // User is logged in, fetch their profile data
      profileProvider.fetchProfile();
      cartProvider.loadCart();
      orderProvider.fetchOrders();
      wishlistProvider.fetchWishlist();
      supportProvider.fetchTickets();
    } else {
      // User is logged out, clear profile data and redirect to Login Screen
      profileProvider.clearProfile();
      cartProvider.clearCartLocal();
      orderProvider.clearOrders();
      wishlistProvider.clearWishlistLocal();
      supportProvider.clearTicketsLocal();
      String? currentRoute;
      rootNavigatorKey.currentState?.popUntil((route) {
        currentRoute = route.settings.name;
        return true;
      });

      if (currentRoute != '/login') {
        rootNavigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(
            settings: const RouteSettings(name: '/login'),
            builder: (_) => const LoginScreen(),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
