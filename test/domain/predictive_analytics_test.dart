import 'package:aquawild/src/core/services/predictive_analytics_service.dart';
import 'package:aquawild/src/domain/models/beverage_type.dart';
import 'package:aquawild/src/domain/models/hydration_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Predictive Analytics Engine Tests', () {
    test('generateReport builds 7-day rolling window, hourly curve, and risk metric', () {
      final service = PredictiveAnalyticsService();
      final now = DateTime.now();
      final entries = [
        HydrationEntry.create(
          id: '1',
          beverage: BeverageType.pureWater,
          volumeMl: 500.0,
          timestamp: now,
        ),
        HydrationEntry.create(
          id: '2',
          beverage: BeverageType.allBeverages.firstWhere((b) => b.id == 'coconut_water'),
          volumeMl: 330.0,
          timestamp: now,
        ),
      ];

      final report = service.generateReport(
        todayEntries: entries,
        todayNetMl: 830.0,
        targetGoalMl: 2500.0,
      );

      expect(report.last7Days.length, equals(7));
      expect(report.todayHourlyDistribution.length, equals(24));
      expect(report.categoryVolumeMap.isNotEmpty, isTrue);
      expect(report.predictedEodIntakeMl, greaterThan(0.0));
      expect(report.dehydrationRiskScore, inInclusiveRange(0.0, 1.0));
      expect(report.riskLabel, isNotEmpty);
      expect(report.predictiveInsight, isNotEmpty);
    });
  });
}
