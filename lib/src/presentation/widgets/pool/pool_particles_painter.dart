import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Available particle visual effect styles in AquaWild
enum ParticleEffectType {
  standardBubbles,
  bioluminescentPlankton,
  auroraDust,
  onsenSteamBubbles;

  String get displayName {
    switch (this) {
      case ParticleEffectType.standardBubbles:
        return 'Standard Mineral Bubbles';
      case ParticleEffectType.bioluminescentPlankton:
        return 'Bioluminescent Plankton';
      case ParticleEffectType.auroraDust:
        return 'Aurora Cosmic Dust';
      case ParticleEffectType.onsenSteamBubbles:
        return 'Onsen Thermal Vapor';
    }
  }
}

/// Single ambient particle (micro-bubble, glowing plankton, aurora dust, or thermal steam puff)
class PoolParticle {
  final double xRatio; // 0.0 to 1.0 of viewport width
  final double yRatio; // 0.0 to 1.0 of viewport height
  final double radius;
  final double speed;
  final double phase;
  final bool isSparkle;
  final Color? customColor;
  final double driftAngle;

  const PoolParticle({
    required this.xRatio,
    required this.yRatio,
    required this.radius,
    required this.speed,
    required this.phase,
    this.isSparkle = false,
    this.customColor,
    this.driftAngle = 0.0,
  });
}

/// CustomPainter rendering dynamic particle visual effects:
/// - Standard: rising micro-bubbles with specular glints
/// - Bioluminescent Plankton: pulsating glowing marine spores with luminous halos
/// - Aurora Cosmic Dust: chromatic prismatic stardust with rotating starbursts
/// - Onsen Thermal Vapor: expanding warm steam puffs with soft dissolution
class PoolParticlesPainter extends CustomPainter {
  final double time;
  final List<PoolParticle> particles;
  final ParticleEffectType effectType;
  final Color? primaryTint;
  final Color? secondaryTint;

  // Cached paint instances to prevent GC pressure during 60/120 FPS animation
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

  final Paint _planktonHaloPaint = Paint()..style = PaintingStyle.fill;
  final Paint _planktonCorePaint = Paint()..style = PaintingStyle.fill;
  final Paint _steamPuffPaint = Paint()..style = PaintingStyle.fill;

  PoolParticlesPainter({
    required this.time,
    required this.particles,
    this.effectType = ParticleEffectType.standardBubbles,
    this.primaryTint,
    this.secondaryTint,
  });

  /// Factory helper creating a uniform distributed set of particles for any effect type
  static List<PoolParticle> generateDefaultParticles({
    int count = 28,
    math.Random? random,
    ParticleEffectType type = ParticleEffectType.standardBubbles,
  }) {
    final rng = random ?? math.Random(42);
    final List<PoolParticle> result = [];

    for (int i = 0; i < count; i++) {
      final double x = rng.nextDouble();
      final double y = rng.nextDouble();
      final double radius = switch (type) {
        ParticleEffectType.standardBubbles => 2.0 + rng.nextDouble() * 3.5,
        ParticleEffectType.bioluminescentPlankton => 2.5 + rng.nextDouble() * 4.0,
        ParticleEffectType.auroraDust => 1.8 + rng.nextDouble() * 3.2,
        ParticleEffectType.onsenSteamBubbles => 4.0 + rng.nextDouble() * 6.5,
      };
      final double speed = switch (type) {
        ParticleEffectType.standardBubbles => 0.8 + rng.nextDouble() * 0.7,
        ParticleEffectType.bioluminescentPlankton => 0.5 + rng.nextDouble() * 0.6,
        ParticleEffectType.auroraDust => 0.6 + rng.nextDouble() * 0.8,
        ParticleEffectType.onsenSteamBubbles => 0.4 + rng.nextDouble() * 0.5,
      };
      final double phase = rng.nextDouble() * math.pi * 2.0;
      final bool isSparkle = rng.nextDouble() < 0.35;
      final double driftAngle = (rng.nextDouble() - 0.5) * 0.8;

      result.add(
        PoolParticle(
          xRatio: x,
          yRatio: y,
          radius: radius,
          speed: speed,
          phase: phase,
          isSparkle: isSparkle,
          driftAngle: driftAngle,
        ),
      );
    }
    return result;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    for (final p in particles) {
      switch (effectType) {
        case ParticleEffectType.standardBubbles:
          _drawStandardBubble(canvas, size, p);
          break;
        case ParticleEffectType.bioluminescentPlankton:
          _drawBioluminescentPlankton(canvas, size, p);
          break;
        case ParticleEffectType.auroraDust:
          _drawAuroraDust(canvas, size, p);
          break;
        case ParticleEffectType.onsenSteamBubbles:
          _drawOnsenSteam(canvas, size, p);
          break;
      }
    }
  }

  void _drawStandardBubble(Canvas canvas, Size size, PoolParticle p) {
    final double y =
        (size.height * ((p.yRatio - (time * p.speed * 0.06)) % 1.0));
    final double xSway = math.sin((time * 2.0) + p.phase) * 12.0;
    final double x = (size.width * p.xRatio) + xSway;
    final Offset center = Offset(x, y);

    if (p.isSparkle) {
      final double opacity =
          (0.5 + 0.5 * math.sin((time * 3.5) + p.phase)).clamp(0.0, 1.0);
      _sparklePaint.color = Colors.white.withValues(alpha: opacity * 0.85);

      canvas.drawCircle(center, p.radius, _sparklePaint);
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
      canvas.drawCircle(center, p.radius, _bubblePaint);
      canvas.drawCircle(
        Offset(center.dx - p.radius * 0.35, center.dy - p.radius * 0.35),
        p.radius * 0.28,
        _bubbleHighlight,
      );
    }
  }

