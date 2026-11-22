import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/models/fluid_layer.dart';
import 'animal_silhouette_paths.dart';
import 'wave_column_solver.dart';

/// Hardware-accelerated CustomPainter rendering:
/// - Exotic animal vector silhouette clipping boundary
/// - 64-column coupled shallow-water sloshing wave surface
/// - Multi-beverage density-stratified colored layers
/// - Internal effervescent rising micro-bubbles
/// - Meniscus surface tension refraction highlights
/// - Glowing bioluminescent hydro-glass outline
class AnimalFluidVesselPainter extends CustomPainter {
  final String animalId;
  final double fillFraction; // 0.0 to 1.0
  final List<FluidLayer> stratifiedLayers;
  final WaveColumnSolver waveSolver;
  final double time;
  final bool reducedMotion;
  final Color accentColor;

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

  AnimalFluidVesselPainter({
    required this.animalId,
    required this.fillFraction,
    required this.stratifiedLayers,
    required this.waveSolver,
    required this.time,
    required this.accentColor,
    this.reducedMotion = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Path animalPath =
        AnimalSilhouettePaths.getSilhouettePath(animalId, size);

    // 1. Draw glowing hydro-glass silhouette outline and backdrop
    _glassGlowPaint.color = accentColor.withValues(alpha: 0.35);
    canvas.drawPath(animalPath, _glassGlowPaint);
    canvas.drawPath(animalPath, _emptyBackdropPaint);

    _glassOutlinePaint.color = accentColor.withValues(alpha: 0.75);
    canvas.drawPath(animalPath, _glassOutlinePaint);

    // If completely empty, skip fluid rendering
    if (fillFraction <= 0.001) return;

    // 2. Clip all fluid layers to the interior of the animal silhouette
    canvas.save();
    canvas.clipPath(animalPath);

    _drawStratifiedFluid(canvas, size);

    canvas.restore();
  }

  void _drawStratifiedFluid(Canvas canvas, Size size) {
    final double clampedFill = fillFraction.clamp(0.0, 1.0);
    final double totalFluidHeight = size.height * clampedFill;
    final double liquidBaseY = size.height;

    // Build the dynamic wave surface path along the top of the liquid
    final int numCols = waveSolver.columnCount;
    final double colWidth = size.width / (numCols - 1);

    // Pre-calculate top surface wave points across width
    final List<Offset> surfacePoints = [];
    for (int i = 0; i < numCols; i++) {
      final double x = i * colWidth;
      final double waveDelta = reducedMotion ? 0.0 : waveSolver.columns[i].height;
      final double y = size.height - totalFluidHeight + waveDelta;
      surfacePoints.add(Offset(x, y));
    }

    // Determine stratum height boundaries
    // Stratified layers are rendered from bottom to top (heaviest density first)
    double currentBaseY = liquidBaseY;

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
            // Smooth quadratic bezier interpolation between wave points
            final prev = surfacePoints[i - 1];
            final curr = surfacePoints[i];
            final midX = (prev.dx + curr.dx) / 2;
            final midY = (prev.dy + curr.dy) / 2;
            layerPath.quadraticBezierTo(prev.dx, prev.dy, midX, midY);
          }
        }
        layerPath.lineTo(size.width, surfacePoints.last.dy);
      } else {
        // Subsurface interfacial layer wave (gentle damped sway)
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

      // Draw stratum with rich gradient
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

      // Draw subtle internal effervescent bubbles inside this layer
      if (!reducedMotion) {
        _drawLayerBubbles(canvas, size, layerTopY, currentBaseY, l);
      }

      currentBaseY = layerTopY;
    }

    // 3. Draw specular meniscus highlight on the active top wave surface
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

  @override
  bool shouldRepaint(covariant AnimalFluidVesselPainter oldDelegate) {
    return oldDelegate.fillFraction != fillFraction ||
        oldDelegate.time != time ||
        oldDelegate.stratifiedLayers.length != stratifiedLayers.length ||
        oldDelegate.reducedMotion != reducedMotion;
  }
}
