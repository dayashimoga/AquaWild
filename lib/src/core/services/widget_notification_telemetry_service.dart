import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/exotic_animal.dart';
import '../../domain/models/out_of_app_telemetry.dart';
import '../../presentation/controllers/animal_habitat_controller.dart';
import '../../presentation/controllers/biome_controller.dart';
import '../../presentation/controllers/gamification_controller.dart';
import '../../presentation/controllers/hydration_controller.dart';

/// Service coordinating real-time physiological budgets and telemetry snapshots
/// for out-of-app glanceability (Home/Lock-Screen Widgets, Wearables, Notification Handlers)
class WidgetNotificationTelemetryService {
  final SharedPreferences? _prefs;

  static const String storageKey = 'aquawild_widget_telemetry_snapshot';

  WidgetNotificationTelemetryService([this._prefs]);

  /// Computes a canonical OutOfAppTelemetrySnapshot from reactive application states
  OutOfAppTelemetrySnapshot computeSnapshot({
    required HydrationState hydrationState,
    required AnimalHabitatState habitatState,
    required GamificationState gamificationState,
    BiomeState? biomeState,
    DateTime? clock,
  }) {
    final now = clock ?? DateTime.now();

    // 1. Calculate nutrient aggregates from today's logged entries
    double electrolytesMg = hydrationState.goal.electrolytesTotalMg;
    double sugarG = 0.0;
    for (final entry in hydrationState.entries) {
      final volRatio = entry.volumeMl / 100.0;
      sugarG += volRatio * entry.beverage.sugarGramsPer100ml;
    }

    // 2. Build physiological budget summary
    final budget = HydrationBudgetSummary(
      targetMl: hydrationState.goal.effectiveGoalMl.toDouble(),
      netConsumedMl: hydrationState.goal.netHydrationMl,
      grossConsumedMl: hydrationState.goal.totalConsumedMl,
      caffeineConsumedMg: hydrationState.goal.caffeineTotalMg,
      electrolytesConsumedMg: electrolytesMg,
      sugarConsumedG: sugarG,
      streakDays: gamificationState.streak.currentStreakDays,
      streakFreezesAvailable: gamificationState.streak.streakFreezesAvailable,
    );

    // 3. Compute next companion unlock progression
    final userXp = habitatState.userXp;
    NextUnlockProgression nextUnlock;

    final lockedAnimals = ExoticAnimal.allAnimals
        .where((animal) => animal.unlockXp > userXp)
        .toList()
      ..sort((a, b) => a.unlockXp.compareTo(b.unlockXp));

    if (lockedAnimals.isEmpty) {
      nextUnlock = NextUnlockProgression(
        nextAnimalId: 'all_companions',
        nextAnimalName: 'All Companions',
        nextAnimalEmoji: '👑',
        unlockXp: userXp,
        currentXp: userXp,
        xpNeeded: 0,
        progressFraction: 1.0,
        isAllUnlocked: true,
      );
    } else {
      final next = lockedAnimals.first;
      final xpNeeded = next.unlockXp - userXp;
      final fraction = (userXp / next.unlockXp).clamp(0.0, 1.0);

      nextUnlock = NextUnlockProgression(
        nextAnimalId: next.id,
        nextAnimalName: next.name,
        nextAnimalEmoji: next.avatarEmoji,
        unlockXp: next.unlockXp,
        currentXp: userXp,
        xpNeeded: xpNeeded,
        progressFraction: fraction,
        isAllUnlocked: false,
      );
    }

    // 4. Compute circadian time-of-day pacing context
    final hour = now.hour;
    String phaseName;
    String anchorTime;
    int expectedPercent;
    int suggestedNextSipMl;
    String suggestedBeverage;

    if (hour < 9) {
      phaseName = 'Morning Awakening Sip';
      anchorTime = '08:00';
      expectedPercent = 15;
      suggestedNextSipMl = 300;
      suggestedBeverage = 'Lemon Water';
    } else if (hour < 12) {
      phaseName = 'Mid-Morning Cognitive Flow';
      anchorTime = '10:30';
      expectedPercent = 35;
      suggestedNextSipMl = 250;
      suggestedBeverage = 'Green Tea';
    } else if (hour < 15) {
      phaseName = 'Post-Lunch Digestion Boost';
      anchorTime = '13:30';
      expectedPercent = 55;
      suggestedNextSipMl = 250;
      suggestedBeverage = 'Pure Water';
    } else if (hour < 18) {
      phaseName = 'Afternoon Rejuvenation';
      anchorTime = '16:30';
      expectedPercent = 75;
      suggestedNextSipMl = 330;
      suggestedBeverage = 'Coconut Water';
    } else if (hour < 21) {
      phaseName = 'Evening Relaxing Taper';
      anchorTime = '19:30';
      expectedPercent = 90;
      suggestedNextSipMl = 200;
      suggestedBeverage = 'Herbal Tea';
    } else {
      phaseName = 'Night Tranquil Rest';
      anchorTime = '22:00';
      expectedPercent = 100;
      suggestedNextSipMl = 150;
      suggestedBeverage = 'Pure Water';
    }

    final paceStatus = CircadianPaceStatus.evaluate(
      progressPercent: budget.progressPercent,
      expectedPercent: expectedPercent,
    );

    final circadianContext = CircadianContext(
      phaseName: phaseName,
      anchorTimeFormatted: anchorTime,
      paceStatus: paceStatus,
      expectedProgressPercent: expectedPercent,
      suggestedNextSipMl: suggestedNextSipMl,
      suggestedBeverageName: suggestedBeverage,
    );

    // 5. Unclaimed badges count
    final unclaimedBadges = gamificationState.badges
        .where((b) => b.isUnlocked && b.unlockedAt != null)
        .length;

    final companion = habitatState.activeAnimal;
    final stage = habitatState.currentStage;
    final biome = biomeState?.activeBiome;

    return OutOfAppTelemetrySnapshot(
      timestamp: now,
      budget: budget,
      activeCompanionId: companion.id,
      activeCompanionName: companion.name,
      companionEmoji: companion.avatarEmoji,
      companionCapacityMl: companion.defaultCapacityMl,
      companionStageTitle: stage.title,
      evolutionStageIndex: stage.stageNumber - 1,
      userXp: userXp,
      xpUntilNextStage: habitatState.xpUntilNextStage,
      activeBiomeId: biome?.id ?? 'bamboo_misty_springs',
      activeBiomeName: biome?.name ?? 'Bamboo Misty Springs',
      nextUnlock: nextUnlock,
      circadianContext: circadianContext,
      unclaimedAchievementsCount: unclaimedBadges,
      quickLogPresetMl: const [150, 250, 330, 500],
    );
  }

  /// Persists the telemetry snapshot to local storage for background widget engines
  Future<void> saveSnapshot(OutOfAppTelemetrySnapshot snapshot) async {
    if (_prefs != null) {
      final jsonStr = jsonEncode(snapshot.toJson());
      await _prefs.setString(storageKey, jsonStr);
    }
  }

  /// Loads cached telemetry snapshot from persistent storage
  OutOfAppTelemetrySnapshot? getCachedSnapshot() {
    if (_prefs == null) return null;
    final jsonStr = _prefs.getString(storageKey);
    if (jsonStr == null || jsonStr.isEmpty) return null;

    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return OutOfAppTelemetrySnapshot.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Clears stored telemetry cache (for testing or reset)
  Future<void> clearCache() async {
    if (_prefs != null) {
      await _prefs.remove(storageKey);
    }
  }
}