  void _drawBioluminescentPlankton(Canvas canvas, Size size, PoolParticle p) {
    // Plankton pulses rhythmically and drifts in soft spiral eddies
    final double y =
        (size.height * ((p.yRatio - (time * p.speed * 0.045)) % 1.0));
    final double xSway =
        math.sin((time * 1.8) + p.phase) * 16.0 + math.cos(time * 0.8) * 6.0;
    final double x = (size.width * p.xRatio) + xSway;
    final Offset center = Offset(x, y);

    final double pulse =
        (0.45 + 0.55 * math.sin((time * 2.8) + p.phase)).clamp(0.0, 1.0);

    // Alternate between neon cyan and electric magenta/lime
    final Color baseColor = p.isSparkle
        ? (secondaryTint ?? const Color(0xFFFF007F))
        : (primaryTint ?? const Color(0xFF00F0FF));

    // Outer luminous halo
    _planktonHaloPaint.color =
        baseColor.withValues(alpha: (0.15 + 0.25 * pulse) * 0.7);
    canvas.drawCircle(center, p.radius * (2.2 + 0.8 * pulse), _planktonHaloPaint);

    // Inner bright core
    _planktonCorePaint.color =
        Color.lerp(baseColor, Colors.white, 0.4 + 0.4 * pulse)!
            .withValues(alpha: 0.85);
    canvas.drawCircle(center, p.radius * (0.8 + 0.3 * pulse), _planktonCorePaint);

    // Faint trailing wake dot
    final Offset trailCenter = Offset(
      center.dx - math.sin(p.driftAngle) * p.radius * 1.8,
      center.dy + p.radius * 2.0,
    );
    _planktonHaloPaint.color = baseColor.withValues(alpha: 0.2 * pulse);
    canvas.drawCircle(trailCenter, p.radius * 0.45, _planktonHaloPaint);
  }

  void _drawAuroraDust(Canvas canvas, Size size, PoolParticle p) {
    // Chromatic iridescent stardust with shifting spectral sheen
    final double y =
        (size.height * ((p.yRatio - (time * p.speed * 0.05)) % 1.0));
    final double xSway =
        math.sin((time * 2.2) + p.phase) * 10.0 + (p.driftAngle * 14.0);
    final double x = (size.width * p.xRatio) + xSway;
    final Offset center = Offset(x, y);

    final double hue = ((time * 35.0) + (p.phase * 60.0)) % 360.0;
    final Color spectralColor =
        HSLColor.fromAHSL(1.0, hue, 0.80, 0.60).toColor();

    final double blink =
        (0.3 + 0.7 * math.sin((time * 3.2) + p.phase)).clamp(0.0, 1.0);

    if (p.isSparkle) {
      // 8-point rotating starburst
      final double rot = (time * 0.8) + p.phase;
      _sparklePaint.color =
          spectralColor.withValues(alpha: (0.6 + 0.4 * blink) * 0.9);

      // Starburst rays
      for (int i = 0; i < 4; i++) {
        final double angle = rot + (i * math.pi / 4.0);
        final double rayLen = (i % 2 == 0) ? p.radius * 2.4 : p.radius * 1.5;
        canvas.drawLine(
          Offset(center.dx - math.cos(angle) * rayLen,
              center.dy - math.sin(angle) * rayLen),
          Offset(center.dx + math.cos(angle) * rayLen,
              center.dy + math.sin(angle) * rayLen),
          _sparklePaint,
        );
      }
      canvas.drawCircle(center, p.radius * 0.6, _sparklePaint);
    } else {
      // Iridescent diamond crystal
      _sparklePaint.color =
          spectralColor.withValues(alpha: (0.4 + 0.5 * blink) * 0.8);
      canvas.drawCircle(center, p.radius, _sparklePaint);
      _bubbleHighlight.color =
          Colors.white.withValues(alpha: (0.6 + 0.4 * blink));
      canvas.drawCircle(center, p.radius * 0.35, _bubbleHighlight);
    }
  }

  void _drawOnsenSteam(Canvas canvas, Size size, PoolParticle p) {
    // Thermal vapor expands as it ascends and gently dissolves near the surface
    final double yProgress =
        ((p.yRatio - (time * p.speed * 0.035)) % 1.0);
    final double y = size.height * yProgress;
    final double xSway =
        math.sin((time * 1.2) + p.phase) * 20.0 + (p.driftAngle * 30.0);
    final double x = (size.width * p.xRatio) + xSway;
    final Offset center = Offset(x, y);

    // Steam expands as it rises
    final double expansion = 1.0 + (1.0 - yProgress) * 1.8;
    final double currentRadius = p.radius * expansion;

    // Steam fades softly at top and bottom
    final double alphaFade = math.sin(yProgress * math.pi).clamp(0.0, 1.0);
    final double opacity = (0.08 + 0.14 * alphaFade) * 0.7;

    // Warm bamboo/onsen vapor off-white
    _steamPuffPaint.color =
        const Color(0xFFFAF8F5).withValues(alpha: opacity);
    canvas.drawCircle(center, currentRadius, _steamPuffPaint);

    // Inner vapor core
    _steamPuffPaint.color =
        const Color(0xFFFFFFFF).withValues(alpha: opacity * 0.6);
    canvas.drawCircle(center, currentRadius * 0.55, _steamPuffPaint);
  }

  @override
  bool shouldRepaint(covariant PoolParticlesPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.effectType != effectType ||
        oldDelegate.primaryTint != primaryTint ||
        oldDelegate.secondaryTint != secondaryTint;
  }
}
