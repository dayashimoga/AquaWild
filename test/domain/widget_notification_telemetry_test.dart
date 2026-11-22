import 'package:aquawild/src/core/services/widget_notification_telemetry_service.dart';
import 'package:aquawild/src/domain/models/animal_evolution_stage.dart';
import 'package:aquawild/src/domain/models/beverage_type.dart';
import 'package:aquawild/src/domain/models/daily_hydration_goal.dart';
import 'package:aquawild/src/domain/models/exotic_animal.dart';
import 'package:aquawild/src/domain/models/hydration_entry.dart';
import 'package:aquawild/src/domain/models/hydration_streak.dart';
import 'package:aquawild/src/domain/models/out_of_app_telemetry.dart';
import 'package:aquawild/src/domain/models/seasonal_challenge.dart';
import 'package:aquawild/src/presentation/controllers/animal_habitat_controller.dart';
import 'package:aquawild/src/presentation/controllers/gamification_controller.dart';
import 'package:aquawild/src/presentation/controllers/hydration_controller.dart';
import 'package:aquawild/src/presentation/controllers/telemetry_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late WidgetNotificationTelemetryService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    service = WidgetNotificationTelemetryService(prefs);
  });

  group('HydrationBudgetSummary Model Tests', () {
    test('Calculates water remaining, fraction, and percentage correctly', () {
      const summary = HydrationBudgetSummary(
        targetMl: 2500,
        netConsumedMl: 1750,
      );

      expect(summary.remainingMl, equals(750.0));
      expect(summary.progressFraction, equals(0.70));
      expect(summary.progressPercent, equals(70));
      expect(summary.isGoalAchieved, isFalse);
    });

    test('Identifies goal achieved when consumption meets or exceeds target', () {
      const achieved = HydrationBudgetSummary(
        targetMl: 2000,
        netConsumedMl: 2200,
      );

      expect(achieved.remainingMl, equals(0.0));
      expect(achieved.progressFraction, equals(1.10));
      expect(achieved.progressPercent, equals(110));
      expect(achieved.isGoalAchieved, isTrue);
    });

    test('Evaluates clinical caffeine safety tiers and remaining budget', () {
      // 100mg caffeine -> Safe (Optimal)
      const safe = HydrationBudgetSummary(
        targetMl: 2500,
        netConsumedMl: 1000,
        caffeineConsumedMg: 100,
      );
      expect(safe.caffeineSafetyStatus, equals(CaffeineSafetyStatus.safe));
      expect(safe.caffeineBudgetRemainingMg, equals(300.0));

      // 280mg caffeine -> Moderate
      const moderate = HydrationBudgetSummary(
        targetMl: 2500,
        netConsumedMl: 1500,
        caffeineConsumedMg: 280,
      );
      expect(moderate.caffeineSafetyStatus, equals(CaffeineSafetyStatus.moderate));
      expect(moderate.caffeineBudgetRemainingMg, equals(120.0));

      // 380mg caffeine -> Near limit (Caution)
      const caution = HydrationBudgetSummary(
        targetMl: 2500,
        netConsumedMl: 2000,
        caffeineConsumedMg: 380,
      );
      expect(caution.caffeineSafetyStatus, equals(CaffeineSafetyStatus.caution));
      expect(caution.caffeineBudgetRemainingMg, equals(20.0));

      // 450mg caffeine -> Exceeded
      const exceeded = HydrationBudgetSummary(
        targetMl: 2500,
        netConsumedMl: 2500,
        caffeineConsumedMg: 450,
      );
      expect(exceeded.caffeineSafetyStatus, equals(CaffeineSafetyStatus.exceeded));
      expect(exceeded.caffeineBudgetRemainingMg, equals(0.0));
    });

    test('Evaluates electrolyte sufficiency tiers', () {
      // 100mg electrolytes -> Depleted (<30%)
      const depleted = HydrationBudgetSummary(
        targetMl: 2500,
        netConsumedMl: 1000,
        electrolytesConsumedMg: 100,
      );
      expect(depleted.electrolyteStatus, equals(ElectrolyteBalanceStatus.depleted));
      expect(depleted.electrolyteScorePercent, equals(20));

      // 350mg electrolytes -> Optimal (70%)
      const optimal = HydrationBudgetSummary(
        targetMl: 2500,
        netConsumedMl: 1500,
        electrolytesConsumedMg: 350,
      );
      expect(optimal.electrolyteStatus, equals(ElectrolyteBalanceStatus.optimal));
      expect(optimal.electrolyteScorePercent, equals(70));

      // 600mg electrolytes -> Surplus (100% clamped)
      const surplus = HydrationBudgetSummary(
        targetMl: 2500,
        netConsumedMl: 2000,
        electrolytesConsumedMg: 600,
      );
      expect(surplus.electrolyteStatus, equals(ElectrolyteBalanceStatus.surplus));
      expect(surplus.electrolyteScorePercent, equals(120));
    });

    test('Evaluates 50g daily added sugar reference limit', () {
      const budget = HydrationBudgetSummary(
        targetMl: 2500,
        netConsumedMl: 1000,
        sugarConsumedG: 18.5,
      );

      expect(budget.sugarBudgetRemainingG, closeTo(31.5, 0.01));
    });

    test('HydrationBudgetSummary JSON serialization round-trips cleanly', () {
      const original = HydrationBudgetSummary(
        targetMl: 2650,
        netConsumedMl: 1850,
        grossConsumedMl: 1950,
        caffeineConsumedMg: 125,
        electrolytesConsumedMg: 380,
        sugarConsumedG: 12,
        streakDays: 7,
        streakFreezesAvailable: 2,
      );

      final json = original.toJson();
      final restored = HydrationBudgetSummary.fromJson(json);

      expect(restored.targetMl, equals(2650));
      expect(restored.netConsumedMl, equals(1850));
      expect(restored.grossConsumedMl, equals(1950));
      expect(restored.caffeineConsumedMg, equals(125));
      expect(restored.electrolytesConsumedMg, equals(380));
      expect(restored.sugarConsumedG, equals(12));
      expect(restored.streakDays, equals(7));
      expect(restored.streakFreezesAvailable, equals(2));
    });
  });

  group('CircadianPaceStatus & CircadianContext Tests', () {
    test('Evaluates circadian pace properly', () {
      // 60% progress vs 40% expected -> Ahead of pace
      expect(
        CircadianPaceStatus.evaluate(progressPercent: 60, expectedPercent: 40),
        equals(CircadianPaceStatus.aheadOfPace),
      );

      // 52% progress vs 50% expected -> On track
      expect(
        CircadianPaceStatus.evaluate(progressPercent: 52, expectedPercent: 50),
        equals(CircadianPaceStatus.onTrack),
      );

      // 40% progress vs 55% expected -> Behind pace
      expect(
        CircadianPaceStatus.evaluate(progressPercent: 40, expectedPercent: 55),
        equals(CircadianPaceStatus.behindPace),
      );

      // 20% progress vs 65% expected -> Critical deficit
      expect(
        CircadianPaceStatus.evaluate(progressPercent: 20, expectedPercent: 65),
        equals(CircadianPaceStatus.criticalDeficit),
      );
    });

    test('CircadianContext JSON round-trip', () {
      const original = CircadianContext(
        phaseName: 'Afternoon Rejuvenation',
        anchorTimeFormatted: '16:30',
        paceStatus: CircadianPaceStatus.onTrack,
        expectedProgressPercent: 75,
        suggestedNextSipMl: 330,
        suggestedBeverageName: 'Coconut Water',
      );

      final json = original.toJson();
      final restored = CircadianContext.fromJson(json);

      expect(restored.phaseName, equals('Afternoon Rejuvenation'));
      expect(restored.anchorTimeFormatted, equals('16:30'));
      expect(restored.paceStatus, equals(CircadianPaceStatus.onTrack));
      expect(restored.expectedProgressPercent, equals(75));
      expect(restored.suggestedNextSipMl, equals(330));
      expect(restored.suggestedBeverageName, equals('Coconut Water'));
    });
  });

  group('NextUnlockProgression Tests', () {
    test('Computes next unlock species and XP needed', () {
      // User with 500 XP: Sea Otter requires 1300 XP
      const nextProgression = NextUnlockProgression(
        nextAnimalId: 'sea_otter',
        nextAnimalName: 'Ollie the Sea Otter',
        nextAnimalEmoji: '🦦',
        unlockXp: 1300,
        currentXp: 500,
        xpNeeded: 800,
        progressFraction: 500 / 1300,
        isAllUnlocked: false,
      );

      expect(nextProgression.nextAnimalId, equals('sea_otter'));
      expect(nextProgression.xpNeeded, equals(800));
      expect(nextProgression.isAllUnlocked, isFalse);

      final json = nextProgression.toJson();
      final restored = NextUnlockProgression.fromJson(json);

      expect(restored.nextAnimalName, equals('Ollie the Sea Otter'));
      expect(restored.xpNeeded, equals(800));
      expect(restored.progressFraction, closeTo(0.384, 0.01));
    });
  });

  group('OutOfAppTelemetrySnapshot & Service Tests', () {
    test('Computes full telemetry snapshot from reactive states', () {
      final now = DateTime(2026, 11, 22, 14, 30); // 14:30 -> Post-Lunch

      // Hydration state with 2 logged drinks
      final drink1 = HydrationEntry.create(
        id: 'drink_1',
        beverage: BeverageType.citrusJuice,
        volumeMl: 300,
        timestamp: now.subtract(const Duration(hours: 4)),
      );
      final drink2 = HydrationEntry.create(
        id: 'drink_2',
        beverage: BeverageType.espresso,
        volumeMl: 60,
        timestamp: now.subtract(const Duration(hours: 2)),
      );

      final hydrationState = HydrationState(
        entries: [drink1, drink2],
        stratifiedLayers: const [],
        goal: const DailyHydrationGoal(
          baseGoalMl: 2500,
          totalConsumedMl: 360,
          netHydrationMl: 360,
          caffeineTotalMg: 126,
          electrolytesTotalMg: 15,
        ),
      );

      final habitatState = AnimalHabitatState(
        activeAnimal: ExoticAnimal.allAnimals[0],
        userXp: 750,
        currentStage: AnimalEvolutionStage.defaultStages[0],
        unlockedAnimals: [ExoticAnimal.allAnimals[0]],
        stageProgressFraction: 0.5,
        xpUntilNextStage: 250,
      );

      final gamificationState = GamificationState(
        streak: const HydrationStreak(
          currentStreakDays: 5,
          longestStreakDays: 14,
          streakFreezesAvailable: 2,
        ),
        activeChallenge: SeasonalChallenge.currentSpringChallenge,
      );

      final snapshot = service.computeSnapshot(
        hydrationState: hydrationState,
        habitatState: habitatState,
        gamificationState: gamificationState,
        clock: now,
      );

      expect(snapshot.budget.targetMl, equals(2500));
      expect(snapshot.budget.grossConsumedMl, equals(360));
      expect(snapshot.budget.streakDays, equals(5));
      expect(snapshot.budget.streakFreezesAvailable, equals(2));
      expect(snapshot.budget.caffeineConsumedMg, equals(126));
      expect(snapshot.budget.caffeineSafetyStatus, equals(CaffeineSafetyStatus.safe));

      // Post-lunch phase at 14:30
      expect(snapshot.circadianContext.phaseName, equals('Post-Lunch Digestion Boost'));
      expect(snapshot.circadianContext.anchorTimeFormatted, equals('13:30'));

      // Next unlock from 750 XP should be Sea Otter (1300 XP)
      expect(snapshot.nextUnlock.nextAnimalId, equals('sea_otter'));
      expect(snapshot.nextUnlock.unlockXp, equals(1300));
      expect(snapshot.nextUnlock.xpNeeded, equals(550));
      expect(snapshot.nextUnlock.isAllUnlocked, isFalse);

      // Notification and widget text helpers
      expect(snapshot.notificationTitle, contains('14% of Goal'));
      expect(snapshot.notificationTitle, contains('2140ml remaining'));
      expect(snapshot.notificationBody, contains('Ruby the Red Panda'));
      expect(snapshot.notificationBody, contains('Streak: 5 days'));
      expect(snapshot.widgetHeadline, contains('360 / 2500 ml'));
    });

    test('Saves and reloads telemetry snapshot from SharedPreferences', () async {
      final now = DateTime(2026, 11, 22, 10, 0);

      const hydrationState = HydrationState(
        entries: [],
        stratifiedLayers: [],
        goal: DailyHydrationGoal(
          baseGoalMl: 2200,
          totalConsumedMl: 1100,
          netHydrationMl: 1100,
          caffeineTotalMg: 45,
          electrolytesTotalMg: 20,
        ),
      );

      final habitatState = AnimalHabitatState(
        activeAnimal: ExoticAnimal.allAnimals[0],
        userXp: 3500,
        currentStage: AnimalEvolutionStage.defaultStages[2],
        unlockedAnimals: [ExoticAnimal.allAnimals[0]],
        stageProgressFraction: 0.8,
        xpUntilNextStage: 500,
      );

      final gamificationState = GamificationState(
        streak: const HydrationStreak(currentStreakDays: 12),
        activeChallenge: SeasonalChallenge.currentSpringChallenge,
      );

      final original = service.computeSnapshot(
        hydrationState: hydrationState,
        habitatState: habitatState,
        gamificationState: gamificationState,
        clock: now,
      );

      // Save to SharedPreferences
      await service.saveSnapshot(original);

      // Verify cached read matches
      final cached = service.getCachedSnapshot();
      expect(cached, isNotNull);
      expect(cached!.budget.targetMl, equals(2200));
      expect(cached.budget.netConsumedMl, equals(1100));
      expect(cached.budget.progressPercent, equals(50));
      expect(cached.budget.streakDays, equals(12));
      expect(cached.nextUnlock.nextAnimalId, equals('emperor_penguin')); // 4500 XP

      // Clear cache
      await service.clearCache();
      expect(service.getCachedSnapshot(), isNull);
    });
  });

  group('Reactive telemetrySnapshotProvider Integration Tests', () {
    test('telemetrySnapshotProvider automatically updates when a drink is logged', () async {
      final container = ProviderContainer(
        overrides: [
          widgetNotificationTelemetryServiceProvider.overrideWithValue(service),
        ],
      );
      addTearDown(container.dispose);

      // Initial telemetry snapshot
      final initial = container.read(telemetrySnapshotProvider);
      expect(initial.budget.netConsumedMl, equals(0.0));
      expect(initial.budget.progressPercent, equals(0));

      // Log 500ml of pure water
      await container.read(hydrationProvider.notifier).logDrink(
            beverage: BeverageType.pureWater,
            volumeMl: 500,
          );

      // Read updated telemetry
      final updated = container.read(telemetrySnapshotProvider);
      expect(updated.budget.netConsumedMl, equals(500.0));
      expect(updated.budget.progressPercent, equals(20)); // 500 / 2500 = 20%
      expect(updated.budget.remainingMl, equals(2000.0));

      // Log 60ml of espresso (high caffeine)
      await container.read(hydrationProvider.notifier).logDrink(
            beverage: BeverageType.espresso,
            volumeMl: 60,
          );

      final afterCoffee = container.read(telemetrySnapshotProvider);
      expect(afterCoffee.budget.caffeineConsumedMg, greaterThan(100.0));
      expect(afterCoffee.budget.caffeineSafetyStatus, equals(CaffeineSafetyStatus.safe));
    });
  });
}
