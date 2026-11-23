import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'floating_red_panda_painter.dart';
import 'mascot_kinematic_controller.dart';
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
  final ParticleEffectType? particleEffectType;

  const InteractivePoolView({
    super.key,
    this.onDiveInPressed,
    this.particleEffectType,
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
  double _reactionPulse = 0.0;

  // Involuntary blinking & spontaneous ear twitch timing clocks
  double _nextBlinkTime = 2.5;
  double _blinkStartTime = -10.0;
  double _nextEarTwitchTime = 3.8;
  double _twitchStartTime = -10.0;

  // Eye-tracking target & smoothed gaze position
  Offset? _pointerPosition;
  Offset _currentLookTarget = Offset.zero;

  // Kinematic locomotion controller for tap/click-to-move pathfinding
  MascotKinematicController? _kinematics;
  double _lastFrameTime = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Initialize 24 randomized ambient particles
    final initialType =
        widget.particleEffectType ?? ParticleEffectType.standardBubbles;
    _particles.addAll(
      PoolParticlesPainter.generateDefaultParticles(
        count: 24,
        random: _random,
        type: initialType,
      ),
    );
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

  ParticleEffectType _resolveEffectType(BuildContext context) {
    if (widget.particleEffectType != null) {
      return widget.particleEffectType!;
    }
    final theme = Theme.of(context);
    if (theme.colorScheme.secondary == const Color(0xFFFF007F)) {
      return ParticleEffectType.bioluminescentPlankton;
    } else if (theme.scaffoldBackgroundColor == const Color(0xFFF9F7F1)) {
      return ParticleEffectType.onsenSteamBubbles;
    } else if (theme.colorScheme.secondary == const Color(0xFF9D4EDD)) {
      return ParticleEffectType.auroraDust;
    }
    return ParticleEffectType.standardBubbles;
  }

  @override
  Widget build(BuildContext context) {
    final bool reducedMotion = MediaQuery.disableAnimationsOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final Size size = Size(constraints.maxWidth, constraints.maxHeight);
        final Offset defaultCenter = Offset(size.width / 2, size.height * 0.42);

        // Initialize kinematics controller at pool center if not yet created
        _kinematics ??=
            MascotKinematicController(initialPosition: defaultCenter);

        final Rect poolBounds = Rect.fromLTRB(
          60.0,
          70.0,
          math.max(60.0, size.width - 60.0),
          math.max(70.0, size.height - 120.0),
        );

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double currentTime =
                DateTime.now().millisecondsSinceEpoch / 1000.0;

            // Frame-rate independent delta time
            final double dt = _lastFrameTime > 0.0
                ? (currentTime - _lastFrameTime).clamp(0.001, 0.05)
                : 0.016;
            _lastFrameTime = currentTime;

            // Update kinematic locomotion simulation
            _kinematics!.update(dt, reducedMotion: reducedMotion);
            final MascotKinematics kState = _kinematics!.state;

            // Emit wake trail ripple behind mascot when traveling
            if (kState.shouldEmitWake && !reducedMotion) {
              final Offset wakeOffset = kState.velocity.distanceSquared > 1.0
                  ? kState.position -
                      (kState.velocity / kState.velocity.distance) * 28.0
                  : kState.position;
              _ripples.add(
                WaterRipple(
                  origin: wakeOffset,
                  startTimeSeconds: currentTime,
                  amplitude: 0.65,
                  maxRadius: 110.0,
                ),
              );
            }

            // Trigger ambient breathing ripple from Red Panda every 2.5 seconds when idle
            if (!reducedMotion &&
                kState.state == LocomotionState.idle &&
                (currentTime - _lastAmbientRippleTime) > 2.5) {
              _lastAmbientRippleTime = currentTime;
              _ripples.add(
                WaterRipple(
                  origin: Offset(kState.position.dx + 40, kState.position.dy + 30),
                  startTimeSeconds: currentTime,
                  amplitude: 0.6,
                  maxRadius: 140.0,
                ),
              );
            }

            // Clean up expired ripples
            _ripples.removeWhere((r) => r.isExpired(currentTime));

            // Damped harmonic buoyancy bobbing & tilt rocking
            final double t = _controller.value * math.pi * 2;
            final double naturalBob =
                reducedMotion ? 0.0 : math.sin(t * 1.5) * 8.0;
            final double naturalTilt =
                reducedMotion ? 0.0 : math.cos(t * 1.1) * 0.05;

            // Decay touch impulses smoothly
            _touchImpulse *= 0.92;
            _touchTilt *= 0.92;
            _reactionPulse *= 0.93;
            if (_reactionPulse < 0.005) _reactionPulse = 0.0;

            final double totalBob =
                naturalBob + _touchImpulse + kState.landingBounce;
            final double totalTilt =
                naturalTilt + _touchTilt + kState.momentumTilt;
            final double glintPhase = (_controller.value * 3.0) % 1.0;

            // Involuntary Blinking calculation
            double blinkProgress = 0.0;
            if (!reducedMotion) {
              if (currentTime >= _nextBlinkTime) {
                _blinkStartTime = currentTime;
                _nextBlinkTime = currentTime + 3.2 + _random.nextDouble() * 2.8;
              }
              final double blinkElapsed = currentTime - _blinkStartTime;
              if (blinkElapsed >= 0.0 && blinkElapsed < 0.22) {
                if (blinkElapsed < 0.10) {
                  blinkProgress = blinkElapsed / 0.10;
                } else {
                  blinkProgress = 1.0 - ((blinkElapsed - 0.10) / 0.12);
                }
              }
            }

            // Spontaneous Ear Twitch calculation
            double earTwitchAngle = 0.0;
            if (!reducedMotion) {
              if (currentTime >= _nextEarTwitchTime) {
                _twitchStartTime = currentTime;
                _nextEarTwitchTime =
                    currentTime + 4.0 + _random.nextDouble() * 3.5;
              }
              final double twitchElapsed = currentTime - _twitchStartTime;
              if (twitchElapsed >= 0.0 && twitchElapsed < 0.24) {
                earTwitchAngle = math.sin(twitchElapsed * math.pi * 18.0) *
                    0.20 *
                    (1.0 - twitchElapsed / 0.24);
              }
            }

            // Gaze eye tracking towards pointer hover relative to active mascot position
            if (!reducedMotion && _pointerPosition != null) {
              final double dx =
                  ((_pointerPosition!.dx - kState.position.dx) / 160.0)
                      .clamp(-1.0, 1.0);
              final double dy =
                  ((_pointerPosition!.dy - (kState.position.dy - 32)) / 160.0)
                      .clamp(-1.0, 1.0);
              final Offset targetLook = Offset(dx, dy);
              _currentLookTarget =
                  Offset.lerp(_currentLookTarget, targetLook, 0.15) ??
                      Offset.zero;
            } else {
              _currentLookTarget =
                  Offset.lerp(_currentLookTarget, Offset.zero, 0.08) ??
                      Offset.zero;
            }

            return MouseRegion(
              cursor: SystemMouseCursors.click,
              onHover: (event) {
                _pointerPosition = event.localPosition;
              },
              onExit: (_) {
                _pointerPosition = null;
              },
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) {
                  final Offset tapPos = details.localPosition;
                  final double distToMascot =
                      (tapPos - kState.position).distance;

                  if (distToMascot < 65.0) {
                    // Direct petting stroke on Ruby
                    _addRipple(tapPos, amplitude: 1.0, maxRadius: 140.0);
                    setState(() {
                      _touchImpulse = 12.0;
                      _reactionPulse = 1.0;
                      _pointerPosition = tapPos;
                    });
                  } else {
                    // Tap-to-move kinematic swim
                    _addRipple(tapPos, amplitude: 1.3, maxRadius: 200.0);
                    setState(() {
                      _touchImpulse = 10.0;
                      _touchTilt =
                          (tapPos.dx > kState.position.dx) ? 0.08 : -0.08;
                      _pointerPosition = tapPos;
                      _kinematics!.moveTo(
                        tapPos,
                        boundaryRect: poolBounds,
                        immediate: reducedMotion,
                      );
                    });
                  }
                },
                onPanUpdate: (details) {
                  if (_random.nextDouble() < 0.25) {
                    _addRipple(details.localPosition,
                        amplitude: 0.8, maxRadius: 120.0);
                  }
                  _pointerPosition = details.localPosition;
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

                    // Layer 2: Rising Dynamic Particles (Bubbles, Plankton, Aurora Dust, Onsen Steam)
                    if (!reducedMotion)
                      CustomPaint(
                        size: size,
                        painter: PoolParticlesPainter(
                          time: currentTime,
                          particles: _particles,
                          effectType: _resolveEffectType(context),
                        ),
                      ),

                    // Layer 3: Anatomically Accurate Red Panda Reclining Naturally in Water
                    Positioned(
                      left: kState.position.dx - 120,
                      top: kState.position.dy - 120,
                      width: 240,
                      height: 240,
                      child: Semantics(
                        label:
                            'Ruby the Red Panda reclining naturally in crystal-clear highland mineral water. Tap anywhere to swim and create ripples.',
                        button: true,
                        child: CustomPaint(
                          size: const Size(240, 240),
                          painter: FloatingRedPandaPainter(
                            bobOffset: totalBob,
                            tiltAngle: totalTilt,
                            glintPhase: glintPhase,
                            breathPhase: _controller.value,
                            blinkProgress: blinkProgress,
                            tailWagPhase: t * 1.4,
                            lookTarget: _currentLookTarget,
                            earTwitchAngle: earTwitchAngle,
                            reactionPulse: _reactionPulse,
                            verticalSquash: kState.verticalSquash,
                            isFacingLeft: kState.velocity.dx < -8.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
