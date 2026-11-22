/// Comprehensive daily goal status tracking physiological intake and environmental adjustments
class DailyHydrationGoal {
  final int baseGoalMl;
  final int weatherBonusMl;
  final int workoutBonusMl;
  final int altitudeBonusMl;
  final double totalConsumedMl;
  final double netHydrationMl;
  final double caffeineTotalMg;
  final double electrolytesTotalMg;

  const DailyHydrationGoal({
    required this.baseGoalMl,
    this.weatherBonusMl = 0,
    this.workoutBonusMl = 0,
    this.altitudeBonusMl = 0,
    required this.totalConsumedMl,
    required this.netHydrationMl,
    required this.caffeineTotalMg,
    required this.electrolytesTotalMg,
  });

  /// Total target in ml including all environmental & physical exertion multipliers
  int get effectiveGoalMl =>
      baseGoalMl + weatherBonusMl + workoutBonusMl + altitudeBonusMl;

  /// Progress fraction from 0.0 to 1.0 (capped at 1.0 for vessel height clamping, or unbounded)
  double get progressFraction {
    if (effectiveGoalMl <= 0) return 0.0;
    return (netHydrationMl / effectiveGoalMl).clamp(0.0, 1.0);
  }

  /// Exact percentage integer (e.g. 78%)
  int get progressPercent {
    if (effectiveGoalMl <= 0) return 0;
    return ((netHydrationMl / effectiveGoalMl) * 100).round();
  }

  /// Remaining volume in ml needed to hit daily optimal hydration
  double get remainingMl {
    final diff = effectiveGoalMl - netHydrationMl;
    return diff > 0 ? diff : 0.0;
  }

  DailyHydrationGoal copyWith({
    int? baseGoalMl,
    int? weatherBonusMl,
    int? workoutBonusMl,
    int? altitudeBonusMl,
    double? totalConsumedMl,
    double? netHydrationMl,
    double? caffeineTotalMg,
    double? electrolytesTotalMg,
  }) {
    return DailyHydrationGoal(
      baseGoalMl: baseGoalMl ?? this.baseGoalMl,
      weatherBonusMl: weatherBonusMl ?? this.weatherBonusMl,
      workoutBonusMl: workoutBonusMl ?? this.workoutBonusMl,
      altitudeBonusMl: altitudeBonusMl ?? this.altitudeBonusMl,
      totalConsumedMl: totalConsumedMl ?? this.totalConsumedMl,
      netHydrationMl: netHydrationMl ?? this.netHydrationMl,
      caffeineTotalMg: caffeineTotalMg ?? this.caffeineTotalMg,
      electrolytesTotalMg: electrolytesTotalMg ?? this.electrolytesTotalMg,
    );
  }
}
