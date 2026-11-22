import 'package:aquawild/src/domain/models/activity_session.dart';
import 'package:aquawild/src/domain/models/weather_condition.dart';

/// Calculates dynamic weather, altitude, and physical activity adjustments to baseline hydration targets.
class WeatherActivityService {
  /// Baseline standard sedentary hydration requirement in ml (typically 2500ml for average adult).
  final double baselineGoalMl;

  const WeatherActivityService({
    this.baselineGoalMl = 2500.0,
  });

  /// Computes the comprehensive dynamic daily hydration target.
  double computeDynamicTargetMl({
    required WeatherCondition weather,
    required List<ActivitySession> activities,
    double? customBaselineMl,
  }) {
    final base = customBaselineMl ?? baselineGoalMl;

    // Weather impact (heat, humidity, UV, altitude)
    final weatherOffset = weather.weatherHydrationOffsetMl.toDouble();

    // Physical activity sweat replenishment (125% of sweat loss)
    final activityOffset = activities.fold<double>(
      0.0,
      (sum, session) => sum + session.recommendedReplenishmentMl.toDouble(),
    );

    return (base + weatherOffset + activityOffset).clamp(1200.0, 6000.0);
  }

  /// Preset atmospheric simulations for local testing, demoing, and offline travel.
  static const List<WeatherCondition> environmentalPresets = [
    WeatherCondition(
      temperatureCelsius: 22.0,
      humidityPercentage: 45.0,
      uvIndex: 4.0,
      altitudeMeters: 50.0,
      description: 'Temperate Spring Day',
      cityName: 'Emerald Meadow',
    ),
    WeatherCondition(
      temperatureCelsius: 32.5,
      humidityPercentage: 78.0,
      uvIndex: 9.0,
      altitudeMeters: 10.0,
      description: 'Tropical Beachfront',
      cityName: 'Coral Bay',
    ),
    WeatherCondition(
      temperatureCelsius: 38.0,
      humidityPercentage: 20.0,
      uvIndex: 11.0,
      altitudeMeters: 300.0,
      description: 'Desert Heatwave',
      cityName: 'Golden Dunes',
    ),
    WeatherCondition(
      temperatureCelsius: 14.0,
      humidityPercentage: 55.0,
      uvIndex: 8.0,
      altitudeMeters: 2800.0,
      description: 'Alpine Mountain Locus',
      cityName: 'Highland Peak',
    ),
    WeatherCondition(
      temperatureCelsius: 29.0,
      humidityPercentage: 60.0,
      uvIndex: 6.0,
      altitudeMeters: 150.0,
      description: 'Urban Summer Afternoon',
      cityName: 'Neo Metropolis',
    ),
  ];
}
