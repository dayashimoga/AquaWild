import '../../data/repositories/hydration_repository.dart';
import '../../domain/models/beverage_type.dart';
import '../../domain/models/hydration_entry.dart';
import '../../domain/models/notification_payload.dart';
import '../../domain/models/out_of_app_telemetry.dart';
import 'widget_notification_telemetry_service.dart';

/// Production-ready engine for generating rich interactive notification payloads
/// and processing background quick-log and snooze action events.
class RichNotificationService {
  final WidgetNotificationTelemetryService? _telemetryService;

  const RichNotificationService([this._telemetryService]);

  /// Builds an interactive RichNotificationPayload tailored to the user's
  /// circadian pace, active companion, and multi-nutrient safety boundaries.
  RichNotificationPayload buildPayload({
    required OutOfAppTelemetrySnapshot snapshot,
    DateTime? scheduledTime,
    String? customMessage,
  }) {
    final budget = snapshot.budget;
    final pace = snapshot.circadianContext.paceStatus;
    final companionName = snapshot.activeCompanionName;
    final companionEmoji = snapshot.companionEmoji;
    final isTargetMet = budget.isTargetMet;

    // 1. Dynamic Title
    final String title;
    if (isTargetMet) {
      title = '🎉 Goal Achieved! (100% Hydrated)';
    } else {
      title = 'Time for a Sip! 💧 ($companionName)';
    }

    // 2. Subtitle with progress metrics
    final String subtitle;
    if (isTargetMet) {
      subtitle =
          '${budget.netConsumedMl.round()} / ${budget.targetMl.round()} ml • All Clean!';
    } else {
      subtitle =
          '${budget.netConsumedMl.round()} / ${budget.targetMl.round()} ml (${budget.progressPercent}%) • ${pace.label}';
    }

    // 3. Body text incorporating circadian suggestions and nutrient alerts
    final StringBuffer bodyBuffer = StringBuffer();
    if (customMessage != null && customMessage.isNotEmpty) {
      bodyBuffer.write(customMessage);
    } else if (isTargetMet) {
      bodyBuffer.write(
        'Incredible habit mastery! You conquered today\'s ${budget.targetMl.round()}ml target with a ${budget.streakDays}-day streak.',
      );
    } else {
      bodyBuffer.write(
        '${snapshot.circadianContext.phaseName}: Aim for ${snapshot.circadianContext.suggestedNextSipMl}ml of ${snapshot.circadianContext.suggestedBeverageName}.',
      );
    }

    // Append nutrient safety notes if applicable
    if (budget.caffeineStatus == CaffeineSafetyStatus.exceeded) {
      bodyBuffer.write(
        ' ⚠️ Caffeine exceeded (${budget.caffeineConsumedMg.round()}mg/400mg limit). Switch to pure water or herbal tea.',
      );
    } else if (budget.caffeineStatus == CaffeineSafetyStatus.caution) {
      bodyBuffer.write(
        ' ⚠️ Caffeine near upper threshold (${budget.caffeineConsumedMg.round()}mg/400mg). Prioritize hydration.',
      );
    }

    if (budget.hasExceededSugarBudget) {
      bodyBuffer.write(
        ' 🍯 Sugar budget exceeded (${budget.sugarConsumedG.toStringAsFixed(1)}g/50g).',
      );
    }

    if (budget.electrolyteStatus == ElectrolyteBalanceStatus.depleted) {
      bodyBuffer.write(
        ' ⚡ Electrolytes low. Consider coconut water or an electrolyte boost.',
      );
    }

    final body = bodyBuffer.toString();

    // 4. Generate companion-specific personality quote
    final companionQuote = _generateCompanionQuote(
      animalId: snapshot.activeCompanionId,
      companionName: companionName,
      pace: pace,
      isTargetMet: isTargetMet,
    );

    // 5. Select actionable buttons
    final List<NotificationAction> actions;
    if (isTargetMet) {
      actions = const [
        NotificationAction.actionLog250Ml,
        NotificationAction.actionViewSanctuary,
      ];
    } else {
      actions = const [
        NotificationAction.actionLog250Ml,
        NotificationAction.actionLog500Ml,
        NotificationAction.actionSnooze30Min,
        NotificationAction.actionViewSanctuary,
      ];
    }

    // 6. Assemble metadata payload for native bridges
    final data = <String, dynamic>{
      'companionId': snapshot.activeCompanionId,
      'remainingMl': budget.remainingMl,
      'progressPercent': budget.progressPercent,
      'caffeineMg': budget.caffeineConsumedMg,
      'streakDays': budget.streakDays,
      'paceStatus': pace.name,
      'snapshotTimestamp': snapshot.timestamp.toIso8601String(),
    };

    return RichNotificationPayload(
      id: 'aquawild_reminder_${scheduledTime?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch}',
      title: title,
      subtitle: subtitle,
      body: body,
      companionQuote: companionQuote,
      companionEmoji: companionEmoji,
      companionName: companionName,
      badgeNumber: isTargetMet ? 0 : 1,
      actions: actions,
      data: data,
      scheduledTime: scheduledTime,
      isGoalCompleted: isTargetMet,
    );
  }

