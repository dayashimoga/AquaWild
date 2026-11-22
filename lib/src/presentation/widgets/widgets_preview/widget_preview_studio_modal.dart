import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/audio_haptics_service.dart';
import '../../../core/services/widget_bridge_sync_service.dart';
import '../../../domain/models/beverage_type.dart';
import '../../../domain/models/notification_payload.dart';
import '../../../domain/models/out_of_app_telemetry.dart';
import '../../../domain/models/widget_models.dart';
import '../../controllers/hydration_controller.dart';
import '../../controllers/notification_controller.dart';
import '../../controllers/telemetry_controller.dart';
import 'compact_widget_view.dart';
import 'lock_screen_widget_view.dart';
import 'medium_widget_view.dart';

/// Interactive modal sheet enabling real-time preview and simulation of
/// native home-screen and lock-screen widgets across all platforms.
class WidgetPreviewStudioModal extends ConsumerStatefulWidget {
  const WidgetPreviewStudioModal({super.key});

  /// Presents the Widget Preview Studio in an accessible glassmorphic modal sheet
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WidgetPreviewStudioModal(),
    );
  }

  @override
  ConsumerState<WidgetPreviewStudioModal> createState() =>
      _WidgetPreviewStudioModalState();
}

class _WidgetPreviewStudioModalState
    extends ConsumerState<WidgetPreviewStudioModal> {
  WidgetFamily _selectedFamily = WidgetFamily.systemSmall;
  WidgetSimulatorWallpaper _selectedWallpaper =
      WidgetSimulatorWallpaper.darkOcean;
  bool _isSyncing = false;

  @override
  Widget build(BuildContext context) {
    final telemetry = ref.watch(telemetrySnapshotProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF090E17).withValues(alpha: 0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
            blurRadius: 40,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.widgets_rounded,
                      color: Color(0xFF00E5FF), size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Widget Preview Studio',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Widget Family Selector Tabs
          Row(
            children: WidgetFamily.values.map((family) {
              final isSelected = _selectedFamily == family;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    key: Key('widget_tab_${family.name}'),
                    label: Center(
                      child: Text(
                        family.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? Colors.black
                              : Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF00E5FF),
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    onSelected: (selected) {
                      if (selected) {
                        unawaited(AudioHapticsService.playTap());
                        setState(() => _selectedFamily = family);
                      }
                    },
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          // Wallpaper Picker Chips
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: WidgetSimulatorWallpaper.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final wallpaper = WidgetSimulatorWallpaper.values[index];
                final isSelected = _selectedWallpaper == wallpaper;
                return GestureDetector(
                  onTap: () {
                    unawaited(AudioHapticsService.playTap());
                    setState(() => _selectedWallpaper = wallpaper);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF00E5FF)
                            : Colors.white.withValues(alpha: 0.15),
                        width: isSelected ? 1.5 : 0.8,
                      ),
                      color: isSelected
                          ? const Color(0xFF00E5FF).withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.05),
                    ),
                    child: Text(
                      wallpaper.name,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF00E5FF)
                            : Colors.white70,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Central Simulator Canvas with Simulated Wallpaper Backdrop
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: _selectedWallpaper.gradient,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: _buildSelectedWidget(telemetry),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Bottom Action Bar: Sync to Native Widgets Button
          SizedBox(
            height: 44,
            child: ElevatedButton.icon(
              key: const Key('widget_sync_native_button'),
              onPressed: _isSyncing ? null : () => _handleSyncToWidgets(telemetry),
              icon: _isSyncing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : const Icon(Icons.sync_rounded, size: 18),
              label: Text(
                _isSyncing
                    ? 'Syncing to Device...'
                    : 'Sync to Device Widgets',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedWidget(OutOfAppTelemetrySnapshot snapshot) {
    switch (_selectedFamily) {
      case WidgetFamily.systemSmall:
        return CompactWidgetView(
          snapshot: snapshot,
          onQuickLog: (volume) => _handleSimulatorQuickLog(volume),
        );
      case WidgetFamily.systemMedium:
        return MediumWidgetView(
          snapshot: snapshot,
          onQuickLog: (volume) => _handleSimulatorQuickLog(volume),
        );
      case WidgetFamily.lockScreenLiveActivity:
        return LockScreenLiveActivityView(
          snapshot: snapshot,
          onQuickLog: (volume) => _handleSimulatorQuickLog(volume),
          onSnooze: () => _handleSimulatorSnooze(),
        );
    }
  }

  Future<void> _handleSimulatorQuickLog(int volumeMl) async {
    unawaited(AudioHapticsService.playTap());

    // Use NotificationActionDispatcher or direct HydrationNotifier
    await ref.read(hydrationProvider.notifier).logDrink(
          beverage: BeverageType.pureWater,
          volumeMl: volumeMl.toDouble(),
          notes: 'Logged via In-App Widget Simulator',
        );

    // Refresh telemetry snapshot
    ref.read(telemetrySnapshotProvider.notifier).refresh();

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Logged ${volumeMl}ml Pure Water in Simulator! 💧',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF0B192C),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleSimulatorSnooze() async {
    unawaited(AudioHapticsService.playTap());
    await ref
        .read(notificationActionDispatcherProvider)
        .dispatchAction(NotificationAction.idSnooze30Min);

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Hydration reminder snoozed for 30 minutes! ⏰',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF0B192C),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleSyncToWidgets(OutOfAppTelemetrySnapshot snapshot) async {
    unawaited(AudioHapticsService.playTap());
    setState(() => _isSyncing = true);

    try {
      final syncService = ref.read(widgetBridgeSyncServiceProvider);
      final result = await syncService.syncSnapshot(snapshot);

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.message,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF042B38),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }
}
