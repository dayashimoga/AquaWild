import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../domain/models/animal_evolution_stage.dart';
import '../../../domain/models/beverage_type.dart';
import '../../../domain/models/exotic_animal.dart';
import '../../../domain/models/fluid_layer.dart';
import '../animal_fluid/animal_fluid_vessel_painter.dart';
import '../animal_fluid/wave_column_solver.dart';

/// Production-grade high-detail vector avatar renderer for exotic animal companions.
///
/// Features authentic vector silhouette geometry, species-specific facial details,
/// dynamic evolution stage aura (Hatchling, Explorer, Guardian, Mythic Spirit),
/// species emoji badge, and accessible semantics.
class CompanionAvatarRenderer extends StatefulWidget {
  final ExoticAnimal animal;
  final AnimalEvolutionStage? stage;
  final double size;
  final bool isUnlocked;
  final bool isSelected;
  final bool showAura;
  final bool showBadge;
  final double fillFraction;
  final double interactionPulse;
  final bool animate;

  const CompanionAvatarRenderer({
    super.key,
    required this.animal,
    this.stage,
    this.size = 52.0,
    this.isUnlocked = true,
    this.isSelected = false,
    this.showAura = true,
    this.showBadge = true,
    this.fillFraction = 0.70,
    this.interactionPulse = 0.0,
    this.animate = false,
  });

  @override
  State<CompanionAvatarRenderer> createState() =>
      _CompanionAvatarRendererState();
}