  /// Processes incoming notification button actions headlessly without opening the main UI.
  Future<NotificationActionResult> handleNotificationAction({
    required String actionId,
    required HydrationRepository hydrationRepository,
    WidgetNotificationTelemetryService? telemetryServiceOverride,
    Map<String, dynamic>? payloadData,
    DateTime? clock,
  }) async {
    final now = clock ?? DateTime.now();
    final telemetry = telemetryServiceOverride ?? _telemetryService;

    switch (actionId) {
      case NotificationAction.idLog250Ml:
        return _executeQuickLog(
          volumeMl: 250.0,
          actionId: actionId,
          repository: hydrationRepository,
          telemetryService: telemetry,
          clock: now,
        );

      case NotificationAction.idLog500Ml:
        return _executeQuickLog(
          volumeMl: 500.0,
          actionId: actionId,
          repository: hydrationRepository,
          telemetryService: telemetry,
          clock: now,
        );

      case NotificationAction.idSnooze30Min:
        final snoozedUntil = now.add(const Duration(minutes: 30));
        final formattedHour = snoozedUntil.hour.toString().padLeft(2, '0');
        final formattedMinute = snoozedUntil.minute.toString().padLeft(2, '0');

        return NotificationActionResult(
          actionId: actionId,
          status: NotificationActionStatus.snoozed,
          snoozedUntil: snoozedUntil,
          message:
              'Hydration reminder snoozed until $formattedHour:$formattedMinute.',
        );

      case NotificationAction.idViewSanctuary:
        return const NotificationActionResult(
          actionId: NotificationAction.idViewSanctuary,
          status: NotificationActionStatus.navigated,
          targetRoute: '/home',
          message: 'Opening AquaWild Sanctuary.',
        );

      default:
        return NotificationActionResult(
          actionId: actionId,
          status: NotificationActionStatus.ignored,
          message: 'Ignored unrecognized notification action: $actionId.',
        );
    }
  }

  Future<NotificationActionResult> _executeQuickLog({
    required double volumeMl,
    required String actionId,
    required HydrationRepository repository,
    WidgetNotificationTelemetryService? telemetryService,
    required DateTime clock,
  }) async {
    final entry = HydrationEntry.create(
      id: clock.microsecondsSinceEpoch.toString(),
      beverage: BeverageType.pureWater,
      volumeMl: volumeMl,
      timestamp: clock,
      notes: 'Logged via interactive notification action',
    );

    // Save intake and award XP (1 XP per 10ml)
    await repository.saveEntry(entry);
    final xpEarned = (volumeMl / 10).round();
    await repository.addXp(xpEarned);

    // If telemetry service is present, refresh cached snapshot
    if (telemetryService != null) {
      final cached = telemetryService.getCachedSnapshot();
      if (cached != null) {
        final updatedNet = cached.budget.netConsumedMl + volumeMl;
        final updatedGross = cached.budget.grossConsumedMl + volumeMl;
        final updatedBudget = cached.budget.copyWith(
          netConsumedMl: updatedNet,
          grossConsumedMl: updatedGross,
        );

        final updatedSnapshot = cached.copyWith(
          timestamp: clock,
          budget: updatedBudget,
          userXp: cached.userXp + xpEarned,
        );
        await telemetryService.saveSnapshot(updatedSnapshot);
      }
    }

    return NotificationActionResult(
      actionId: actionId,
      status: NotificationActionStatus.logged,
      volumeLoggedMl: volumeMl,
      message:
          'Logged ${volumeMl.round()}ml of Pure Water in background! +$xpEarned XP.',
      extraData: {'beverageId': 'pure_water', 'xpEarned': xpEarned},
    );
  }

