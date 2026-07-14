import 'package:flutter/material.dart';
import 'package:gadget_store/core/theme.dart';
import 'package:provider/provider.dart';
import 'package:gadget_store/features/profile/providers/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileProvider>(context).profile;

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopWarningBanner(),
                    const SizedBox(height: 32),
                    _buildSectionHeader(Icons.person_outline, 'Personal Information'),
                    const SizedBox(height: 16),
                    _buildFormField('Full Name', profile?.fullName ?? 'Not provided', Icons.person_outline, isRequired: true),
                    const SizedBox(height: 16),
                    _buildFormField('Phone Number', profile?.phoneNumber ?? 'Not provided', Icons.phone_outlined, isRequired: true),
                    const SizedBox(height: 16),
                    _buildLockedFormField('Email Address', profile?.email ?? 'Not provided', Icons.email_outlined),
                    const SizedBox(height: 16),
                    _buildFormField('Date of Birth', profile?.dateOfBirth?.toIso8601String().split('T').first ?? 'Not provided', Icons.calendar_today_outlined, isRequired: true, trailingIcon: Icons.calendar_today_outlined),
                    const SizedBox(height: 32),
                    _buildActionButtons(context),
                    const SizedBox(height: 32), // Padding for scroll clearance
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
                  Text('Edit Profile', style: TextStyle(color: AppTheme.black, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.verified_user_outlined, color: AppTheme.black),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTopWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, color: Colors.orange, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Some fields require verification', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.black)),
                SizedBox(height: 4),
                Text('Changes to verified fields may require re-verification and approval.', style: TextStyle(fontSize: 10, color: AppTheme.greyText, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.black)),
      ],
    );
  }

  Widget _buildFormField(String label, String value, IconData leadingIcon, {bool isRequired = false, IconData? trailingIcon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.greyBorder.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(leadingIcon, color: AppTheme.greyText, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.greyText)),
                    if (isRequired) ...[
                      const SizedBox(width: 4),
                      const Text('*', style: TextStyle(fontSize: 10, color: Colors.red)),
                    ]
                  ],
                ),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 14, color: AppTheme.black)),
              ],
            ),
          ),
          if (trailingIcon != null) Icon(trailingIcon, color: AppTheme.greyText, size: 20),
        ],
      ),
    );
  }

  Widget _buildLockedFormField(String label, String value, IconData leadingIcon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.greyBackground.withOpacity(0.3),
        border: Border.all(color: AppTheme.greyBorder.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(leadingIcon, color: AppTheme.greyText, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.greyText)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 14, color: AppTheme.greyText)),
              ],
            ),
          ),
          const Icon(Icons.lock_outline, color: AppTheme.greyText, size: 16),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: AppTheme.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Save Changes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.deepPurple,
              side: const BorderSide(color: Colors.deepPurple),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Cancel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
