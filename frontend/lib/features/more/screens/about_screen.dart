import 'package:flutter/material.dart';
import 'package:gadget_store/core/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBrandingSection(),
                    const SizedBox(height: 32),
                    _buildInfoList(),
                    const SizedBox(height: 32),
                    _buildFollowUsSection(),
                    const SizedBox(height: 32),
                    _buildDataSafeCard(),
                    const SizedBox(height: 32),
                    const Center(
                      child: Text(
                        'Â© 2025 Gadget World. All rights reserved.',
                        style: TextStyle(fontSize: 12, color: AppTheme.greyText),
                      ),
                    ),
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
                  Text('About', style: TextStyle(color: AppTheme.black, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Learn more about us', style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.black,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.g_mobiledata, color: AppTheme.white, size: 40), // Placeholder for G logo
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Gadget World', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.black)),
                SizedBox(height: 4),
                Text('Upgrade Your World', style: TextStyle(fontSize: 14, color: AppTheme.greyText)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Gadget World is your one-stop destination for premium gadgets and accessories. We bring you the latest tech with unbeatable quality and trust.',
          style: TextStyle(fontSize: 14, color: AppTheme.greyText, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildInfoList() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.greyBorder.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.inventory_2_outlined, 'App Version', '1.2.0 (Build 45)'),
          Divider(height: 1, color: AppTheme.greyBorder.withValues(alpha: 0.5), indent: 64),
          _buildInfoRow(Icons.email_outlined, 'Email', 'support@gadgetworld.com'),
          Divider(height: 1, color: AppTheme.greyBorder.withValues(alpha: 0.5), indent: 64),
          _buildInfoRow(Icons.phone_outlined, 'Phone', '+91 98765 43210'),
          Divider(height: 1, color: AppTheme.greyBorder.withValues(alpha: 0.5), indent: 64),
          _buildInfoRow(Icons.language_outlined, 'Website', 'www.gadgetworld.com', hasTrailing: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String subtitle, {bool hasTrailing = false}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.greyBackground.withValues(alpha: 0.5), shape: BoxShape.circle),
            child: Icon(icon, color: AppTheme.black, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.black)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.greyText)),
              ],
            ),
          ),
          if (hasTrailing) const Icon(Icons.chevron_right, color: AppTheme.greyText, size: 20),
        ],
      ),
    );
  }

  Widget _buildFollowUsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Follow Us', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.black)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSocialIcon(Icons.facebook, 'Facebook'),
            _buildSocialIcon(Icons.camera_alt_outlined, 'Instagram'), // Using camera for IG placeholder
            _buildSocialIcon(Icons.alternate_email, 'Twitter'), // Using @ for Twitter
            _buildSocialIcon(Icons.play_circle_outline, 'YouTube'),
            _buildSocialIcon(Icons.work_outline, 'LinkedIn'),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.greyBackground.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.black, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.greyText)),
      ],
    );
  }

  Widget _buildDataSafeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.greyBorder.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.greyBackground.withValues(alpha: 0.5), shape: BoxShape.circle),
            child: const Icon(Icons.shield_outlined, color: AppTheme.black, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Your Data is Safe', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.black)),
                SizedBox(height: 4),
                Text('We respect your privacy and are committed to keeping your data secure.', style: TextStyle(fontSize: 12, color: AppTheme.greyText, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppTheme.greyText, size: 20),
        ],
      ),
    );
  }
}
