import 'package:flutter/material.dart';

/// Supported widget dimensions and form factors
enum WidgetFamily {
  systemSmall(
    label: 'Compact 2x2',
    description: 'Minimal circular progress ring with companion avatar & quick-log',
    width: 156.0,
    height: 156.0,
  ),
  systemMedium(
    label: 'Medium 4x2',
    description: 'Rich telemetry with nutrient status, circadian pace & multi-log dock',
    width: 328.0,
    height: 156.0,
  ),
  lockScreenLiveActivity(
    label: 'Lock Screen Live Activity',
    description: 'High-contrast glanceable pill and expanded notification island',
    width: 340.0,
    height: 140.0,
  );

  final String label;
  final String description;
  final double width;
  final double height;

  const WidgetFamily({
    required this.label,
    required this.description,
    required this.width,
    required this.height,
  });
}

/// Simulated mobile backdrop wallpapers for in-app widget studio preview
enum WidgetSimulatorWallpaper {
  darkOcean(
    name: 'Dark Abyssal Ocean',
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF030712), Color(0xFF0B192C), Color(0xFF1E3E62)],
    ),
  ),
  minimalMidnight(
    name: 'Minimal Midnight',
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0F172A), Color(0xFF020617)],
    ),
  ),
  emeraldBamboo(
    name: 'Emerald Bamboo Mist',
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF052E16), Color(0xFF064E3B), Color(0xFF022C22)],
    ),
  ),
  auroraGlacier(
    name: 'Aurora Arctic Glacier',
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0C4A6E), Color(0xFF0369A1), Color(0xFF082F49)],
    ),
  );

  final String name;
  final Gradient gradient;

  const WidgetSimulatorWallpaper({
    required this.name,
    required this.gradient,
  });
}

/// Result returned from synchronizing telemetry to native widget engines
@immutable
class WidgetSyncResult {
  final bool isSuccess;
  final DateTime syncedAt;
  final List<String> targetPlatforms;
  final String message;

  const WidgetSyncResult({
    required this.isSuccess,
    required this.syncedAt,
    required this.targetPlatforms,
    required this.message,
  });

  Map<String, dynamic> toJson() => {
        'isSuccess': isSuccess,
        'syncedAt': syncedAt.toIso8601String(),
        'targetPlatforms': targetPlatforms,
        'message': message,
      };
}
