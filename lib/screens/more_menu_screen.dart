import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'about_screen.dart';
import 'contact_us_screen.dart';
import 'login_screen.dart'; // For logout

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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
            icon: const Icon(Icons.arrow_back, color: AppTheme.black),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('More Menu', style: TextStyle(color: AppTheme.black, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Explore more options', style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.greyBorder.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildMenuItem(Icons.info_outline, 'About', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
          }),
          Divider(height: 1, color: AppTheme.greyBorder.withOpacity(0.5), indent: 56),
          _buildMenuItem(Icons.support_agent_outlined, 'Contact Us', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactUsScreen()));
          }),
          Divider(height: 1, color: AppTheme.greyBorder.withOpacity(0.5), indent: 56),
          _buildMenuItem(Icons.shield_outlined, 'Privacy Policy', onTap: () {}),
          Divider(height: 1, color: AppTheme.greyBorder.withOpacity(0.5), indent: 56),
          _buildMenuItem(Icons.description_outlined, 'Terms & Conditions', onTap: () {}),
          Divider(height: 1, color: AppTheme.greyBorder.withOpacity(0.5), indent: 56),
          _buildMenuItem(Icons.autorenew_outlined, 'Refund Policy', onTap: () {}),
          Divider(height: 1, color: AppTheme.greyBorder.withOpacity(0.5), indent: 56),
          _buildMenuItem(
            Icons.logout_outlined,
            'Logout',
            subtitle: 'Sign out of your account',
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {String? subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppTheme.greyBackground.withOpacity(0.5), shape: BoxShape.circle),
              child: Icon(icon, color: AppTheme.black, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.black)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.greyText)),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.greyText, size: 20),
          ],
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.g_mobiledata, color: AppTheme.white, size: 32),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Gadget World', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.black)),
                SizedBox(height: 2),
                Text('Upgrade Your World', style: TextStyle(fontSize: 12, color: AppTheme.greyText)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Version 1.2.0 (Build 45)', style: TextStyle(fontSize: 12, color: AppTheme.greyText)),
      ],
    );
  }
}
