import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/widgets/custom_text_field.dart';
import '../core/widgets/primary_button.dart';
import '../core/widgets/logo_widget.dart';
import 'login_screen.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetLink() {
    setState(() {
      _emailSent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _emailSent ? _buildEmailSentState() : _buildForgotForm(),
        ),
      ),
    );
  }

  Widget _buildForgotForm() {
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
        const SizedBox(height: 20),
        const LogoWidget(size: 48),
        const SizedBox(height: 16),
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 20, color: AppTheme.black),
            children: [
              TextSpan(text: 'Gadget ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: 'Store', style: TextStyle(fontWeight: FontWeight.w300)),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Forgot Password?',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.black),
        ),
        const SizedBox(height: 8),
        const Text(
          'Enter your email and we\'ll\nsend a reset link',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppTheme.greyText),
        ),
        const SizedBox(height: 40),
        CustomTextField(
          label: 'Email address',
          hintText: 'Enter your email',
          prefixIcon: Icons.email_outlined,
          controller: _emailController,
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          text: 'Send Reset Link',
          onPressed: _sendResetLink,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(child: Divider(color: AppTheme.greyBorder)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('or', style: TextStyle(color: AppTheme.greyText.withValues(alpha: 0.5))),
            ),
            const Expanded(child: Divider(color: AppTheme.greyBorder)),
          ],
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.arrow_back, size: 16, color: AppTheme.black),
              const SizedBox(width: 6),
              const Text(
                'Back to Login',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.black,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        _buildIllustration(),
      ],
    );
  }

  Widget _buildEmailSentState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  _emailSent = false;
                });
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const LogoWidget(size: 48),
        const SizedBox(height: 16),
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 20, color: AppTheme.black),
            children: [
              TextSpan(text: 'Gadget ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: 'Store', style: TextStyle(fontWeight: FontWeight.w300)),
            ],
          ),
        ),
        const SizedBox(height: 40),
        _buildEnvelopeIllustration(),
        const SizedBox(height: 32),
        const Text(
          'Check your email',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.black),
        ),
        const SizedBox(height: 12),
        const Text(
          'We\'ve sent a password reset link to',
          style: TextStyle(fontSize: 14, color: AppTheme.greyText),
        ),
        const SizedBox(height: 4),
        Text(
          _emailController.text.isNotEmpty ? _emailController.text : 'example@email.com',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.black,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'The link will expire in 15 minutes.',
          style: TextStyle(fontSize: 13, color: AppTheme.greyText),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ResetPasswordScreen()));
          },
          child: const Text(
            'Click here to reset password',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.black,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const SizedBox(height: 28),
        PrimaryButton(
          text: 'Back to Login',
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildIllustration() {
    return SizedBox(
      height: 140,
      child: CustomPaint(
        painter: _ForgotIllustrationPainter(),
        size: const Size(double.infinity, 140),
      ),
    );
  }

  Widget _buildEnvelopeIllustration() {
    return SizedBox(
      height: 170,
      child: CustomPaint(
        painter: _EnvelopeIllustrationPainter(),
        size: const Size(double.infinity, 170),
      ),
    );
  }
}

class _ForgotIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final centerX = size.width / 2;

    paint.color = AppTheme.black;
    paint.style = PaintingStyle.fill;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(centerX, 80), width: 60, height: 70),
      const Radius.circular(8),
    );
    canvas.drawRRect(rrect, paint);

    paint.color = Colors.transparent;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 5;
    paint.color = const Color(0xFF9E9E9E);
    canvas.drawCircle(Offset(centerX, 50), 14, paint);

    paint.style = PaintingStyle.fill;
    paint.color = AppTheme.white;
    canvas.drawCircle(Offset(centerX, 85), 5, paint);

    paint.color = AppTheme.white;
    final rectBody = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(centerX, 85), width: 5, height: 12),
      const Radius.circular(2),
    );
    canvas.drawRRect(rectBody, paint);

    paint.color = const Color(0xFFF0F0F0);
    paint.style = PaintingStyle.fill;
    final rrect2 = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(centerX + 25, 90), width: 60, height: 38),
      const Radius.circular(6),
    );
    canvas.drawRRect(rrect2, paint);

    paint.color = const Color(0xFFDCDCDC);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;
    canvas.drawRRect(rrect2, paint);

    paint.color = AppTheme.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    canvas.drawLine(Offset(centerX + 18, 120), Offset(centerX + 46, 82), paint);

    paint.color = AppTheme.black;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX + 60, 82), 3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EnvelopeIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final paint = Paint();

    paint.color = const Color(0xFFF5F5F5);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, 85), 70, paint);

    paint.color = const Color(0xFFD8D8D8);
    paint.style = PaintingStyle.fill;
    for (final offset in [
      Offset(centerX - 70, 28),
      Offset(centerX - 56, 28),
      Offset(centerX - 70, 42),
      Offset(centerX - 56, 42),
      Offset(centerX + 56, 28),
      Offset(centerX + 70, 28),
      Offset(centerX + 56, 42),
      Offset(centerX + 70, 42),
      Offset(centerX - 66, 128),
      Offset(centerX - 52, 128),
      Offset(centerX - 66, 142),
      Offset(centerX - 52, 142),
    ]) {
      canvas.drawCircle(offset, 2, paint);
    }

    paint.color = AppTheme.white;
    paint.style = PaintingStyle.fill;
    final mainRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(centerX - 25, 100), width: 80, height: 60),
      const Radius.circular(6),
    );
    canvas.drawRRect(mainRect, paint);

    paint.color = const Color(0xFFE5E5E5);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    canvas.drawRRect(mainRect, paint);

    paint.color = const Color(0xFFE5E5E5);
    canvas.drawLine(Offset(centerX - 45, 88), Offset(centerX - 25, 108), paint);
    canvas.drawLine(Offset(centerX - 25, 108), Offset(centerX - 5, 88), paint);

    paint.color = AppTheme.white;
    paint.style = PaintingStyle.fill;
    final backRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(centerX + 30, 112), width: 100, height: 55),
      const Radius.circular(6),
    );
    canvas.drawRRect(backRect, paint);

    paint.color = const Color(0xFFE0E0E0);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    canvas.drawRRect(backRect, paint);

    paint.color = AppTheme.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawLine(Offset(centerX - 15, 100), Offset(centerX + 30, 130), paint);
    canvas.drawLine(Offset(centerX + 30, 130), Offset(centerX + 75, 100), paint);
    canvas.drawLine(Offset(centerX - 15, 145), Offset(centerX + 18, 118), paint);
    canvas.drawLine(Offset(centerX + 75, 145), Offset(centerX + 42, 118), paint);

    paint.color = AppTheme.black;
    paint.style = PaintingStyle.fill;
    final envelopePath = Path()
      ..moveTo(centerX + 20, 48)
      ..lineTo(centerX + 10, 58)
      ..lineTo(centerX + 18, 60)
      ..lineTo(centerX + 26, 50)
      ..close();
    canvas.drawPath(envelopePath, paint);

    paint.color = AppTheme.black;
    canvas.drawCircle(Offset(centerX + 65, 58), 20, paint);

    paint.style = PaintingStyle.stroke;
    paint.color = AppTheme.white;
    paint.strokeWidth = 3;
    paint.strokeCap = StrokeCap.round;
    paint.strokeJoin = StrokeJoin.round;
    final checkPath = Path()
      ..moveTo(centerX + 56, 58)
      ..lineTo(centerX + 62, 64)
      ..lineTo(centerX + 74, 52);
    canvas.drawPath(checkPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