  /// Generates dynamic quotes matching companion lore and circadian pace
  String _generateCompanionQuote({
    required String animalId,
    required String companionName,
    required CircadianPaceStatus pace,
    required bool isTargetMet,
  }) {
    if (isTargetMet) {
      return switch (animalId) {
        'red_panda' =>
          '$companionName does backflips on the bamboo dock! "Sanctuary celebration! We reached 100%!"',
        'capybara' =>
          '$companionName closes eyes in pure hot spring bliss. "Complete serenity achieved, my friend."',
        'axolotl' =>
          '$companionName twinkles with iridescent light. "Cellular vitality is at its maximum peak!"',
        'sea_otter' =>
          '$companionName floats on back clapping paws together! "Goal cracked! Splendid work!"',
        'andean_llama' =>
          '$companionName holds head high in alpine majesty. "A triumph as high as the Andes peaks!"',
        _ =>
          '$companionName dances with joyful energy! "Daily hydration goal achieved!"',
      };
    }

    return switch (animalId) {
      'red_panda' => switch (pace) {
          CircadianPaceStatus.aheadOfPace =>
            '$companionName chirps with delight! "Your tail is wagging ahead of schedule today!"',
          CircadianPaceStatus.onTrack =>
            '$companionName gently points a fluffy paw toward your water. "Steady as the mountain stream!"',
          CircadianPaceStatus.behindPace =>
            '$companionName peers up curiously. "The bamboo springs await—let\'s take a refreshing sip!"',
          CircadianPaceStatus.criticalDeficit =>
            '$companionName curls up looking parched. "Don\'t let dehydration catch us, friend!"',
        },
      'capybara' => switch (pace) {
          CircadianPaceStatus.aheadOfPace =>
            '$companionName soaks in total bliss. "Maximum zen hydration achieved."',
          CircadianPaceStatus.onTrack =>
            '$companionName enjoys the warm bath. "Flowing at a perfectly chill pace."',
          CircadianPaceStatus.behindPace =>
            '$companionName blinks lazily. "A gentle sip will restore the hot spring tranquility."',
          CircadianPaceStatus.criticalDeficit =>
            '$companionName nudges the water bowl. "Even capybaras need water to stay peaceful!"',
        },
      'axolotl' => switch (pace) {
          CircadianPaceStatus.aheadOfPace =>
            '$companionName swims joyous loops! "Cellular regeneration is in top gear!"',
          CircadianPaceStatus.onTrack =>
            '$companionName flutters external gills cheerfully. "Submerged and perfectly balanced!"',
          CircadianPaceStatus.behindPace =>
            '$companionName hovers quietly. "Time to replenish the freshwater cavern!"',
          CircadianPaceStatus.criticalDeficit =>
            '$companionName\'s gills droop slightly. "Emergency rehydration called for!"',
        },
      'sea_otter' => switch (pace) {
          CircadianPaceStatus.aheadOfPace =>
            '$companionName spins on the water! "Fastest swimmer in the kelp forest!"',
          CircadianPaceStatus.onTrack =>
            '$companionName cracks a pebble happily. "Smooth waters and steady sips."',
          CircadianPaceStatus.behindPace =>
            '$companionName balances a shell. "Don\'t let the tide go out—take a drink!"',
          CircadianPaceStatus.criticalDeficit =>
            '$companionName splashes urgent ripples. "Kelp forest drying out! Hydrate now!"',
        },
      'bottlenose_dolphin' => switch (pace) {
          CircadianPaceStatus.aheadOfPace =>
            '$companionName leaps over the wave crest! "Magnificent hydration pace!"',
          CircadianPaceStatus.onTrack =>
            '$companionName clicks harmoniously. "Echo-location confirms perfect rhythm."',
          CircadianPaceStatus.behindPace =>
            '$companionName breaches for air. "Dive in and catch up on your water!"',
          CircadianPaceStatus.criticalDeficit =>
            '$companionName whistles high. "Low water reserves detected! Time to drink!"',
        },
      _ => switch (pace) {
          CircadianPaceStatus.aheadOfPace =>
            '$companionName is energized! "You\'re cruising ahead of pace!"',
          CircadianPaceStatus.onTrack =>
            '$companionName smiles warmly. "Right on schedule for today\'s goal!"',
          CircadianPaceStatus.behindPace =>
            '$companionName gives a friendly nudge. "Time for a rejuvenating sip!"',
          CircadianPaceStatus.criticalDeficit =>
            '$companionName waits by your side. "Let\'s take a big drink and catch up!"',
        },
    };
  }
}
