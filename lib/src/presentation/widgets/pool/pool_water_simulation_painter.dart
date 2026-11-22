import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'ripple_emitter.dart';

/// Hardware-accelerated CustomPainter rendering top-view procedural pool water:
/// - Underwater ceramic tile grid with caustic refraction distortion
/// - Dual-layer sinusoidal caustic lattices with specular sunlight glints
/// - Dynamic interactive expanding ripple wavefield
class PoolWaterSimulationPainter extends CustomPainter {
  final double time; // In seconds
  final List<WaterRipple> ripples;
  final bool reducedMotion;

  // Cached paints to eliminate per-frame allocations (120 FPS target)
  final Paint _tileGroutPaint = Paint()
    ..color = const Color(0x2200E5FF)
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke;

  final Paint _causticPaint1 = Paint()
    ..color = const Color(0x33B2EBF2)
    ..strokeWidth = 2.5
    ..style = PaintingStyle.stroke;

  final Paint _causticPaint2 = Paint()
    ..color = const Color(0x22FFFFFF)
    ..strokeWidth = 1.8
    ..style = PaintingStyle.stroke;

  final Paint _ripplePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  PoolWaterSimulationPainter({
    required this.time,
    required this.ripples,
    this.reducedMotion = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final effectiveTime = reducedMotion ? 0.0 : time;

    // 1. Base Pool Gradient (Deep Tropical Aqua to Abyssal Cyan)
    final Rect rect = Offset.zero & size;
    final Paint bgPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.0, -0.1),
        radius: 1.1,
        colors: [
          Color(0xFF006064),
          Color(0xFF00363A),
          AppColors.surfaceAbyssal,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // 2. Underwater Ceramic Pool Tile Grid with Procedural Distortion
    _drawUnderwaterTiles(canvas, size, effectiveTime);

    // 3. Dual-Layer Caustic Refraction Lines
    if (!reducedMotion) {
      _drawCaustics(canvas, size, effectiveTime);
    }

    // 4. Interactive Expanding Water Ripples
    _drawRipples(canvas, size, effectiveTime);
  }

  void _drawUnderwaterTiles(Canvas canvas, Size size, double t) {
    const double tileSize = 48.0;
    final int cols = (size.width / tileSize).ceil() + 1;
    final int rows = (size.height / tileSize).ceil() + 1;

    final Path gridPath = Path();

    // Vertical tile lines with subtle refraction sway
    for (int i = 0; i <= cols; i++) {
      final double baseX = i * tileSize;
      gridPath.moveTo(baseX, 0);
      for (double y = 0; y <= size.height; y += 16.0) {
        final double waveOffset = math.sin((y / 40.0) + (t * 1.2)) * 2.5;
        gridPath.lineTo(baseX + waveOffset, y);
      }
    }

    // Horizontal tile lines with subtle refraction sway
    for (int j = 0; j <= rows; j++) {
      final double baseY = j * tileSize;
      gridPath.moveTo(0, baseY);
      for (double x = 0; x <= size.width; x += 16.0) {
        final double waveOffset = math.cos((x / 40.0) + (t * 1.4)) * 2.5;
        gridPath.lineTo(x, baseY + waveOffset);
      }
    }

    canvas.drawPath(gridPath, _tileGroutPaint);
  }

  void _drawCaustics(Canvas canvas, Size size, double t) {
    final Path causticPath1 = Path();
    final Path causticPath2 = Path();

    const double step = 36.0;
    final int numX = (size.width / step).ceil();
    final int numY = (size.height / step).ceil();

    for (int ix = 0; ix < numX; ix++) {
      for (int iy = 0; iy < numY; iy++) {
        final double x = ix * step;
        final double y = iy * step;

        // Primary caustic network nodes
        final double dx1 = math.sin((x / 30.0) + (t * 1.5)) * 10.0;
        final double dy1 = math.cos((y / 28.0) + (t * 1.2)) * 8.0;
        final double r1 = 12.0 + math.sin(((x + y) / 45.0) + (t * 1.8)) * 6.0;

        causticPath1.addOval(
          Rect.fromCircle(center: Offset(x + dx1, y + dy1), radius: r1),
        );

        // Secondary sharper glint nodes
        if ((ix + iy) % 2 == 0) {
          final double dx2 = math.cos((x / 34.0) - (t * 1.6)) * 8.0;
          final double dy2 = math.sin((y / 32.0) + (t * 1.4)) * 10.0;
          final double r2 = 7.0 + math.cos(((x - y) / 40.0) - (t * 2.0)) * 4.0;

          causticPath2.addOval(
            Rect.fromCircle(center: Offset(x + dx2, y + dy2), radius: r2),
          );
        }
      }
    }

    canvas.drawPath(causticPath1, _causticPaint1);
    canvas.drawPath(causticPath2, _causticPaint2);
  }

  void _drawRipples(Canvas canvas, Size size, double t) {
    for (final ripple in ripples) {
      if (ripple.isExpired(t)) continue;

      final double radius = ripple.radiusAt(t);
      final double opacity = ripple.opacityAt(t).clamp(0.0, 1.0);

      _ripplePaint.color = ripple.color.withValues(alpha: opacity * 0.7);
      _ripplePaint.strokeWidth = 2.5 * (1.0 - (radius / ripple.maxRadius));

      // Draw primary concentric ring
      canvas.drawCircle(ripple.origin, radius, _ripplePaint);

      // Draw secondary trailing reflection ring
      if (radius > 15.0) {
        _ripplePaint.color = Colors.white.withValues(alpha: opacity * 0.4);
        _ripplePaint.strokeWidth = 1.2;
        canvas.drawCircle(ripple.origin, radius * 0.75, _ripplePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant PoolWaterSimulationPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.ripples.length != ripples.length ||
        oldDelegate.reducedMotion != reducedMotion;
  }
}
