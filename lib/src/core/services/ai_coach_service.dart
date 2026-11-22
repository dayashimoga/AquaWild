import 'dart:convert';
import 'package:aquawild/src/domain/models/activity_session.dart';
import 'package:aquawild/src/domain/models/ai_recommendation.dart';
import 'package:aquawild/src/domain/models/exotic_animal.dart';
import 'package:aquawild/src/domain/models/hydration_entry.dart';
import 'package:aquawild/src/domain/models/weather_condition.dart';
import 'package:http/http.dart' as http;

/// OpenAI-compatible AI Hydration Coach Client with resilient offline heuristic fallback.
class AiCoachService {
  final http.Client _client;
  final String endpointUrl;
  final String? apiKey;
  final String modelName;

  AiCoachService({
    http.Client? client,
    this.endpointUrl = 'https://api.openai.com/v1',
    this.apiKey,
    this.modelName = 'gpt-4o-mini',
  }) : _client = client ?? http.Client();

  /// Whether an active API key is configured.
  bool get hasValidApiKey => apiKey != null && apiKey!.trim().isNotEmpty;

  /// Generates personalized contextual advice from the companion.
  /// If [apiKey] is absent or network fails, gracefully falls back to the deterministic heuristic engine.
  Future<AiRecommendation> getHydrationAdvice({
    required ExoticAnimal companion,
    required double currentIntakeMl,
    required double targetGoalMl,
    required List<HydrationEntry> recentEntries,
    required WeatherCondition weather,
    required List<ActivitySession> todayActivities,
  }) async {
    if (!hasValidApiKey) {
      return generateOfflineHeuristicRecommendation(
        companion: companion,
        currentIntakeMl: currentIntakeMl,
        targetGoalMl: targetGoalMl,
        recentEntries: recentEntries,
        weather: weather,
        todayActivities: todayActivities,
      );
    }

    try {
      final sanitizedPrompt = _buildContextPrompt(
        companion: companion,
        currentIntakeMl: currentIntakeMl,
        targetGoalMl: targetGoalMl,
        recentEntries: recentEntries,
        weather: weather,
        todayActivities: todayActivities,
      );

      final cleanEndpoint = endpointUrl.endsWith('/')
          ? '${endpointUrl}chat/completions'
          : '$endpointUrl/chat/completions';

      final response = await _client
          .post(
            Uri.parse(cleanEndpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${apiKey!.trim()}',
            },
            body: jsonEncode({
              'model': modelName,
              'response_format': {'type': 'json_object'},
              'messages': [
                {
                  'role': 'system',
                  'content': _getSystemPrompt(companion),
                },
                {
                  'role': 'user',
                  'content': sanitizedPrompt,
                },
              ],
              'temperature': 0.7,
              'max_tokens': 350,
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final choices = decoded['choices'] as List<dynamic>?;
        if (choices != null && choices.isNotEmpty) {
          final messageObj = choices[0]['message'];
          final contentStr = messageObj['content'] as String;
          final jsonContent = jsonDecode(contentStr) as Map<String, dynamic>;

          return AiRecommendation(
            companionId: companion.id,
            companionName: companion.name,
            headline: jsonContent['headline'] as String? ?? 'Hydration Insight',
            message: jsonContent['message'] as String? ?? 'Stay hydrated to fuel your journey!',
            recommendedIntakeMl: (jsonContent['recommendedIntakeMl'] as num?)?.toInt() ?? 250,
            suggestedBeverageId: jsonContent['suggestedBeverageId'] as String? ?? 'pure_water',
            electrolyteFocus: jsonContent['electrolyteFocus'] as bool? ?? false,
            urgency: _parseUrgency(jsonContent['urgency'] as String?),
            reasoningTags: (jsonContent['reasoningTags'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                ['AI Coach', companion.name],
            isFromOfflineHeuristic: false,
          );
        }
      }
    } catch (_) {
      // Graceful fallback to heuristic engine on network or token errors
    }

    return generateOfflineHeuristicRecommendation(
      companion: companion,
      currentIntakeMl: currentIntakeMl,
      targetGoalMl: targetGoalMl,
      recentEntries: recentEntries,
      weather: weather,
      todayActivities: todayActivities,
    );
  }

  /// Deterministic clinical & motivational heuristic rule system.
  AiRecommendation generateOfflineHeuristicRecommendation({
    required ExoticAnimal companion,
    required double currentIntakeMl,
    required double targetGoalMl,
    required List<HydrationEntry> recentEntries,
    required WeatherCondition weather,
    required List<ActivitySession> todayActivities,
  }) {
    final deficitMl = targetGoalMl - currentIntakeMl;
    final progressPercent = (currentIntakeMl / (targetGoalMl > 0 ? targetGoalMl : 1.0)) * 100.0;
    final now = DateTime.now();
    final hour = now.hour;

    // 1. Critical Post-Workout / High Activity Rule
    if (todayActivities.isNotEmpty) {
      final totalSweatLoss = todayActivities.fold<int>(
        0,
        (sum, a) => sum + a.estimatedSweatLossMl,
      );
      if (totalSweatLoss > 300) {
        return AiRecommendation(
          companionId: companion.id,
          companionName: companion.name,
          headline: 'Electrolyte Restoration Active',
          message:
              '${companion.name} noticed your intense workout session! Perspiration drained roughly ${totalSweatLoss}ml with vital electrolytes. Sip a cool coconut water or electrolyte blend to restore cellular equilibrium.',
          recommendedIntakeMl: 350,
          suggestedBeverageId: 'electrolyte_drink',
          electrolyteFocus: true,
          urgency: RecommendationUrgency.high,
          reasoningTags: ['Post-Workout', 'Electrolytes', '${totalSweatLoss}ml Sweat Loss'],
          isFromOfflineHeuristic: true,
        );
      }
    }

    // 2. High Heat / Muggy Weather Rule
    if (weather.temperatureCelsius > 28.0 || weather.heatIndexCelsius > 30.0) {
      return AiRecommendation(
        companionId: companion.id,
        companionName: companion.name,
        headline: 'Heat Index Hydration Shield',
        message:
            'Ambient temperatures at ${weather.cityName} have climbed to ${weather.temperatureCelsius.toStringAsFixed(1)}°C (${weather.description}). Your skin loses water through insensible perspiration. Take regular small sips!',
        recommendedIntakeMl: 300,
        suggestedBeverageId: 'pure_water',
        electrolyteFocus: weather.temperatureCelsius > 32.0,
        urgency: RecommendationUrgency.high,
        reasoningTags: ['Heatwave Compensation', '${weather.temperatureCelsius.toStringAsFixed(0)}°C Ambient', 'Cellular Defense'],
        isFromOfflineHeuristic: true,
      );
    }

    // 3. Morning Kickstart Rule (05:00 - 10:00)
    if (hour >= 5 && hour < 10 && currentIntakeMl < 500) {
      return AiRecommendation(
        companionId: companion.id,
        companionName: companion.name,
        headline: 'Morning Metabolism Awakening',
        message:
            'Good morning! After 7-8 hours of sleep respiration, your blood volume is naturally slightly concentrated. ${companion.name} recommends 400ml of fresh room-temperature water to activate circulation and digestion.',
        recommendedIntakeMl: 400,
        suggestedBeverageId: 'lemon_water',
        electrolyteFocus: false,
        urgency: RecommendationUrgency.normal,
        reasoningTags: ['Circadian Wakeup', 'Digestive Kickstart', 'Zero Overnight Deficit'],
        isFromOfflineHeuristic: true,
      );
    }

    // 4. Afternoon Slump / Caffeine Balancing Rule (13:00 - 17:00)
    if (hour >= 13 && hour < 17) {
      final hasRecentCoffee = recentEntries.any(
        (e) => e.beverage.id == 'espresso' || e.beverage.id == 'black_coffee',
      );
      if (hasRecentCoffee) {
        return AiRecommendation(
          companionId: companion.id,
          companionName: companion.name,
          headline: 'Caffeine Diuretic Balancing',
          message:
              'Enjoying afternoon coffee? Caffeine transiently increases glomerular filtration. Sip a glass of water alongside your brew to keep your fluid reserves optimal.',
          recommendedIntakeMl: 250,
          suggestedBeverageId: 'pure_water',
          electrolyteFocus: false,
          urgency: RecommendationUrgency.normal,
          reasoningTags: ['Afternoon Focus', 'Caffeine Buffer', 'Sustained Vitality'],
          isFromOfflineHeuristic: true,
        );
      }
    }

    // 5. Goal Achieved / Habitat Celebration Rule
    if (deficitMl <= 0) {
      return AiRecommendation(
        companionId: companion.id,
        companionName: companion.name,
        headline: 'Hydration Target Conquered! 🎉',
        message:
            'Magnificent work! You have reached ${progressPercent.toStringAsFixed(0)}% of your daily hydration goal. ${companion.name} is swimming happily in a flourishing crystal habitat. Rest easy with light herbal tea.',
        recommendedIntakeMl: 150,
        suggestedBeverageId: 'herbal_tea',
        electrolyteFocus: false,
        urgency: RecommendationUrgency.low,
        reasoningTags: ['Goal Complete', 'Habitat Thriving', 'Evening Relaxation'],
        isFromOfflineHeuristic: true,
      );
    }

    // 6. Default Steady Hydration Companion Guidance
    return AiRecommendation(
      companionId: companion.id,
      companionName: companion.name,
      headline: 'Rhythmic Hydration Rhythm',
      message:
          'You are currently at ${progressPercent.toStringAsFixed(0)}% of your target with ${deficitMl.round()}ml remaining. Keep your momentum steady with a crisp 250ml pour.',
      recommendedIntakeMl: 250,
      suggestedBeverageId: 'pure_water',
      electrolyteFocus: false,
      urgency: RecommendationUrgency.normal,
      reasoningTags: ['Steady Pace', '${deficitMl.round()}ml Remaining', companion.name],
      isFromOfflineHeuristic: true,
    );
  }

  String _getSystemPrompt(ExoticAnimal companion) {
    return '''
You are ${companion.name}, a sentient hydration companion (${companion.name} the ${companion.species}) in the AquaWild ecosystem.
Your role: Provide concise, medically sound, and delightful hydration guidance.
Respond ONLY with a valid JSON object matching this schema:
{
  "headline": "Short punchy title (max 5 words)",
  "message": "Warm, inspiring 2-sentence advice tailored to the user's weather, activity, and companion persona",
  "recommendedIntakeMl": 250,
  "suggestedBeverageId": "pure_water",
  "electrolyteFocus": false,
  "urgency": "normal",
  "reasoningTags": ["Tag 1", "Tag 2"]
}
Available urgency values: "low", "normal", "high", "immediate".
Valid beverage IDs: pure_water, sparkling_water, coconut_water, green_tea, herbal_tea, black_coffee, espresso, fresh_orange_juice, electrolyte_drink, kombucha, milk_whole, almond_milk, bone_broth, lemon_water, matcha_latte, protein_shake.
''';
  }

  String _buildContextPrompt({
    required ExoticAnimal companion,
    required double currentIntakeMl,
    required double targetGoalMl,
    required List<HydrationEntry> recentEntries,
    required WeatherCondition weather,
    required List<ActivitySession> todayActivities,
  }) {
    return jsonEncode({
      'companion': {
        'name': companion.name,
        'species': companion.species,
        'personality': companion.description,
      },
      'status': {
        'currentIntakeMl': currentIntakeMl.round(),
        'targetGoalMl': targetGoalMl.round(),
        'percentage': ((currentIntakeMl / (targetGoalMl > 0 ? targetGoalMl : 1)) * 100).round(),
        'entriesCountToday': recentEntries.length,
      },
      'weather': {
        'temperatureC': weather.temperatureCelsius,
        'humidity': weather.humidityPercentage,
        'uvIndex': weather.uvIndex,
        'condition': weather.description,
        'city': weather.cityName,
      },
      'activities': todayActivities
          .map((a) => {
                'type': a.activityType.name,
                'durationMinutes': a.durationMinutes,
                'calories': a.caloriesBurned,
                'sweatLossMl': a.estimatedSweatLossMl,
              })
          .toList(),
    });
  }

  RecommendationUrgency _parseUrgency(String? val) {
    if (val == null) return RecommendationUrgency.normal;
    switch (val.toLowerCase()) {
      case 'low':
        return RecommendationUrgency.low;
      case 'high':
        return RecommendationUrgency.high;
      case 'immediate':
      case 'critical':
        return RecommendationUrgency.immediate;
      default:
        return RecommendationUrgency.normal;
    }
  }
}
