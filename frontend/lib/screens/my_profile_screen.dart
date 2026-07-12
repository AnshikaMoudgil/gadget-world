import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'edit_profile_screen.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

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
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(context),
                    const SizedBox(height: 24),
                    _buildPersonalInfoCard(),
                    const SizedBox(height: 24),
                    _buildCompanyInfoCard(),
                    const SizedBox(height: 24),
                    _buildTrustBanner(),
                    const SizedBox(height: 48), // Padding for scroll clearance
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
              padding: const EdgeInsets.only(top: 8.0), // Align text baseline with icon
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('My Profile', style: TextStyle(color: AppTheme.black, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('View your personal and company information', style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppTheme.black),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.greyBorder.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(color: AppTheme.greyBackground, shape: BoxShape.circle),
                child: const Icon(Icons.person, size: 40, color: AppTheme.greyText),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.greyBorder.withOpacity(0.3)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                  ),
                  child: const Icon(Icons.camera_alt_outlined, size: 12, color: AppTheme.black),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rohit Sharma', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.black)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.check_circle_outline, size: 12, color: Colors.green),
                      SizedBox(width: 4),
                      Text('Verified', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.black,
              foregroundColor: AppTheme.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            icon: const Icon(Icons.edit_outlined, size: 14),
            label: const Text('Edit Profile', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.greyBorder.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: const [
                Icon(Icons.person_outline, size: 20, color: AppTheme.black),
                SizedBox(width: 12),
                Text('Personal Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.black)),
              ],
            ),
          ),
          const Divider(color: AppTheme.greyBorder, height: 1),
          _buildInfoRow(Icons.email_outlined, 'Full Name', 'Rohit Sharma'),
          const Divider(color: AppTheme.greyBorder, height: 1, indent: 56),
          _buildInfoRow(Icons.email_outlined, 'Email Address', 'rohit.sharma@example.com'),
          const Divider(color: AppTheme.greyBorder, height: 1, indent: 56),
          _buildInfoRow(Icons.phone_outlined, 'Phone Number', '+91 98765 43210'),
          const SizedBox(height: 8), // Bottom padding for card content
        ],
      ),
    );
  }

  Widget _buildCompanyInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.greyBorder.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: const [
                Icon(Icons.business_outlined, size: 20, color: AppTheme.black),
                SizedBox(width: 12),
                Text('Company Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.black)),
              ],
            ),
          ),
          const Divider(color: AppTheme.greyBorder, height: 1),
          _buildInfoRow(Icons.work_outline, 'Company Name', 'Sharma Enterprises Pvt. Ltd.'),
          const Divider(color: AppTheme.greyBorder, height: 1, indent: 56),
          _buildInfoRow(Icons.receipt_long_outlined, 'GSTIN', '27AABCS1234D1Z5'),
          const Divider(color: AppTheme.greyBorder, height: 1, indent: 56),
          _buildInfoRow(Icons.local_offer_outlined, 'Business Type', 'Private Limited Company'),
          const SizedBox(height: 8), // Bottom padding for card content
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.greyBackground.withOpacity(0.5), shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: AppTheme.black),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.black))),
          Text(value, style: const TextStyle(fontSize: 12, color: AppTheme.greyText)),
        ],
      ),
    );
  }

  Widget _buildTrustBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.greyBackground.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle),
            child: const Icon(Icons.security, color: Colors.orange, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Your information is safe with us', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.black)),
                SizedBox(height: 4),
                Text('We never share your personal or business details with anyone.', style: TextStyle(fontSize: 10, color: AppTheme.greyText, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
