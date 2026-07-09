import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import '../core/widgets/primary_button.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true);
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
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
                style: TextStyle(fontSize: 24, color: AppTheme.black),
              ),
              const Text(
                'Gadget World',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.black),
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
                      subtitle: 'Get more for less. Our tiered pricing\nensures better value on every order.',
                      icon: Icons.percent,
                    ),
                    _buildOnboardingCard(
                      title: 'Secure & fast\ntransactions',
                      subtitle: 'Experience seamless payments with\nour trusted B2B payment gateway.',
                      icon: Icons.security,
                    ),
                    _buildOnboardingCard(
                      title: 'Direct delivery to\nyour warehouse',
                      subtitle: 'Track your orders in real-time and\nget them delivered fast.',
                      icon: Icons.local_shipping,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Get Started',
                onPressed: _completeOnboarding,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? ', style: TextStyle(color: AppTheme.greyText)),
                  GestureDetector(
                    onTap: _completeOnboarding,
                    child: const Text(
                      'Log in',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.black),
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

  Widget _buildOnboardingCard({required String title, required String subtitle, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Simplified illustration
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.greyBackground,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, size: 80, color: AppTheme.black),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index ? AppTheme.black : AppTheme.greyBorder,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.black),
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppTheme.greyText),
          ),
        ],
      ),
    );
  }
}
