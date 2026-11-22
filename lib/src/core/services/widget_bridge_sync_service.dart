import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/out_of_app_telemetry.dart';
import '../../domain/models/widget_models.dart';
import '../../presentation/controllers/telemetry_controller.dart';
import 'widget_notification_telemetry_service.dart';

/// Cross-platform bridge service synchronizing live application hydration telemetry
/// to native iOS WidgetKit, Android Glance, and Web/Desktop local storage.
class WidgetBridgeSyncService {
  final WidgetNotificationTelemetryService _telemetryService;
  final MethodChannel? _methodChannel;
  DateTime? _lastSyncTime;

  static const String channelName = 'com.aquawild/widget_bridge';

  WidgetBridgeSyncService({
    required WidgetNotificationTelemetryService telemetryService,
    MethodChannel? methodChannel,
  })  : _telemetryService = telemetryService,
        _methodChannel = methodChannel;

  DateTime? get lastSyncTime => _lastSyncTime;

  /// Synchronizes the telemetry snapshot to both persistent local storage
  /// and native platform widget reload triggers
  Future<WidgetSyncResult> syncSnapshot(OutOfAppTelemetrySnapshot snapshot) async {
    final now = DateTime.now();

    // 1. Persist snapshot into local storage (App Groups / SharedPreferences)
    await _telemetryService.saveSnapshot(snapshot);

    final targetPlatforms = <String>['local_storage', 'web_storage'];
    bool nativeTriggerSuccess = true;

    // 2. Invoke native widget reload channel (iOS WidgetCenter / Android Glance)
    if (_methodChannel != null) {
      try {
        await _methodChannel.invokeMethod('reloadWidgets', snapshot.toJson());
        targetPlatforms.addAll(['ios_widgetkit', 'android_glance']);
      } catch (_) {
        // Graceful non-fatal fallback for platforms without host channel implementation
        nativeTriggerSuccess = false;
      }
    }

    _lastSyncTime = now;

    return WidgetSyncResult(
      isSuccess: true,
      syncedAt: now,
      targetPlatforms: targetPlatforms,
      message: nativeTriggerSuccess
          ? 'Successfully synchronized telemetry to native widgets!'
          : 'Telemetry cached to local storage. Native widget reload deferred.',
    );
  }
}

/// Riverpod provider exposing the singleton WidgetBridgeSyncService
final widgetBridgeSyncServiceProvider = Provider<WidgetBridgeSyncService>((ref) {
  final telemetryService = ref.watch(widgetNotificationTelemetryServiceProvider);
  const channel = MethodChannel(WidgetBridgeSyncService.channelName);
  return WidgetBridgeSyncService(
    telemetryService: telemetryService,
    methodChannel: channel,
  );
});
