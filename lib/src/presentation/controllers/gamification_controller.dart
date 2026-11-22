import 'package:aquawild/src/core/services/gamification_service.dart';
import 'package:aquawild/src/domain/models/achievement_badge.dart';
import 'package:aquawild/src/domain/models/hydration_streak.dart';
import 'package:aquawild/src/domain/models/seasonal_challenge.dart';
import 'package:aquawild/src/presentation/controllers/animal_habitat_controller.dart';
import 'package:aquawild/src/presentation/controllers/hydration_controller.dart';
import 'package:aquawild/src/presentation/controllers/weather_activity_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State of the gamification, habit streak, and achievement system.
class GamificationState {
  final HydrationStreak streak;
  final List<AchievementBadge> badges;
  final SeasonalChallenge activeChallenge;
  final AchievementBadge? recentlyUnlockedBadge;

  const GamificationState({
    this.streak = const HydrationStreak(currentStreakDays: 4, longestStreakDays: 12),
    this.badges = AchievementBadge.defaultAchievements,
    required this.activeChallenge,
    this.recentlyUnlockedBadge,
  });

  GamificationState copyWith({
    HydrationStreak? streak,
    List<AchievementBadge>? badges,
    SeasonalChallenge? activeChallenge,
    AchievementBadge? recentlyUnlockedBadge,
  }) {
    return GamificationState(
      streak: streak ?? this.streak,
      badges: badges ?? this.badges,
      activeChallenge: activeChallenge ?? this.activeChallenge,
      recentlyUnlockedBadge: recentlyUnlockedBadge,
    );
  }
}

/// Riverpod 3 Notifier managing habit streaks, achievement rewards, and seasonal quests.
class GamificationNotifier extends Notifier<GamificationState> {
  late final GamificationService _service;

  @override
  GamificationState build() {
    _service = GamificationService();
    return GamificationState(
      activeChallenge: SeasonalChallenge.currentSpringChallenge,
    );
  }

  /// Evaluates streaks and unlocks badges whenever drinks are logged.
  void checkProgress() {
    final hydration = ref.read(hydrationProvider);
    final habitat = ref.read(animalHabitatProvider);
    final weather = ref.read(weatherActivityNotifierProvider);

    final updatedStreak = _service.evaluateDailyStreak(
      currentStreak: state.streak,
      currentNetMl: hydration.goal.netHydrationMl,
      targetGoalMl: weather.dynamicTargetMl,
    );

    final updatedBadges = _service.evaluateAchievements(
      currentBadges: state.badges,
      allEntries: hydration.entries,
      streak: updatedStreak,
      userXp: habitat.userXp,
    );

    // Update seasonal challenge progress with current user XP
    final updatedChallenge = state.activeChallenge.copyWith(
      currentXp: habitat.userXp,
    );

    state = state.copyWith(
      streak: updatedStreak,
      badges: updatedBadges,
      activeChallenge: updatedChallenge,
    );
  }

  /// Consume a streak freeze manually to protect streak tomorrow.
  void deployStreakFreeze() {
    if (state.streak.streakFreezesAvailable > 0) {
      final updated = state.streak.copyWith(
        streakFreezesAvailable: state.streak.streakFreezesAvailable - 1,
        lastFreezeUsedDate: DateTime.now(),
      );
      state = state.copyWith(streak: updated);
    }
  }

  /// Claim a completed seasonal challenge reward.
  void claimChallengeReward() {
    if (state.activeChallenge.isCompleted && !state.activeChallenge.isClaimed) {
      state = state.copyWith(
        activeChallenge: state.activeChallenge.copyWith(isClaimed: true),
      );
      // Award 250 bonus XP
      ref.read(animalHabitatProvider.notifier).addXp(250);
    }
  }
}

/// Provider for the Gamification and Habit Engine.
final gamificationProvider =
    NotifierProvider<GamificationNotifier, GamificationState>(() {
  return GamificationNotifier();
});
