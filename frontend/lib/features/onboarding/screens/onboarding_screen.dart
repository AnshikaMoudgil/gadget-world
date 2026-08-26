import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gadget_store/core/theme.dart';
import 'package:gadget_store/core/widgets/primary_button.dart';
import 'package:gadget_store/features/auth/screens/login_screen.dart';
import 'package:gadget_store/core/navigation/app_transitions.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (!mounted) return;
    Navigator.pushReplacement(context, fadeScaleRoute(const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Welcome to',
                style: TextStyle(fontSize: 18, color: AppTheme.black),
              ),
              const Text(
                'Gadget World',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.black,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'The B2B marketplace for all your\ngadget needs.',
                style: TextStyle(fontSize: 14, color: AppTheme.greyText),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildOnboardingCard(
                      title: 'Bulk pricing that\nadjusts as you buy',
                      subtitle:
                          'Get more for less. Our tiered pricing\nensures better value on every order.',
                      imagePath: 'assets/images/onboarding_2.png',
                    ),
                    _buildOnboardingCard(
                      title: 'Secure payments,\nworry-free',
                      subtitle:
                          'Safe, encrypted, and hassle-free\ntransactions every time.',
                      imagePath: 'assets/images/onboarding_secure.png',
                    ),
                    _buildOnboardingCard(
                      title: 'Quality you can trust,\nalways',
                      subtitle:
                          'Every product is curated for\nquality and performance.',
                      imagePath: 'assets/images/onboarding_quality.png',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildAnimatedIndicators(),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Get Started',
                onPressed: _completeOnboarding,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: AppTheme.greyText),
                  ),
                  GestureDetector(
                    onTap: _completeOnboarding,
                    child: const Text(
                      'Log in',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingCard({
    required String title,
    required String subtitle,
    required String imagePath,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppTheme.greyText),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIndicators() {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (_, _) {
        final page = _pageController.hasClients
            ? (_pageController.page ?? _currentPage.toDouble())
            : _currentPage.toDouble();
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final proximity = (1 - (page - index).abs()).clamp(0.0, 1.0);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8 + (22 * proximity),
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                color: Color.lerp(
                  AppTheme.greyBorder,
                  AppTheme.black,
                  proximity,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
