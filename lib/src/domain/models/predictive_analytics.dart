/// Daily summary record for predictive analytics and 7-day rolling charts.
class DailyHydrationSummary {
  final DateTime date;
  final double netHydrationMl;
  final double targetGoalMl;
  final int drinksCount;
  final bool goalAchieved;

  const DailyHydrationSummary({
    required this.date,
    required this.netHydrationMl,
    required this.targetGoalMl,
    required this.drinksCount,
    required this.goalAchieved,
  });

  double get progressFraction {
    if (targetGoalMl <= 0) return 0.0;
    return (netHydrationMl / targetGoalMl).clamp(0.0, 1.5);
  }

  String get weekdayShort {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}

/// Hourly consumption bucket for circadian curve analysis.
class HourlyIntakeBucket {
  final int hour; // 0 to 23
  final double volumeMl;

  const HourlyIntakeBucket({
    required this.hour,
    required this.volumeMl,
  });

  String get label => '${hour.toString().padLeft(2, '0')}:00';
}

/// Aggregated predictive analytics dataset calculating dehydration risk,
/// weekly rolling intake, and intake composition.
class PredictiveAnalyticsReport {
  final List<DailyHydrationSummary> last7Days;
  final List<HourlyIntakeBucket> todayHourlyDistribution;
  final Map<String, double> categoryVolumeMap;
  final double weeklyAverageMl;
  final double predictedEodIntakeMl;
  final double dehydrationRiskScore; // 0.0 (Optimal) to 1.0 (Critical)
  final String predictiveInsight;

  const PredictiveAnalyticsReport({
    required this.last7Days,
    required this.todayHourlyDistribution,
    required this.categoryVolumeMap,
    required this.weeklyAverageMl,
    required this.predictedEodIntakeMl,
    required this.dehydrationRiskScore,
    required this.predictiveInsight,
  });

  /// Risk label for UI badge.
  String get riskLabel {
    if (dehydrationRiskScore < 0.25) return 'Optimal Balance';
    if (dehydrationRiskScore < 0.50) return 'Mild Deficit';
    if (dehydrationRiskScore < 0.75) return 'Elevated Risk';
    return 'Critical Dehydration';
  }

  int get riskBadgeColorHex {
    if (dehydrationRiskScore < 0.25) return 0xFF26A69A; // Teal Green
    if (dehydrationRiskScore < 0.50) return 0xFF00B4D8; // Ocean Blue
    if (dehydrationRiskScore < 0.75) return 0xFFFFB703; // Amber
    return 0xFFFF5252; // Coral Red
  }
}
