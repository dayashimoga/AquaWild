import 'package:aquawild/src/core/services/rich_notification_service.dart';
import 'package:aquawild/src/core/services/widget_notification_telemetry_service.dart';
import 'package:aquawild/src/data/repositories/hydration_repository.dart';
import 'package:aquawild/src/data/repositories/local_hydration_repository.dart';
import 'package:aquawild/src/domain/models/notification_payload.dart';
import 'package:aquawild/src/domain/models/out_of_app_telemetry.dart';
import 'package:aquawild/src/presentation/controllers/hydration_controller.dart';
import 'package:aquawild/src/presentation/controllers/notification_controller.dart';
import 'package:aquawild/src/presentation/controllers/telemetry_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RichNotificationPayload & Action Models Tests', () {
    test('NotificationAction serializes and deserializes cleanly', () {
      const action = NotificationAction(
        id: 'test_action',
        title: 'Drink 300ml',
        icon: 'water_drop',
        isDestructive: false,
        isForeground: true,
      );

      final json = action.toJson();
      expect(json['id'], equals('test_action'));
      expect(json['title'], equals('Drink 300ml'));
      expect(json['isForeground'], isTrue);

      final reconstructed = NotificationAction.fromJson(json);
      expect(reconstructed, equals(action));
      expect(reconstructed.id, equals(action.id));
      expect(reconstructed.title, equals(action.title));
      expect(reconstructed.isForeground, equals(action.isForeground));
    });

    test('RichNotificationPayload serializes and deserializes accurately', () {
      final payload = RichNotificationPayload(
        id: 'notif_1001',
        title: 'Time for a Sip! 💧 (Bramble)',
        subtitle: '1250 / 2500 ml (50%) • On Track',
        body: 'Mid-Morning Focus: Aim for 250ml of Green Tea.',
        companionQuote: 'Bramble gently points a fluffy paw.',
        companionEmoji: '🐾',
        companionName: 'Bramble',
        badgeNumber: 1,
        actions: const [
          NotificationAction.actionLog250Ml,
          NotificationAction.actionLog500Ml,
          NotificationAction.actionSnooze30Min,
          NotificationAction.actionViewSanctuary,
        ],
        data: {'progress': 50, 'streak': 7},
        scheduledTime: DateTime(2026, 11, 22, 10, 30),
        isGoalCompleted: false,
      );

      final json = payload.toJson();
      expect(json['id'], equals('notif_1001'));
      expect(json['actions'].length, equals(4));
      expect(json['data']['progress'], equals(50));

      final reconstructed = RichNotificationPayload.fromJson(json);
      expect(reconstructed.id, equals(payload.id));
      expect(reconstructed.title, equals(payload.title));
      expect(reconstructed.actions.length, equals(4));
      expect(reconstructed.scheduledTime, equals(DateTime(2026, 11, 22, 10, 30)));
      expect(reconstructed.isGoalCompleted, isFalse);
    });

    test('NotificationActionResult evaluates isSuccess and JSON roundtrip', () {
      const loggedResult = NotificationActionResult(
        actionId: NotificationAction.idLog250Ml,
        status: NotificationActionStatus.logged,
        message: 'Logged 250ml of Pure Water!',
        volumeLoggedMl: 250.0,
      );
      expect(loggedResult.isSuccess, isTrue);

      final snoozedResult = NotificationActionResult(
        actionId: NotificationAction.idSnooze30Min,
        status: NotificationActionStatus.snoozed,
        message: 'Snoozed for 30m',
        snoozedUntil: DateTime(2026, 11, 22, 11, 0),
      );
      expect(snoozedResult.isSuccess, isTrue);

      const ignoredResult = NotificationActionResult(
        actionId: 'unknown',
        status: NotificationActionStatus.ignored,
        message: 'Ignored',
      );
      expect(ignoredResult.isSuccess, isFalse);

      final json = loggedResult.toJson();
      final reconstructed = NotificationActionResult.fromJson(json);
      expect(reconstructed.actionId, equals(loggedResult.actionId));
      expect(reconstructed.status, equals(NotificationActionStatus.logged));
      expect(reconstructed.volumeLoggedMl, equals(250.0));
    });
  });

  group('RichNotificationService Payload Generator Tests', () {
    late RichNotificationService service;

    setUp(() {
      service = const RichNotificationService();
    });

    OutOfAppTelemetrySnapshot createTestSnapshot({
      double netConsumedMl = 1250,
      double targetMl = 2500,
      double caffeineConsumedMg = 100,
      double electrolytesConsumedMg = 400,
      double sugarConsumedG = 10,
      int streakDays = 6,
      String companionId = 'red_panda',
      String companionName = 'Bramble',
      CircadianPaceStatus pace = CircadianPaceStatus.onTrack,
    }) {
      return OutOfAppTelemetrySnapshot(
        timestamp: DateTime(2026, 11, 22, 11, 0),
        budget: HydrationBudgetSummary(
          targetMl: targetMl,
          netConsumedMl: netConsumedMl,
          grossConsumedMl: netConsumedMl,
          caffeineConsumedMg: caffeineConsumedMg,
          electrolytesConsumedMg: electrolytesConsumedMg,
          sugarConsumedG: sugarConsumedG,
          streakDays: streakDays,
        ),
        activeCompanionId: companionId,
        activeCompanionName: companionName,
        companionEmoji: '🐾',
        companionCapacityMl: 2500,
        companionStageTitle: 'Novice Puddle Cub',
        evolutionStageIndex: 0,
        userXp: 500,
        xpUntilNextStage: 500,
        activeBiomeId: 'bamboo_misty_springs',
        activeBiomeName: 'Bamboo Misty Springs',
        nextUnlock: const NextUnlockProgression(
          nextAnimalId: 'capybara',
          nextAnimalName: 'Barnaby the Capybara',
          nextAnimalEmoji: '🦫',
          unlockXp: 800,
          currentXp: 500,
          xpNeeded: 300,
          progressFraction: 0.625,
          isAllUnlocked: false,
        ),
        circadianContext: CircadianContext(
          phaseName: 'Mid-Morning Cognitive Flow',
          anchorTimeFormatted: '10:30',
          paceStatus: pace,
          expectedProgressPercent: 35,
          suggestedNextSipMl: 250,
          suggestedBeverageName: 'Green Tea',
        ),
        unclaimedAchievementsCount: 2,
        quickLogPresetMl: const [150, 250, 330, 500],
      );
    }

    test('Generates in-progress payload with 4 actionable buttons', () {
      final snapshot = createTestSnapshot();
      final payload = service.buildPayload(snapshot: snapshot);

      expect(payload.title, contains('Time for a Sip! 💧 (Bramble)'));
      expect(payload.subtitle, contains('1250 / 2500 ml (50%)'));
      expect(payload.subtitle, contains('On Track'));
      expect(payload.body, contains('Mid-Morning Cognitive Flow'));
      expect(payload.body, contains('250ml'));
      expect(payload.actions.length, equals(4));
      expect(payload.actions[0].id, equals(NotificationAction.idLog250Ml));
      expect(payload.actions[1].id, equals(NotificationAction.idLog500Ml));
      expect(payload.actions[2].id, equals(NotificationAction.idSnooze30Min));
      expect(payload.actions[3].id, equals(NotificationAction.idViewSanctuary));
      expect(payload.isGoalCompleted, isFalse);
      expect(payload.badgeNumber, equals(1));
    });

    test('Generates goal achieved celebration payload with 2 actions', () {
      final snapshot = createTestSnapshot(
        netConsumedMl: 2500,
        targetMl: 2500,
      );
      final payload = service.buildPayload(snapshot: snapshot);

      expect(payload.title, contains('🎉 Goal Achieved! (100% Hydrated)'));
      expect(payload.subtitle, contains('All Clean!'));
      expect(payload.body, contains('Incredible habit mastery!'));
      expect(payload.companionQuote, contains('backflips on the bamboo dock'));
      expect(payload.isGoalCompleted, isTrue);
      expect(payload.badgeNumber, equals(0));
      expect(payload.actions.length, equals(2));
      expect(payload.actions[0].id, equals(NotificationAction.idLog250Ml));
      expect(payload.actions[1].id, equals(NotificationAction.idViewSanctuary));
    });

    test('Attaches caffeine warning when budget enters caution or exceeded', () {
      final cautionSnapshot = createTestSnapshot(caffeineConsumedMg: 380);
      final cautionPayload = service.buildPayload(snapshot: cautionSnapshot);
      expect(cautionPayload.body, contains('⚠️ Caffeine near upper threshold'));

      final exceededSnapshot = createTestSnapshot(caffeineConsumedMg: 450);
      final exceededPayload = service.buildPayload(snapshot: exceededSnapshot);
      expect(exceededPayload.body, contains('⚠️ Caffeine exceeded (450mg/400mg limit)'));
    });

    test('Attaches added sugar and electrolyte warnings when thresholds crossed', () {
      final sugarSnapshot = createTestSnapshot(sugarConsumedG: 55.4);
      final sugarPayload = service.buildPayload(snapshot: sugarSnapshot);
      expect(sugarPayload.body, contains('🍯 Sugar budget exceeded (55.4g/50g)'));

      final depletedSnapshot = createTestSnapshot(electrolytesConsumedMg: 100);
      final depletedPayload = service.buildPayload(snapshot: depletedSnapshot);
      expect(depletedPayload.body, contains('⚡ Electrolytes low'));
    });

    test('Generates distinct circadian quotes for Red Panda across all 4 paces', () {
      final aheadSnap = createTestSnapshot(pace: CircadianPaceStatus.aheadOfPace);
      final onTrackSnap = createTestSnapshot(pace: CircadianPaceStatus.onTrack);
      final behindSnap = createTestSnapshot(pace: CircadianPaceStatus.behindPace);
      final criticalSnap = createTestSnapshot(pace: CircadianPaceStatus.criticalDeficit);

      expect(service.buildPayload(snapshot: aheadSnap).companionQuote,
          contains('ahead of schedule'));
      expect(service.buildPayload(snapshot: onTrackSnap).companionQuote,
          contains('Steady as the mountain stream'));
      expect(service.buildPayload(snapshot: behindSnap).companionQuote,
          contains('bamboo springs await'));
      expect(service.buildPayload(snapshot: criticalSnap).companionQuote,
          contains('looking parched'));
    });

    test('Generates companion personality quotes for Capybara, Axolotl, Otter & Dolphin', () {
      final capySnap = createTestSnapshot(
        companionId: 'capybara',
        companionName: 'Barnaby',
        pace: CircadianPaceStatus.onTrack,
      );
      expect(service.buildPayload(snapshot: capySnap).companionQuote,
          contains('warm bath'));

      final axoSnap = createTestSnapshot(
        companionId: 'axolotl',
        companionName: 'Axel',
        pace: CircadianPaceStatus.aheadOfPace,
      );
      expect(service.buildPayload(snapshot: axoSnap).companionQuote,
          contains('swims joyous loops'));

      final otterSnap = createTestSnapshot(
        companionId: 'sea_otter',
        companionName: 'Ollie',
        pace: CircadianPaceStatus.onTrack,
      );
      expect(service.buildPayload(snapshot: otterSnap).companionQuote,
          contains('cracks a pebble'));

      final dolphinSnap = createTestSnapshot(
        companionId: 'bottlenose_dolphin',
        companionName: 'Echo',
        pace: CircadianPaceStatus.behindPace,
      );
      expect(service.buildPayload(snapshot: dolphinSnap).companionQuote,
          contains('breaches for air'));
    });
  });

  group('RichNotificationService Action Handlers Tests', () {
    late HydrationRepository repository;
    late RichNotificationService service;

    setUp(() {
      repository = LocalHydrationRepository();
      service = const RichNotificationService();
    });

    test('Action Log 250ml records pure water intake and awards 25 XP', () async {
      final clock = DateTime(2026, 11, 22, 14, 0);
      final result = await service.handleNotificationAction(
        actionId: NotificationAction.idLog250Ml,
        hydrationRepository: repository,
        clock: clock,
      );

      expect(result.status, equals(NotificationActionStatus.logged));
      expect(result.volumeLoggedMl, equals(250.0));
      expect(result.message, contains('250ml'));

      final entries = await repository.getTodayEntries();
      expect(entries.length, equals(1));
      expect(entries.first.beverageId, equals('pure_water'));
      expect(entries.first.volumeMl, equals(250.0));

      final xp = await repository.getUserXp();
      expect(xp, equals(25));
    });

    test('Action Log 500ml records pure water intake and awards 50 XP', () async {
      final clock = DateTime(2026, 11, 22, 15, 30);
      final result = await service.handleNotificationAction(
        actionId: NotificationAction.idLog500Ml,
        hydrationRepository: repository,
        clock: clock,
      );

      expect(result.status, equals(NotificationActionStatus.logged));
      expect(result.volumeLoggedMl, equals(500.0));
      expect(result.message, contains('500ml'));

      final entries = await repository.getTodayEntries();
      expect(entries.length, equals(1));
      expect(entries.first.volumeMl, equals(500.0));

      final xp = await repository.getUserXp();
      expect(xp, equals(50));
    });

    test('Action Snooze 30m calculates precise snooze timestamp', () async {
      final clock = DateTime(2026, 11, 22, 9, 15);
      final result = await service.handleNotificationAction(
        actionId: NotificationAction.idSnooze30Min,
        hydrationRepository: repository,
        clock: clock,
      );

      expect(result.status, equals(NotificationActionStatus.snoozed));
      expect(result.snoozedUntil, equals(DateTime(2026, 11, 22, 9, 45)));
      expect(result.message, contains('09:45'));
    });

    test('Action View Sanctuary returns navigation destination', () async {
      final result = await service.handleNotificationAction(
        actionId: NotificationAction.idViewSanctuary,
        hydrationRepository: repository,
      );

      expect(result.status, equals(NotificationActionStatus.navigated));
      expect(result.targetRoute, equals('/home'));
      expect(result.message, contains('Sanctuary'));
    });

    test('Unrecognized action returns ignored status safely', () async {
      final result = await service.handleNotificationAction(
        actionId: 'non_existent_action',
        hydrationRepository: repository,
      );

      expect(result.status, equals(NotificationActionStatus.ignored));
      expect(result.message, contains('Ignored unrecognized'));
    });
  });

  group('Notification Controller & Action Dispatcher Integration Tests', () {
    test('NotificationActionDispatcher dispatches quick-log and reloads hydration state', () async {
      final testRepository = LocalHydrationRepository();
      final telemetryService = WidgetNotificationTelemetryService();

      final container = ProviderContainer(
        overrides: [
          hydrationRepositoryProvider.overrideWithValue(testRepository),
          widgetNotificationTelemetryServiceProvider
              .overrideWithValue(telemetryService),
        ],
      );
      addTearDown(container.dispose);

      // Verify initial hydration state is empty
      var hydration = container.read(hydrationProvider);
      expect(hydration.entries, isEmpty);

      // Dispatch 250ml quick-log notification action
      final dispatcher = container.read(notificationActionDispatcherProvider);
      final result = await dispatcher.dispatchAction(NotificationAction.idLog250Ml);

      expect(result.status, equals(NotificationActionStatus.logged));
      expect(result.volumeLoggedMl, equals(250.0));

      // Hydration state should reload automatically
      hydration = container.read(hydrationProvider);
      expect(hydration.entries.length, equals(1));
      expect(hydration.goal.totalConsumedMl, equals(250.0));
      expect(hydration.goal.netHydrationMl, equals(250.0));

      // Latest notification payload updates to reflect new intake
      final payload = container.read(latestNotificationPayloadProvider);
      expect(payload.subtitle, contains('250'));
    });
  });
}
