import 'package:flutter/material.dart';
import 'package:gadget_store/core/theme.dart';
import 'package:gadget_store/core/widgets/primary_button.dart';
import 'package:gadget_store/core/widgets/logo_widget.dart';
import 'package:gadget_store/features/auth/screens/login_screen.dart';

const Color _green = Color(0xFF22A854);
const Color _red = Color(0xFFE0433D);

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _passwordReset = false;

  bool get _hasMinLength => _newPasswordController.text.length >= 8;
  bool get _hasUppercase => _newPasswordController.text.contains(RegExp(r'[A-Z]'));
  bool get _hasNumber => _newPasswordController.text.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial => _newPasswordController.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  bool get _passwordsMatch =>
      _confirmPasswordController.text.isNotEmpty &&
      _newPasswordController.text == _confirmPasswordController.text;

  int get _strengthLevel {
    int count = 0;
    if (_hasMinLength) count++;
    if (_hasUppercase) count++;
    if (_hasNumber) count++;
    if (_hasSpecial) count++;
    return count;
  }

  String get _strengthLabel {
    if (_newPasswordController.text.isEmpty) return '';
    return switch (_strengthLevel) {
      1 => 'Weak',
      2 => 'Fair',
      3 => 'Strong',
      4 => 'Very Strong',
      _ => '',
    };
  }

  Color get _strengthColor {
    return switch (_strengthLevel) {
      1 => _red,
      2 => Colors.orange,
      3 => _green,
      4 => _green,
      _ => AppTheme.greyBorder,
    };
  }

  bool get _showError =>
      _confirmPasswordController.text.isNotEmpty && !_passwordsMatch;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetPassword() {
    if (_passwordsMatch && _strengthLevel >= 3) {
      setState(() => _passwordReset = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _passwordReset ? _buildSuccessState() : _buildResetForm(),
        ),
      ),
    );
  }

  Widget _buildResetForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const LogoWidget(size: 48),
        const SizedBox(height: 12),
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 20, color: AppTheme.black),
            children: [
              TextSpan(text: 'Gadget ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: 'Store', style: TextStyle(fontWeight: FontWeight.w300)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildStepper(),
        const SizedBox(height: 24),
        const Text(
          'Reset Password',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.black),
        ),
        const SizedBox(height: 8),
        const Text(
          'Create a new password\nfor your account.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppTheme.greyText),
        ),
        const SizedBox(height: 28),
        _buildNewPasswordField(),
        _buildStrengthIndicator(),
        const SizedBox(height: 14),
        _buildConfirmPasswordField(),
        if (_showError) _buildErrorRow(),
        const SizedBox(height: 18),
        _buildRequirements(),
        const SizedBox(height: 24),
        PrimaryButton(
          text: 'Reset Password',
          onPressed: _resetPassword,
        ),
        const SizedBox(height: 24),
        _buildIllustration(),
      ],
    );
  }

  Widget _buildStepper() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepWidget('Verify Email', false),
        _connector(true),
        _stepWidget('Reset Password', true),
        _connector(false),
        _stepWidget('Done', false),
      ],
    );
  }

  Widget _stepWidget(String label, bool active) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: active ? 16 : 14,
          height: active ? 16 : 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppTheme.black : Colors.white,
            border: Border.all(
              color: active ? AppTheme.black : const Color(0xFFC9C9C9),
              width: 2,
            ),
          ),
          child: active
              ? Padding(
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: active ? AppTheme.black : AppTheme.greyText,
          ),
        ),
      ],
    );
  }

  Widget _connector(bool active) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: active ? AppTheme.black : const Color(0xFFD8D8D8),
    );
  }

  Widget _buildNewPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'New Password',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.black),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.greyBorder, width: 1.5),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.lock_outline, size: 18, color: Color(0xFF9A9A9A)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _newPasswordController,
                  obscureText: _obscureNew,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Enter new password',
                    hintStyle: TextStyle(color: Color(0xFFB9B9B9)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _obscureNew = !_obscureNew),
                child: Icon(
                  _obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 18, color: const Color(0xFF9A9A9A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStrengthIndicator() {
    if (_newPasswordController.text.isEmpty) return const SizedBox(height: 20);
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 2),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: List.generate(4, (i) {
                final on = i < _strengthLevel;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.only(right: 5),
                    decoration: BoxDecoration(
                      color: on ? _strengthColor : const Color(0xFFE9E9E9),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _strengthLabel,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _strengthColor),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Confirm Password',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.black),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: _showError ? _red : AppTheme.greyBorder,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                Icons.lock_outline,
                size: 18,
                color: _showError ? _red : const Color(0xFF9A9A9A),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Confirm new password',
                    hintStyle: TextStyle(color: Color(0xFFB9B9B9)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                child: Icon(
                  _showError ? Icons.visibility_off_outlined : (_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  size: 18,
                  color: _showError ? _red : const Color(0xFF9A9A9A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 15, color: _red),
          const SizedBox(width: 6),
          const Text(
            'Passwords do not match',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _red),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password must contain:',
          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppTheme.black),
        ),
        const SizedBox(height: 10),
        _requirementItem('At least 8 characters', _hasMinLength),
        const SizedBox(height: 8),
        _requirementItem('One uppercase letter (Aâ€“Z)', _hasUppercase),
        const SizedBox(height: 8),
        _requirementItem('One number (0â€“9)', _hasNumber),
        const SizedBox(height: 8),
        _requirementItem('One special character (!@#\$%^&)', _hasSpecial),
      ],
    );
  }

  Widget _requirementItem(String text, bool met) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: met ? _green : Colors.transparent,
            border: met ? null : Border.all(color: const Color(0xFFD0D0D0), width: 2),
          ),
          child: met
              ? const Icon(Icons.check, size: 11, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(fontSize: 13.5, color: Color(0xFF3D3D3D)),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        _buildSuccessIllustration(),
        const SizedBox(height: 32),
        const Text(
          'Password Reset\nSuccessful!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.black, height: 1.25),
        ),
        const SizedBox(height: 14),
        const Text(
          'Your password has been updated\nsuccessfully.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.5, color: AppTheme.greyText, height: 1.6),
        ),
        const SizedBox(height: 40),
        PrimaryButton(
          text: 'Go to Login',
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
          child: const Text(
            'Back to Home',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: AppTheme.black,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIllustration() {
    return SizedBox(
      height: 140,
      child: CustomPaint(
        painter: _ResetIllustrationPainter(),
        size: const Size(double.infinity, 140),
      ),
    );
  }

  Widget _buildSuccessIllustration() {
    return SizedBox(
      height: 180,
      child: CustomPaint(
        painter: _SuccessIllustrationPainter(),
        size: const Size(double.infinity, 180),
      ),
    );
  }
}

class _ResetIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final cx = size.width / 2;

    paint.color = const Color(0xFFF1F1F1);
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, 105), width: 190, height: 8), const Radius.circular(4)),
      paint,
    );

    paint.color = AppTheme.black;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx - 50, 80), width: 46, height: 46), const Radius.circular(8)),
      paint,
    );

    paint.style = PaintingStyle.stroke;
    paint.color = Colors.white;
    paint.strokeWidth = 3;
    final path = Path()
      ..moveTo(cx - 60, 65)
      ..lineTo(cx - 60, 58)
      ..arcToPoint(Offset(cx - 48, 58), radius: const Radius.circular(6))
      ..lineTo(cx - 48, 65);
    canvas.drawPath(path, paint);

    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFFF4F4F4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx + 30, 70), width: 60, height: 55), const Radius.circular(8)),
      paint,
    );

    paint.style = PaintingStyle.stroke;
    paint.color = const Color(0xFFE2E2E2);
    paint.strokeWidth = 1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx + 30, 70), width: 60, height: 55), const Radius.circular(8)),
      paint,
    );

    paint.color = AppTheme.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4;
    paint.strokeJoin = StrokeJoin.round;
    final roof = Path()
      ..moveTo(cx + 5, 55)
      ..lineTo(cx + 30, 42)
      ..lineTo(cx + 55, 55);
    canvas.drawPath(roof, paint);

    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx + 30, 72), 6, paint);

    paint.color = AppTheme.black;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx + 80, 90), width: 14, height: 46), const Radius.circular(7)),
      paint,
    );

    paint.color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx + 76, 70), width: 24, height: 14), const Radius.circular(4)),
      paint,
    );

    paint.style = PaintingStyle.stroke;
    paint.color = AppTheme.black;
    paint.strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx + 76, 70), width: 24, height: 14), const Radius.circular(4)),
      paint,
    );

    paint.style = PaintingStyle.stroke;
    paint.color = const Color(0xFF4CAF50);
    paint.strokeWidth = 2;
    paint.strokeCap = StrokeCap.round;
    paint.strokeJoin = StrokeJoin.round;
    final wifiPath = Path()
      ..moveTo(cx + 74, 62)
      ..lineTo(cx + 76, 66)
      ..lineTo(cx + 78, 62);
    canvas.drawPath(wifiPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SuccessIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final cx = size.width / 2;

    paint.color = const Color(0xFFF5F5F5);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, 85), 72, paint);

    paint.color = Colors.white;
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx - 10, 90), width: 80, height: 80), const Radius.circular(6)),
      paint,
    );

    paint.style = PaintingStyle.stroke;
    paint.color = AppTheme.black;
    paint.strokeWidth = 3;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx - 10, 90), width: 80, height: 80), const Radius.circular(6)),
      paint,
    );

    paint.style = PaintingStyle.fill;
    paint.color = Colors.white;
    paint.strokeWidth = 0;
    final lockPath = Path()
      ..moveTo(cx - 25, 72)
      ..lineTo(cx + 15, 72)
      ..lineTo(cx + 25, 92)
      ..lineTo(cx - 35, 92)
      ..close();
    canvas.drawPath(lockPath, paint);

    paint.style = PaintingStyle.stroke;
    paint.color = AppTheme.black;
    paint.strokeWidth = 2.5;
    paint.strokeJoin = StrokeJoin.round;
    canvas.drawPath(lockPath, paint);

    paint.style = PaintingStyle.stroke;
    paint.color = AppTheme.black;
    paint.strokeWidth = 3.5;
    final shacklePath = Path()
      ..moveTo(cx - 12, 72)
      ..lineTo(cx - 12, 62)
      ..arcToPoint(Offset(cx + 2, 62), radius: const Radius.circular(14))
      ..lineTo(cx + 2, 72);
    canvas.drawPath(shacklePath, paint);

    paint.color = _green;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx + 50, 70), 18, paint);

    paint.style = PaintingStyle.stroke;
    paint.color = Colors.white;
    paint.strokeWidth = 3.5;
    paint.strokeCap = StrokeCap.round;
    paint.strokeJoin = StrokeJoin.round;
    final check = Path()
      ..moveTo(cx + 40, 70)
      ..lineTo(cx + 47, 77)
      ..lineTo(cx + 60, 63);
    canvas.drawPath(check, paint);

    paint.style = PaintingStyle.fill;
    paint.color = AppTheme.black;
    paint.strokeWidth = 0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx + 60, 115), width: 55, height: 48), const Radius.circular(8)),
      paint,
    );

    paint.style = PaintingStyle.stroke;
    paint.color = const Color(0xFFB9B9B9);
    paint.strokeWidth = 5;
    final rightShackle = Path()
      ..moveTo(cx + 48, 98)
      ..lineTo(cx + 48, 88)
      ..arcToPoint(Offset(cx + 72, 88), radius: const Radius.circular(16))
      ..lineTo(cx + 72, 98);
    canvas.drawPath(rightShackle, paint);

    paint.style = PaintingStyle.fill;
    paint.color = Colors.white;
    canvas.drawCircle(Offset(cx + 60, 130), 14, paint);

    paint.style = PaintingStyle.stroke;
    paint.color = AppTheme.black;
    paint.strokeWidth = 3;
    paint.strokeCap = StrokeCap.round;
    paint.strokeJoin = StrokeJoin.round;
    final innerCheck = Path()
      ..moveTo(cx + 53, 130)
      ..lineTo(cx + 58, 135)
      ..lineTo(cx + 67, 125);
    canvas.drawPath(innerCheck, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
