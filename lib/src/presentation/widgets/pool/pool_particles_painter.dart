import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Single ambient particle (micro-bubble or water sparkle glint)
class PoolParticle {
  final double xRatio; // 0.0 to 1.0 of viewport width
  final double yRatio; // 0.0 to 1.0 of viewport height
  final double radius;
  final double speed;
  final double phase;
  final bool isSparkle;

  const PoolParticle({
    required this.xRatio,
    required this.yRatio,
    required this.radius,
    required this.speed,
    required this.phase,
    this.isSparkle = false,
  });
}

/// CustomPainter rendering rising micro-bubbles and sparkling specular glints
class PoolParticlesPainter extends CustomPainter {
  final double time;
  final List<PoolParticle> particles;

  final Paint _bubblePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2
    ..color = const Color(0x66B2EBF2);

  final Paint _bubbleHighlight = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0xAAFFFFFF);

  final Paint _sparklePaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0xCCFFFFFF);

  PoolParticlesPainter({
    required this.time,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      // Particles drift upward with gentle horizontal sway
      final double y =
          (size.height * ((p.yRatio - (time * p.speed * 0.06)) % 1.0));
      final double xSway = math.sin((time * 2.0) + p.phase) * 12.0;
      final double x = (size.width * p.xRatio) + xSway;

      final Offset center = Offset(x, y);

      if (p.isSparkle) {
        // Star-like sparkle glint that blinks
        final double opacity =
            (0.5 + 0.5 * math.sin((time * 3.5) + p.phase)).clamp(0.0, 1.0);
        _sparklePaint.color = Colors.white.withValues(alpha: opacity * 0.85);

        canvas.drawCircle(center, p.radius, _sparklePaint);
        // Crosshair rays
        canvas.drawLine(
          Offset(center.dx - p.radius * 2.2, center.dy),
          Offset(center.dx + p.radius * 2.2, center.dy),
          _sparklePaint,
        );
        canvas.drawLine(
          Offset(center.dx, center.dy - p.radius * 2.2),
          Offset(center.dx, center.dy + p.radius * 2.2),
          _sparklePaint,
        );
      } else {
        // Spherical micro-bubble with specular specular reflection
        canvas.drawCircle(center, p.radius, _bubblePaint);
        canvas.drawCircle(
          Offset(center.dx - p.radius * 0.35, center.dy - p.radius * 0.35),
          p.radius * 0.28,
          _bubbleHighlight,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant PoolParticlesPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}
