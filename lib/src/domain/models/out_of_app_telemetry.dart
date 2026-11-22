/// Daily physiological caffeine safety status
enum CaffeineSafetyStatus {
  safe,
  moderate,
  caution,
  exceeded;

  String get label {
    switch (this) {
      case CaffeineSafetyStatus.safe:
        return 'Optimal (Safe)';
      case CaffeineSafetyStatus.moderate:
        return 'Moderate';
      case CaffeineSafetyStatus.caution:
        return 'Near Limit (Caution)';
      case CaffeineSafetyStatus.exceeded:
        return 'Limit Exceeded';
    }
  }

  static CaffeineSafetyStatus fromConsumedMg(double mg) {
    if (mg <= 200.0) return CaffeineSafetyStatus.safe;
    if (mg <= 350.0) return CaffeineSafetyStatus.moderate;
    if (mg <= 400.0) return CaffeineSafetyStatus.caution;
    return CaffeineSafetyStatus.exceeded;
  }
}

/// Daily physiological electrolyte balance sufficiency status
enum ElectrolyteBalanceStatus {
  depleted,
  optimal,
  surplus;

  String get label {
    switch (this) {
      case ElectrolyteBalanceStatus.depleted:
        return 'Depleted (<30%)';
      case ElectrolyteBalanceStatus.optimal:
        return 'Optimal (30-100%)';
      case ElectrolyteBalanceStatus.surplus:
        return 'Surplus (>100%)';
    }
  }

  static ElectrolyteBalanceStatus fromScorePercent(int percent) {
    if (percent < 30) return ElectrolyteBalanceStatus.depleted;
    if (percent <= 100) return ElectrolyteBalanceStatus.optimal;
    return ElectrolyteBalanceStatus.surplus;
  }
}

/// Circadian hydration pacing relative to time of day
enum CircadianPaceStatus {
  aheadOfPace,
  onTrack,
  behindPace,
  criticalDeficit;

  String get label {
    switch (this) {
      case CircadianPaceStatus.aheadOfPace:
        return 'Ahead of Pace 🚀';
      case CircadianPaceStatus.onTrack:
        return 'On Track 🌊';
      case CircadianPaceStatus.behindPace:
        return 'Behind Pace 💧';
      case CircadianPaceStatus.criticalDeficit:
        return 'Critical Deficit ⚠️';
    }
  }

  static CircadianPaceStatus evaluate({
    required int progressPercent,
    required int expectedPercent,
  }) {
    final diff = progressPercent - expectedPercent;
    if (diff >= 10) return CircadianPaceStatus.aheadOfPace;
    if (diff >= -10) return CircadianPaceStatus.onTrack;
    if (diff >= -25) return CircadianPaceStatus.behindPace;
    return CircadianPaceStatus.criticalDeficit;
  }
}

/// Progress towards unlocking the next animal companion
class NextUnlockProgression {
  final String nextAnimalId;
  final String nextAnimalName;
  final String nextAnimalEmoji;
  final int unlockXp;
  final int currentXp;
  final int xpNeeded;
  final double progressFraction;
  final bool isAllUnlocked;

  const NextUnlockProgression({
    required this.nextAnimalId,
    required this.nextAnimalName,
    required this.nextAnimalEmoji,
    required this.unlockXp,
    required this.currentXp,
    required this.xpNeeded,
    required this.progressFraction,
    this.isAllUnlocked = false,
  });

  Map<String, dynamic> toJson() => {
        'next_animal_id': nextAnimalId,
        'next_animal_name': nextAnimalName,
        'next_animal_emoji': nextAnimalEmoji,
        'unlock_xp': unlockXp,
        'current_xp': currentXp,
        'xp_needed': xpNeeded,
        'progress_fraction': progressFraction,
        'is_all_unlocked': isAllUnlocked,
      };

  factory NextUnlockProgression.fromJson(Map<String, dynamic> json) {
    return NextUnlockProgression(
      nextAnimalId: json['next_animal_id'] as String? ?? '',
      nextAnimalName: json['next_animal_name'] as String? ?? 'All Companions',
      nextAnimalEmoji: json['next_animal_emoji'] as String? ?? '🐾',
      unlockXp: (json['unlock_xp'] as num?)?.toInt() ?? 0,
      currentXp: (json['current_xp'] as num?)?.toInt() ?? 0,
      xpNeeded: (json['xp_needed'] as num?)?.toInt() ?? 0,
      progressFraction:
          (json['progress_fraction'] as num?)?.toDouble() ?? 1.0,
      isAllUnlocked: json['is_all_unlocked'] as bool? ?? false,
    );
  }
}

