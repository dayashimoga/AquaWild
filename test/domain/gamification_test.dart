import 'package:aquawild/src/core/services/gamification_service.dart';
import 'package:aquawild/src/domain/models/achievement_badge.dart';
import 'package:aquawild/src/domain/models/beverage_type.dart';
import 'package:aquawild/src/domain/models/hydration_entry.dart';
import 'package:aquawild/src/domain/models/hydration_streak.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Gamification & Habit Streak Engine Tests', () {
    late GamificationService service;

    setUp(() {
      service = GamificationService();
    });

    test('Meeting goal increments daily streak and updates longest streak', () {
      const initial = HydrationStreak(currentStreakDays: 2, longestStreakDays: 5);
      final updated = service.evaluateDailyStreak(
        currentStreak: initial,
        currentNetMl: 2600.0,
        targetGoalMl: 2500.0,
      );

      expect(updated.currentStreakDays, equals(3));
      expect(updated.longestStreakDays, equals(5));
      expect(updated.isCompletedToday, isTrue);
    });

    test('Streak freeze preserves streak when a day is missed', () {
      final now = DateTime.now();
      final twoDaysAgo = now.subtract(const Duration(days: 2));
      final initial = HydrationStreak(
        currentStreakDays: 8,
        longestStreakDays: 14,
        streakFreezesAvailable: 2,
        lastCompletedDate: twoDaysAgo,
      );

      final result = service.evaluateDailyStreak(
        currentStreak: initial,
        currentNetMl: 500.0,
        targetGoalMl: 2500.0,
        evalDate: now,
      );

      expect(result.streakFreezesAvailable, equals(1));
      expect(result.currentStreakDays, equals(8)); // Protected by freeze!
    });

    test('Achievement evaluation unlocks badges upon meeting criteria', () {
      const badges = AchievementBadge.defaultAchievements;
      const streak = HydrationStreak(currentStreakDays: 4, longestStreakDays: 4);
      final entries = [
        HydrationEntry.create(
          id: '1',
          beverage: BeverageType.pureWater,
          volumeMl: 500.0,
        ),
      ];

      final evaluated = service.evaluateAchievements(
        currentBadges: badges,
        allEntries: entries,
        streak: streak,
        userXp: 600,
      );

      final firstSip = evaluated.firstWhere((b) => b.id == 'first_sip');
      expect(firstSip.isUnlocked, isTrue);

      final streak3 = evaluated.firstWhere((b) => b.id == 'streak_3');
      expect(streak3.isUnlocked, isTrue);

      final rubyGuardian = evaluated.firstWhere((b) => b.id == 'ruby_guardian');
      expect(rubyGuardian.isUnlocked, isTrue); // Unlocked at 500 XP
    });
  });
}
