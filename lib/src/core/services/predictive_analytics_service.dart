import 'package:aquawild/src/domain/models/hydration_entry.dart';
import 'package:aquawild/src/domain/models/predictive_analytics.dart';

/// Aggregates historical logs into circadian curves, weekly trends, and dehydration risk forecasts.
class PredictiveAnalyticsService {
  /// Generates a predictive analytics report based on user entries and daily target.
  PredictiveAnalyticsReport generateReport({
    required List<HydrationEntry> todayEntries,
    required double todayNetMl,
    required double targetGoalMl,
    List<DailyHydrationSummary>? pastWeekSummaries,
  }) {
    final now = DateTime.now();

    // 1. Build 7-day rolling window
    final weekSummaries = pastWeekSummaries ?? _buildSimulatedWeek(now, todayNetMl, targetGoalMl);

    // 2. Build 24-hour circadian hourly buckets
    final hourlyBuckets = List.generate(24, (hour) {
      final hourEntries = todayEntries.where((e) => e.timestamp.hour == hour);
      final vol = hourEntries.fold<double>(0.0, (s, e) => s + e.netHydrationMl);
      return HourlyIntakeBucket(hour: hour, volumeMl: vol);
    });

    // 3. Beverage category volume map
    final categoryMap = <String, double>{};
    for (final e in todayEntries) {
      final cat = e.beverage.category.name;
      categoryMap[cat] = (categoryMap[cat] ?? 0.0) + e.volumeMl;
    }

    // 4. Weekly average
    final weeklyAvg = weekSummaries.fold<double>(0.0, (s, d) => s + d.netHydrationMl) / weekSummaries.length;

    // 5. Predictive End-of-Day (EOD) Forecast
    // Active waking window is assumed 07:00 to 23:00 (16 hours).
    final currentHour = now.hour;
    final elapsedActiveHours = (currentHour - 7).clamp(1, 16);
    final hourlyPace = todayNetMl / elapsedActiveHours;
    final remainingActiveHours = (23 - currentHour).clamp(0, 16);
    final predictedEod = todayNetMl + (hourlyPace * remainingActiveHours);

    // 6. Dehydration Risk Index (0.0 to 1.0)
    final deficitRatio = (targetGoalMl - predictedEod) / (targetGoalMl > 0 ? targetGoalMl : 1.0);
    final riskScore = deficitRatio.clamp(0.0, 1.0);

    String insight;
    if (riskScore < 0.2) {
      insight = 'Flawless pacing! Your projected intake meets or exceeds your metabolic hydration target.';
    } else if (riskScore < 0.5) {
      insight = 'Moderate momentum. Sipping 250ml every 90 minutes will safely maintain equilibrium.';
    } else {
      insight = 'Elevated deficit detected. Your current intake pace lags behind circadian requirements. Prioritize rehydration!';
    }

    return PredictiveAnalyticsReport(
      last7Days: weekSummaries,
      todayHourlyDistribution: hourlyBuckets,
      categoryVolumeMap: categoryMap,
      weeklyAverageMl: weeklyAvg,
      predictedEodIntakeMl: predictedEod,
      dehydrationRiskScore: riskScore,
      predictiveInsight: insight,
    );
  }

  List<DailyHydrationSummary> _buildSimulatedWeek(DateTime now, double todayNet, double target) {
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      if (i == 6) {
        return DailyHydrationSummary(
          date: date,
          netHydrationMl: todayNet,
          targetGoalMl: target,
          drinksCount: (todayNet / 300).round(),
          goalAchieved: todayNet >= target,
        );
      }
      // Simulated realistic past days
      final simulatedMl = target * (0.85 + ((i * 17) % 35) / 100.0);
      return DailyHydrationSummary(
        date: date,
        netHydrationMl: simulatedMl,
        targetGoalMl: target,
        drinksCount: 6,
        goalAchieved: simulatedMl >= target,
      );
    });
  }
}