/// Circadian metabolic time-of-day context
class CircadianContext {
  final String phaseName;
  final String anchorTimeFormatted;
  final CircadianPaceStatus paceStatus;
  final int expectedProgressPercent;
  final int suggestedNextSipMl;
  final String suggestedBeverageName;

  const CircadianContext({
    required this.phaseName,
    required this.anchorTimeFormatted,
    required this.paceStatus,
    required this.expectedProgressPercent,
    required this.suggestedNextSipMl,
    required this.suggestedBeverageName,
  });

  Map<String, dynamic> toJson() => {
        'phase_name': phaseName,
        'anchor_time_formatted': anchorTimeFormatted,
        'pace_status': paceStatus.name,
        'expected_progress_percent': expectedProgressPercent,
        'suggested_next_sip_ml': suggestedNextSipMl,
        'suggested_beverage_name': suggestedBeverageName,
      };

  factory CircadianContext.fromJson(Map<String, dynamic> json) {
    final statusName = json['pace_status'] as String?;
    final pace = CircadianPaceStatus.values.firstWhere(
      (e) => e.name == statusName,
      orElse: () => CircadianPaceStatus.onTrack,
    );

    return CircadianContext(
      phaseName: json['phase_name'] as String? ?? 'Midday Focus',
      anchorTimeFormatted:
          json['anchor_time_formatted'] as String? ?? '12:00',
      paceStatus: pace,
      expectedProgressPercent:
          (json['expected_progress_percent'] as num?)?.toInt() ?? 50,
      suggestedNextSipMl:
          (json['suggested_next_sip_ml'] as num?)?.toInt() ?? 250,
      suggestedBeverageName:
          json['suggested_beverage_name'] as String? ?? 'Pure Water',
    );
  }
}

/// Daily physiological budget summary for out-of-app glanceability
class HydrationBudgetSummary {
  final double targetMl;
  final double netConsumedMl;
  final double grossConsumedMl;
  final double caffeineConsumedMg;
  final double electrolytesConsumedMg;
  final double sugarConsumedG;
  final int streakDays;
  final int streakFreezesAvailable;

