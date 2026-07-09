import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.black,
              child: Icon(Icons.business, size: 40, color: AppTheme.white),
            ),
            const SizedBox(height: 16),
            const Text('Tech Solutions Ltd', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text('you@business.com', style: TextStyle(color: AppTheme.greyText)),
            const SizedBox(height: 24),
            _buildProfileMenu(Icons.shopping_bag_outlined, 'My Orders'),
            _buildProfileMenu(Icons.favorite_border, 'Wishlist'),
            _buildProfileMenu(Icons.location_on_outlined, 'Saved Addresses'),
            _buildProfileMenu(Icons.receipt_long_outlined, 'GST Details'),
            _buildProfileMenu(Icons.help_outline, 'Help & Support'),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Go back to login screen to simulate logout
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppTheme.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Log Out', style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenu(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.black),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.greyText),
      onTap: () {},
    );
  }
}
