import 'package:uuid/uuid.dart';

/// Intensity levels for physical workout sessions.
enum ActivityIntensity {
  light(sweatRateMlPerMinute: 6.0, metabolicMultiplier: 1.2),
  moderate(sweatRateMlPerMinute: 12.0, metabolicMultiplier: 1.5),
  high(sweatRateMlPerMinute: 18.0, metabolicMultiplier: 1.9),
  extreme(sweatRateMlPerMinute: 24.0, metabolicMultiplier: 2.3);

  final double sweatRateMlPerMinute;
  final double metabolicMultiplier;

  const ActivityIntensity({
    required this.sweatRateMlPerMinute,
    required this.metabolicMultiplier,
  });
}

/// Common physical activities tracked for hydration replenishment.
enum ActivityType {
  running(label: 'Running', defaultIntensity: ActivityIntensity.high, iconEmoji: '🏃'),
  cycling(label: 'Cycling', defaultIntensity: ActivityIntensity.moderate, iconEmoji: '🚴'),
  swimming(label: 'Swimming', defaultIntensity: ActivityIntensity.high, iconEmoji: '🏊'),
  hiit(label: 'HIIT / Cardio', defaultIntensity: ActivityIntensity.extreme, iconEmoji: '⚡'),
  walking(label: 'Brisk Walking', defaultIntensity: ActivityIntensity.light, iconEmoji: '🚶'),
  strength(label: 'Strength Training', defaultIntensity: ActivityIntensity.moderate, iconEmoji: '🏋️'),
  yoga(label: 'Yoga / Pilates', defaultIntensity: ActivityIntensity.light, iconEmoji: '🧘'),
  custom(label: 'General Fitness', defaultIntensity: ActivityIntensity.moderate, iconEmoji: '🎯');

  final String label;
  final ActivityIntensity defaultIntensity;
  final String iconEmoji;

  const ActivityType({
    required this.label,
    required this.defaultIntensity,
    required this.iconEmoji,
  });
}

/// Represents a completed physical activity that consumed metabolic energy and induced sweat loss.
class ActivitySession {
  final String id;
  final ActivityType activityType;
  final int durationMinutes;
  final ActivityIntensity intensity;
  final int caloriesBurned;
  final DateTime timestamp;

  ActivitySession({
    String? id,
    required this.activityType,
    required this.durationMinutes,
    ActivityIntensity? intensity,
    int? caloriesBurned,
    DateTime? timestamp,
  })  : id = id ?? const Uuid().v4(),
        intensity = intensity ?? activityType.defaultIntensity,
        caloriesBurned = caloriesBurned ?? (durationMinutes * 8),
        timestamp = timestamp ?? DateTime.now();

  /// Estimated water volume lost through perspiration (in ml).
  int get estimatedSweatLossMl {
    return (durationMinutes * intensity.sweatRateMlPerMinute).round();
  }

  /// Recommended post-activity replenishment (125% of sweat loss to account for urine output).
  int get recommendedReplenishmentMl {
    return (estimatedSweatLossMl * 1.25).round();
  }

  ActivitySession copyWith({
    String? id,
    ActivityType? activityType,
    int? durationMinutes,
    ActivityIntensity? intensity,
    int? caloriesBurned,
    DateTime? timestamp,
  }) {
    return ActivitySession(
      id: id ?? this.id,
      activityType: activityType ?? this.activityType,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      intensity: intensity ?? this.intensity,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activityType': activityType.name,
      'durationMinutes': durationMinutes,
      'intensity': intensity.name,
      'caloriesBurned': caloriesBurned,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ActivitySession.fromJson(Map<String, dynamic> json) {
    return ActivitySession(
      id: json['id'] as String,
      activityType: ActivityType.values.firstWhere(
        (e) => e.name == json['activityType'],
        orElse: () => ActivityType.custom,
      ),
      durationMinutes: json['durationMinutes'] as int,
      intensity: ActivityIntensity.values.firstWhere(
        (e) => e.name == json['intensity'],
        orElse: () => ActivityIntensity.moderate,
      ),
      caloriesBurned: json['caloriesBurned'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
