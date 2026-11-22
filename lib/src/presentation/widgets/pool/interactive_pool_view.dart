import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'floating_red_panda_painter.dart';
import 'pool_particles_painter.dart';
import 'pool_water_simulation_painter.dart';
import 'ripple_emitter.dart';

/// Full interactive top-view pool simulation widget featuring:
/// - Procedural water caustics & ceramic tiles
/// - Buoyancy spring-damper physics with gentle bobbing & rocking
/// - Interactive touch & ambient water ripples
/// - Ambient rising micro-bubbles and specular sparkles
/// - Accessibility reduced-motion mode compliance
class InteractivePoolView extends StatefulWidget {
  final VoidCallback? onDiveInPressed;

  const InteractivePoolView({
    super.key,
    this.onDiveInPressed,
  });

  @override
  State<InteractivePoolView> createState() => _InteractivePoolViewState();
}

class _InteractivePoolViewState extends State<InteractivePoolView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<WaterRipple> _ripples = [];
  final List<PoolParticle> _particles = [];
  final math.Random _random = math.Random(42);

  double _lastAmbientRippleTime = 0.0;
  double _touchImpulse = 0.0;
  double _touchTilt = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Initialize 24 randomized ambient particles
    for (int i = 0; i < 24; i++) {
      _particles.add(
        PoolParticle(
          xRatio: _random.nextDouble(),
          yRatio: _random.nextDouble(),
          radius: 2.0 + _random.nextDouble() * 4.0,
          speed: 0.6 + _random.nextDouble() * 0.8,
          phase: _random.nextDouble() * math.pi * 2,
          isSparkle: i % 4 == 0,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addRipple(Offset position, {double amplitude = 1.0, double maxRadius = 180.0}) {
    final double currentTime =
        DateTime.now().millisecondsSinceEpoch / 1000.0;

    setState(() {
      _ripples.add(
        WaterRipple(
          origin: position,
          startTimeSeconds: currentTime,
          amplitude: amplitude,
          maxRadius: maxRadius,
        ),
      );

      // Clean up expired ripples
      _ripples.removeWhere((r) => r.isExpired(currentTime));
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool reducedMotion = MediaQuery.disableAnimationsOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final Size size = Size(constraints.maxWidth, constraints.maxHeight);
        final Offset center = Offset(size.width / 2, size.height * 0.42);

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double currentTime =
                DateTime.now().millisecondsSinceEpoch / 1000.0;

            // Trigger ambient breathing ripple from Red Panda every 2.5 seconds
            if (!reducedMotion && (currentTime - _lastAmbientRippleTime) > 2.5) {
              _lastAmbientRippleTime = currentTime;
              _ripples.add(
                WaterRipple(
                  origin: Offset(center.dx + 40, center.dy + 30),
                  startTimeSeconds: currentTime,
                  amplitude: 0.6,
                  maxRadius: 140.0,
                ),
              );
            }

            // Damped harmonic buoyancy bobbing & tilt rocking
            final double t = _controller.value * math.pi * 2;
            final double naturalBob = reducedMotion ? 0.0 : math.sin(t * 1.5) * 8.0;
            final double naturalTilt =
                reducedMotion ? 0.0 : math.cos(t * 1.1) * 0.05;

            // Decay touch impulses smoothly
            _touchImpulse *= 0.92;
            _touchTilt *= 0.92;

            final double totalBob = naturalBob + _touchImpulse;
            final double totalTilt = naturalTilt + _touchTilt;
            final double glintPhase = (_controller.value * 3.0) % 1.0;

            return GestureDetector(
              onTapDown: (details) {
                _addRipple(details.localPosition, amplitude: 1.2, maxRadius: 220.0);
                setState(() {
                  _touchImpulse = 14.0;
                  _touchTilt = (details.localPosition.dx > center.dx) ? 0.12 : -0.12;
                });
              },
              onPanUpdate: (details) {
                if (_random.nextDouble() < 0.25) {
                  _addRipple(details.localPosition, amplitude: 0.8, maxRadius: 120.0);
                }
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Layer 1: Procedural Water Caustics, Tiles, and Ripples
                  CustomPaint(
                    size: size,
                    painter: PoolWaterSimulationPainter(
                      time: currentTime,
                      ripples: _ripples,
                      reducedMotion: reducedMotion,
                    ),
                  ),

                  // Layer 2: Rising Micro-bubbles & Star Specular Glints
                  if (!reducedMotion)
                    CustomPaint(
                      size: size,
                      painter: PoolParticlesPainter(
                        time: currentTime,
                        particles: _particles,
                      ),
                    ),

                  // Layer 3: Anatomically Accurate Red Panda Reclining Naturally in Water
                  Positioned(
                    left: center.dx - 120,
                    top: center.dy - 120,
                    width: 240,
                    height: 240,
                    child: Semantics(
                      label:
                          'Ruby the Red Panda reclining naturally in crystal-clear highland mineral water. Tap anywhere to splash and create ripples.',
                      button: true,
                      child: CustomPaint(
                        size: const Size(240, 240),
                        painter: FloatingRedPandaPainter(
                          bobOffset: totalBob,
                          tiltAngle: totalTilt,
                          glintPhase: glintPhase,
                          breathPhase: _controller.value,
                          tailWagPhase: t * 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
