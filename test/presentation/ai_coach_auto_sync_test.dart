import 'package:aquawild/src/core/services/widget_notification_telemetry_service.dart';
import 'package:aquawild/src/data/repositories/local_hydration_repository.dart';
import 'package:aquawild/src/domain/models/beverage_type.dart';
import 'package:aquawild/src/domain/models/exotic_animal.dart';
import 'package:aquawild/src/domain/models/notification_payload.dart';
import 'package:aquawild/src/presentation/controllers/ai_coach_controller.dart';
import 'package:aquawild/src/presentation/controllers/animal_habitat_controller.dart';
import 'package:aquawild/src/presentation/controllers/hydration_controller.dart';
import 'package:aquawild/src/presentation/controllers/notification_controller.dart';
import 'package:aquawild/src/presentation/controllers/telemetry_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AI Hydration Coach Reactive Auto-Sync Tests', () {
    test('AiCoachNotifier automatically synchronizes when a drink is logged', () async {
      final repository = LocalHydrationRepository();
      final container = ProviderContainer(
        overrides: [
          hydrationRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      // Listen to aiCoachProvider to keep it active
      container.listen(aiCoachProvider, (_, _) {});
      container.listen(hydrationProvider, (_, _) {});

      // Initial advice should be fetched
      await container.read(aiCoachProvider.notifier).refreshAdvice();
      var coachState = container.read(aiCoachProvider);
      expect(coachState.recommendation, isNotNull);
      expect(
        coachState.recommendation!.companionMessage.contains('0% of your target') ||
            coachState.recommendation!.companionMessage.contains('Good morning!'),
        isTrue,
      );

      // Log a drink of 1000ml pure water
      await container.read(hydrationProvider.notifier).logDrink(
            beverage: BeverageType.pureWater,
            volumeMl: 1000.0,
          );
      await pumpEventQueue();

      // Verify AI Coach auto-updated without calling refreshAdvice manually!
      coachState = container.read(aiCoachProvider);
      expect(coachState.recommendation!.companionMessage, contains('40% of your target'));
      expect(coachState.recommendation!.companionMessage, contains('1500ml remaining'));
    });

    test('AiCoachNotifier automatically synchronizes when a drink is removed', () async {
      final repository = LocalHydrationRepository();
      final container = ProviderContainer(
        overrides: [
          hydrationRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      container.listen(aiCoachProvider, (_, _) {});
      container.listen(hydrationProvider, (_, _) {});

      // Log an entry
      await container.read(hydrationProvider.notifier).logDrink(
            beverage: BeverageType.pureWater,
            volumeMl: 500.0,
          );
      await pumpEventQueue();

      var coachState = container.read(aiCoachProvider);
      expect(
        coachState.recommendation!.companionMessage.contains('20% of your target') ||
            coachState.recommendation!.companionMessage.contains('Good morning!'),
        isTrue,
      );

      // Remove the entry
      final entryId = container.read(hydrationProvider).entries.first.id;
      await container.read(hydrationProvider.notifier).removeEntry(entryId);
      await pumpEventQueue();

      // Verify AI Coach auto-updated back to 0% / initial morning advice
      coachState = container.read(aiCoachProvider);
      expect(
        coachState.recommendation!.companionMessage.contains('0% of your target') ||
            coachState.recommendation!.companionMessage.contains('Good morning!'),
        isTrue,
      );
    });

    test('AiCoachNotifier transitions to Sanctuary Goal Conquered when daily target reached', () async {
      final repository = LocalHydrationRepository();
      final container = ProviderContainer(
        overrides: [
          hydrationRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      container.listen(aiCoachProvider, (_, _) {});
      container.listen(hydrationProvider, (_, _) {});

      // Log 2500ml to reach 100% of goal
      await container.read(hydrationProvider.notifier).logDrink(
            beverage: BeverageType.pureWater,
            volumeMl: 2500.0,
          );
      await pumpEventQueue();

      final coachState = container.read(aiCoachProvider);
      expect(coachState.recommendation!.headline, equals('Hydration Target Conquered! 🎉'));
      expect(coachState.recommendation!.companionMessage, contains('100%'));
    });

    test('AiCoachNotifier automatically synchronizes when companion is changed', () async {
      final repository = LocalHydrationRepository();
      final container = ProviderContainer(
        overrides: [
          hydrationRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      container.listen(aiCoachProvider, (_, _) {});
      container.listen(animalHabitatProvider, (_, _) {});

      await container.read(aiCoachProvider.notifier).refreshAdvice();
      await pumpEventQueue();
      var coachState = container.read(aiCoachProvider);
      expect(coachState.recommendation!.companionId, equals('red_panda'));

      // Switch active companion to Cappy the Capybara
      final capybara = ExoticAnimal.allAnimals.firstWhere((a) => a.id == 'capybara');
      await container.read(animalHabitatProvider.notifier).selectAnimal(capybara.id);
      await pumpEventQueue();

      coachState = container.read(aiCoachProvider);
      expect(coachState.recommendation!.companionId, equals('capybara'));
      expect(coachState.recommendation!.companionName, contains('Cappy'));
    });
  });

  group('Stage 6 End-to-End Reactive Telemetry Pipeline Tests', () {
    test('End-to-End: Drink log updates AI Coach, Telemetry Snapshot, Notification and Dispatcher', () async {
      final repository = LocalHydrationRepository();
      final telemetryService = WidgetNotificationTelemetryService();

      final container = ProviderContainer(
        overrides: [
          hydrationRepositoryProvider.overrideWithValue(repository),
          widgetNotificationTelemetryServiceProvider
              .overrideWithValue(telemetryService),
        ],
      );
      addTearDown(container.dispose);

      // Keep active
      container.listen(hydrationProvider, (_, _) {});
      container.listen(aiCoachProvider, (_, _) {});
      container.listen(telemetrySnapshotProvider, (_, _) {});
      container.listen(latestNotificationPayloadProvider, (_, _) {});

      // Initial state verification
      var telemetry = container.read(telemetrySnapshotProvider);
      expect(telemetry.budget.netConsumedMl, equals(0.0));
      expect(telemetry.budget.progressPercent, equals(0));

      // 1. Dispatch actionable quick-log notification (+250ml)
      final dispatcher = container.read(notificationActionDispatcherProvider);
      final result = await dispatcher.dispatchAction(NotificationAction.idLog250Ml);
      expect(result.status, equals(NotificationActionStatus.logged));
      await pumpEventQueue();

      // 2. Hydration provider auto-updated
      final hydration = container.read(hydrationProvider);
      expect(hydration.goal.netHydrationMl, equals(250.0));

      // 3. AI Coach auto-updated
      final coach = container.read(aiCoachProvider);
      expect(
        coach.recommendation!.companionMessage.contains('10% of your target') ||
            coach.recommendation!.companionMessage.contains('Good morning!'),
        isTrue,
      );

      // 4. Telemetry snapshot auto-updated
      telemetry = container.read(telemetrySnapshotProvider);
      expect(telemetry.budget.netConsumedMl, equals(250.0));
      expect(telemetry.budget.progressPercent, equals(10));

      // 5. Rich notification payload auto-updated
      final payload = container.read(latestNotificationPayloadProvider);
      expect(payload.subtitle, contains('250 / 2500 ml (10%)'));
      expect(payload.actions.length, equals(4));
    });
  });
}
