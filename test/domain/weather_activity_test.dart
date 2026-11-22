import 'package:aquawild/src/core/services/weather_activity_service.dart';
import 'package:aquawild/src/domain/models/activity_session.dart';
import 'package:aquawild/src/domain/models/weather_condition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Weather & Activity Dynamic Goal Tests', () {
    test('Standard weather produces 0 additional weather offset', () {
      const standard = WeatherCondition.standard;
      expect(standard.weatherHydrationOffsetMl, equals(0));
    });

    test('High heat and humidity calculate positive weather offset', () {
      const tropical = WeatherCondition(
        temperatureCelsius: 32.0,
        humidityPercentage: 75.0,
        cityName: 'Tropical Shore',
      );
      // Heat: (32 - 22) * 25 = 250ml
      // Heat index > 28°C adds humidity offset
      expect(tropical.weatherHydrationOffsetMl, greaterThan(250));
      expect(tropical.heatIndexCelsius, greaterThan(32.0));
    });

    test('High altitude above 1500m compensates for respiratory loss', () {
      const alpine = WeatherCondition(
        temperatureCelsius: 18.0,
        humidityPercentage: 40.0,
        altitudeMeters: 2500.0, // 1000m above 1500m -> (1000/500)*150 = 300ml
        cityName: 'Alpine Peak',
      );
      expect(alpine.weatherHydrationOffsetMl, equals(300));
    });

    test('Activity sweat loss scales with intensity and duration', () {
      final run = ActivitySession(
        activityType: ActivityType.running,
        durationMinutes: 30,
        intensity: ActivityIntensity.high, // 18 ml/min
      );
      expect(run.estimatedSweatLossMl, equals(540));
      expect(run.recommendedReplenishmentMl, equals((540 * 1.25).round()));

      final walk = ActivitySession(
        activityType: ActivityType.walking,
        durationMinutes: 60,
        intensity: ActivityIntensity.light, // 6 ml/min
      );
      expect(walk.estimatedSweatLossMl, equals(360));
    });

    test('WeatherActivityService integrates weather and workouts into dynamic goal', () {
      const calculator = WeatherActivityService(baselineGoalMl: 2500.0);
      const hotWeather = WeatherCondition(
        temperatureCelsius: 30.0,
        humidityPercentage: 50.0,
      );
      final workout = ActivitySession(
        activityType: ActivityType.cycling,
        durationMinutes: 45,
        intensity: ActivityIntensity.moderate, // 12 ml/min -> 540ml sweat -> 675ml replenishment
      );

      final dynamicGoal = calculator.computeDynamicTargetMl(
        weather: hotWeather,
        activities: [workout],
      );

      // Baseline: 2500 + weatherOffset + activityOffset
      expect(dynamicGoal, greaterThan(3000.0));
      expect(dynamicGoal, lessThan(4500.0));
    });
  });
}
