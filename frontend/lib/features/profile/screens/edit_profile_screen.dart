import 'package:flutter/material.dart';
import 'package:gadget_store/core/theme.dart';
import 'package:provider/provider.dart';
import 'package:gadget_store/features/profile/providers/profile_provider.dart';
import 'package:gadget_store/features/profile/models/profile_model.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  DateTime? _selectedDate;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final profile = Provider.of<ProfileProvider>(
        context,
        listen: false,
      ).profile;
      _nameController = TextEditingController(text: profile?.fullName ?? '');
      _phoneController = TextEditingController(
        text: profile?.phoneNumber ?? '',
      );
      _selectedDate = profile?.dateOfBirth;
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: AppTheme.white,
              onSurface: AppTheme.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null && mounted) {
      final provider = Provider.of<ProfileProvider>(context, listen: false);
      final success = await provider.uploadAvatar(image);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.errorMessage ?? 'Failed to update profile picture',
            ),
          ),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    final currentProfile = provider.profile;
    if (currentProfile == null) return;

    final updatedProfile = Profile(
      id: currentProfile.id,
      fullName: _nameController.text,
      email: currentProfile.email,
      phoneNumber: _phoneController.text,
      dateOfBirth: _selectedDate,
      createdAt: currentProfile.createdAt,
    );

    final success = await provider.updateProfile(updatedProfile);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to update profile'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context);
    final profile = provider.profile;

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
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppTheme.greyBackground,
                              shape: BoxShape.circle,
                              image: profile?.avatarUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(profile!.avatarUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: profile?.avatarUrl == null
                                ? const Icon(
                                    PhosphorIcons.userFill,
                                    size: 48,
                                    color: AppTheme.greyText,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: provider.isLoading ? null : _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.black,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.white,
                                    width: 2,
                                  ),
                                ),
                                child: provider.isLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          color: AppTheme.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        PhosphorIcons.camera,
                                        color: AppTheme.white,
                                        size: 16,
                                      ),
                              ),
                            ),
                          ),
                          if (profile?.avatarUrl != null)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              child: GestureDetector(
                                onTap: provider.isLoading
                                    ? null
                                    : () async {
                                        final success = await provider
                                            .deleteAvatar();
                                        if (success && context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Profile picture deleted successfully',
                                              ),
                                            ),
                                          );
                                        } else if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                provider.errorMessage ??
                                                    'Failed to delete profile picture',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    PhosphorIcons.trash,
                                    color: AppTheme.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTopWarningBanner(),
                    const SizedBox(height: 32),
                    _buildSectionHeader(
                      PhosphorIcons.user,
                      'Personal Information',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Full Name',
                      controller: _nameController,
                      leadingIcon: PhosphorIcons.user,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Phone Number',
                      controller: _phoneController,
                      leadingIcon: PhosphorIcons.phone,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    _buildLockedFormField(
                      'Email Address',
                      profile?.email ?? 'Not provided',
                      PhosphorIcons.envelopeSimple,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: _buildDateField(
                        label: 'Date of Birth',
                        value:
                            _selectedDate?.toIso8601String().split('T').first ??
                            'Not provided',
                        leadingIcon: PhosphorIcons.calendarBlank,
                        isRequired: true,
                        trailingIcon: PhosphorIcons.calendarBlank,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildActionButtons(context, provider.isLoading),
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
                    'Edit Profile',
                    style: TextStyle(
                      color: AppTheme.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(PhosphorIcons.shieldCheck, color: AppTheme.black),
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
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade100.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              PhosphorIcons.shieldCheck,
              color: Colors.orange,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Some fields require verification',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Changes to verified fields may require re-verification and approval.',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.greyText,
                    height: 1.4,
                  ),
                ),
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
        Icon(icon, color: AppTheme.black, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.black,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData leadingIcon,
    bool isRequired = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.greyBorder.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(leadingIcon, color: AppTheme.greyText, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.greyText,
                        ),
                      ),
                      if (isRequired) ...[
                        const SizedBox(width: 4),
                        const Text(
                          '*',
                          style: TextStyle(fontSize: 10, color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
                TextField(
                  controller: controller,
                  style: const TextStyle(fontSize: 14, color: AppTheme.black),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.only(bottom: 8, top: 4),
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required String value,
    required IconData leadingIcon,
    bool isRequired = false,
    IconData? trailingIcon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.greyBorder.withValues(alpha: 0.5)),
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
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.greyText,
                      ),
                    ),
                    if (isRequired) ...[
                      const SizedBox(width: 4),
                      const Text(
                        '*',
                        style: TextStyle(fontSize: 10, color: Colors.red),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, color: AppTheme.black),
                ),
              ],
            ),
          ),
          if (trailingIcon != null)
            Icon(trailingIcon, color: AppTheme.greyText, size: 20),
        ],
      ),
    );
  }

  Widget _buildLockedFormField(
    String label,
    String value,
    IconData leadingIcon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.greyBorder.withValues(alpha: 0.5)),
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
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.greyText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, color: AppTheme.black),
                ),
              ],
            ),
          ),
          const Icon(PhosphorIcons.lock, color: AppTheme.greyText, size: 16),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isLoading) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.black,
              foregroundColor: AppTheme.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: AppTheme.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(PhosphorIcons.floppyDisk, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: isLoading ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.black,
              side: const BorderSide(color: AppTheme.black),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
