import 'package:aquawild/src/core/services/audio_haptics_service.dart';
import 'package:aquawild/src/presentation/controllers/analytics_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Modal sheet presenting 7-day rolling intake, circadian hourly curve, and dehydration forecast.
class PredictiveAnalyticsSheet extends ConsumerWidget {
  const PredictiveAnalyticsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PredictiveAnalyticsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsState = ref.watch(analyticsProvider);
    final report = analyticsState.report;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1728).withValues(alpha: 0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: const Color(0xFF00B4D8).withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  '📊 Predictive Hydration Analytics',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Expanded(
            child: report == null
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // 1. Predictive Risk Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(report.riskBadgeColorHex).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Color(report.riskBadgeColorHex).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    report.riskLabel,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Color(report.riskBadgeColorHex),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Risk: ${(report.dehydrationRiskScore * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: Color(report.riskBadgeColorHex),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              report.predictiveInsight,
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Projected EOD Intake: ${report.predictedEodIntakeMl.toStringAsFixed(0)}ml • 7d Average: ${report.weeklyAverageMl.toStringAsFixed(0)}ml',
                              style: const TextStyle(color: Colors.white60, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 2. 7-Day Rolling Trend Bar Chart
                      const Text(
                        '7-Day Rolling Intake History',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 150,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF14243B),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: report.last7Days.map((summary) {
                            final pct = summary.progressFraction;
                            final barHeight = (pct * 60).clamp(6.0, 70.0);
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '${summary.netHydrationMl.toStringAsFixed(0)}m',
                                  style: const TextStyle(color: Colors.white54, fontSize: 8),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 22,
                                  height: barHeight,
                                  decoration: BoxDecoration(
                                    color: summary.goalAchieved
                                        ? const Color(0xFF00E5FF)
                                        : const Color(0xFF00B4D8).withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  summary.weekdayShort,
                                  style: TextStyle(
                                    color: summary.goalAchieved ? const Color(0xFF00E5FF) : Colors.white60,
                                    fontSize: 11,
                                    fontWeight: summary.goalAchieved ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 3. Circadian Hourly Distribution
                      const Text(
                        'Circadian Hourly Distribution (Today)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 90,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF14243B),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: report.todayHourlyDistribution.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final bucket = report.todayHourlyDistribution[index];
                            final hasVol = bucket.volumeMl > 0;
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  width: 14,
                                  height: hasVol ? 35 : 8,
                                  decoration: BoxDecoration(
                                    color: hasVol ? const Color(0xFFFFB703) : Colors.white12,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${bucket.hour}h',
                                  style: TextStyle(
                                    color: hasVol ? const Color(0xFFFFB703) : Colors.white38,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Refresh button
                      OutlinedButton.icon(
                        icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white70),
                        label: const Text('Recalculate Predictive Forecast', style: TextStyle(color: Colors.white70)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          AudioHapticsService.playTap();
                          ref.read(analyticsProvider.notifier).refreshAnalytics();
                        },
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
