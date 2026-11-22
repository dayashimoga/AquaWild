import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/models/fluid_layer.dart';
import 'animal_silhouette_paths.dart';
import 'wave_column_solver.dart';

/// Hardware-accelerated CustomPainter rendering:
/// - Exotic animal vector silhouette clipping boundary
/// - 64-column coupled shallow-water sloshing wave surface
/// - Multi-beverage density-stratified colored layers
/// - Species-specific interactive animations:
///   * Cappy the Capybara: Thermal Yuzu onsen bobbing citrus fruits, rising steam wisps, zen head towel
///   * Lottie the Axolotl: Pulsing bioluminescent feathery external gills & floating ocean spores
///   * Ruby the Red Panda: Highland cloud forest markings & ringed tail highlights
/// - Meniscus surface tension refraction highlights & glowing hydro-glass outline
class AnimalFluidVesselPainter extends CustomPainter {
  final String animalId;
  final double fillFraction; // 0.0 to 1.0
  final List<FluidLayer> stratifiedLayers;
  final WaveColumnSolver waveSolver;
  final double time;
  final bool reducedMotion;
  final Color accentColor;
  final double interactionPulse; // 0.0 to 1.0 decaying pulse on tap

  final Paint _glassOutlinePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.0;

  final Paint _glassGlowPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 7.0
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

