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

  final Paint _meniscusGlowPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5.2
    ..color = const Color(0x38FFFFFF)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

  final Paint _meniscusHighlight = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.2
    ..strokeCap = StrokeCap.round
    ..color = const Color(0xEEFFFFFF);

  final Paint _interfacialMeniscusPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4
    ..color = const Color(0x66FFFFFF);

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

  // Pre-allocated Red Panda facial & anatomical feature paints
  final Paint _pandaWhiteFurPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0xEEFFFFFF);
  final Paint _pandaPinkEarPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0x55FF8A80);
  final Paint _pandaBlushPaint = Paint()..style = PaintingStyle.fill;
  final Paint _pandaTearStripePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..color = const Color(0xAA3E2723);
  final Paint _pandaEyeBasePaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0xFF2C1810);
  final Paint _pandaEyePupilPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0xFF150804);
  final Paint _pandaCatchlightPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.white;
  final Paint _pandaNosePaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0xFF1F1B18);
  final Paint _pandaTailRingPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  // Pre-allocated companion facial & anatomical feature paints
  final Paint _companionWhiteFurPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0xEEFFFFFF);
  final Paint _companionPinkAccentPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0x66FF8A80);
  final Paint _companionBlushPaint = Paint()..style = PaintingStyle.fill;
  final Paint _companionEyeBasePaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0xFF1A1A2E);
  final Paint _companionEyePupilPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0xFF000000);
  final Paint _companionDarkNosePaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0xFF1F1B18);
  final Paint _companionWoolAccentPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4
    ..strokeCap = StrokeCap.round
    ..color = const Color(0x44FFFFFF);

  // Pre-allocated Apex Exotic Companion anatomical paints
  final Paint _apexEyeBasePaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0xFF102027);
  final Paint _apexEyePupilPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.black;
  final Paint _apexDarkNosePaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0xFF212121);
  final Paint _apexSoftPinkPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0xFFFFAB91);
  final Paint _apexMuzzlePaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0xEEFFFFFF);
  final Paint _apexSonarPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final Paint _apexRosettePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

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

    // 1. Draw glowing hydro-glass silhouette glow aura
    final double dynamicGlowAlpha =
        0.35 + (interactionPulse * 0.45).clamp(0.0, 0.55);
    _glassGlowPaint.color = accentColor.withValues(alpha: dynamicGlowAlpha);
    canvas.drawPath(animalPath, _glassGlowPaint);

    // 2. Draw authentic species anatomical underlay (fur shading, chest bib, depth)
    _drawSpeciesAnatomicalUnderlay(canvas, size, animalPath);

    final List<Offset> surfacePoints = _computeSurfacePoints(size);

    // 3. Clip all fluid layers and interior species details to animal silhouette
    if (fillFraction > 0.001) {
      canvas.save();
      canvas.clipPath(animalPath);

      _drawStratifiedFluid(canvas, size, surfacePoints);

      // Interior species accents
      if (animalId == 'capybara') {
        _drawCapybaraInteriorYuzus(canvas, size, surfacePoints);
      } else if (animalId == 'axolotl') {
        _drawAxolotlInteriorSpores(canvas, size);
      } else if (animalId == 'sea_otter') {
        _drawSeaOtterInteriorKelp(canvas, size);
      } else if (animalId == 'blue_ringed_octopus') {
        _drawOctopusInteriorRings(canvas, size);
      }

      canvas.restore();
    }

    // 4. Draw crisp hydro-glass rim outline
    _glassOutlinePaint.color = accentColor.withValues(alpha: 0.85);
    canvas.drawPath(animalPath, _glassOutlinePaint);

    // 5. Draw exterior companion details & interactive overlays (steam, towels, pulsing gills, faces)
    _drawSpeciesExteriorDetails(canvas, size, surfacePoints);
  }

  void _drawSpeciesAnatomicalUnderlay(
    Canvas canvas,
    Size size,
    Path animalPath,
  ) {
    canvas.save();
    canvas.clipPath(animalPath);

    final double w = size.width;
    final double h = size.height;
    final Rect bounds = Rect.fromLTWH(0, 0, w, h);

    switch (animalId) {
      case 'red_panda':
        _drawRedPandaAnatomicalUnderlay(canvas, size, bounds);
        break;
      case 'capybara':
        _drawCapybaraAnatomicalUnderlay(canvas, size, bounds);
        break;
      case 'axolotl':
        _drawAxolotlAnatomicalUnderlay(canvas, size, bounds);
        break;
      case 'sea_otter':
        _drawSeaOtterAnatomicalUnderlay(canvas, size, bounds);
        break;
      default:
        _drawGenericCompanionUnderlay(canvas, size, bounds);
        break;
    }

    canvas.restore();
  }

  void _drawRedPandaAnatomicalUnderlay(Canvas canvas, Size size, Rect bounds) {
    final double w = size.width;
    final double h = size.height;

    // 1. Warm highland auburn fur body gradient
    final Paint furPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFE64A19), // Highland auburn red
          Color(0xFFD84315),
          Color(0xFFBF360C),
          Color(0xFF3E2723), // Dark espresso belly / limb base
        ],
        stops: [0.0, 0.35, 0.70, 1.0],
      ).createShader(bounds);
    canvas.drawRect(bounds, furPaint);

    // 2. Volumetric depth vignette
    final Paint depthPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.2),
        radius: 0.85,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.28),
        ],
      ).createShader(bounds);
    canvas.drawRect(bounds, depthPaint);

    // 3. Fluffy Cream-White Chest Bib
    final Path chestBib = Path()
      ..moveTo(w * 0.38, h * 0.36)
      ..cubicTo(w * 0.32, h * 0.44, w * 0.34, h * 0.60, w * 0.50, h * 0.68)
      ..cubicTo(w * 0.66, h * 0.60, w * 0.68, h * 0.44, w * 0.62, h * 0.36)
      ..close();
    final Paint bibPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFFF8E1),
          const Color(0xFFFFECB3).withValues(alpha: 0.85),
        ],
      ).createShader(chestBib.getBounds());
    canvas.drawPath(chestBib, bibPaint);

    // 4. Charcoal/Espresso Hind Limbs & Paws at bottom
    final Paint limbPaint = Paint()..color = const Color(0xFF211510);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.28, h * 0.90), width: w * 0.18, height: h * 0.12),
      limbPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.74, h * 0.90), width: w * 0.18, height: h * 0.12),
      limbPaint,
    );

    // 5. Plush Ringed Tail auburn/ochre underlay on left
    final Rect tailRect = Rect.fromLTWH(0, h * 0.36, w * 0.30, h * 0.52);
    final Paint tailBasePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color(0xFFBF360C),
          Color(0xFFD84315),
          Color(0xFFE64A19),
        ],
      ).createShader(tailRect);
    canvas.drawRect(tailRect, tailBasePaint);
  }

  void _drawCapybaraAnatomicalUnderlay(Canvas canvas, Size size, Rect bounds) {
    final double w = size.width;
    final double h = size.height;

    // 1. Warm earthy chestnut/caramel fur body gradient
    final Paint furPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF8D6E63), // Warm golden brown crown & back
          Color(0xFF6D4C41),
          Color(0xFF5D4037),
          Color(0xFF3E2723), // Deep earthy flank & paw base
        ],
        stops: [0.0, 0.30, 0.65, 1.0],
      ).createShader(bounds);
    canvas.drawRect(bounds, furPaint);

    // 2. Soft golden-buff throat & under-chin patch
    final Path throatPatch = Path()
      ..moveTo(w * 0.14, h * 0.38)
      ..cubicTo(w * 0.22, h * 0.40, w * 0.28, h * 0.48, w * 0.26, h * 0.62)
      ..cubicTo(w * 0.18, h * 0.64, w * 0.14, h * 0.52, w * 0.14, h * 0.38)
      ..close();
    final Paint throatPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFA1887F),
          const Color(0xFF8D6E63).withValues(alpha: 0.6),
        ],
      ).createShader(throatPatch.getBounds());
    canvas.drawPath(throatPatch, throatPaint);

    // 3. Grounded loaf paw shading at base
    final Paint pawPaint = Paint()..color = const Color(0xFF2E1C14);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.26, h * 0.94), width: w * 0.14, height: h * 0.06),
      pawPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.78, h * 0.94), width: w * 0.16, height: h * 0.06),
      pawPaint,
    );

    // 4. Ambient depth shadow along rump & underbelly
    final Paint shadowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.2, 0.4),
        radius: 0.9,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.25),
        ],
      ).createShader(bounds);
    canvas.drawRect(bounds, shadowPaint);
  }

  void _drawAxolotlAnatomicalUnderlay(Canvas canvas, Size size, Rect bounds) {
    final double w = size.width;
    final double h = size.height;

    // 1. Soft pearlescent rose aquatic body gradient
    final Paint bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFCE4EC), // Pearl white-pink head
          Color(0xFFF8BBD0), // Soft rose torso
          Color(0xFFF48FB1), // Vibrant axolotl pink tail
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(bounds);
    canvas.drawRect(bounds, bodyPaint);

    // 2. Soft translucent pale belly highlight
    final Rect bellyRect = Rect.fromCenter(
      center: Offset(w * 0.50, h * 0.55),
      width: w * 0.44,
      height: h * 0.45,
    );
    final Paint bellyPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.45),
          Colors.transparent,
        ],
      ).createShader(bellyRect);
    canvas.drawOval(bellyRect, bellyPaint);
  }

  void _drawSeaOtterAnatomicalUnderlay(Canvas canvas, Size size, Rect bounds) {
    final Paint furPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFD7CCC8), // Pale blonde face
          Color(0xFF6D4C41), // Rich brown chest
          Color(0xFF3E2723), // Deep sea-otter espresso body
        ],
        stops: [0.0, 0.30, 0.80],
      ).createShader(bounds);
    canvas.drawRect(bounds, furPaint);
  }

  void _drawGenericCompanionUnderlay(Canvas canvas, Size size, Rect bounds) {
    final Paint basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          accentColor.withValues(alpha: 0.40),
          accentColor.withValues(alpha: 0.22),
          const Color(0xFF1A1A2E).withValues(alpha: 0.60),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(bounds);
    canvas.drawRect(bounds, basePaint);

    final Paint depthPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.1),
        radius: 0.85,
        colors: [
          Colors.white.withValues(alpha: 0.12),
          Colors.transparent,
        ],
      ).createShader(bounds);
    canvas.drawRect(bounds, depthPaint);
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
    if (stratifiedLayers.isEmpty || surfacePoints.isEmpty) return;

    final double clampedFill = fillFraction.clamp(0.0, 1.0);
    final double totalFluidHeight = size.height * clampedFill;
    final int numLayers = stratifiedLayers.length;

    // 1. Calculate nominal top boundary heights for each stratum
    final List<double> nominalTops = List.filled(numLayers, 0.0);
    double currentBaseY = size.height;
    for (int l = 0; l < numLayers; l++) {
      final layer = stratifiedLayers[l];
      final double layerHeight = totalFluidHeight * layer.fractionOfTotal;
      nominalTops[l] = currentBaseY - layerHeight;
      currentBaseY = nominalTops[l];
    }

    // 2. Pre-generate continuous interfacial boundary vertices for all internal interfaces (l = 0 .. numLayers - 2)
    // Using identical vertex sample density ensuring 0.0px gap between layer l and layer l+1
    final List<List<Offset>> internalInterfaces = [];
    const int sampleSteps = 32;
    final double stepX = size.width / sampleSteps;

    for (int l = 0; l < numLayers - 1; l++) {
      final double nominalY = nominalTops[l];
      final List<Offset> points = [];
      for (int s = 0; s <= sampleSteps; s++) {
        final double x = s * stepX;
        double y = nominalY;
        if (!reducedMotion) {
          final double wave1 =
              math.sin((x / 36.0) + (time * 1.8) + (l * 1.3)) * 2.2;
          final double wave2 =
              math.cos((x / 68.0) - (time * 1.1) + l) * 1.2;
          final double edgeDamping = (x / 24.0).clamp(0.0, 1.0) *
              ((size.width - x) / 24.0).clamp(0.0, 1.0);
          y += (wave1 + wave2) * edgeDamping;
        }
        points.add(Offset(x, y));
      }
      internalInterfaces.add(points);
    }

    // 3. Draw each stratum with locked, gap-free polygonal boundaries
    for (int l = 0; l < numLayers; l++) {
      final layer = stratifiedLayers[l];
      final List<Offset> topPoints = (l == numLayers - 1)
          ? surfacePoints
          : internalInterfaces[l];

      final Path layerPath = Path();
      layerPath.moveTo(topPoints.first.dx, topPoints.first.dy);

      // Forward pass across top boundary
      for (int i = 1; i < topPoints.length; i++) {
        final prev = topPoints[i - 1];
        final curr = topPoints[i];
        final midX = (prev.dx + curr.dx) / 2;
        final midY = (prev.dy + curr.dy) / 2;
        layerPath.quadraticBezierTo(prev.dx, prev.dy, midX, midY);
      }
      layerPath.lineTo(topPoints.last.dx, topPoints.last.dy);

      // Reverse pass across bottom boundary (strictly locked to stratum below)
      if (l == 0) {
        layerPath.lineTo(size.width, size.height);
        layerPath.lineTo(0, size.height);
      } else {
        final bottomPoints = internalInterfaces[l - 1];
        layerPath.lineTo(bottomPoints.last.dx, bottomPoints.last.dy);
        for (int i = bottomPoints.length - 1; i > 0; i--) {
          final curr = bottomPoints[i];
          final prev = bottomPoints[i - 1];
          final midX = (curr.dx + prev.dx) / 2;
          final midY = (curr.dy + prev.dy) / 2;
          layerPath.quadraticBezierTo(curr.dx, curr.dy, midX, midY);
        }
        layerPath.lineTo(bottomPoints.first.dx, bottomPoints.first.dy);
      }

      layerPath.close();

      // Stratum gradient
      final double stratumTop = topPoints.map((p) => p.dy).reduce(math.min);
      final double stratumBottom = (l == 0)
          ? size.height
          : internalInterfaces[l - 1].map((p) => p.dy).reduce(math.max);

      final Paint stratumPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            layer.beverage.secondaryColor,
            layer.beverage.primaryColor,
          ],
        ).createShader(
          Rect.fromLTRB(0, stratumTop, size.width, stratumBottom),
        );

      canvas.drawPath(layerPath, stratumPaint);

      if (!reducedMotion) {
        _drawLayerBubbles(canvas, size, stratumTop, stratumBottom, l);
      }
    }

    // 4. Draw crisp specular interfacial meniscus separation lines
    if (!reducedMotion) {
      for (int l = 0; l < internalInterfaces.length; l++) {
        final ifacePoints = internalInterfaces[l];
        final Path meniscusPath = Path();
        meniscusPath.moveTo(ifacePoints.first.dx, ifacePoints.first.dy);
        for (int i = 1; i < ifacePoints.length; i++) {
          final prev = ifacePoints[i - 1];
          final curr = ifacePoints[i];
          final midX = (prev.dx + curr.dx) / 2;
          final midY = (prev.dy + curr.dy) / 2;
          meniscusPath.quadraticBezierTo(prev.dx, prev.dy, midX, midY);
        }
        meniscusPath.lineTo(ifacePoints.last.dx, ifacePoints.last.dy);
        canvas.drawPath(meniscusPath, _interfacialMeniscusPaint);
      }
    }

    // 5. Free surface specular meniscus highlight on top stratum (dual-pass glow + core)
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
      canvas.drawPath(meniscusPath, _meniscusGlowPaint);
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
    if (layerH < 12) return;

    final layer = stratifiedLayers[layerIndex];
    final isEffervescent = layer.beverage.id == 'sparkling_water' ||
        layer.beverage.id == 'electrolyte_drink' ||
        layer.beverage.id == 'kombucha';

    final int bubbleCount = isEffervescent ? 12 : 6;
    final double speedMultiplier = isEffervescent ? 0.70 : 0.35;

    for (int b = 0; b < bubbleCount; b++) {
      final double seed = (b * 19.0) + (layerIndex * 37.0);
      final double baseX = (size.width * 0.18) +
          (math.sin(seed * 1.3) * 0.5 + 0.5) * (size.width * 0.64);

      final double cycle = (time * speedMultiplier + (seed * 0.08)) % 1.0;
      final double y = bottomY - (cycle * layerH);

      // Organic horizontal sinusoidal wobble as bubbles ascend
      final double wobble = isEffervescent
          ? math.sin(y * 0.15 + (time * 5.0) + seed) * 2.8
          : math.sin(y * 0.08 + (time * 2.5) + seed) * 1.2;
      final double x = baseX + wobble;

      final double baseRadius = isEffervescent ? 1.0 : 1.5;
      final double radius = baseRadius + (math.cos(seed) * 0.5 + 0.5) * 2.0;

      canvas.drawCircle(Offset(x, y), radius, _bubblePaint);

      // Delicate specular highlight dot on larger bubbles
      if (radius > 2.2) {
        canvas.drawCircle(
          Offset(x - radius * 0.3, y - radius * 0.3),
          radius * 0.3,
          _meniscusHighlight,
        );
      }
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
    final double towelX = w * 0.30;
    final double towelY = h * 0.13;
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

    // 3. Small Rounded Ear Shading & Inner Fold
    final Path earFold = Path()
      ..moveTo(w * 0.32, h * 0.18)
      ..quadraticBezierTo(w * 0.35, h * 0.16, w * 0.38, h * 0.19);
    canvas.drawPath(earFold, _faceFeaturePaint..strokeWidth = 1.4);

    // 4. Characteristic Capybara Flat Snout & High-Contrast Nostrils
    final Offset snoutPos = Offset(w * 0.10, h * 0.31);
    canvas.drawCircle(
      Offset(snoutPos.dx, snoutPos.dy - 1.0),
      2.2,
      _companionDarkNosePaint,
    );
    canvas.drawCircle(
      Offset(snoutPos.dx + 4.0, snoutPos.dy - 1.0),
      2.2,
      _companionDarkNosePaint,
    );
    canvas.drawCircle(
      Offset(snoutPos.dx - 0.5, snoutPos.dy - 2.0),
      0.8,
      _companionWhiteFurPaint,
    );

    // Muzzle whisker dots
    final List<Offset> whiskerDots = [
      Offset(snoutPos.dx + 8.0, snoutPos.dy),
      Offset(snoutPos.dx + 12.0, snoutPos.dy - 3.0),
      Offset(snoutPos.dx + 12.0, snoutPos.dy + 3.0),
    ];
    for (final dot in whiskerDots) {
      canvas.drawCircle(dot, 1.0, _companionDarkNosePaint);
    }

    // Peaceful contented smile
    final Path smile = Path()
      ..moveTo(snoutPos.dx + 2.0, snoutPos.dy + 5.0)
      ..quadraticBezierTo(
        snoutPos.dx + 12.0,
        snoutPos.dy + 9.0,
        snoutPos.dx + 22.0,
        snoutPos.dy + 4.0,
      );
    canvas.drawPath(smile, _faceFeaturePaint..strokeWidth = 1.6);

    // 5. Zen Closed Eye with Eyelid Squint / Flutter & Catchlight
    final Offset eyePos = Offset(w * 0.22, h * 0.26);
    final double blinkCycle = (time * 0.5) % 4.0;
    final bool isEyesPeeking = !reducedMotion && blinkCycle > 3.7;

    if (isEyesPeeking) {
      // Peeking open slightly with zen pupil
      canvas.drawCircle(eyePos, 3.2, _companionEyeBasePaint);
      canvas.drawCircle(eyePos, 2.4, _companionEyePupilPaint);
      canvas.drawCircle(
        Offset(eyePos.dx - 0.8, eyePos.dy - 0.8),
        0.9,
        _companionWhiteFurPaint,
      );
    } else {
      // Blissful curved sleeping smile lash with corner lash
      final Path eyePath = Path();
      eyePath.moveTo(eyePos.dx - 6.0, eyePos.dy + 1.0);
      eyePath.quadraticBezierTo(
        eyePos.dx,
        eyePos.dy - 3.0,
        eyePos.dx + 6.0,
        eyePos.dy + 1.0,
      );
      canvas.drawPath(eyePath, _faceFeaturePaint..strokeWidth = 2.2);

      // Corner lash
      canvas.drawLine(
        Offset(eyePos.dx + 5.0, eyePos.dy),
        Offset(eyePos.dx + 8.0, eyePos.dy - 2.5),
        _faceFeaturePaint..strokeWidth = 1.4,
      );
    }

    // 6. Warm Onsen Rosy Cheek Blush
    final double blushAlpha =
        (0.35 + interactionPulse * 0.45).clamp(0.0, 0.80);
    _companionBlushPaint.color =
        const Color(0xFFFF8A80).withValues(alpha: blushAlpha);
    canvas.drawCircle(
      Offset(w * 0.23, h * 0.33),
      w * 0.040,
      _companionBlushPaint,
    );

    // 7. Relaxed Front Paw Contour
    final Path pawPath = Path()
      ..moveTo(w * 0.22, h * 0.58)
      ..quadraticBezierTo(w * 0.26, h * 0.62, w * 0.32, h * 0.60);
    canvas.drawPath(pawPath, _faceFeaturePaint..strokeWidth = 1.4);
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

    // 1. Glowing Feathery External Gills (3 Left Branches, 3 Right Branches)
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

    // 2. Cute Expressive Axolotl Eyes with Radial Gradient Iris & Involuntary Blinking
    final Offset leftEye = Offset(w * 0.42, h * 0.22);
    final Offset rightEye = Offset(w * 0.58, h * 0.22);
    final double eyeRadius = w * 0.035;

    final double blinkCycle = (time * 0.6) % 3.5;
    final bool isBlinking = !reducedMotion && blinkCycle < 0.20;

    if (isBlinking) {
      // Happy curved closed eyelids
      final Path leftLid = Path()
        ..moveTo(leftEye.dx - eyeRadius, leftEye.dy)
        ..quadraticBezierTo(
          leftEye.dx,
          leftEye.dy + eyeRadius * 0.8,
          leftEye.dx + eyeRadius,
          leftEye.dy,
        );
      canvas.drawPath(leftLid, _faceFeaturePaint..strokeWidth = 2.4);

      final Path rightLid = Path()
        ..moveTo(rightEye.dx - eyeRadius, rightEye.dy)
        ..quadraticBezierTo(
          rightEye.dx,
          rightEye.dy + eyeRadius * 0.8,
          rightEye.dx + eyeRadius,
          rightEye.dy,
        );
      canvas.drawPath(rightLid, _faceFeaturePaint..strokeWidth = 2.4);
    } else {
      for (final eyeCenter in [leftEye, rightEye]) {
        // Deep obsidian base
        canvas.drawCircle(eyeCenter, eyeRadius, _companionEyeBasePaint);

        // Bioluminescent pink/lavender radial iris gradient
        final Paint axoIrisPaint = Paint()
          ..shader = const RadialGradient(
            colors: [Color(0xFFFF80AB), Color(0xFFC2185B), Color(0xFF1A1A2E)],
            stops: [0.2, 0.6, 1.0],
          ).createShader(
            Rect.fromCircle(center: eyeCenter, radius: eyeRadius * 0.85),
          );
        canvas.drawCircle(eyeCenter, eyeRadius * 0.85, axoIrisPaint);

        // Core pupil
        canvas.drawCircle(eyeCenter, eyeRadius * 0.48, _companionEyePupilPaint);

        // Specular catchlights
        canvas.drawCircle(
          Offset(
            eyeCenter.dx - eyeRadius * 0.28,
            eyeCenter.dy - eyeRadius * 0.28,
          ),
          eyeRadius * 0.34,
          _companionWhiteFurPaint,
        );
        canvas.drawCircle(
          Offset(
            eyeCenter.dx + eyeRadius * 0.24,
            eyeCenter.dy + eyeRadius * 0.22,
          ),
          eyeRadius * 0.16,
          _companionWhiteFurPaint,
        );
      }
    }

    // 3. Wide Joyous Smile with Inner Tongue
    final Path smilePath = Path();
    smilePath.moveTo(w * 0.44, h * 0.275);
    smilePath.quadraticBezierTo(w * 0.50, h * 0.305, w * 0.56, h * 0.275);
    canvas.drawPath(smilePath, _faceFeaturePaint..strokeWidth = 2.0);

    // Inner pink tongue dot
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.292),
      2.0,
      _companionPinkAccentPaint,
    );

    // 4. Glowing Bioluminescent Rosy Cheeks
    final double blushAlpha =
        (0.45 + interactionPulse * 0.45).clamp(0.0, 0.90);
    _companionBlushPaint.color =
        const Color(0xFFFF4081).withValues(alpha: blushAlpha);
    canvas.drawCircle(
      Offset(w * 0.35, h * 0.255),
      w * 0.032,
      _companionBlushPaint,
    );
    canvas.drawCircle(
      Offset(w * 0.65, h * 0.255),
      w * 0.032,
      _companionBlushPaint,
    );
  }

  // =========================================================================
  // RED PANDA CLOUD FOREST HIGHLAND ACCENTS
  // =========================================================================

  void _drawRedPandaExteriorDetails(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Warm Pink Inner Ear Fill & Fluffy White Ear Tufts
    // Left Ear
    final Path leftEarInner = Path()
      ..moveTo(w * 0.28, h * 0.15)
      ..cubicTo(w * 0.26, h * 0.12, w * 0.25, h * 0.09, w * 0.27, h * 0.08)
      ..cubicTo(w * 0.30, h * 0.08, w * 0.34, h * 0.11, w * 0.36, h * 0.14)
      ..close();
    canvas.drawPath(leftEarInner, _pandaPinkEarPaint);

    // Right Ear
    final Path rightEarInner = Path()
      ..moveTo(w * 0.64, h * 0.14)
      ..cubicTo(w * 0.66, h * 0.11, w * 0.70, h * 0.08, w * 0.73, h * 0.08)
      ..cubicTo(w * 0.75, h * 0.09, w * 0.74, h * 0.12, w * 0.72, h * 0.15)
      ..close();
    canvas.drawPath(rightEarInner, _pandaPinkEarPaint);

    // Dense White Inner Ear Fur Tufts
    final Path leftEarTuft = Path()
      ..moveTo(w * 0.29, h * 0.16)
      ..lineTo(w * 0.31, h * 0.11)
      ..lineTo(w * 0.33, h * 0.14)
      ..lineTo(w * 0.35, h * 0.10)
      ..lineTo(w * 0.36, h * 0.15)
      ..close();
    canvas.drawPath(leftEarTuft, _pandaWhiteFurPaint);

    final Path rightEarTuft = Path()
      ..moveTo(w * 0.64, h * 0.15)
      ..lineTo(w * 0.65, h * 0.10)
      ..lineTo(w * 0.67, h * 0.14)
      ..lineTo(w * 0.69, h * 0.11)
      ..lineTo(w * 0.71, h * 0.16)
      ..close();
    canvas.drawPath(rightEarTuft, _pandaWhiteFurPaint);

    // 2. White Muzzle, Brow Spots & Cheek Ruffs
    // Pure White Muzzle Oval around Nose and Mouth
    final Rect muzzleRect = Rect.fromCenter(
      center: Offset(w * 0.50, h * 0.265),
      width: w * 0.17,
      height: h * 0.085,
    );
    canvas.drawOval(muzzleRect, _pandaWhiteFurPaint);

    // White Teardrop Eye Brow Accents (Above eyes)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.43, h * 0.17),
        width: w * 0.045,
        height: h * 0.024,
      ),
      _pandaWhiteFurPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.57, h * 0.17),
        width: w * 0.045,
        height: h * 0.024,
      ),
      _pandaWhiteFurPaint,
    );

    // White Cheek Fur Patches
    final Path leftCheekWhite = Path()
      ..moveTo(w * 0.36, h * 0.24)
      ..cubicTo(w * 0.28, h * 0.25, w * 0.24, h * 0.28, w * 0.26, h * 0.33)
      ..cubicTo(w * 0.30, h * 0.35, w * 0.36, h * 0.32, w * 0.38, h * 0.28)
      ..close();
    canvas.drawPath(leftCheekWhite, _pandaWhiteFurPaint);

    final Path rightCheekWhite = Path()
      ..moveTo(w * 0.64, h * 0.24)
      ..cubicTo(w * 0.72, h * 0.25, w * 0.76, h * 0.28, w * 0.74, h * 0.33)
      ..cubicTo(w * 0.70, h * 0.35, w * 0.64, h * 0.32, w * 0.62, h * 0.28)
      ..close();
    canvas.drawPath(rightCheekWhite, _pandaWhiteFurPaint);

    // Rosy Blush on White Cheeks (enhanced by interaction pulse)
    final double blushAlpha = (0.25 + interactionPulse * 0.45).clamp(0.0, 0.75);
    _pandaBlushPaint.color =
        const Color(0xFFFF8A80).withValues(alpha: blushAlpha);
    canvas.drawCircle(Offset(w * 0.33, h * 0.29), w * 0.032, _pandaBlushPaint);
    canvas.drawCircle(Offset(w * 0.67, h * 0.29), w * 0.032, _pandaBlushPaint);

    // 3. Red Panda Characteristic Dark Tear Stripes
    // Dark auburn/espresso vertical stripes from eyes down cheeks
    final Path leftTearStripe = Path()
      ..moveTo(w * 0.40, h * 0.22)
      ..quadraticBezierTo(w * 0.38, h * 0.26, w * 0.37, h * 0.30);
    canvas.drawPath(leftTearStripe, _pandaTearStripePaint..strokeWidth = 2.4);

    final Path rightTearStripe = Path()
      ..moveTo(w * 0.60, h * 0.22)
      ..quadraticBezierTo(w * 0.62, h * 0.26, w * 0.63, h * 0.30);
    canvas.drawPath(rightTearStripe, _pandaTearStripePaint..strokeWidth = 2.4);

    // 4. Expressive Hazel / Amber Eyes with Specular Catchlights & Blinking
    final Offset leftEyeCenter = Offset(w * 0.42, h * 0.215);
    final Offset rightEyeCenter = Offset(w * 0.58, h * 0.215);
    final double eyeRadius = w * 0.034;

    // Involuntary blinking cycle every ~3.5 seconds for 200ms
    final double blinkCycle = (time * 0.7) % 3.5;
    final bool isBlinking = !reducedMotion && blinkCycle < 0.20;

    if (isBlinking) {
      // Gentle curved smiling eyelids
      final Path leftLid = Path()
        ..moveTo(leftEyeCenter.dx - eyeRadius, leftEyeCenter.dy)
        ..quadraticBezierTo(
          leftEyeCenter.dx,
          leftEyeCenter.dy + eyeRadius * 0.8,
          leftEyeCenter.dx + eyeRadius,
          leftEyeCenter.dy,
        );
      canvas.drawPath(leftLid, _faceFeaturePaint..strokeWidth = 2.4);

      final Path rightLid = Path()
        ..moveTo(rightEyeCenter.dx - eyeRadius, rightEyeCenter.dy)
        ..quadraticBezierTo(
          rightEyeCenter.dx,
          rightEyeCenter.dy + eyeRadius * 0.8,
          rightEyeCenter.dx + eyeRadius,
          rightEyeCenter.dy,
        );
      canvas.drawPath(rightLid, _faceFeaturePaint..strokeWidth = 2.4);
    } else {
      for (final eyeCenter in [leftEyeCenter, rightEyeCenter]) {
        // Deep espresso eye base
        canvas.drawCircle(eyeCenter, eyeRadius, _pandaEyeBasePaint);

        // Luminous Hazel/Amber Iris Radial Gradient
        final Paint irisPaint = Paint()
          ..shader = const RadialGradient(
            colors: [
              Color(0xFFFFB74D),
              Color(0xFFD84315),
              Color(0xFF3E2723),
            ],
            stops: [0.2, 0.7, 1.0],
          ).createShader(
            Rect.fromCircle(center: eyeCenter, radius: eyeRadius * 0.85),
          );
        canvas.drawCircle(eyeCenter, eyeRadius * 0.85, irisPaint);

        // Dark obsidian pupil
        canvas.drawCircle(eyeCenter, eyeRadius * 0.48, _pandaEyePupilPaint);

        // Primary crisp catchlight
        canvas.drawCircle(
          Offset(
            eyeCenter.dx - eyeRadius * 0.28,
            eyeCenter.dy - eyeRadius * 0.28,
          ),
          eyeRadius * 0.32,
          _pandaCatchlightPaint,
        );

        // Secondary subtle specular gleam
        canvas.drawCircle(
          Offset(
            eyeCenter.dx + eyeRadius * 0.24,
            eyeCenter.dy + eyeRadius * 0.22,
          ),
          eyeRadius * 0.16,
          _pandaCatchlightPaint,
        );
      }
    }

    // 5. Button Nose & Gentle Smile
    final Offset noseCenter = Offset(w * 0.50, h * 0.252);
    // Dark brown/black nose with rounded triangular contour
    final Path nosePath = Path()
      ..moveTo(noseCenter.dx - w * 0.022, noseCenter.dy - h * 0.008)
      ..quadraticBezierTo(
        noseCenter.dx,
        noseCenter.dy - h * 0.012,
        noseCenter.dx + w * 0.022,
        noseCenter.dy - h * 0.008,
      )
      ..quadraticBezierTo(
        noseCenter.dx + w * 0.018,
        noseCenter.dy + h * 0.009,
        noseCenter.dx,
        noseCenter.dy + h * 0.012,
      )
      ..quadraticBezierTo(
        noseCenter.dx - w * 0.018,
        noseCenter.dy + h * 0.009,
        noseCenter.dx - w * 0.022,
        noseCenter.dy - h * 0.008,
      )
      ..close();
    canvas.drawPath(nosePath, _pandaNosePaint);

    // High-contrast specular highlight on nose bridge (visible on all backgrounds!)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(noseCenter.dx - 1.2, noseCenter.dy - 2.0),
        width: 3.5,
        height: 2.0,
      ),
      _pandaCatchlightPaint,
    );

    // Cheerful philtrum and mouth
    final Path mouthPath = Path()
      ..moveTo(noseCenter.dx, noseCenter.dy + h * 0.012)
      ..lineTo(noseCenter.dx, noseCenter.dy + h * 0.022)
      ..moveTo(noseCenter.dx - w * 0.035, noseCenter.dy + h * 0.025)
      ..quadraticBezierTo(
        noseCenter.dx - w * 0.018,
        noseCenter.dy + h * 0.032,
        noseCenter.dx,
        noseCenter.dy + h * 0.022,
      )
      ..quadraticBezierTo(
        noseCenter.dx + w * 0.018,
        noseCenter.dy + h * 0.032,
        noseCenter.dx + w * 0.035,
        noseCenter.dy + h * 0.025,
      );
    canvas.drawPath(mouthPath, _faceFeaturePaint..strokeWidth = 1.6);

    // Whiskers
    final Path whiskers = Path()
      ..moveTo(w * 0.39, h * 0.265)
      ..lineTo(w * 0.28, h * 0.260)
      ..moveTo(w * 0.39, h * 0.280)
      ..lineTo(w * 0.29, h * 0.295)
      ..moveTo(w * 0.61, h * 0.265)
      ..lineTo(w * 0.72, h * 0.260)
      ..moveTo(w * 0.61, h * 0.280)
      ..lineTo(w * 0.71, h * 0.295);
    canvas.drawPath(whiskers, _faceFeaturePaint..strokeWidth = 1.0);

    // 6. Signature Red Panda Tail Rings!
    // Alternating cream and golden bands across the curved bushy tail on left
    final List<(Offset, Offset)> tailRingSpans = [
      (Offset(w * 0.08, h * 0.44), Offset(w * 0.17, h * 0.46)),
      (Offset(w * 0.05, h * 0.52), Offset(w * 0.18, h * 0.55)),
      (Offset(w * 0.04, h * 0.61), Offset(w * 0.19, h * 0.64)),
      (Offset(w * 0.06, h * 0.70), Offset(w * 0.20, h * 0.73)),
    ];

    for (int r = 0; r < tailRingSpans.length; r++) {
      final (p1, p2) = tailRingSpans[r];
      final Path ringPath = Path()
        ..moveTo(p1.dx, p1.dy)
        ..quadraticBezierTo(
          (p1.dx + p2.dx) / 2 + 3.0,
          (p1.dy + p2.dy) / 2 - 3.0,
          p2.dx,
          p2.dy,
        );

      final Color ringColor = (r % 2 == 0)
          ? const Color(0x66FFE082) // Warm cream band
          : const Color(0x44FFFFFF); // Specular white band
      _pandaTailRingPaint
        ..color = ringColor
        ..strokeWidth = 3.6;
      canvas.drawPath(ringPath, _pandaTailRingPaint);
    }

    // 7. Chest Fur Collar Accent
    final Path chestFur = Path()
      ..moveTo(w * 0.40, h * 0.38)
      ..quadraticBezierTo(w * 0.50, h * 0.43, w * 0.60, h * 0.38);
    _pandaTailRingPaint
      ..color = const Color(0x44FFFFFF)
      ..strokeWidth = 1.8;
    canvas.drawPath(chestFur, _pandaTailRingPaint);
  }

  // =========================================================================
  // SEA OTTER KELP LAGOON & PEARL SHELL ACCENTS
  // =========================================================================

  void _drawSeaOtterInteriorKelp(Canvas canvas, Size size) {
    if (reducedMotion) return;
    final w = size.width;
    final h = size.height;

    final kelpPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..color = const Color(0x882E7D32);

    final kelpColumns = [w * 0.30, w * 0.50, w * 0.70];
    for (int k = 0; k < kelpColumns.length; k++) {
      final double baseX = kelpColumns[k];
      final Path kelpPath = Path();
      kelpPath.moveTo(baseX, h * 0.95);

      for (double y = h * 0.95; y >= h * 0.35; y -= 20.0) {
        final double sway = math.sin(time * 2.5 + (y * 0.03) + k) *
            (4.0 + interactionPulse * 6.0);
        kelpPath.lineTo(baseX + sway, y);
      }
      canvas.drawPath(kelpPath, kelpPaint);
    }
  }

  void _drawSeaOtterExteriorDetails(
    Canvas canvas,
    Size size,
    List<Offset> surfacePoints,
  ) {
    final w = size.width;
    final h = size.height;

    // 1. Iridescent Scallop Pearl Shell on Tummy
    final double shellX = w * 0.50;
    final double shellY = h * 0.58;
    final double shellTilt =
        reducedMotion ? 0.0 : math.sin(time * 2.5) * 0.08;

    canvas.save();
    canvas.translate(shellX, shellY);
    canvas.rotate(shellTilt);

    final Paint shellPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFF9C4), Color(0xFFFFD54F), Color(0xFFFFB300)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: w * 0.08));

    final Path shellPath = Path();
    shellPath.moveTo(-w * 0.07, 0);
    shellPath.quadraticBezierTo(0, -w * 0.06, w * 0.07, 0);
    shellPath.quadraticBezierTo(w * 0.05, w * 0.07, 0, w * 0.08);
    shellPath.quadraticBezierTo(-w * 0.05, w * 0.07, -w * 0.07, 0);
    canvas.drawPath(shellPath, shellPaint);

    // Glowing Pearl in center of shell
    final Paint pearlPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFFFFFFF);
    final Paint pearlGlow = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0x8800E5FF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawCircle(Offset.zero, w * 0.025, pearlGlow);
    canvas.drawCircle(Offset.zero, w * 0.018, pearlPaint);

    canvas.restore();

    // 2. Rounded Front Paws Clutching the Shell
    final Path leftPaw = Path()
      ..moveTo(w * 0.38, h * 0.56)
      ..quadraticBezierTo(w * 0.42, h * 0.58, w * 0.44, h * 0.55);
    canvas.drawPath(leftPaw, _faceFeaturePaint..strokeWidth = 2.0);

    final Path rightPaw = Path()
      ..moveTo(w * 0.62, h * 0.56)
      ..quadraticBezierTo(w * 0.58, h * 0.58, w * 0.56, h * 0.55);
    canvas.drawPath(rightPaw, _faceFeaturePaint..strokeWidth = 2.0);

    // 3. Blonde / Cream Face & Muzzle Patch
    final Rect muzzleRect = Rect.fromCenter(
      center: Offset(w * 0.50, h * 0.25),
      width: w * 0.22,
      height: h * 0.09,
    );
    canvas.drawOval(muzzleRect, _companionWhiteFurPaint);

    // 4. Little Rounded Ears with Inner Shading
    canvas.drawCircle(
      Offset(w * 0.28, h * 0.19),
      w * 0.03,
      _companionWhiteFurPaint,
    );
    canvas.drawCircle(
      Offset(w * 0.28, h * 0.19),
      w * 0.018,
      _companionPinkAccentPaint,
    );
    canvas.drawCircle(
      Offset(w * 0.72, h * 0.19),
      w * 0.03,
      _companionWhiteFurPaint,
    );
    canvas.drawCircle(
      Offset(w * 0.72, h * 0.19),
      w * 0.018,
      _companionPinkAccentPaint,
    );

    // 5. Expressive Dark Otter Eyes with Specular Catchlights & Blinking
    final Offset leftEye = Offset(w * 0.43, h * 0.21);
    final Offset rightEye = Offset(w * 0.57, h * 0.21);
    final double eyeRadius = w * 0.030;

    final double blinkCycle = (time * 0.65) % 3.8;
    final bool isBlinking = !reducedMotion && blinkCycle < 0.20;

    if (isBlinking) {
      final Path leftLid = Path()
        ..moveTo(leftEye.dx - eyeRadius, leftEye.dy)
        ..quadraticBezierTo(
          leftEye.dx,
          leftEye.dy + eyeRadius * 0.7,
          leftEye.dx + eyeRadius,
          leftEye.dy,
        );
      canvas.drawPath(leftLid, _faceFeaturePaint..strokeWidth = 2.2);

      final Path rightLid = Path()
        ..moveTo(rightEye.dx - eyeRadius, rightEye.dy)
        ..quadraticBezierTo(
          rightEye.dx,
          rightEye.dy + eyeRadius * 0.7,
          rightEye.dx + eyeRadius,
          rightEye.dy,
        );
      canvas.drawPath(rightLid, _faceFeaturePaint..strokeWidth = 2.2);
    } else {
      for (final eyeCenter in [leftEye, rightEye]) {
        canvas.drawCircle(eyeCenter, eyeRadius, _companionEyeBasePaint);
        // Rich chocolate iris
        final Paint otterIrisPaint = Paint()
          ..shader = const RadialGradient(
            colors: [Color(0xFF8D6E63), Color(0xFF3E2723), Color(0xFF1B0000)],
            stops: [0.2, 0.7, 1.0],
          ).createShader(
            Rect.fromCircle(center: eyeCenter, radius: eyeRadius * 0.85),
          );
        canvas.drawCircle(eyeCenter, eyeRadius * 0.85, otterIrisPaint);
        canvas.drawCircle(eyeCenter, eyeRadius * 0.48, _companionEyePupilPaint);
        canvas.drawCircle(
          Offset(
            eyeCenter.dx - eyeRadius * 0.28,
            eyeCenter.dy - eyeRadius * 0.28,
          ),
          eyeRadius * 0.32,
          _companionWhiteFurPaint,
        );
      }
    }

    // 6. Broad Button Nose, Cheerful Mouth & Whisker Pads
    final Offset nosePos = Offset(w * 0.50, h * 0.245);
    final Path nosePath = Path()
      ..moveTo(nosePos.dx - 4.5, nosePos.dy - 2.0)
      ..quadraticBezierTo(
        nosePos.dx,
        nosePos.dy - 3.5,
        nosePos.dx + 4.5,
        nosePos.dy - 2.0,
      )
      ..quadraticBezierTo(
        nosePos.dx,
        nosePos.dy + 3.5,
        nosePos.dx - 4.5,
        nosePos.dy - 2.0,
      )
      ..close();
    canvas.drawPath(nosePath, _companionDarkNosePaint);
    canvas.drawCircle(
      Offset(nosePos.dx - 1.0, nosePos.dy - 1.2),
      0.9,
      _companionWhiteFurPaint,
    );

    // Mouth
    final Path mouth = Path()
      ..moveTo(nosePos.dx - 7.0, nosePos.dy + 4.5)
      ..quadraticBezierTo(
        nosePos.dx,
        nosePos.dy + 8.0,
        nosePos.dx + 7.0,
        nosePos.dy + 4.5,
      );
    canvas.drawPath(mouth, _faceFeaturePaint..strokeWidth = 1.6);

    // 6 White Whiskers
    final whiskerSpans = [
      (Offset(w * 0.44, h * 0.245), Offset(w * 0.33, h * 0.235)),
      (Offset(w * 0.44, h * 0.255), Offset(w * 0.32, h * 0.260)),
      (Offset(w * 0.44, h * 0.265), Offset(w * 0.34, h * 0.285)),
      (Offset(w * 0.56, h * 0.245), Offset(w * 0.67, h * 0.235)),
      (Offset(w * 0.56, h * 0.255), Offset(w * 0.68, h * 0.260)),
      (Offset(w * 0.56, h * 0.265), Offset(w * 0.66, h * 0.285)),
    ];
    for (final (start, end) in whiskerSpans) {
      canvas.drawLine(start, end, _faceFeaturePaint..strokeWidth = 1.0);
    }
  }

  // =========================================================================
  // ANDEAN LLAMA WOVEN COLLAR ACCENTS
  // =========================================================================

  void _drawLlamaExteriorDetails(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Andean Aztec Geometric Collar
    final double collarTopY = h * 0.30;
    final double collarH = h * 0.045;
    final Rect collarRect =
        Rect.fromLTRB(w * 0.28, collarTopY, w * 0.52, collarTopY + collarH);

    final Paint collarPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF5252), Color(0xFFFFD54F), Color(0xFF00E5FF)],
      ).createShader(collarRect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(collarRect, const Radius.circular(4)),
      collarPaint,
    );

    // Dangling Colorful Wool Pompoms / Tassels
    final tasselColors = [
      const Color(0xFFFF5252),
      const Color(0xFFFFD54F),
      const Color(0xFF00E5FF),
      const Color(0xFF69F0AE),
    ];
    for (int t = 0; t < 4; t++) {
      final double tx = w * (0.31 + t * 0.06);
      final double sway = reducedMotion
          ? 0.0
          : math.sin(time * 3.0 + t) * (2.5 + interactionPulse * 4.0);
      final double ty = collarTopY + collarH + 10.0;

      canvas.drawLine(
        Offset(tx, collarTopY + collarH),
        Offset(tx + sway, ty),
        _faceFeaturePaint..strokeWidth = 1.2,
      );
      canvas.drawCircle(
        Offset(tx + sway, ty),
        3.2,
        Paint()
          ..style = PaintingStyle.fill
          ..color = tasselColors[t],
      );
    }

    // 2. Soft White Muzzle Patch & Snout
    final Rect llamaMuzzle = Rect.fromCenter(
      center: Offset(w * 0.32, h * 0.12),
      width: w * 0.12,
      height: h * 0.065,
    );
    canvas.drawOval(llamaMuzzle, _companionWhiteFurPaint);

    // Dark nostrils & smile
    canvas.drawCircle(
      Offset(w * 0.29, h * 0.11),
      1.5,
      _companionDarkNosePaint,
    );
    final Path llamaSmile = Path()
      ..moveTo(w * 0.29, h * 0.13)
      ..quadraticBezierTo(w * 0.32, h * 0.145, w * 0.35, h * 0.13);
    canvas.drawPath(llamaSmile, _faceFeaturePaint..strokeWidth = 1.4);

    // 3. Cute Llama Eye with Long Curled Eyelashes & Blinking
    final Offset eye = Offset(w * 0.34, h * 0.10);
    final double eyeRadius = w * 0.024;

    final double blinkCycle = (time * 0.55) % 4.0;
    final bool isBlinking = !reducedMotion && blinkCycle < 0.20;

    if (isBlinking) {
      final Path lid = Path()
        ..moveTo(eye.dx - eyeRadius, eye.dy)
        ..quadraticBezierTo(
          eye.dx,
          eye.dy + eyeRadius * 0.8,
          eye.dx + eyeRadius,
          eye.dy,
        );
      canvas.drawPath(lid, _faceFeaturePaint..strokeWidth = 2.0);
    } else {
      canvas.drawCircle(eye, eyeRadius, _companionEyeBasePaint);
      final Paint llamaIrisPaint = Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFFB74D), Color(0xFF6D4C41), Color(0xFF1B0000)],
          stops: [0.2, 0.7, 1.0],
        ).createShader(
          Rect.fromCircle(center: eye, radius: eyeRadius * 0.85),
        );
      canvas.drawCircle(eye, eyeRadius * 0.85, llamaIrisPaint);
      canvas.drawCircle(eye, eyeRadius * 0.45, _companionEyePupilPaint);
      canvas.drawCircle(
        Offset(
          eye.dx - eyeRadius * 0.28,
          eye.dy - eyeRadius * 0.28,
        ),
        eyeRadius * 0.32,
        _companionWhiteFurPaint,
      );

      // Long curled eyelashes
      canvas.drawLine(
        Offset(eye.dx - 1, eye.dy - eyeRadius),
        Offset(eye.dx - 4, eye.dy - eyeRadius - 3),
        _faceFeaturePaint..strokeWidth = 1.2,
      );
      canvas.drawLine(
        Offset(eye.dx + 2, eye.dy - eyeRadius),
        Offset(eye.dx + 3, eye.dy - eyeRadius - 4),
        _faceFeaturePaint..strokeWidth = 1.2,
      );
    }

    // 4. Pink Inner Ear Linings
    final Path leftEarInner = Path()
      ..moveTo(w * 0.40, h * 0.06)
      ..quadraticBezierTo(w * 0.42, h * 0.03, w * 0.44, h * 0.06);
    canvas.drawPath(leftEarInner, _companionPinkAccentPaint);

    final Path rightEarInner = Path()
      ..moveTo(w * 0.49, h * 0.06)
      ..quadraticBezierTo(w * 0.51, h * 0.03, w * 0.53, h * 0.06);
    canvas.drawPath(rightEarInner, _companionPinkAccentPaint);

    // 5. Woolly Texture Scallop Curls along Back & Rump
    final List<Offset> woolAccents = [
      Offset(w * 0.56, h * 0.24),
      Offset(w * 0.55, h * 0.34),
      Offset(w * 0.68, h * 0.45),
      Offset(w * 0.78, h * 0.52),
    ];
    for (final pos in woolAccents) {
      final Path woolCurl = Path()
        ..moveTo(pos.dx - 4.0, pos.dy)
        ..quadraticBezierTo(pos.dx, pos.dy - 3.5, pos.dx + 4.0, pos.dy);
      canvas.drawPath(woolCurl, _companionWoolAccentPaint);
    }
  }

  // =========================================================================
  // BLUE-RINGED OCTOPUS BIOLUMINESCENT RINGS
  // =========================================================================

  void _drawOctopusInteriorRings(Canvas canvas, Size size) {
    _drawOctopusRingNetwork(canvas, size, isInterior: true);
  }

  void _drawOctopusExteriorDetails(Canvas canvas, Size size) {
    _drawOctopusRingNetwork(canvas, size, isInterior: false);

    final w = size.width;
    final h = size.height;

    final Offset leftEye = Offset(w * 0.38, h * 0.36);
    final Offset rightEye = Offset(w * 0.62, h * 0.36);
    final double eyeWidth = w * 0.048;
    final double eyeHeight = h * 0.024;

    // Involuntary cephalopod blink / squint clock (~4.2s cycle, 220ms blink)
    final double blinkCycle = (time * 0.50) % 4.2;
    final bool isBlinking = !reducedMotion && blinkCycle < 0.22;

    if (isBlinking) {
      for (final eyeCenter in [leftEye, rightEye]) {
        final Path lid = Path()
          ..moveTo(eyeCenter.dx - eyeWidth * 0.6, eyeCenter.dy)
          ..quadraticBezierTo(
            eyeCenter.dx,
            eyeCenter.dy + eyeHeight * 0.5,
            eyeCenter.dx + eyeWidth * 0.6,
            eyeCenter.dy,
          );
        canvas.drawPath(lid, _faceFeaturePaint..strokeWidth = 2.0);
      }
    } else {
      for (final eyeCenter in [leftEye, rightEye]) {
        // Golden cephalopod iris oval
        final Rect eyeRect = Rect.fromCenter(
          center: eyeCenter,
          width: eyeWidth,
          height: eyeHeight,
        );
        final Paint eyePaint = Paint()
          ..style = PaintingStyle.fill
          ..color = const Color(0xFFFFD54F);
        canvas.drawOval(eyeRect, eyePaint);

        // Thin dark outer rim
        canvas.drawOval(
          eyeRect,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0
            ..color = const Color(0xFF5D4037),
        );

        // Horizontal slit pupil (characteristic cephalopod slit shape)
        canvas.drawLine(
          Offset(eyeCenter.dx - eyeWidth * 0.38, eyeCenter.dy),
          Offset(eyeCenter.dx + eyeWidth * 0.38, eyeCenter.dy),
          _apexEyePupilPaint
            ..strokeWidth = 2.0
            ..style = PaintingStyle.stroke,
        );

        // Bioluminescent brow dot pulsing with interactionPulse
        final double browAlpha = (0.5 + interactionPulse * 0.5).clamp(0.0, 1.0);
        canvas.drawCircle(
          Offset(eyeCenter.dx, eyeCenter.dy - eyeHeight * 0.8),
          1.2,
          Paint()
            ..style = PaintingStyle.fill
            ..color = const Color(0xFF18FFFF).withValues(alpha: browAlpha),
        );
      }
    }
  }

  void _drawOctopusRingNetwork(
    Canvas canvas,
    Size size, {
    required bool isInterior,
  }) {
    final w = size.width;
    final h = size.height;

    final ringCenters = [
      Offset(w * 0.40, h * 0.18),
      Offset(w * 0.60, h * 0.18),
      Offset(w * 0.50, h * 0.28),
      Offset(w * 0.28, h * 0.45),
      Offset(w * 0.72, h * 0.45),
      Offset(w * 0.18, h * 0.68),
      Offset(w * 0.82, h * 0.68),
      Offset(w * 0.36, h * 0.78),
      Offset(w * 0.64, h * 0.78),
      Offset(w * 0.50, h * 0.86),
    ];

    for (int r = 0; r < ringCenters.length; r++) {
      if (isInterior && r < 4) continue;
      if (!isInterior && r >= 4) continue;

      final center = ringCenters[r];
      final double pulse = reducedMotion
          ? 0.7
          : (0.4 + 0.6 * math.sin(time * 3.5 + r))
              .clamp(0.0, 1.0);
      final double totalPulse =
          (pulse * 0.6 + interactionPulse * 0.4).clamp(0.0, 1.0);
      final double radius =
          (w * 0.032) * (1.0 + interactionPulse * 0.5);

      final Paint ringGlow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0 + interactionPulse * 5.0
        ..color = const Color(0xFF00E5FF).withValues(alpha: totalPulse * 0.85)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

      final Paint ringCore = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = const Color(0xFF18FFFF).withValues(alpha: totalPulse * 0.95);

      final Paint centerDisc = Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFF0D47A1).withValues(alpha: 0.6);

      canvas.drawCircle(center, radius * 0.65, centerDisc);
      canvas.drawCircle(center, radius, ringGlow);
      canvas.drawCircle(center, radius, ringCore);
    }
  }

  // =========================================================================
  // BOTTLENOSE DOLPHIN SONAR, CATCHLIGHT EYE & ROSTRUM ACCENTS
  // =========================================================================

  void _drawDolphinExteriorDetails(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Expanding Acoustic Sonar Bubble Rings from Melon
    if (!reducedMotion) {
      final Offset melon = Offset(w * 0.52, h * 0.14);
      for (int s = 0; s < 3; s++) {
        final double cycle = (time * 0.8 + (s * 0.33)) % 1.0;
        final double ringRadius = 10.0 + (cycle * (w * 0.18));
        final double alpha =
            ((1.0 - cycle) * 0.6 + (interactionPulse * 0.4)).clamp(0.0, 1.0);

        _apexSonarPaint
          ..strokeWidth = 1.8
          ..color = const Color(0xFF80DEEA).withValues(alpha: alpha);

        canvas.drawArc(
          Rect.fromCircle(center: melon, radius: ringRadius),
          -math.pi * 0.65,
          math.pi * 0.75,
          false,
          _apexSonarPaint,
        );
      }
    }

    // 2. Playful Cetacean Eye with Involuntary Blinking (~3.9s cycle, 200ms blink)
    final Offset eye = Offset(w * 0.46, h * 0.20);
    final double blinkCycle = (time * 0.55) % 3.9;
    final bool isBlinking = !reducedMotion && blinkCycle < 0.20;

    if (isBlinking) {
      final Path lid = Path()
        ..moveTo(eye.dx - 4.0, eye.dy)
        ..quadraticBezierTo(eye.dx, eye.dy - 2.5, eye.dx + 4.0, eye.dy);
      canvas.drawPath(lid, _faceFeaturePaint..strokeWidth = 1.8);
    } else {
      // Oceanic sapphire outer base
      canvas.drawCircle(eye, 3.8, _apexEyeBasePaint);

      // Electric turquoise iris
      canvas.drawCircle(
        eye,
        2.8,
        Paint()
          ..style = PaintingStyle.fill
          ..color = const Color(0xFF00E5FF),
      );

      // Jet black pupil
      canvas.drawCircle(
        eye,
        1.8,
        _apexEyePupilPaint..style = PaintingStyle.fill,
      );

      // Dual sparkle catchlight gleams
      canvas.drawCircle(
        Offset(eye.dx - 1.0, eye.dy - 1.0),
        1.1,
        _companionWhiteFurPaint..color = const Color(0xEEFFFFFF),
      );
      canvas.drawCircle(
        Offset(eye.dx + 0.9, eye.dy + 0.7),
        0.5,
        _companionWhiteFurPaint..color = const Color(0xEEFFFFFF),
      );
    }

    // 3. Playful Rostrum Smile line
    final Path rostrumSmile = Path()
      ..moveTo(w * 0.38, h * 0.16)
      ..quadraticBezierTo(w * 0.44, h * 0.21, w * 0.50, h * 0.22);
    canvas.drawPath(rostrumSmile, _faceFeaturePaint..strokeWidth = 1.4);

    // 4. Blowhole highlight gleam
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.56, h * 0.11),
        width: 3.5,
        height: 1.8,
      ),
      _companionWhiteFurPaint..color = const Color(0x66FFFFFF),
    );
  }

  // =========================================================================
  // ARCTIC FOX AURORA VEIL, GLACIAL EYES & VELVET EAR TIPS
  // =========================================================================

  void _drawArcticFoxExteriorDetails(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Aurora Borealis Shimmer Veil across chest/flank
    if (!reducedMotion) {
      final double shimmerPhase = (time * 0.4) % 1.0;
      final Rect shimmerRect =
          Rect.fromLTRB(w * 0.24, h * 0.30, w * 0.62, h * 0.55);

      final Paint auroraPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0x3369F0AE),
            const Color(0x33B388FF),
            const Color(0x3300E5FF),
          ],
          stops: [
            (shimmerPhase * 0.5).clamp(0.0, 1.0),
            shimmerPhase,
            ((shimmerPhase + 0.5) % 1.0),
          ],
        ).createShader(shimmerRect);

      canvas.drawOval(shimmerRect, auroraPaint);
    }

    // 2. Velvety Black Ear Tips & Soft Pink Inner Accents
    canvas.drawCircle(Offset(w * 0.28, h * 0.05), 3.8, _apexDarkNosePaint);
    canvas.drawCircle(Offset(w * 0.48, h * 0.05), 3.8, _apexDarkNosePaint);
    canvas.drawCircle(Offset(w * 0.28, h * 0.08), 2.0, _apexSoftPinkPaint);
    canvas.drawCircle(Offset(w * 0.47, h * 0.08), 2.0, _apexSoftPinkPaint);

    // 3. Almond Glacial Ice-Blue Eye with Involuntary Blinking (~3.7s cycle, 200ms blink)
    final Offset eye = Offset(w * 0.25, h * 0.20);
    final double blinkCycle = (time * 0.60) % 3.7;
    final bool isBlinking = !reducedMotion && blinkCycle < 0.20;

    if (isBlinking) {
      final Path lid = Path()
        ..moveTo(eye.dx - 4.5, eye.dy)
        ..quadraticBezierTo(eye.dx, eye.dy + 2.5, eye.dx + 4.5, eye.dy);
      canvas.drawPath(lid, _faceFeaturePaint..strokeWidth = 1.8);
    } else {
      // Dark eyeliner frame
      canvas.drawOval(
        Rect.fromCenter(center: eye, width: 8.0, height: 6.0),
        _apexDarkNosePaint,
      );
      // Glacial cyan iris
      canvas.drawOval(
        Rect.fromCenter(center: eye, width: 6.5, height: 4.8),
        Paint()
          ..style = PaintingStyle.fill
          ..color = const Color(0xFF80D8FF),
      );
      // Black pupil
      canvas.drawCircle(eye, 1.8, _apexEyePupilPaint..style = PaintingStyle.fill);
      // Sparkling white catchlight
      canvas.drawCircle(
        Offset(eye.dx - 1.2, eye.dy - 1.0),
        1.1,
        _companionWhiteFurPaint..color = const Color(0xEEFFFFFF),
      );
    }

    // 4. Pure White Muzzle Mask & Button Nose
    final Offset snout = Offset(w * 0.12, h * 0.24);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(snout.dx + 4.0, snout.dy), width: 12.0, height: 7.0),
      _apexMuzzlePaint,
    );
    canvas.drawCircle(snout, 2.8, _apexDarkNosePaint);
    canvas.drawCircle(
      Offset(snout.dx - 0.7, snout.dy - 0.7),
      0.8,
      _companionWhiteFurPaint..color = const Color(0xEEFFFFFF),
    );

    // 5. Delicate Swept-Back Whiskers
    final whiskers = [
      (Offset(snout.dx + 3.0, snout.dy - 1.0), Offset(snout.dx + 13.0, snout.dy - 4.0)),
      (Offset(snout.dx + 3.0, snout.dy + 1.0), Offset(snout.dx + 14.0, snout.dy + 3.0)),
    ];
    for (final (start, end) in whiskers) {
      canvas.drawLine(start, end, _faceFeaturePaint..strokeWidth = 1.0);
    }

    // 6. Fluffy White Bushy Tail Tip Accent
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.88, h * 0.62), width: 14.0, height: 9.0),
      _companionWhiteFurPaint..color = const Color(0x44FFFFFF),
    );
  }

  // =========================================================================
  // EMPEROR PENGUIN GOLDEN AURICULAR PLUMAGE, TUXEDO BIB & MANDIBLE STRIPE
  // =========================================================================

  void _drawPenguinExteriorDetails(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Golden Auricular Neck Plumage Patches (Mandarin to Amber Gradient)
    final Paint plumagePaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF6F00), Color(0xFFFFD54F)],
      ).createShader(
        Rect.fromLTRB(w * 0.40, h * 0.12, w * 0.65, h * 0.26),
      );

    final Path plumagePath = Path()
      ..moveTo(w * 0.50, h * 0.13)
      ..quadraticBezierTo(w * 0.62, h * 0.16, w * 0.58, h * 0.25)
      ..quadraticBezierTo(w * 0.46, h * 0.20, w * 0.50, h * 0.13);
    canvas.drawPath(plumagePath, plumagePaint);

    // 2. Immaculate White Tuxedo Bib Contour
    final Path bibPath = Path()
      ..moveTo(w * 0.38, h * 0.22)
      ..quadraticBezierTo(w * 0.32, h * 0.38, w * 0.36, h * 0.55)
      ..quadraticBezierTo(w * 0.48, h * 0.52, w * 0.48, h * 0.30)
      ..close();
    canvas.drawPath(
      bibPath,
      _companionWhiteFurPaint..color = const Color(0x33FFFFFF),
    );

    // 3. Playful Penguin Eye with Involuntary Blinking (~4.1s cycle, 200ms blink)
    final Offset eye = Offset(w * 0.36, h * 0.16);
    final double blinkCycle = (time * 0.52) % 4.1;
    final bool isBlinking = !reducedMotion && blinkCycle < 0.20;

    if (isBlinking) {
      final Path lid = Path()
        ..moveTo(eye.dx - 3.5, eye.dy)
        ..quadraticBezierTo(eye.dx, eye.dy + 2.0, eye.dx + 3.5, eye.dy);
      canvas.drawPath(lid, _faceFeaturePaint..strokeWidth = 1.8);
    } else {
      // Dark base
      canvas.drawCircle(eye, 3.2, _apexEyeBasePaint);
      // Rich amber/ruby ring
      canvas.drawCircle(
        eye,
        2.4,
        Paint()
          ..style = PaintingStyle.fill
          ..color = const Color(0xFFFFB300),
      );
      // Black pupil
      canvas.drawCircle(eye, 1.4, _apexEyePupilPaint..style = PaintingStyle.fill);
      // Crisp catchlight
      canvas.drawCircle(
        Offset(eye.dx - 0.9, eye.dy - 0.8),
        0.8,
        _companionWhiteFurPaint..color = const Color(0xEEFFFFFF),
      );
    }

    // 4. Pointed Beak with Vivid Yellow/Pink Mandible Stripe
    final Path beakPath = Path()
      ..moveTo(w * 0.32, h * 0.17)
      ..lineTo(w * 0.16, h * 0.19)
      ..lineTo(w * 0.30, h * 0.21)
      ..close();
    canvas.drawPath(beakPath, _apexDarkNosePaint);

    // Mandible stripe
    canvas.drawLine(
      Offset(w * 0.31, h * 0.20),
      Offset(w * 0.18, h * 0.192),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFF80AB),
    );
    canvas.drawLine(
      Offset(w * 0.30, h * 0.20),
      Offset(w * 0.22, h * 0.195),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFFD54F),
    );

    // 5. Flipper Wing Contour Line
    final Path flipper = Path()
      ..moveTo(w * 0.58, h * 0.32)
      ..quadraticBezierTo(w * 0.72, h * 0.46, w * 0.68, h * 0.60);
    canvas.drawPath(
      flipper,
      _faceFeaturePaint
        ..strokeWidth = 1.5
        ..color = const Color(0x44FFFFFF),
    );
  }

  // =========================================================================
  // SNOW LEOPARD ALPINE ROSETTES, SAGE EYES & WHISKER PADS
  // =========================================================================

  void _drawSnowLeopardExteriorDetails(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Alpine Rosettes along Flank and Thick Tail
    _apexRosettePaint
      ..strokeWidth = 1.8
      ..color = const Color(0x77455A64);

    final rosettes = [
      Offset(w * 0.45, h * 0.42),
      Offset(w * 0.60, h * 0.45),
      Offset(w * 0.52, h * 0.58),
      Offset(w * 0.68, h * 0.60),
      Offset(w * 0.84, h * 0.74),
      Offset(w * 0.90, h * 0.62),
    ];
    for (final r in rosettes) {
      canvas.drawCircle(r, 4.2, _apexRosettePaint);
      canvas.drawCircle(r, 1.2, _apexDarkNosePaint);
    }

    // 2. Rounded Ears with Soft White Inner Tufts
    canvas.drawCircle(
      Offset(w * 0.25, h * 0.15),
      3.0,
      _companionWhiteFurPaint..color = const Color(0x88FFFFFF),
    );
    canvas.drawCircle(
      Offset(w * 0.45, h * 0.13),
      3.0,
      _companionWhiteFurPaint..color = const Color(0x88FFFFFF),
    );

    // 3. Piercing Sage-Green / Jade Eyes with Involuntary Blinking (~3.6s cycle, 200ms blink)
    final Offset leftEye = Offset(w * 0.26, h * 0.28);
    final Offset rightEye = Offset(w * 0.42, h * 0.26);
    final double blinkCycle = (time * 0.58) % 3.6;
    final bool isBlinking = !reducedMotion && blinkCycle < 0.20;

    if (isBlinking) {
      for (final eyeCenter in [leftEye, rightEye]) {
        final Path lid = Path()
          ..moveTo(eyeCenter.dx - 4.5, eyeCenter.dy)
          ..quadraticBezierTo(eyeCenter.dx, eyeCenter.dy + 2.5, eyeCenter.dx + 4.5, eyeCenter.dy);
        canvas.drawPath(lid, _faceFeaturePaint..strokeWidth = 1.8);
      }
    } else {
      for (final eyeCenter in [leftEye, rightEye]) {
        // Dark feline eyeliner border
        canvas.drawOval(
          Rect.fromCenter(center: eyeCenter, width: 8.5, height: 6.5),
          _apexDarkNosePaint,
        );

        // Piercing sage jade iris
        canvas.drawOval(
          Rect.fromCenter(center: eyeCenter, width: 7.0, height: 5.2),
          Paint()
            ..style = PaintingStyle.fill
            ..color = const Color(0xFF80CBC4),
        );

        // Slender vertical slit pupil
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: eyeCenter, width: 2.0, height: 4.6),
            const Radius.circular(1.0),
          ),
          _apexEyePupilPaint..style = PaintingStyle.fill,
        );

        // Crisp white gleam
        canvas.drawCircle(
          Offset(eyeCenter.dx - 1.2, eyeCenter.dy - 1.1),
          1.0,
          _companionWhiteFurPaint..color = const Color(0xEEFFFFFF),
        );
      }
    }

    // 4. White Whisker Pads & Soft Pink Inverted Triangle Nose
    final Offset nosePos = Offset(w * 0.20, h * 0.32);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(nosePos.dx + 3.0, nosePos.dy + 1.0),
        width: 14.0,
        height: 8.0,
      ),
      _apexMuzzlePaint,
    );

    // Inverted triangle pink nose
    final Path nose = Path()
      ..moveTo(nosePos.dx - 3.2, nosePos.dy - 2.0)
      ..lineTo(nosePos.dx + 3.2, nosePos.dy - 2.0)
      ..lineTo(nosePos.dx, nosePos.dy + 2.5)
      ..close();
    canvas.drawPath(nose, _apexSoftPinkPaint);

    // 5. Six Swept-Back Whiskers
    final whiskers = [
      (Offset(nosePos.dx + 2.0, nosePos.dy - 1.0), Offset(nosePos.dx + 14.0, nosePos.dy - 4.0)),
      (Offset(nosePos.dx + 2.0, nosePos.dy + 1.0), Offset(nosePos.dx + 15.0, nosePos.dy + 1.0)),
      (Offset(nosePos.dx + 2.0, nosePos.dy + 3.0), Offset(nosePos.dx + 13.0, nosePos.dy + 5.0)),
    ];
    for (final (start, end) in whiskers) {
      canvas.drawLine(start, end, _faceFeaturePaint..strokeWidth = 1.0);
    }
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
      case 'sea_otter':
        _drawSeaOtterExteriorDetails(canvas, size, surfacePoints);
        break;
      case 'andean_llama':
        _drawLlamaExteriorDetails(canvas, size);
        break;
      case 'blue_ringed_octopus':
        _drawOctopusExteriorDetails(canvas, size);
        break;
      case 'bottlenose_dolphin':
        _drawDolphinExteriorDetails(canvas, size);
        break;
      case 'arctic_fox':
        _drawArcticFoxExteriorDetails(canvas, size);
        break;
      case 'emperor_penguin':
        _drawPenguinExteriorDetails(canvas, size);
        break;
      case 'snow_leopard':
        _drawSnowLeopardExteriorDetails(canvas, size);
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
