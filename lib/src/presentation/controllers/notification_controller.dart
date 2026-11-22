import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/rich_notification_service.dart';
import '../../domain/models/notification_payload.dart';
import 'hydration_controller.dart';
import 'telemetry_controller.dart';

/// Provider exposing the singleton RichNotificationService
final richNotificationServiceProvider = Provider<RichNotificationService>((ref) {
  final telemetryService = ref.watch(widgetNotificationTelemetryServiceProvider);
  return RichNotificationService(telemetryService);
});

/// Reactive provider emitting the live RichNotificationPayload derived from
/// the current OutOfAppTelemetrySnapshot
final latestNotificationPayloadProvider =
    Provider<RichNotificationPayload>((ref) {
  final snapshot = ref.watch(telemetrySnapshotProvider);
  final service = ref.watch(richNotificationServiceProvider);
  return service.buildPayload(snapshot: snapshot);
});

/// Action dispatcher handling in-app and background notification callbacks
class NotificationActionDispatcher {
  final Ref _ref;

  const NotificationActionDispatcher(this._ref);

  /// Executes an interactive notification action and syncs the hydration state
  Future<NotificationActionResult> dispatchAction(
    String actionId, {
    Map<String, dynamic>? extraData,
  }) async {
    final repository = _ref.read(hydrationRepositoryProvider);
    final telemetryService =
        _ref.read(widgetNotificationTelemetryServiceProvider);
    final service = _ref.read(richNotificationServiceProvider);

    final result = await service.handleNotificationAction(
      actionId: actionId,
      hydrationRepository: repository,
      telemetryServiceOverride: telemetryService,
      payloadData: extraData,
    );

    // If an intake was logged, reload hydration controller so the UI refreshes
    if (result.status == NotificationActionStatus.logged &&
        result.volumeLoggedMl != null) {
      await _ref.read(hydrationProvider.notifier).loadToday();
      _ref.read(telemetrySnapshotProvider.notifier).refresh();
    }

    return result;
  }
}

/// Provider exposing the notification action dispatcher
final notificationActionDispatcherProvider =
    Provider<NotificationActionDispatcher>((ref) {
  return NotificationActionDispatcher(ref);
});