  final Paint _emptyBackdropPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0x15FFFFFF);

  final Paint _meniscusHighlight = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.8
    ..color = const Color(0xCCFFFFFF);

  final Paint _bubblePaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0x99FFFFFF);

  // Reusable species feature paints
  final Paint _yuzuFruitPaint = Paint()..style = PaintingStyle.fill;
  final Paint _yuzuLeafPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0xFF66BB6A);
  final Paint _steamPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.2
    ..strokeCap = StrokeCap.round;
  final Paint _towelPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0xFFF5F5F5);
  final Paint _towelBorderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2
    ..color = const Color(0x33000000);
  final Paint _gillGlowPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
  final Paint _gillCorePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 2.5;
  final Paint _sporePaint = Paint()..style = PaintingStyle.fill;
  final Paint _faceFeaturePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0
    ..strokeCap = StrokeCap.round
    ..color = const Color(0xDDFFFFFF);

  AnimalFluidVesselPainter({
    required this.animalId,
    required this.fillFraction,
    required this.stratifiedLayers,
    required this.waveSolver,
    required this.time,
    required this.accentColor,
    this.reducedMotion = false,
    this.interactionPulse = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Path animalPath =
        AnimalSilhouettePaths.getSilhouettePath(animalId, size);

    // 1. Draw glowing hydro-glass silhouette outline and backdrop
    final double dynamicGlowAlpha =
        0.35 + (interactionPulse * 0.45).clamp(0.0, 0.55);
    _glassGlowPaint.color = accentColor.withValues(alpha: dynamicGlowAlpha);
    canvas.drawPath(animalPath, _glassGlowPaint);
    canvas.drawPath(animalPath, _emptyBackdropPaint);

    _glassOutlinePaint.color = accentColor.withValues(alpha: 0.75);
    canvas.drawPath(animalPath, _glassOutlinePaint);

    final List<Offset> surfacePoints = _computeSurfacePoints(size);

    // 2. Clip all fluid layers and interior species details to animal silhouette
    if (fillFraction > 0.001) {
      canvas.save();
      canvas.clipPath(animalPath);

      _drawStratifiedFluid(canvas, size, surfacePoints);

      // Interior species accents (Yuzu fruits inside Capybara pool, glowing spores in Axolotl)
      if (animalId == 'capybara') {
        _drawCapybaraInteriorYuzus(canvas, size, surfacePoints);
      } else if (animalId == 'axolotl') {
        _drawAxolotlInteriorSpores(canvas, size);
      }

      canvas.restore();
    }

    // 3. Draw exterior companion details & interactive overlays (steam, towels, pulsing gills, faces)
    _drawSpeciesExteriorDetails(canvas, size, surfacePoints);
  }

  List<Offset> _computeSurfacePoints(Size size) {
    final double clampedFill = fillFraction.clamp(0.0, 1.0);
    final double totalFluidHeight = size.height * clampedFill;
    final int numCols = waveSolver.columnCount;
    final double colWidth = size.width / (numCols - 1);

    final List<Offset> points = [];
    for (int i = 0; i < numCols; i++) {
      final double x = i * colWidth;
      final double waveDelta =
          reducedMotion ? 0.0 : waveSolver.columns[i].height;
      final double y = size.height - totalFluidHeight + waveDelta;
      points.add(Offset(x, y));
    }
    return points;
  }

  void _drawStratifiedFluid(
    Canvas canvas,
    Size size,
    List<Offset> surfacePoints,
  ) {
    final double clampedFill = fillFraction.clamp(0.0, 1.0);
    final double totalFluidHeight = size.height * clampedFill;
    double currentBaseY = size.height;

    for (int l = 0; l < stratifiedLayers.length; l++) {
      final layer = stratifiedLayers[l];
      final double layerHeight = totalFluidHeight * layer.fractionOfTotal;
      final double layerTopY = currentBaseY - layerHeight;

      final Path layerPath = Path();
      layerPath.moveTo(0, currentBaseY);

      if (l == stratifiedLayers.length - 1) {
        // Topmost fluid layer uses the dynamic wave column surface
        for (int i = 0; i < surfacePoints.length; i++) {
          if (i == 0) {
            layerPath.lineTo(surfacePoints[i].dx, surfacePoints[i].dy);
          } else {
            final prev = surfacePoints[i - 1];
            final curr = surfacePoints[i];
            final midX = (prev.dx + curr.dx) / 2;
            final midY = (prev.dy + curr.dy) / 2;
            layerPath.quadraticBezierTo(prev.dx, prev.dy, midX, midY);
          }
        }
        layerPath.lineTo(size.width, surfacePoints.last.dy);
      } else {
        // Subsurface interfacial layer wave
        layerPath.lineTo(0, layerTopY);
        for (double x = 0; x <= size.width; x += 16.0) {
          final double sway = reducedMotion
              ? 0.0
              : math.sin((x / 30.0) + (time * 2.0) + l) * 2.5;
          layerPath.lineTo(x, layerTopY + sway);
        }
        layerPath.lineTo(size.width, layerTopY);
      }

      layerPath.lineTo(size.width, currentBaseY);
      layerPath.close();

      // Stratum gradient
      final Paint stratumPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            layer.beverage.secondaryColor,
            layer.beverage.primaryColor,
          ],
        ).createShader(
          Rect.fromLTRB(0, layerTopY, size.width, currentBaseY),
        );

      canvas.drawPath(layerPath, stratumPaint);

      if (!reducedMotion) {
        _drawLayerBubbles(canvas, size, layerTopY, currentBaseY, l);
      }

      currentBaseY = layerTopY;
    }

    // Specular meniscus surface highlight
    if (!reducedMotion && surfacePoints.isNotEmpty) {
      final Path meniscusPath = Path();
      for (int i = 0; i < surfacePoints.length; i++) {
        if (i == 0) {
          meniscusPath.moveTo(surfacePoints[i].dx, surfacePoints[i].dy);
        } else {
          final prev = surfacePoints[i - 1];
          final curr = surfacePoints[i];
          final midX = (prev.dx + curr.dx) / 2;
          final midY = (prev.dy + curr.dy) / 2;
          meniscusPath.quadraticBezierTo(prev.dx, prev.dy, midX, midY);
        }
      }
      canvas.drawPath(meniscusPath, _meniscusHighlight);
    }
  }

  void _drawLayerBubbles(
    Canvas canvas,
    Size size,
    double topY,
    double bottomY,
    int layerIndex,
  ) {
    final double layerH = bottomY - topY;
    if (layerH < 15) return;

    for (int b = 0; b < 6; b++) {
      final double seed = (b * 17.0) + (layerIndex * 31.0);
      final double x = (size.width * 0.2) +
          (math.sin(seed) * 0.5 + 0.5) * (size.width * 0.6);

      final double cycle = (time * 0.4 + (seed * 0.1)) % 1.0;
      final double y = bottomY - (cycle * layerH);

      final double radius = 1.5 + (math.cos(seed) * 0.5 + 0.5) * 2.2;
      canvas.drawCircle(Offset(x, y), radius, _bubblePaint);
    }
  }

  // =========================================================================
  // CAPYBARA THERMAL ONZEN ANIMATIONS
  // =========================================================================

  void _drawCapybaraInteriorYuzus(
    Canvas canvas,
    Size size,
    List<Offset> surfacePoints,
  ) {
    if (surfacePoints.isEmpty || fillFraction < 0.08) return;

    final yuzuColumns = [22, 44];
    final w = size.width;

    for (int i = 0; i < yuzuColumns.length; i++) {
      final col = yuzuColumns[i].clamp(0, surfacePoints.length - 1);
      final surfacePoint = surfacePoints[col];

      final double bobbing = reducedMotion
          ? 0.0
          : math.sin(time * 3.0 + (i * 2.0)) *
              (2.5 + (interactionPulse * 6.0));
      final double radius = w * 0.048;
      final Offset center =
          Offset(surfacePoint.dx, surfacePoint.dy - (radius * 0.2) + bobbing);

      // Yuzu fruit gradient
      _yuzuFruitPaint.shader = const RadialGradient(
        colors: [Color(0xFFFFF176), Color(0xFFFFB300), Color(0xFFF57C00)],
        stops: [0.0, 0.7, 1.0],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

      canvas.drawCircle(center, radius, _yuzuFruitPaint);

      // Tiny green leaf
      final Path leafPath = Path();
      leafPath.moveTo(center.dx, center.dy - radius);
      leafPath.quadraticBezierTo(
        center.dx + radius * 0.7,
        center.dy - radius * 1.5,
        center.dx + radius * 0.3,
        center.dy - radius * 1.8,
      );
      leafPath.quadraticBezierTo(
        center.dx,
        center.dy - radius * 1.2,
        center.dx,
        center.dy - radius,
      );
      canvas.drawPath(leafPath, _yuzuLeafPaint);

      // Specular highlight
      canvas.drawCircle(
        Offset(center.dx - radius * 0.35, center.dy - radius * 0.35),
        radius * 0.25,
        _bubblePaint,
      );
    }
  }

  void _drawCapybaraExteriorDetails(
    Canvas canvas,
    Size size,
    List<Offset> surfacePoints,
  ) {
    final w = size.width;
    final h = size.height;

    // 1. Zen Folded Onsen Head Towel
    final double towelW = w * 0.16;
    final double towelH = h * 0.055;
    final double towelX = w * 0.33;
    final double towelY = h * 0.17;
    final double towelTilt =
        reducedMotion ? 0.0 : math.sin(time * 2.0) * 0.035;

    canvas.save();
    canvas.translate(towelX + towelW / 2, towelY + towelH / 2);
    canvas.rotate(towelTilt);
    final RRect towelRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset.zero,
        width: towelW,
        height: towelH,
      ),
      const Radius.circular(5),
    );
    canvas.drawRRect(towelRRect, _towelPaint);
    canvas.drawRRect(towelRRect, _towelBorderPaint);
    // Towel fold seam
    canvas.drawLine(
      Offset(-towelW * 0.45, towelH * 0.1),
      Offset(towelW * 0.45, towelH * 0.1),
      _towelBorderPaint,
    );
    canvas.restore();

    // 2. Rising Onsen Steam Wisps
    if (!reducedMotion && fillFraction > 0.05 && surfacePoints.isNotEmpty) {
      final double waterY = surfacePoints[32].dy;
      for (int s = 0; s < 4; s++) {
        final double steamX = w * (0.28 + s * 0.15);
        final double cycle = (time * 0.5 + s * 0.25) % 1.0;
        final double steamY = waterY - (cycle * (h * 0.28));
        final double steamAlpha =
            (math.sin(cycle * math.pi) * 0.45).clamp(0.0, 1.0);

        _steamPaint.color = Colors.white.withValues(alpha: steamAlpha);

        final Path steamPath = Path();
        steamPath.moveTo(steamX, steamY);
        steamPath.cubicTo(
          steamX + math.sin(time * 3 + s) * 8,
          steamY - 14,
          steamX - math.sin(time * 3 + s) * 8,
          steamY - 28,
          steamX + math.sin(time * 2 + s) * 4,
          steamY - 42,
        );
        canvas.drawPath(steamPath, _steamPaint);
      }
    }

    // 3. Zen Closed Smiling Eye and Snout Nostril
    final Path eyePath = Path();
    eyePath.moveTo(w * 0.17, h * 0.32);
    eyePath.quadraticBezierTo(w * 0.20, h * 0.30, w * 0.23, h * 0.32);
    canvas.drawPath(eyePath, _faceFeaturePaint);

    // Nostril
    canvas.drawCircle(
      Offset(w * 0.11, h * 0.33),
      1.8,
      _faceFeaturePaint..style = PaintingStyle.fill,
    );
    _faceFeaturePaint.style = PaintingStyle.stroke;
  }

  // =========================================================================
  // AXOLOTL BIOLUMINESCENT CENOTE ANIMATIONS
  // =========================================================================

  void _drawAxolotlInteriorSpores(Canvas canvas, Size size) {
    if (reducedMotion) return;

    final w = size.width;
    final h = size.height;

    for (int i = 0; i < 9; i++) {
      final double seed = i * 23.0;
      final double sporeCycle = (time * 0.25 + (i * 0.11)) % 1.0;
      final double x = w * (0.35 + (math.sin(seed + time) * 0.18));
      final double y = h * (0.90 - (sporeCycle * 0.60));
      final double radius = 2.0 + math.sin(seed) * 1.2;

      final double pulse =
          (0.4 + 0.6 * math.sin(time * 3.5 + i)).clamp(0.0, 1.0);
      final Color sporeColor = i % 2 == 0
          ? const Color(0xFF00E5FF)
          : const Color(0xFFFF4081);

      _sporePaint.color = sporeColor.withValues(alpha: pulse * 0.7);
      _sporePaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);
      canvas.drawCircle(Offset(x, y), radius * 1.5, _sporePaint);

      _sporePaint.color = Colors.white.withValues(alpha: pulse * 0.9);
      _sporePaint.maskFilter = null;
      canvas.drawCircle(Offset(x, y), radius * 0.7, _sporePaint);
    }
  }

  void _drawAxolotlExteriorDetails(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Glowing Feathery External Gills (3 Left Branches, 3 Right Branches)
    final leftGills = [
      (Offset(w * 0.25, h * 0.34), Offset(w * 0.08, h * 0.38)),
      (Offset(w * 0.26, h * 0.26), Offset(w * 0.05, h * 0.25)),
      (Offset(w * 0.29, h * 0.19), Offset(w * 0.12, h * 0.12)),
    ];

    final rightGills = [
      (Offset(w * 0.75, h * 0.34), Offset(w * 0.92, h * 0.38)),
      (Offset(w * 0.74, h * 0.26), Offset(w * 0.95, h * 0.25)),
      (Offset(w * 0.71, h * 0.19), Offset(w * 0.88, h * 0.12)),
    ];

    final allGills = [...leftGills, ...rightGills];

    for (int g = 0; g < allGills.length; g++) {
      final (base, tip) = allGills[g];
      final double gillWave = reducedMotion
          ? 0.0
          : math.sin(time * 3.0 + g) * (2.0 + interactionPulse * 6.0);
      final Offset waveTip = Offset(tip.dx, tip.dy + gillWave);

      final double glowPhase =
          (0.5 + 0.5 * math.sin(time * 2.8 + g)).clamp(0.0, 1.0);
      final double totalGlow =
          (glowPhase * 0.6 + interactionPulse * 0.4).clamp(0.0, 1.0);
      final Color gillColor = g % 2 == 0
          ? const Color(0xFF00E5FF)
          : const Color(0xFFFF4081);

      // Outer luminous halo
      _gillGlowPaint.color = gillColor.withValues(alpha: totalGlow * 0.85);
      _gillGlowPaint.strokeWidth = 6.0 + (interactionPulse * 8.0);
      canvas.drawLine(base, waveTip, _gillGlowPaint);

      // Core filament
      _gillCorePaint.color = Colors.white.withValues(alpha: 0.9);
      canvas.drawLine(base, waveTip, _gillCorePaint);

      // Feathery fringe hairs along branch
      for (double f = 0.3; f <= 0.9; f += 0.2) {
        final double px = base.dx + (waveTip.dx - base.dx) * f;
        final double py = base.dy + (waveTip.dy - base.dy) * f;
        final double hairLen = 5.0 + math.sin(time * 4.0 + f * 10) * 2.0;

        canvas.drawLine(
          Offset(px, py),
          Offset(px, py - hairLen),
          _gillCorePaint..strokeWidth = 1.0,
        );
      }
    }

    // Cute Axolotl Eyes and Rosy Cheeks
    final Offset leftEye = Offset(w * 0.42, h * 0.22);
    final Offset rightEye = Offset(w * 0.58, h * 0.22);

    final Paint eyePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF1A1A2E);
    canvas.drawCircle(leftEye, w * 0.035, eyePaint);
    canvas.drawCircle(rightEye, w * 0.035, eyePaint);

    // Eye catchlights
    canvas.drawCircle(
      Offset(leftEye.dx - 1.5, leftEye.dy - 1.5),
      1.8,
      _bubblePaint,
    );
    canvas.drawCircle(
      Offset(rightEye.dx - 1.5, rightEye.dy - 1.5),
      1.8,
      _bubblePaint,
    );

    // Cheerful Smile
    final Path smilePath = Path();
    smilePath.moveTo(w * 0.46, h * 0.27);
    smilePath.quadraticBezierTo(w * 0.50, h * 0.295, w * 0.54, h * 0.27);
    canvas.drawPath(smilePath, _faceFeaturePaint..strokeWidth = 1.8);

    // Rosy Pink Blush
    final Paint blushPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0x66FF80AB);
    canvas.drawCircle(Offset(w * 0.36, h * 0.25), w * 0.03, blushPaint);
    canvas.drawCircle(Offset(w * 0.64, h * 0.25), w * 0.03, blushPaint);
  }

  // =========================================================================
  // RED PANDA CLOUD FOREST HIGHLAND ACCENTS
  // =========================================================================

  void _drawRedPandaExteriorDetails(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // White Inner Ear Tufts
    final Paint earTuftPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xCCFFFFFF);
    canvas.drawCircle(Offset(w * 0.29, h * 0.17), w * 0.045, earTuftPaint);
    canvas.drawCircle(Offset(w * 0.71, h * 0.17), w * 0.045, earTuftPaint);

    // Auburn Muzzle & Nose
    final Offset nosePos = Offset(w * 0.50, h * 0.25);
    canvas.drawCircle(
      nosePos,
      3.2,
      Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFF212121),
    );

    // Playful Whisker Lines
    final Path whiskerPath = Path();
    whiskerPath.moveTo(w * 0.44, h * 0.26);
    whiskerPath.lineTo(w * 0.34, h * 0.27);
    whiskerPath.moveTo(w * 0.56, h * 0.26);
    whiskerPath.lineTo(w * 0.66, h * 0.27);
    canvas.drawPath(whiskerPath, _faceFeaturePaint..strokeWidth = 1.2);
  }

  void _drawSpeciesExteriorDetails(
    Canvas canvas,
    Size size,
    List<Offset> surfacePoints,
  ) {
    switch (animalId) {
      case 'capybara':
        _drawCapybaraExteriorDetails(canvas, size, surfacePoints);
        break;
      case 'axolotl':
        _drawAxolotlExteriorDetails(canvas, size);
        break;
      case 'red_panda':
      default:
        _drawRedPandaExteriorDetails(canvas, size);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant AnimalFluidVesselPainter oldDelegate) {
    return oldDelegate.fillFraction != fillFraction ||
        oldDelegate.time != time ||
        oldDelegate.stratifiedLayers.length != stratifiedLayers.length ||
        oldDelegate.reducedMotion != reducedMotion ||
        oldDelegate.animalId != animalId ||
        oldDelegate.interactionPulse != interactionPulse;
  }
}
