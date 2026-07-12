import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'login_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isCurrentObscured = true;
  bool _isNewObscured = true;
  bool _isConfirmObscured = true;

  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(() {
      setState(() {}); // Rebuild to update password strength
    });
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleUpdatePassword() {
    // For demonstration, typing 'error' in current password triggers error state
    if (_currentPasswordController.text.toLowerCase() == 'error') {
      setState(() {
        _hasError = true;
      });
      return;
    }
    
    setState(() {
      _hasError = false;
    });

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Green Checkmark Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, color: Colors.green, size: 48),
                ),
                const SizedBox(height: 24),
                const Text('Password Updated!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.black)),
                const SizedBox(height: 12),
                const Text(
                  'Your password has been updated successfully.\nYou will be logged out for security.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppTheme.greyText, height: 1.4),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.black,
                      foregroundColor: AppTheme.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Continue', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Current Password'),
                        _buildPasswordField(
                          controller: _currentPasswordController,
                          hint: 'Enter current password',
                          isObscured: _isCurrentObscured,
                          hasError: _hasError,
                          onToggleVisibility: () {
                            setState(() {
                              _isCurrentObscured = !_isCurrentObscured;
                            });
                          },
                        ),
                        if (_hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: const [
                                Icon(Icons.error_outline, color: Colors.red, size: 16),
                                SizedBox(width: 4),
                                Text('Incorrect current password. Please try again.', style: TextStyle(color: Colors.red, fontSize: 12)),
                              ],
                            ),
                          ),
                        const SizedBox(height: 24),
                        _buildLabel('New Password'),
                        _buildPasswordField(
                          controller: _newPasswordController,
                          hint: 'Enter new password',
                          isObscured: _isNewObscured,
                          hasError: false,
                          onToggleVisibility: () {
                            setState(() {
                              _isNewObscured = !_isNewObscured;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildPasswordStrengthIndicator(_newPasswordController.text),
                        const SizedBox(height: 24),
                        _buildLabel('Confirm New Password'),
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          hint: 'Confirm new password',
                          isObscured: _isConfirmObscured,
                          hasError: false,
                          onToggleVisibility: () {
                            setState(() {
                              _isConfirmObscured = !_isConfirmObscured;
                            });
                          },
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _handleUpdatePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.black,
                            foregroundColor: AppTheme.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.lock_outline, size: 20),
                                  SizedBox(width: 8),
                                  Text('Update Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                  Text('Change Password', style: TextStyle(color: AppTheme.black, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Update your password to keep your account secure.', style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.black),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isObscured,
    required bool hasError,
    required VoidCallback onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: hasError ? Colors.red : AppTheme.greyBorder),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscured,
        style: const TextStyle(fontSize: 14, color: AppTheme.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, color: AppTheme.greyText),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: IconButton(
            icon: Icon(
              isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: AppTheme.black,
              size: 20,
            ),
            onPressed: onToggleVisibility,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator(String password) {
    // Simple logic for mockup demonstration
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#\$&*~]'))) strength++;

    if (password.isEmpty) {
      return const Text(
        'Must be at least 8 characters with a mix of letters, numbers & symbols.',
        style: TextStyle(fontSize: 10, color: AppTheme.greyText, height: 1.4),
      );
    }

    Color color;
    String label;
    if (strength <= 1) {
      color = Colors.red;
      label = 'Weak password';
    } else if (strength == 2) {
      color = Colors.orange;
      label = 'Fair password';
    } else if (strength == 3) {
      color = Colors.lightGreen;
      label = 'Good password';
    } else {
      color = Colors.green;
      label = 'Strong password';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (index) {
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                decoration: BoxDecoration(
                  color: index < strength ? color : AppTheme.greyBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
