import 'package:aquawild/src/core/services/ai_coach_service.dart';
import 'package:aquawild/src/domain/models/ai_recommendation.dart';
import 'package:aquawild/src/presentation/controllers/animal_habitat_controller.dart';
import 'package:aquawild/src/presentation/controllers/hydration_controller.dart';
import 'package:aquawild/src/presentation/controllers/weather_activity_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State of the OpenAI-compatible AI Hydration Coach.
class AiCoachState {
  final bool isLoading;
  final AiRecommendation? recommendation;
  final String? apiKey;
  final String customEndpoint;
  final String selectedModel;
  final String? errorMessage;

  const AiCoachState({
    this.isLoading = false,
    this.recommendation,
    this.apiKey,
    this.customEndpoint = 'https://api.openai.com/v1',
    this.selectedModel = 'gpt-4o-mini',
    this.errorMessage,
  });

  AiCoachState copyWith({
    bool? isLoading,
    AiRecommendation? recommendation,
    String? apiKey,
    String? customEndpoint,
    String? selectedModel,
    String? errorMessage,
  }) {
    return AiCoachState(
      isLoading: isLoading ?? this.isLoading,
      recommendation: recommendation ?? this.recommendation,
      apiKey: apiKey ?? this.apiKey,
      customEndpoint: customEndpoint ?? this.customEndpoint,
      selectedModel: selectedModel ?? this.selectedModel,
      errorMessage: errorMessage,
    );
  }
}

/// Riverpod 3 Notifier managing intelligent AI hydration advice.
class AiCoachNotifier extends Notifier<AiCoachState> {
  AiCoachService? _service;

  @override
  AiCoachState build() {
    _service = AiCoachService();

    // Listen reactively to hydration state mutations (drink logged, removed, or goal changed)
    ref.listen<HydrationState>(hydrationProvider, (previous, next) {
      if (previous == null ||
          previous.goal.netHydrationMl != next.goal.netHydrationMl ||
          previous.entries.length != next.entries.length ||
          previous.goal.baseGoalMl != next.goal.baseGoalMl) {
        refreshAdvice();
      }
    });

    // Listen reactively to active companion switches
    ref.listen<AnimalHabitatState>(animalHabitatProvider, (previous, next) {
      if (previous?.activeAnimal.id != next.activeAnimal.id) {
        refreshAdvice();
      }
    });

    // Listen reactively to weather & workout activity target adjustments
    ref.listen<WeatherActivityState>(weatherActivityNotifierProvider,
        (previous, next) {
      if (previous?.dynamicTargetMl != next.dynamicTargetMl ||
          previous?.activities.length != next.activities.length) {
        refreshAdvice();
      }
    });

    // Auto-fetch initial advice on startup
    Future.microtask(() => refreshAdvice());
    return const AiCoachState();
  }

  AiCoachService get service {
    return _service ??= AiCoachService(
      endpointUrl: state.customEndpoint,
      apiKey: state.apiKey,
      modelName: state.selectedModel,
    );
  }

  /// Update custom LLM provider configuration.
  void updateConfig({
    String? apiKey,
    String? customEndpoint,
    String? selectedModel,
  }) {
    final newEndpoint = customEndpoint ?? state.customEndpoint;
    final newKey = apiKey ?? state.apiKey;
    final newModel = selectedModel ?? state.selectedModel;

    _service = AiCoachService(
      endpointUrl: newEndpoint,
      apiKey: newKey,
      modelName: newModel,
    );

    state = state.copyWith(
      apiKey: newKey,
      customEndpoint: newEndpoint,
      selectedModel: newModel,
    );

    refreshAdvice();
  }

  /// Fetches real-time personalized hydration guidance.
  Future<void> refreshAdvice() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final hydrationState = ref.read(hydrationProvider);
    final habitatState = ref.read(animalHabitatProvider);
    final weatherState = ref.read(weatherActivityNotifierProvider);

    try {
      final advice = await service.getHydrationAdvice(
        companion: habitatState.activeAnimal,
        currentIntakeMl: hydrationState.goal.netHydrationMl,
        targetGoalMl: weatherState.dynamicTargetMl,
        recentEntries: hydrationState.entries,
        weather: weatherState.currentWeather,
        todayActivities: weatherState.activities,
      );

      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        recommendation: advice,
      );
    } catch (e) {
      if (!ref.mounted) return;
      // Fallback on error
      final fallback = service.generateOfflineHeuristicRecommendation(
        companion: habitatState.activeAnimal,
        currentIntakeMl: hydrationState.goal.netHydrationMl,
        targetGoalMl: weatherState.dynamicTargetMl,
        recentEntries: hydrationState.entries,
        weather: weatherState.currentWeather,
        todayActivities: weatherState.activities,
      );

      state = state.copyWith(
        isLoading: false,
        recommendation: fallback,
        errorMessage: 'Offline mode active: Using clinical heuristic engine',
      );
    }
  }
}

/// Provider for the AI Hydration Coach.
final aiCoachNotifierProvider =
    NotifierProvider<AiCoachNotifier, AiCoachState>(() {
  return AiCoachNotifier();
});

/// Alias provider for AI Coach
final aiCoachProvider = aiCoachNotifierProvider;
