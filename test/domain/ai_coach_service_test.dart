import 'package:aquawild/src/core/services/ai_coach_service.dart';
import 'package:aquawild/src/domain/models/activity_session.dart';
import 'package:aquawild/src/domain/models/ai_recommendation.dart';
import 'package:aquawild/src/domain/models/exotic_animal.dart';
import 'package:aquawild/src/domain/models/weather_condition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AI Coach Service & Heuristic Advice Engine Tests', () {
    late AiCoachService service;
    late ExoticAnimal redPanda;

    setUp(() {
      service = AiCoachService();
      redPanda = ExoticAnimal.allAnimals.first; // Ruby the Red Panda
    });

    test('Heuristic engine generates high urgency electrolyte recommendation after intense workout', () {
      final highSweatSession = ActivitySession(
        activityType: ActivityType.hiit,
        durationMinutes: 45,
        intensity: ActivityIntensity.extreme, // 24 ml/min -> 1080ml
      );

      final advice = service.generateOfflineHeuristicRecommendation(
        companion: redPanda,
        currentIntakeMl: 1000.0,
        targetGoalMl: 2500.0,
        recentEntries: [],
        weather: WeatherCondition.standard,
        todayActivities: [highSweatSession],
      );

      expect(advice.companionName, contains('Ruby'));
      expect(advice.electrolyteFocus, isTrue);
      expect(advice.urgency, equals(RecommendationUrgency.high));
      expect(advice.suggestedBeverageId, equals('electrolyte_drink'));
      expect(advice.isFromOfflineHeuristic, isTrue);
    });

    test('Heuristic engine generates heatwave hydration defense for hot weather', () {
      const heatwave = WeatherCondition(
        temperatureCelsius: 34.0,
        humidityPercentage: 70.0,
        cityName: 'Neo Metropolis',
      );

      final advice = service.generateOfflineHeuristicRecommendation(
        companion: redPanda,
        currentIntakeMl: 800.0,
        targetGoalMl: 2500.0,
        recentEntries: [],
        weather: heatwave,
        todayActivities: [],
      );

      expect(advice.urgency, equals(RecommendationUrgency.high));
      expect(advice.headline, contains('Heat'));
      expect(advice.reasoningTags, contains(predicate((String s) => s.contains('Heatwave'))));
    });

    test('Heuristic engine celebrates when daily goal is reached or exceeded', () {
      final advice = service.generateOfflineHeuristicRecommendation(
        companion: redPanda,
        currentIntakeMl: 2600.0,
        targetGoalMl: 2500.0,
        recentEntries: [],
        weather: WeatherCondition.standard,
        todayActivities: [],
      );

      expect(advice.urgency, equals(RecommendationUrgency.low));
      expect(advice.headline, contains('Target Conquered'));
      expect(advice.suggestedBeverageId, equals('herbal_tea'));
    });
  });
}
