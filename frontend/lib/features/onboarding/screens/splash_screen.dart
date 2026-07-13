import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gadget_store/core/theme.dart';
import 'package:gadget_store/core/widgets/logo_widget.dart';
import 'package:gadget_store/features/onboarding/screens/onboarding_screen.dart';
import 'package:gadget_store/features/auth/screens/login_screen.dart';
import 'package:gadget_store/features/home/screens/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAppState();
  }

  Future<void> _checkAppState() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!hasSeenOnboarding) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else if (!isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: CustomPaint(
        painter: SplashBackgroundPainter(),
        child: Stack(
          children: [
            // Top Content
            Positioned(
              top: MediaQuery.of(context).size.height * 0.25,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  const LogoWidget(size: 100),
                  const SizedBox(height: 16),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 36, color: AppTheme.black),
                      children: [
                        TextSpan(text: 'Gadget ', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: 'World', style: TextStyle(fontWeight: FontWeight.w300)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(width: 40, height: 2, color: AppTheme.black),
                  const SizedBox(height: 24),
                  const Text(
                    'B2B COMMERCE. SIMPLIFIED.',
                    style: TextStyle(
                      letterSpacing: 2,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.greyText,
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Content
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 40,
              left: 0,
              right: 0,
              child: const Column(
                children: [
                  Icon(Icons.shopping_cart_outlined, color: AppTheme.white, size: 28),
                  SizedBox(height: 16),
                  Text(
                    'Wholesale. Reliable. Futures Ready.',
                    style: TextStyle(color: AppTheme.white, fontSize: 12),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, color: AppTheme.white, size: 8),
                      SizedBox(width: 8),
                      Icon(Icons.circle, color: Color(0xFF555555), size: 8),
                      SizedBox(width: 8),
                      Icon(Icons.circle, color: Color(0xFF555555), size: 8),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SplashBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw subtle light gray angled lines at the top and left
    final lightGrayPaint = Paint()
      ..color = const Color(0xFFF5F5F5)
      ..style = PaintingStyle.fill;
    
    // Top left triangle
    final path1 = Path();
    path1.moveTo(0, 0);
    path1.lineTo(size.width * 0.3, 0);
    path1.lineTo(0, size.height * 0.2);
    path1.close();
    canvas.drawPath(path1, lightGrayPaint);

    // Right middle large subtle polygon
    final path2 = Path();
    path2.moveTo(size.width, size.height * 0.3);
    path2.lineTo(size.width, size.height * 1.0);
    path2.lineTo(0, size.height * 1.0);
    path2.lineTo(size.width * 0.6, size.height * 0.5);
    path2.close();
    canvas.drawPath(path2, Paint()..color = const Color(0xFFFAFAFA));

    // 2. Draw the main black curved area at the bottom
    final blackPaint = Paint()
      ..color = AppTheme.black
      ..style = PaintingStyle.fill;

    final blackPath = Path();
    // Start at bottom left
    blackPath.moveTo(0, size.height);
    // Go up the left edge to about 80% down
    blackPath.lineTo(0, size.height * 0.80);
    // Curve to the right edge at about 55% down
    blackPath.quadraticBezierTo(
      size.width * 0.3, size.height * 0.65, // Control point
      size.width, size.height * 0.55,       // End point
    );
    // Go down the right edge to the bottom right
    blackPath.lineTo(size.width, size.height);
    blackPath.close();

    canvas.drawPath(blackPath, blackPaint);
    
    // There is a thin gray curved line above the black shape
    final linePaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
      
    final linePath = Path();
    linePath.moveTo(0, size.height * 0.70);
    linePath.quadraticBezierTo(
      size.width * 0.4, size.height * 0.55,
      size.width, size.height * 0.35,
    );
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
