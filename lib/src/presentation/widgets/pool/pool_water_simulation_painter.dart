import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'ripple_emitter.dart';

/// Hardware-accelerated CustomPainter rendering top-view organic pool water:
/// - Underwater ceramic tile grid with gentle refractive wave sway
/// - Continuous organic caustic ribbon networks (eliminating artificial bubble grids)
/// - Interactive expanding concentric water ripples
class PoolWaterSimulationPainter extends CustomPainter {
  final double time; // In seconds
  final List<WaterRipple> ripples;
  final bool reducedMotion;

  // Cached paints to eliminate per-frame allocations (120 FPS target)
  final Paint _tileGroutPaint = Paint()
    ..color = const Color(0x1A00E5FF)
    ..strokeWidth = 1.4
    ..style = PaintingStyle.stroke;

  final Paint _causticRibbonPaint1 = Paint()
    ..color = const Color(0x38B2EBF2)
    ..strokeWidth = 2.4
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  final Paint _causticRibbonPaint2 = Paint()
    ..color = const Color(0x28FFFFFF)
    ..strokeWidth = 1.6
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  final Paint _causticNodePaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0x44FFFFFF);

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
        radius: 1.15,
        colors: [
          Color(0xFF006064),
          Color(0xFF00363A),
          AppColors.surfaceAbyssal,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // 2. Underwater Ceramic Pool Tile Grid with Soft Wave Refraction
    _drawUnderwaterTiles(canvas, size, effectiveTime);

    // 3. Continuous Organic Caustic Ribbon Network (Zero bubble circles)
    if (!reducedMotion) {
      _drawOrganicCaustics(canvas, size, effectiveTime);
    }

    // 4. Interactive Expanding Water Ripples
    _drawRipples(canvas, size, effectiveTime);
  }

  void _drawUnderwaterTiles(Canvas canvas, Size size, double t) {
    const double tileSize = 52.0;
    final int cols = (size.width / tileSize).ceil() + 1;
    final int rows = (size.height / tileSize).ceil() + 1;

    final Path gridPath = Path();

    // Vertical tile lines with subtle refraction sway
    for (int i = 0; i <= cols; i++) {
      final double baseX = i * tileSize;
      gridPath.moveTo(baseX, 0);
      for (double y = 0; y <= size.height; y += 20.0) {
        final double waveOffset = math.sin((y / 48.0) + (t * 1.1)) * 2.2;
        gridPath.lineTo(baseX + waveOffset, y);
      }
    }

    // Horizontal tile lines with subtle refraction sway
    for (int j = 0; j <= rows; j++) {
      final double baseY = j * tileSize;
      gridPath.moveTo(0, baseY);
      for (double x = 0; x <= size.width; x += 20.0) {
        final double waveOffset = math.cos((x / 48.0) + (t * 1.3)) * 2.2;
        gridPath.lineTo(x, baseY + waveOffset);
      }
    }

    canvas.drawPath(gridPath, _tileGroutPaint);
  }

  void _drawOrganicCaustics(Canvas canvas, Size size, double t) {
    final Path causticWeb1 = Path();
    final Path causticWeb2 = Path();
    final double w = size.width;
    final double h = size.height;

    // Layer 1: Horizontal undulating caustic ribbons
    const double ribbonSpacing = 48.0;
    final int ribbonCount = (h / ribbonSpacing).ceil() + 2;

    for (int r = 0; r < ribbonCount; r++) {
      final double baseY = (r - 1) * ribbonSpacing;
      final double phase = (r * 1.4) + (t * 1.15);

      causticWeb1.moveTo(-20, baseY + math.sin(phase) * 12.0);

      for (double x = 0; x <= w + 40; x += 48.0) {
        final double wave1 = math.sin((x / 52.0) + phase) * 10.0;
        final double wave2 = math.cos((x / 36.0) - (t * 1.4) + r) * 7.0;
        final double waveY = baseY + wave1 + wave2;

        final double ctrlX = x - 24.0;
        final double ctrlY = baseY + math.sin((ctrlX / 42.0) + phase) * 14.0;
        causticWeb1.quadraticBezierTo(ctrlX, ctrlY, x, waveY);
      }
    }

    // Layer 2: Intersecting diagonal caustic light ribbons creating natural organic webs
    const double diagSpacing = 64.0;
    final int diagCount = ((w + h) / diagSpacing).ceil() + 2;

    for (int d = 0; d < diagCount; d++) {
      final double startX = (d * diagSpacing) - (h * 0.45);
      final double phase = (d * 1.1) - (t * 1.25);

      causticWeb2.moveTo(startX + math.sin(phase) * 8.0, -20);

      for (double step = 0; step <= h + 40; step += 48.0) {
        final double currentY = step;
        final double currentX =
            startX + (step * 0.55) + math.sin((step / 44.0) + phase) * 12.0;
        final double ctrlX = startX +
            ((step - 24.0) * 0.55) +
            math.cos(((step - 24.0) / 38.0) + phase) * 14.0;
        final double ctrlY = step - 24.0;
        causticWeb2.quadraticBezierTo(ctrlX, ctrlY, currentX, currentY);
      }
    }

    canvas.drawPath(causticWeb1, _causticRibbonPaint1);
    canvas.drawPath(causticWeb2, _causticRibbonPaint2);

    // Subtle natural caustic intersection highlights
    final Path causticNodes = Path();
    const double nodeStep = 80.0;
    final int nx = (w / nodeStep).ceil() + 1;
    final int ny = (h / nodeStep).ceil() + 1;

    for (int ix = 0; ix < nx; ix++) {
      for (int iy = 0; iy < ny; iy++) {
        final double cx =
            (ix * nodeStep) + math.sin((iy * 1.6) + (t * 1.3)) * 14.0;
        final double cy =
            (iy * nodeStep) + math.cos((ix * 1.3) - (t * 1.1)) * 12.0;
        final double radius = 3.2 + math.sin((ix + iy) + (t * 2.0)) * 1.6;
        causticNodes.addOval(
          Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        );
      }
    }
    canvas.drawPath(causticNodes, _causticNodePaint);
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
