import 'package:aquawild/src/domain/models/achievement_badge.dart';
import 'package:aquawild/src/domain/models/hydration_entry.dart';
import 'package:aquawild/src/domain/models/hydration_streak.dart';

/// Evaluates habit consistency streaks, milestone badges, and XP rewards.
class GamificationService {
  /// Evaluates and updates the streak based on target goal achievement.
  HydrationStreak evaluateDailyStreak({
    required HydrationStreak currentStreak,
    required double currentNetMl,
    required double targetGoalMl,
    DateTime? evalDate,
  }) {
    final now = evalDate ?? DateTime.now();
    final isGoalMet = currentNetMl >= targetGoalMl && targetGoalMl > 0;

    if (!isGoalMet) {
      // Check if day missed: if lastCompleted was yesterday, streak is still active today
      if (currentStreak.lastCompletedDate != null) {
        final daysDiff = now.difference(currentStreak.lastCompletedDate!).inDays;
        if (daysDiff > 1) {
          // Missed yesterday! Can we deploy a streak freeze?
          if (currentStreak.streakFreezesAvailable > 0 && !currentStreak.isFrozenToday) {
            return currentStreak.copyWith(
              streakFreezesAvailable: currentStreak.streakFreezesAvailable - 1,
              lastFreezeUsedDate: now,
            );
          } else if (daysDiff > 2) {
            // Streak broken
            return currentStreak.copyWith(currentStreakDays: 0);
          }
        }
      }
      return currentStreak;
    }

    // Goal met! Check if already recorded today
    if (currentStreak.isCompletedToday) {
      return currentStreak;
    }

    final newDays = currentStreak.currentStreakDays + 1;
    final newLongest = newDays > currentStreak.longestStreakDays ? newDays : currentStreak.longestStreakDays;

    return currentStreak.copyWith(
      currentStreakDays: newDays,
      longestStreakDays: newLongest,
      lastCompletedDate: now,
    );
  }

  /// Evaluates and unlocks achievement badges according to current user history.
  List<AchievementBadge> evaluateAchievements({
    required List<AchievementBadge> currentBadges,
    required List<HydrationEntry> allEntries,
    required HydrationStreak streak,
    required int userXp,
  }) {
    final now = DateTime.now();
    return currentBadges.map((badge) {
      if (badge.isUnlocked) return badge;

      bool unlocked = false;
      double progress = 0.0;

      switch (badge.id) {
        case 'first_sip':
          progress = allEntries.isNotEmpty ? 1.0 : 0.0;
          unlocked = allEntries.isNotEmpty;
          break;
        case 'streak_3':
          progress = (streak.currentStreakDays / 3.0).clamp(0.0, 1.0);
          unlocked = streak.currentStreakDays >= 3;
          break;
        case 'streak_7':
          progress = (streak.currentStreakDays / 7.0).clamp(0.0, 1.0);
          unlocked = streak.currentStreakDays >= 7;
          break;
        case 'streak_30':
          progress = (streak.currentStreakDays / 30.0).clamp(0.0, 1.0);
          unlocked = streak.currentStreakDays >= 30;
          break;
        case 'morning_ritual':
          final hasEarly = allEntries.any((e) => e.timestamp.hour < 9 && e.volumeMl >= 400);
          progress = hasEarly ? 1.0 : 0.0;
          unlocked = hasEarly;
          break;
        case 'electrolyte_alchemist':
          final hasElectrolyte = allEntries.any(
            (e) => e.beverage.category.name == 'electrolyte' || e.beverage.id == 'coconut_water',
          );
          progress = hasElectrolyte ? 1.0 : 0.0;
          unlocked = hasElectrolyte;
          break;
        case 'botanical_infusion':
          final hasTea = allEntries.any(
            (e) => e.beverage.category.name == 'tea' || e.beverage.id == 'green_tea',
          );
          progress = hasTea ? 1.0 : 0.0;
          unlocked = hasTea;
          break;
        case 'ruby_guardian':
          progress = (userXp / 500.0).clamp(0.0, 1.0);
          unlocked = userXp >= 500;
          break;
        case 'capy_zen':
          progress = (userXp / 300.0).clamp(0.0, 1.0);
          unlocked = userXp >= 300;
          break;
        case 'mythic_transcendence':
          progress = (userXp / 1500.0).clamp(0.0, 1.0);
          unlocked = userXp >= 1500;
          break;
        default:
          progress = 0.2;
          unlocked = false;
      }

      if (unlocked) {
        return badge.copyWith(
          isUnlocked: true,
          progressFraction: 1.0,
          unlockedAt: now,
        );
      } else {
        return badge.copyWith(progressFraction: progress);
      }
    }).toList();
  }
}