  const HydrationBudgetSummary({
    required this.targetMl,
    required this.netConsumedMl,
    this.grossConsumedMl = 0.0,
    this.caffeineConsumedMg = 0.0,
    this.electrolytesConsumedMg = 0.0,
    this.sugarConsumedG = 0.0,
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

  /// Whether user achieved daily target
  bool get isGoalAchieved => netConsumedMl >= targetMl;

  /// Daily safe caffeine budget remaining in mg (400mg FDA/EFSA adult daily limit)
  double get caffeineBudgetRemainingMg =>
      (400.0 - caffeineConsumedMg).clamp(0.0, 400.0);

  /// Clinical caffeine safety assessment
  CaffeineSafetyStatus get caffeineSafetyStatus =>
      CaffeineSafetyStatus.fromConsumedMg(caffeineConsumedMg);

  /// Electrolyte sufficiency score (0 to 100%+ based on recommended 500mg daily baseline)
  int get electrolyteScorePercent =>
      ((electrolytesConsumedMg / 500.0) * 100).round().clamp(0, 200);

  /// Electrolyte sufficiency status
  ElectrolyteBalanceStatus get electrolyteStatus =>
      ElectrolyteBalanceStatus.fromScorePercent(electrolyteScorePercent);

  /// Reference maximum recommended daily added sugar: 50g (WHO/AHA guidance)
  double get sugarBudgetRemainingG =>
      (50.0 - sugarConsumedG).clamp(0.0, 50.0);

  /// Alias for target completion
  bool get isTargetMet => isGoalAchieved;

  /// Alias for caffeine safety status
  CaffeineSafetyStatus get caffeineStatus => caffeineSafetyStatus;

  /// Whether user has exceeded 50g daily added sugar guidance
  bool get hasExceededSugarBudget => sugarConsumedG > 50.0;

  HydrationBudgetSummary copyWith({
    double? targetMl,
    double? netConsumedMl,
    double? grossConsumedMl,
    double? caffeineConsumedMg,
    double? electrolytesConsumedMg,
    double? sugarConsumedG,
    int? streakDays,
    int? streakFreezesAvailable,
  }) {
    return HydrationBudgetSummary(
      targetMl: targetMl ?? this.targetMl,
      netConsumedMl: netConsumedMl ?? this.netConsumedMl,
      grossConsumedMl: grossConsumedMl ?? this.grossConsumedMl,
      caffeineConsumedMg: caffeineConsumedMg ?? this.caffeineConsumedMg,
      electrolytesConsumedMg:
          electrolytesConsumedMg ?? this.electrolytesConsumedMg,
      sugarConsumedG: sugarConsumedG ?? this.sugarConsumedG,
      streakDays: streakDays ?? this.streakDays,
      streakFreezesAvailable:
          streakFreezesAvailable ?? this.streakFreezesAvailable,
    );
  }

  Map<String, dynamic> toJson() => {
        'target_ml': targetMl,
        'net_consumed_ml': netConsumedMl,
        'gross_consumed_ml': grossConsumedMl,
        'remaining_ml': remainingMl,
        'progress_percent': progressPercent,
        'is_goal_achieved': isGoalAchieved,
        'caffeine_consumed_mg': caffeineConsumedMg,
        'caffeine_budget_remaining_mg': caffeineBudgetRemainingMg,
        'caffeine_safety_status': caffeineSafetyStatus.name,
        'electrolytes_consumed_mg': electrolytesConsumedMg,
        'electrolyte_score_percent': electrolyteScorePercent,
        'electrolyte_status': electrolyteStatus.name,
        'sugar_consumed_g': sugarConsumedG,
        'sugar_budget_remaining_g': sugarBudgetRemainingG,
        'streak_days': streakDays,
        'streak_freezes_available': streakFreezesAvailable,
      };

  factory HydrationBudgetSummary.fromJson(Map<String, dynamic> json) {
    return HydrationBudgetSummary(
      targetMl: (json['target_ml'] as num?)?.toDouble() ?? 2500.0,
      netConsumedMl: (json['net_consumed_ml'] as num?)?.toDouble() ?? 0.0,
      grossConsumedMl:
          (json['gross_consumed_ml'] as num?)?.toDouble() ?? 0.0,
      caffeineConsumedMg:
          (json['caffeine_consumed_mg'] as num?)?.toDouble() ?? 0.0,
      electrolytesConsumedMg:
          (json['electrolytes_consumed_mg'] as num?)?.toDouble() ?? 0.0,
      sugarConsumedG:
          (json['sugar_consumed_g'] as num?)?.toDouble() ?? 0.0,
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
  final String companionEmoji;
  final int companionCapacityMl;
  final String companionStageTitle;
  final int evolutionStageIndex;
  final int userXp;
  final int xpUntilNextStage;
  final String activeBiomeId;
  final String activeBiomeName;
  final NextUnlockProgression nextUnlock;
  final CircadianContext circadianContext;
  final int unclaimedAchievementsCount;
  final List<int> quickLogPresetMl;

  static const NextUnlockProgression defaultNextUnlock =
      NextUnlockProgression(
    nextAnimalId: 'sea_otter',
    nextAnimalName: 'Ollie the Sea Otter',
    nextAnimalEmoji: '🦦',
    unlockXp: 1300,
    currentXp: 0,
    xpNeeded: 1300,
    progressFraction: 0.0,
  );

  static const CircadianContext defaultCircadianContext = CircadianContext(
    phaseName: 'Midday Focus',
    anchorTimeFormatted: '12:00',
    paceStatus: CircadianPaceStatus.onTrack,
    expectedProgressPercent: 50,
    suggestedNextSipMl: 250,
    suggestedBeverageName: 'Pure Water',
  );

  const OutOfAppTelemetrySnapshot({
    required this.timestamp,
    required this.budget,
    required this.activeCompanionId,
    required this.activeCompanionName,
    this.companionEmoji = '🦊',
    this.companionCapacityMl = 2500,
    required this.companionStageTitle,
    this.evolutionStageIndex = 0,
    required this.userXp,
    required this.xpUntilNextStage,
    this.activeBiomeId = 'bamboo_misty_springs',
    required this.activeBiomeName,
    this.nextUnlock = defaultNextUnlock,
    this.circadianContext = defaultCircadianContext,
    this.unclaimedAchievementsCount = 0,
    this.quickLogPresetMl = const [150, 250, 330, 500],
  });

  /// Notification title text
  String get notificationTitle =>
      '${budget.progressPercent}% of Goal • ${budget.remainingMl.round()}ml remaining';

  /// Notification body text summarizing companion & streak
  String get notificationBody =>
      '$companionEmoji Keep $activeCompanionName hydrated! Streak: ${budget.streakDays} days (${budget.streakFreezesAvailable} 🛡️ freezes left).';

  /// Primary widget headline
  String get widgetHeadline =>
      '${budget.netConsumedMl.round()} / ${budget.targetMl.round()} ml';

  /// Secondary widget subheadline
  String get widgetSubheadline =>
      '${circadianContext.paceStatus.label} • ${budget.caffeineSafetyStatus.label} Caffeine';

  OutOfAppTelemetrySnapshot copyWith({
    DateTime? timestamp,
    HydrationBudgetSummary? budget,
    String? activeCompanionId,
    String? activeCompanionName,
    String? companionEmoji,
    int? companionCapacityMl,
    String? companionStageTitle,
    int? evolutionStageIndex,
    int? userXp,
    int? xpUntilNextStage,
    String? activeBiomeId,
    String? activeBiomeName,
    NextUnlockProgression? nextUnlock,
    CircadianContext? circadianContext,
    int? unclaimedAchievementsCount,
    List<int>? quickLogPresetMl,
  }) {
    return OutOfAppTelemetrySnapshot(
      timestamp: timestamp ?? this.timestamp,
      budget: budget ?? this.budget,
      activeCompanionId: activeCompanionId ?? this.activeCompanionId,
      activeCompanionName: activeCompanionName ?? this.activeCompanionName,
      companionEmoji: companionEmoji ?? this.companionEmoji,
      companionCapacityMl: companionCapacityMl ?? this.companionCapacityMl,
      companionStageTitle: companionStageTitle ?? this.companionStageTitle,
      evolutionStageIndex: evolutionStageIndex ?? this.evolutionStageIndex,
      userXp: userXp ?? this.userXp,
      xpUntilNextStage: xpUntilNextStage ?? this.xpUntilNextStage,
      activeBiomeId: activeBiomeId ?? this.activeBiomeId,
      activeBiomeName: activeBiomeName ?? this.activeBiomeName,
      nextUnlock: nextUnlock ?? this.nextUnlock,
      circadianContext: circadianContext ?? this.circadianContext,
      unclaimedAchievementsCount:
          unclaimedAchievementsCount ?? this.unclaimedAchievementsCount,
      quickLogPresetMl: quickLogPresetMl ?? this.quickLogPresetMl,
    );
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'budget': budget.toJson(),
        'active_companion_id': activeCompanionId,
        'active_companion_name': activeCompanionName,
        'companion_emoji': companionEmoji,
        'companion_capacity_ml': companionCapacityMl,
        'companion_stage_title': companionStageTitle,
        'evolution_stage_index': evolutionStageIndex,
        'user_xp': userXp,
        'xp_until_next_stage': xpUntilNextStage,
        'active_biome_id': activeBiomeId,
        'active_biome_name': activeBiomeName,
        'next_unlock': nextUnlock.toJson(),
        'circadian_context': circadianContext.toJson(),
        'unclaimed_achievements_count': unclaimedAchievementsCount,
        'quick_log_preset_ml': quickLogPresetMl,
        'notification_title': notificationTitle,
        'notification_body': notificationBody,
        'widget_headline': widgetHeadline,
        'widget_subheadline': widgetSubheadline,
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
      activeCompanionId:
          json['active_companion_id'] as String? ?? 'red_panda',
      activeCompanionName:
          json['active_companion_name'] as String? ?? 'Ruby the Red Panda',
      companionEmoji: json['companion_emoji'] as String? ?? '🦊',
      companionCapacityMl:
          (json['companion_capacity_ml'] as num?)?.toInt() ?? 2500,
      companionStageTitle:
          json['companion_stage_title'] as String? ?? 'Hatchling',
      evolutionStageIndex:
          (json['evolution_stage_index'] as num?)?.toInt() ?? 0,
      userXp: (json['user_xp'] as num?)?.toInt() ?? 0,
      xpUntilNextStage:
          (json['xp_until_next_stage'] as num?)?.toInt() ?? 300,
      activeBiomeId:
          json['active_biome_id'] as String? ?? 'bamboo_misty_springs',
      activeBiomeName:
          json['active_biome_name'] as String? ?? 'Bamboo Misty Springs',
      nextUnlock: json['next_unlock'] != null
          ? NextUnlockProgression.fromJson(
              json['next_unlock'] as Map<String, dynamic>)
          : const NextUnlockProgression(
              nextAnimalId: 'capybara',
              nextAnimalName: 'Bramble the Capybara',
              nextAnimalEmoji: '🦫',
              unlockXp: 0,
              currentXp: 0,
              xpNeeded: 0,
              progressFraction: 1.0,
            ),
      circadianContext: json['circadian_context'] != null
          ? CircadianContext.fromJson(
              json['circadian_context'] as Map<String, dynamic>)
          : const CircadianContext(
              phaseName: 'Midday Focus',
              anchorTimeFormatted: '12:00',
              paceStatus: CircadianPaceStatus.onTrack,
              expectedProgressPercent: 50,
              suggestedNextSipMl: 250,
              suggestedBeverageName: 'Pure Water',
            ),
      unclaimedAchievementsCount:
          (json['unclaimed_achievements_count'] as num?)?.toInt() ?? 0,
      quickLogPresetMl: (json['quick_log_preset_ml'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [150, 250, 330, 500],
    );
  }
}
