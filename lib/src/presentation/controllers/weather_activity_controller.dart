import 'package:aquawild/src/core/services/health_platform_service.dart';
import 'package:aquawild/src/core/services/weather_activity_service.dart';
import 'package:aquawild/src/domain/models/activity_session.dart';
import 'package:aquawild/src/domain/models/weather_condition.dart';
import 'package:aquawild/src/presentation/controllers/hydration_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State of environmental conditions, physical workouts, and dynamic hydration goals.
class WeatherActivityState {
  final WeatherCondition currentWeather;
  final List<ActivitySession> activities;
  final double baselineTargetMl;
  final double dynamicTargetMl;
  final bool isSyncingHealth;

  const WeatherActivityState({
    this.currentWeather = WeatherCondition.standard,
    this.activities = const [],
    this.baselineTargetMl = 2500.0,
    this.dynamicTargetMl = 2500.0,
    this.isSyncingHealth = false,
  });

  WeatherActivityState copyWith({
    WeatherCondition? currentWeather,
    List<ActivitySession>? activities,
    double? baselineTargetMl,
    double? dynamicTargetMl,
    bool? isSyncingHealth,
  }) {
    return WeatherActivityState(
      currentWeather: currentWeather ?? this.currentWeather,
      activities: activities ?? this.activities,
      baselineTargetMl: baselineTargetMl ?? this.baselineTargetMl,
      dynamicTargetMl: dynamicTargetMl ?? this.dynamicTargetMl,
      isSyncingHealth: isSyncingHealth ?? this.isSyncingHealth,
    );
  }
}

/// Riverpod 3 Notifier managing weather conditions and activity sessions.
class WeatherActivityNotifier extends Notifier<WeatherActivityState> {
  late final WeatherActivityService _calculator;
  late final HealthPlatformService _healthPlatform;

  @override
  WeatherActivityState build() {
    _calculator = const WeatherActivityService();
    _healthPlatform = LocalMockHealthPlatformService();
    return const WeatherActivityState();
  }

  /// Change current ambient weather condition and recalculate goal.
  void setWeather(WeatherCondition weather) {
    final newTarget = _calculator.computeDynamicTargetMl(
      weather: weather,
      activities: state.activities,
      customBaselineMl: state.baselineTargetMl,
    );

    state = state.copyWith(
      currentWeather: weather,
      dynamicTargetMl: newTarget,
    );

    // Update global hydration repository daily goal
    ref.read(hydrationProvider.notifier).setWeatherBonus(weather.weatherHydrationOffsetMl);
  }

  /// Log a physical activity workout and adjust hydration target.
  void logActivity(ActivitySession session) {
    final updated = List<ActivitySession>.from(state.activities)..add(session);
    final newTarget = _calculator.computeDynamicTargetMl(
      weather: state.currentWeather,
      activities: updated,
      customBaselineMl: state.baselineTargetMl,
    );

    state = state.copyWith(
      activities: updated,
      dynamicTargetMl: newTarget,
    );

    final workoutBonus = updated.fold<int>(0, (s, a) => s + a.recommendedReplenishmentMl);
    ref.read(hydrationProvider.notifier).setWorkoutBonus(workoutBonus);
  }

  /// Remove an activity session.
  void removeActivity(String id) {
    final updated = state.activities.where((a) => a.id != id).toList();
    final newTarget = _calculator.computeDynamicTargetMl(
      weather: state.currentWeather,
      activities: updated,
      customBaselineMl: state.baselineTargetMl,
    );

    state = state.copyWith(
      activities: updated,
      dynamicTargetMl: newTarget,
    );

    final workoutBonus = updated.fold<int>(0, (s, a) => s + a.recommendedReplenishmentMl);
    ref.read(hydrationProvider.notifier).setWorkoutBonus(workoutBonus);
  }

  /// Synchronize workouts and active calories with Apple Health / Google Health Connect.
  Future<void> syncHealthPlatform() async {
    state = state.copyWith(isSyncingHealth: true);
    await _healthPlatform.requestPermissions();
    final workouts = await _healthPlatform.fetchWorkouts(DateTime.now());

    if (!ref.mounted) return;

    final newTarget = _calculator.computeDynamicTargetMl(
      weather: state.currentWeather,
      activities: workouts,
      customBaselineMl: state.baselineTargetMl,
    );

    state = state.copyWith(
      activities: workouts,
      dynamicTargetMl: newTarget,
      isSyncingHealth: false,
    );

    final workoutBonus = workouts.fold<int>(0, (s, a) => s + a.recommendedReplenishmentMl);
    await ref.read(hydrationProvider.notifier).setWorkoutBonus(workoutBonus);
  }
}

/// Provider for dynamic weather and activity tracking.
final weatherActivityNotifierProvider =
    NotifierProvider<WeatherActivityNotifier, WeatherActivityState>(() {
  return WeatherActivityNotifier();
});
