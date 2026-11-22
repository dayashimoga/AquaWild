/// Daily physiological budget summary for out-of-app glanceability
class HydrationBudgetSummary {
  final double targetMl;
  final double netConsumedMl;
  final double caffeineConsumedMg;
  final double electrolytesConsumedMg;
  final int streakDays;
  final int streakFreezesAvailable;

  const HydrationBudgetSummary({
    required this.targetMl,
    required this.netConsumedMl,
    this.caffeineConsumedMg = 0.0,
    this.electrolytesConsumedMg = 0.0,
    this.streakDays = 0,
    this.streakFreezesAvailable = 0,
  });

  /// Milliliters remaining to reach daily goal
  double get remainingMl => (targetMl - netConsumedMl).clamp(0.0, targetMl);

  /// Fraction of daily goal achieved (0.0 to 1.0+)
  double get progressFraction =>
      targetMl > 0 ? (netConsumedMl / targetMl).clamp(0.0, 2.0) : 0.0;

  /// Progress formatted as integer percentage (e.g. 66)
  int get progressPercent => (progressFraction * 100).round();

  /// Daily safe caffeine budget remaining in mg (400mg FDA/EFSA adult daily limit)
  double get caffeineBudgetRemainingMg =>
      (400.0 - caffeineConsumedMg).clamp(0.0, 400.0);

  /// Electrolyte sufficiency score (0 to 100% based on recommended 500mg daily baseline)
  int get electrolyteScorePercent =>
      ((electrolytesConsumedMg / 500.0) * 100).round().clamp(0, 100);

  Map<String, dynamic> toJson() => {
        'target_ml': targetMl,
        'net_consumed_ml': netConsumedMl,
        'remaining_ml': remainingMl,
        'progress_percent': progressPercent,
        'caffeine_consumed_mg': caffeineConsumedMg,
        'caffeine_budget_remaining_mg': caffeineBudgetRemainingMg,
        'electrolytes_consumed_mg': electrolytesConsumedMg,
        'electrolyte_score_percent': electrolyteScorePercent,
        'streak_days': streakDays,
        'streak_freezes_available': streakFreezesAvailable,
      };

  factory HydrationBudgetSummary.fromJson(Map<String, dynamic> json) {
    return HydrationBudgetSummary(
      targetMl: (json['target_ml'] as num?)?.toDouble() ?? 2500.0,
      netConsumedMl: (json['net_consumed_ml'] as num?)?.toDouble() ?? 0.0,
      caffeineConsumedMg:
          (json['caffeine_consumed_mg'] as num?)?.toDouble() ?? 0.0,
      electrolytesConsumedMg:
          (json['electrolytes_consumed_mg'] as num?)?.toDouble() ?? 0.0,
      streakDays: (json['streak_days'] as num?)?.toInt() ?? 0,
      streakFreezesAvailable:
          (json['streak_freezes_available'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Canonical Out-of-App Telemetry Snapshot used by Lock-Screen Widgets,
/// Home-Screen Widgets, Wearables, and Rich Interactive Notification Handlers.
class OutOfAppTelemetrySnapshot {
  final DateTime timestamp;
  final HydrationBudgetSummary budget;
  final String activeCompanionId;
  final String activeCompanionName;
  final String companionStageTitle;
  final int userXp;
  final int xpUntilNextStage;
  final String activeBiomeName;
  final List<int> quickLogPresetMl;

  const OutOfAppTelemetrySnapshot({
    required this.timestamp,
    required this.budget,
    required this.activeCompanionId,
    required this.activeCompanionName,
    required this.companionStageTitle,
    required this.userXp,
    required this.xpUntilNextStage,
    required this.activeBiomeName,
    this.quickLogPresetMl = const [150, 250, 330, 500],
  });

  /// Notification title text
  String get notificationTitle =>
      '${budget.progressPercent}% of Goal • ${budget.remainingMl.round()}ml remaining';

  /// Notification body text summarizing companion & streak
  String get notificationBody =>
      'Keep $activeCompanionName hydrated! Streak: ${budget.streakDays} days (${budget.streakFreezesAvailable} 🛡️ freezes left).';

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'budget': budget.toJson(),
        'active_companion_id': activeCompanionId,
        'active_companion_name': activeCompanionName,
        'companion_stage_title': companionStageTitle,
        'user_xp': userXp,
        'xp_until_next_stage': xpUntilNextStage,
        'active_biome_name': activeBiomeName,
        'quick_log_preset_ml': quickLogPresetMl,
        'notification_title': notificationTitle,
        'notification_body': notificationBody,
      };

  factory OutOfAppTelemetrySnapshot.fromJson(Map<String, dynamic> json) {
    return OutOfAppTelemetrySnapshot(
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      budget: json['budget'] != null
          ? HydrationBudgetSummary.fromJson(
              json['budget'] as Map<String, dynamic>)
          : const HydrationBudgetSummary(
              targetMl: 2500,
              netConsumedMl: 0,
            ),
      activeCompanionId: json['active_companion_id'] as String? ?? 'red_panda',
      activeCompanionName:
          json['active_companion_name'] as String? ?? 'Ruby the Red Panda',
      companionStageTitle:
          json['companion_stage_title'] as String? ?? 'Hatchling',
      userXp: (json['user_xp'] as num?)?.toInt() ?? 0,
      xpUntilNextStage: (json['xp_until_next_stage'] as num?)?.toInt() ?? 300,
      activeBiomeName:
          json['active_biome_name'] as String? ?? 'Bamboo Misty Springs',
      quickLogPresetMl: (json['quick_log_preset_ml'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [150, 250, 330, 500],
    );
  }
}
