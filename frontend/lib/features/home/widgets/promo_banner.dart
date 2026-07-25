import 'package:flutter/material.dart';
import 'package:gadget_store/core/theme.dart';
import 'package:gadget_store/features/products/screens/best_sellers_screen.dart';

class PromoBannerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw background gradient
    final Rect rect = Offset.zero & size;
    final Paint bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFF4F5FF), Color(0xFFE4E1FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // Draw waves
    final Paint wavePaint = Paint()
      ..color = const Color(0xFFC7C9FF).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final Path wavePath1 = Path()
      ..moveTo(0, size.height * 0.75)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.9,
        size.width * 0.5,
        size.height * 0.8,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.7,
        size.width,
        size.height * 0.5,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(wavePath1, wavePaint);

    final Path wavePath2 = Path()
      ..moveTo(size.width * 0.2, size.height)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.85,
        size.width * 0.8,
        size.height * 0.95,
      )
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.98,
        size.width,
        size.height * 0.8,
      )
      ..lineTo(size.width, size.height)
      ..close();

    wavePaint.color = const Color(0xFFA6ADFF).withValues(alpha: 0.3);
    canvas.drawPath(wavePath2, wavePaint);

    // Draw sparkles
    _drawSparkle(canvas, Offset(size.width * 0.85, size.height * 0.2), 15);
    _drawSparkle(canvas, Offset(size.width * 0.65, size.height * 0.45), 8);

    // Draw dot grid (bottom right)
    final Paint dotPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.6);
    final double gridStartX = size.width * 0.82;
    final double gridStartY = size.height * 0.7;
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 4; col++) {
        canvas.drawCircle(
          Offset(gridStartX + col * 12, gridStartY + row * 12),
          1.5,
          dotPaint,
        );
      }
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double size) {
    final Paint paint = Paint()..color = const Color(0xFF7A81FF);
    final Path path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + size, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + size)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - size, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - size)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CustomPromoBanner extends StatelessWidget {
  const CustomPromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: PromoBannerPainter())),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.black,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                      children: [
                        TextSpan(text: 'Upgrade Your\n'),
                        TextSpan(
                          text: 'Tech ',
                          style: TextStyle(color: Color(0xFF6B58F5)),
                        ),
                        TextSpan(text: 'Game'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Discover the latest gadgets\nand innovative tech products.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF555555),
                      height: 1.4,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BestSellersScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF161828),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Shop Now',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF161828),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
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
}
