import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Single expanding circular ripple caused by mascot bobbing or touch interaction
class WaterRipple {
  final Offset origin;
  final double startTimeSeconds;
  final double maxRadius;
  final double amplitude;
  final Color color;

  WaterRipple({
    required this.origin,
    required this.startTimeSeconds,
    this.maxRadius = 160.0,
    this.amplitude = 1.0,
    this.color = const Color(0x66E0F7FA),
  });

  /// Evaluates current expansion progress (0.0 to 1.0) and opacity at time [t]
  double progressAt(double currentTimeSeconds, {double durationSeconds = 2.4}) {
    final elapsed = currentTimeSeconds - startTimeSeconds;
    if (elapsed < 0.0) return 0.0;
    return (elapsed / durationSeconds).clamp(0.0, 1.0);
  }

  bool isExpired(double currentTimeSeconds, {double durationSeconds = 2.4}) {
    return (currentTimeSeconds - startTimeSeconds) >= durationSeconds;
  }

  /// Calculates dynamic radius at time [t]
  double radiusAt(double currentTimeSeconds, {double durationSeconds = 2.4}) {
    final p = progressAt(currentTimeSeconds, durationSeconds: durationSeconds);
    // Smooth deceleration curve for physical ripple propagation
    return maxRadius * math.sin(p * math.pi * 0.5);
  }

  /// Calculates dynamic stroke opacity (fades out as it expands)
  double opacityAt(double currentTimeSeconds, {double durationSeconds = 2.4}) {
    final p = progressAt(currentTimeSeconds, durationSeconds: durationSeconds);
    return (1.0 - p) * amplitude;
  }
}
