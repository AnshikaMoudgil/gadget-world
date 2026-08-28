import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'web_button_stub.dart' if (dart.library.html) 'web_button_web.dart';

class GoogleButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const GoogleButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  State<GoogleButton> createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<GoogleButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final visualButton = _buildStyledButton();
    final button = kIsWeb
        ? SizedBox(
            height: 52,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(child: visualButton),
                Positioned.fill(
                  child: Opacity(opacity: 0.01, child: buildWebButton()),
                ),
              ],
            ),
          )
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.isLoading ? null : widget.onPressed,
            child: visualButton,
          );

    return MouseRegion(
      cursor: widget.isLoading
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      child: Listener(
        onPointerDown: widget.isLoading
            ? null
            : (_) => setState(() => _isPressed = true),
        onPointerUp: (_) => setState(() => _isPressed = false),
        onPointerCancel: (_) => setState(() => _isPressed = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 130),
          curve: Curves.easeOutCubic,
          scale: _isPressed ? .975 : 1,
          child: button,
        ),
      ),
    );
  }

  Widget _buildStyledButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      height: 52,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF4285F4,
            ).withValues(alpha: _isHovered ? .16 : .06),
            blurRadius: _isHovered ? 22 : 12,
            offset: Offset(0, _isHovered ? 7 : 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: _isHovered ? .88 : .72),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isHovered
                    ? const Color(0xFF8AB4F8)
                    : Colors.white.withValues(alpha: .9),
                width: 1.2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: widget.isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildGoogleIcon(),
                        const SizedBox(width: 12),
                        const Text(
                          'Continue with Google',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return Image.network(
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/512px-Google_%22G%22_logo.svg.png',
      width: 22,
      height: 22,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => SizedBox(
        width: 22,
        height: 22,
        child: CustomPaint(painter: _GoogleLogoPainter()),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    final paint = Paint()..style = PaintingStyle.fill;

    // Blue sector
    paint.color = const Color(0xFF4285F4);
    final bluePath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -0.785,
        1.571,
        false,
      )
      ..close();
    canvas.drawPath(bluePath, paint);

    // Red sector
    paint.color = const Color(0xFFEA4335);
    final redPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -0.785,
        -1.571,
        false,
      )
      ..close();
    canvas.drawPath(redPath, paint);

    // Yellow sector
    paint.color = const Color(0xFFFBBC05);
    final yellowPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        1.571,
        1.571,
        false,
      )
      ..close();
    canvas.drawPath(yellowPath, paint);

    // Green sector
    paint.color = const Color(0xFF34A853);
    final greenPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        3.142,
        -1.571,
        false,
      )
      ..close();
    canvas.drawPath(greenPath, paint);

    // Inner cutout circle
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.55, paint);

    // Blue horizontal bar of G
    paint.color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx - 1,
        center.dy - (radius * 0.15),
        radius * 1.05,
        radius * 0.3,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
