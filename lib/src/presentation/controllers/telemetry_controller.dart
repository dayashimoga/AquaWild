import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/widget_notification_telemetry_service.dart';
import '../../domain/models/out_of_app_telemetry.dart';
import 'animal_habitat_controller.dart';
import 'biome_controller.dart';
import 'gamification_controller.dart';
import 'hydration_controller.dart';

/// Provider for the singleton WidgetNotificationTelemetryService
final widgetNotificationTelemetryServiceProvider =
    Provider<WidgetNotificationTelemetryService>((ref) {
  return WidgetNotificationTelemetryService();
});

/// Riverpod 3 provider exposing the live OutOfAppTelemetrySnapshot
final telemetrySnapshotProvider =
    NotifierProvider<TelemetryNotifier, OutOfAppTelemetrySnapshot>(
  TelemetryNotifier.new,
);

/// Reactive notifier synchronizing application hydration states to
/// unified out-of-app telemetry snapshots
class TelemetryNotifier extends Notifier<OutOfAppTelemetrySnapshot> {
  WidgetNotificationTelemetryService get _service =>
      ref.read(widgetNotificationTelemetryServiceProvider);

  @override
  OutOfAppTelemetrySnapshot build() {
    final hydration = ref.watch(hydrationProvider);
    final habitat = ref.watch(animalHabitatProvider);
    final gamification = ref.watch(gamificationProvider);
    final biome = ref.watch(biomeProvider);

    final snapshot = _service.computeSnapshot(
      hydrationState: hydration,
      habitatState: habitat,
      gamificationState: gamification,
      biomeState: biome,
    );

    // Save snapshot to persistent storage in background for native widgets
    unawaited(_service.saveSnapshot(snapshot));

    return snapshot;
  }

  /// Forces an explicit recomputation of telemetry data
  void refresh() {
    final hydration = ref.read(hydrationProvider);
    final habitat = ref.read(animalHabitatProvider);
    final gamification = ref.read(gamificationProvider);
    final biome = ref.read(biomeProvider);

    final snapshot = _service.computeSnapshot(
      hydrationState: hydration,
      habitatState: habitat,
      gamificationState: gamification,
      biomeState: biome,
    );

    unawaited(_service.saveSnapshot(snapshot));
    state = snapshot;
  }
}