class _CompanionAvatarRendererState extends State<CompanionAvatarRenderer>
    with SingleTickerProviderStateMixin {
  AnimationController? _rotationController;

  static final WaveColumnSolver _staticWaveSolver =
      WaveColumnSolver(columnCount: 16);

  static const List<FluidLayer> _previewStratifiedLayers = [
    FluidLayer(
      beverage: BeverageType.pureWater,
      volumeMl: 500,
      fractionOfTotal: 0.65,
      relativeDensity: 1.0,
    ),
    FluidLayer(
      beverage: BeverageType.electrolyteDrink,
      volumeMl: 250,
      fractionOfTotal: 0.35,
      relativeDensity: 1.015,
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _rotationController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 14),
      )..repeat();
    }
  }

  @override
  void didUpdateWidget(covariant CompanionAvatarRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate && _rotationController == null) {
        _rotationController = AnimationController(
          vsync: this,
          duration: const Duration(seconds: 14),
        )..repeat();
      } else if (!widget.animate && _rotationController != null) {
        _rotationController?.dispose();
        _rotationController = null;
      }
    }
  }

  @override
  void dispose() {
    _rotationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final stageNumber = widget.stage?.stageNumber ?? 1;
    final accent = widget.animal.accentColor;
    final auraColor = widget.stage?.auraColor ?? accent;

    final double effectiveSize = widget.size;
    final double innerVesselSize = effectiveSize * 0.72;
    final double badgeSize = (effectiveSize * 0.38).clamp(18.0, 36.0);

    return Semantics(
      label: '${widget.animal.name}, ${widget.animal.scientificName}. '
          'Stage $stageNumber: ${widget.stage?.title ?? "Hatchling"}. '
          '${widget.isSelected ? "Active companion." : widget.isUnlocked ? "Unlocked." : "Locked, requires ${widget.animal.unlockXp} XP."}',
      child: SizedBox(
        width: effectiveSize + (widget.showAura ? 12 : 0),
        height: effectiveSize + (widget.showAura ? 12 : 0),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // 1. Dynamic Evolution Stage Aura
            if (widget.showAura && widget.isUnlocked)
              _buildEvolutionAura(
                stageNumber: stageNumber,
                auraColor: auraColor,
                accentColor: accent,
                size: effectiveSize,
                reducedMotion: reducedMotion,
              ),

            // 2. Avatar Container with Glassmorphic Border
            Container(
              width: effectiveSize,
              height: effectiveSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  center: Alignment(-0.2, -0.3),
                  radius: 0.9,
                  colors: [
                    Color(0xFF1B2C4B),
                    Color(0xFF0B172B),
                  ],
                ),
                border: Border.all(
                  color: widget.isSelected
                      ? const Color(0xFF00E5FF)
                      : (widget.isUnlocked
                          ? accent.withValues(alpha: 0.6)
                          : Colors.white24),
                  width: widget.isSelected ? 2.2 : 1.4,
                ),
                boxShadow: [
                  if (widget.isSelected)
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                      blurRadius: 12,
                      spreadRadius: 1,
                    )
                  else if (widget.isUnlocked)
                    BoxShadow(
                      color: accent.withValues(alpha: 0.25),
                      blurRadius: 8,
                    ),
                ],
              ),
              child: ClipOval(
                child: Center(
                  child: SizedBox(
                    width: innerVesselSize,
                    height: innerVesselSize,
                    child: CustomPaint(
                      size: Size(innerVesselSize, innerVesselSize),
                      painter: AnimalFluidVesselPainter(
                        animalId: widget.animal.id,
                        fillFraction: widget.fillFraction,
                        stratifiedLayers: _previewStratifiedLayers,
                        waveSolver: _staticWaveSolver,
                        time: 1.5,
                        accentColor: accent,
                        reducedMotion: true,
                        interactionPulse: widget.interactionPulse,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 3. Locked State Frosted Overlay
            if (!widget.isUnlocked)
              Container(
                width: effectiveSize,
                height: effectiveSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xAA08101E),
                  border: Border.all(color: Colors.white12, width: 1.0),
                ),
                child: const Center(
                  child: Icon(
                    Icons.lock_rounded,
                    color: Color(0xDDFFFFFF),
                    size: 20,
                  ),
                ),
              ),

            // 4. Species Emoji Badge Pill
            if (widget.showBadge)
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: badgeSize,
                  height: badgeSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0C192E),
                    border: Border.all(
                      color: widget.isSelected
                          ? const Color(0xFF00E5FF)
                          : accent.withValues(alpha: 0.8),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.animal.avatarEmoji,
                      style: TextStyle(
                        fontSize: (badgeSize * 0.55).clamp(10.0, 18.0),
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvolutionAura({
    required int stageNumber,
    required Color auraColor,
    required Color accentColor,
    required double size,
    required bool reducedMotion,
  }) {
    switch (stageNumber) {
      case 4:
        // Stage 4: Mythic Spirit — Cosmic celestial water aurora with starfall shimmer
        final auraWidget = Container(
          width: size + 16,
          height: size + 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [
                accentColor.withValues(alpha: 0.15),
                const Color(0xFFFFD54F).withValues(alpha: 0.85),
                const Color(0xFF00E5FF).withValues(alpha: 0.90),
                const Color(0xFFB388FF).withValues(alpha: 0.90),
                Colors.white.withValues(alpha: 0.95),
                accentColor.withValues(alpha: 0.15),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD54F).withValues(alpha: 0.5),
                blurRadius: 18,
                spreadRadius: 3,
              ),
            ],
          ),
        );

        if (_rotationController != null && !reducedMotion) {
          return AnimatedBuilder(
            animation: _rotationController!,
            builder: (context, child) => Transform.rotate(
              angle: _rotationController!.value * 2 * math.pi,
              child: child,
            ),
            child: auraWidget,
          );
        }
        return auraWidget;

      case 3:
        // Stage 3: Guardian — Iridescent caustic halo
        final auraWidget = Container(
          width: size + 12,
          height: size + 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [
                accentColor.withValues(alpha: 0.1),
                const Color(0xFF00E5FF).withValues(alpha: 0.8),
                Colors.white.withValues(alpha: 0.85),
                accentColor.withValues(alpha: 0.75),
                accentColor.withValues(alpha: 0.1),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.45),
                blurRadius: 14,
                spreadRadius: 2,
              ),
            ],
          ),
        );

        if (_rotationController != null && !reducedMotion) {
          return AnimatedBuilder(
            animation: _rotationController!,
            builder: (context, child) => Transform.rotate(
              angle: _rotationController!.value * 2 * math.pi,
              child: child,
            ),
            child: auraWidget,
          );
        }
        return auraWidget;

      case 2:
        // Stage 2: Explorer — Bioluminescent concentric shimmer ring
        return Container(
          width: size + 10,
          height: size + 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: auraColor.withValues(alpha: 0.65),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: auraColor.withValues(alpha: 0.4),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
        );

      case 1:
      default:
        // Stage 1: Hatchling — Gentle morning dew ambient glow
        return Container(
          width: size + 6,
          height: size + 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: auraColor.withValues(alpha: 0.35),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
        );
    }
  }
}
