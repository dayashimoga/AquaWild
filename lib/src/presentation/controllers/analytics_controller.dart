import 'package:aquawild/src/core/services/predictive_analytics_service.dart';
import 'package:aquawild/src/domain/models/predictive_analytics.dart';
import 'package:aquawild/src/presentation/controllers/hydration_controller.dart';
import 'package:aquawild/src/presentation/controllers/weather_activity_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State of the predictive analytics report.
class AnalyticsState {
  final bool isLoading;
  final PredictiveAnalyticsReport? report;

  const AnalyticsState({
    this.isLoading = false,
    this.report,
  });

  AnalyticsState copyWith({
    bool? isLoading,
    PredictiveAnalyticsReport? report,
  }) {
    return AnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      report: report ?? this.report,
    );
  }
}

/// Riverpod 3 Notifier managing predictive reports, weekly rolling trends, and circadian charts.
class AnalyticsNotifier extends Notifier<AnalyticsState> {
  late final PredictiveAnalyticsService _service;

  @override
  AnalyticsState build() {
    _service = PredictiveAnalyticsService();
    Future.microtask(() => refreshAnalytics());
    return const AnalyticsState();
  }

  /// Recalculates predictive report from current hydration logs and target.
  void refreshAnalytics() {
    final hydration = ref.read(hydrationProvider);
    final weather = ref.read(weatherActivityNotifierProvider);

    final generated = _service.generateReport(
      todayEntries: hydration.entries,
      todayNetMl: hydration.goal.netHydrationMl,
      targetGoalMl: weather.dynamicTargetMl,
    );

    state = state.copyWith(
      isLoading: false,
      report: generated,
    );
  }
}

/// Provider for Predictive Analytics.
final analyticsProvider =
    NotifierProvider<AnalyticsNotifier, AnalyticsState>(() {
  return AnalyticsNotifier();
});
