import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class BrandLogo extends StatelessWidget {
  final double size;
  final bool showBackground;

  const BrandLogo({
    super.key,
    this.size = 40,
    this.showBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget logo = CustomPaint(
      size: Size(size, size),
      painter: _HighFidelityLogoPainter(),
    );

    if (showBackground) {
      return Container(
        width: size * 1.8,
        height: size * 1.8,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.cyanAccent.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.05),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: logo,
      );
    }

    return logo;
  }
}

class _HighFidelityLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double strokeWidth = w * 0.08;

    // 1. Shield Chrome Effect
    final Path shieldPath = Path();
    shieldPath.moveTo(w * 0.5, h * 0.15);
    shieldPath.lineTo(w * 0.82, h * 0.15);
    shieldPath.lineTo(w * 0.82, h * 0.52);
    shieldPath.quadraticBezierTo(w * 0.82, h * 0.78, w * 0.5, h * 0.92);
    shieldPath.quadraticBezierTo(w * 0.18, h * 0.78, w * 0.18, h * 0.52);
    shieldPath.lineTo(w * 0.18, h * 0.15);
    shieldPath.close();

    // Metallic Gradient for the shield
    final Paint shieldPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(w * 0.2, h * 0.2),
        Offset(w * 0.8, h * 0.8),
        [
          Colors.white,
          Colors.grey.shade400,
          Colors.white,
          Colors.grey.shade700,
        ],
        [0.0, 0.4, 0.6, 1.0],
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Draw base shield
    canvas.drawPath(shieldPath, shieldPaint);

    // 2. Neon Pulse Effect
    final Path pulsePath = Path();
    final double midY = h * 0.51;
    pulsePath.moveTo(w * 0.0, midY);
    pulsePath.lineTo(w * 0.36, midY);
    pulsePath.lineTo(w * 0.43, midY + h * 0.16);
    pulsePath.lineTo(w * 0.51, midY - h * 0.24);
    pulsePath.lineTo(w * 0.59, midY + h * 0.16);
    pulsePath.lineTo(w * 0.66, midY);
    pulsePath.lineTo(w * 1.0, midY);

    // Inner Neon Core
    final Paint pulseCorePaint = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Outer Neon Glow
    final Paint pulseGlowPaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 2.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    // Deep Inner Glow
    final Paint pulseDeepGlowPaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 5.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawPath(pulsePath, pulseDeepGlowPaint);
    canvas.drawPath(pulsePath, pulseGlowPaint);
    canvas.drawPath(pulsePath, pulseCorePaint);

    // 3. Specular Highlights on the Shield
    final Paint highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.4
      ..strokeCap = StrokeCap.round;

    final Path h1 = Path();
    h1.moveTo(w * 0.25, h * 0.18);
    h1.lineTo(w * 0.45, h * 0.18);
    canvas.drawPath(h1, highlightPaint);

    final Path h2 = Path();
    h2.moveTo(w * 0.8, h * 0.25);
    h2.lineTo(w * 0.8, h * 0.45);
    canvas.drawPath(h2, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
