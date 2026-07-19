import 'dart:async';
import 'package:flutter/material.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? 'https://xyzcompany.supabase.co',
    publishableKey: dotenv.env['SUPABASE_ANON_KEY'] ?? 'public-anon-key',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => CatalogProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gadget World',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGuard(child: SplashScreen()),
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

    if (authProvider.isAuthenticated) {
      // User is logged in, fetch their profile data
      profileProvider.fetchProfile();
      cartProvider.loadCart();
    } else {
      // User is logged out, clear profile data and redirect to Login Screen
      profileProvider.clearProfile();
      cartProvider.clearCartLocal();
      // We check if current route is not login/signup/splash to avoid looping
      bool isPublicRoute = false;
      Navigator.popUntil(context, (route) {
        final name = route.settings.name;
        if (name == '/login' || name == '/' || name == null) {
          isPublicRoute = true;
        }
        return true;
      });

      if (!isPublicRoute) {
        Navigator.pushAndRemoveUntil(
          context,
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
