import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/widgets/custom_text_field.dart';
import '../core/widgets/primary_button.dart';
import '../core/widgets/logo_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Create your account',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.black),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Join Gadget World and grow your business\nwith better prices and service.',
                          style: TextStyle(fontSize: 14, color: AppTheme.greyText),
                        ),
                      ],
                    ),
                  ),
                  const LogoWidget(size: 60),
                ],
              ),
              const SizedBox(height: 32),
              const CustomTextField(
                label: 'Email address',
                hintText: 'you@business.com',
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 24),
              const CustomTextField(
                label: 'Password',
                hintText: 'Enter password',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Container(height: 4, color: AppTheme.black)),
                  const SizedBox(width: 4),
                  Expanded(child: Container(height: 4, color: AppTheme.greyBorder)),
                  const SizedBox(width: 4),
                  Expanded(child: Container(height: 4, color: AppTheme.greyBorder)),
                  const SizedBox(width: 4),
                  Expanded(child: Container(height: 4, color: AppTheme.greyBorder)),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Password strength: Weak', style: TextStyle(color: AppTheme.error, fontSize: 12)),
              const SizedBox(height: 24),
              const CustomTextField(
                label: 'Confirm password',
                hintText: 'Confirm password',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 24),
              const CustomTextField(
                label: 'Business name',
                hintText: 'Enter your business name',
                prefixIcon: Icons.business_outlined,
              ),
              const SizedBox(height: 24),
              const CustomTextField(
                label: 'GSTIN',
                hintText: 'Enter GSTIN',
                prefixIcon: Icons.receipt_long_outlined,
              ),
              const SizedBox(height: 8),
              const Text('15-character GSTIN (e.g. 29ABCDE1234F1Z5)', style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
              const SizedBox(height: 24),
              // Simplified dropdown using CustomTextField for now, but ideally a DropdownButtonFormField
              const CustomTextField(
                label: 'Business type',
                hintText: 'Select your business type',
                prefixIcon: Icons.work_outline,
                suffixIcon: Icon(Icons.keyboard_arrow_down, color: AppTheme.black),
              ),
              const SizedBox(height: 8),
              const Text('Retailer / Reseller / Distributor / Other', style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Create Account',
                onPressed: () {
                  // Simulate account creation and go back to login
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? ', style: TextStyle(color: AppTheme.greyText)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Log in',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.black, decoration: TextDecoration.underline),
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
}
