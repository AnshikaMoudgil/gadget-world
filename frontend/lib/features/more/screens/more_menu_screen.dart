import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gadget_world/core/theme.dart';
import 'package:gadget_world/features/auth/providers/auth_provider.dart';
import 'package:gadget_world/features/more/screens/about_screen.dart';
import 'package:gadget_world/features/more/screens/contact_us_screen.dart';
import 'package:gadget_world/features/auth/screens/login_screen.dart'; // For logout
import 'package:gadget_world/core/widgets/logo_widget.dart'; // Assuming this is where LogoWidget is
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class MoreMenuScreen extends StatelessWidget {
  const MoreMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    _buildMenuList(context),
                    const SizedBox(height: 48),
                    _buildFooterBranding(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(PhosphorIcons.arrowLeft, color: AppTheme.black),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'More Menu',
                    style: TextStyle(
                      color: AppTheme.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Explore more options',
                    style: TextStyle(color: AppTheme.greyText, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          Icons.info_outline,
          'About',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          Icons
              .headset_mic_outlined, // Match the reference image headphone icon
          'Contact Us',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ContactUsScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildMenuItem(Icons.shield_outlined, 'Privacy Policy', onTap: () {}),
        const SizedBox(height: 12),
        _buildMenuItem(
          Icons.description_outlined,
          'Terms & Conditions',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _buildMenuItem(Icons.autorenew_outlined, 'Refund Policy', onTap: () {}),
        const SizedBox(height: 12),
        _buildMenuItem(
          Icons.logout_outlined,
          'Logout',
          subtitle: 'Sign out of your account',
          onTap: () async {
            // Sign out from Supabase first, then navigate
            await Provider.of<AuthProvider>(context, listen: false).signOut();
            if (!context.mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title, {
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: const Color(0xFFF0F0F0)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFEAEAEA)),
                ),
                child: Icon(icon, color: AppTheme.black, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.black,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.greyText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                PhosphorIcons.caretRight,
                color: AppTheme.black,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterBranding() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LogoWidget(size: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Gadget World',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.black,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Upgrade Your World',
                  style: TextStyle(fontSize: 12, color: AppTheme.greyText),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Version 1.2.0 (Build 45)',
          style: TextStyle(fontSize: 12, color: AppTheme.greyText),
        ),
      ],
    );
  }
}
