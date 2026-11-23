import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/audio_haptics_service.dart';
import '../../../core/theme/theme_mode_notifier.dart';
import '../../../domain/models/beverage_type.dart';
import '../../controllers/animal_habitat_controller.dart';
import '../../controllers/hydration_controller.dart';
import '../../screens/admin/admin_portal_screen.dart';
import '../ai/ai_coach_sheet.dart';
import '../analytics/predictive_analytics_sheet.dart';
import '../backup/data_backup_modal.dart';
import '../biomes/biome_companion_selector_sheet.dart';
import '../gamification/achievements_gallery_sheet.dart';
import '../monetization/premium_storefront_modal.dart';
import '../reminders/smart_reminders_sheet.dart';
import '../voice/voice_command_modal.dart';
import '../widgets_preview/widget_preview_studio_modal.dart';
import 'keyboard_shortcuts_modal.dart';

/// Wraps widgets with global keyboard accelerators for desktop, web, and hardware keyboards
class AquaWildShortcutsWrapper extends ConsumerWidget {
  final Widget child;

  const AquaWildShortcutsWrapper({
    super.key,
    required this.child,
  });

  void _logBeverageByIndex(BuildContext context, WidgetRef ref, int index) {
    if (index >= 0 && index < BeverageType.allBeverages.length) {
      final beverage = BeverageType.allBeverages[index];
      final volumeMl = beverage.presetVolumesMl.first.toDouble();
      ref.read(hydrationProvider.notifier).logDrink(
            beverage: beverage,
            volumeMl: volumeMl,
          );
      ref.read(animalHabitatProvider.notifier).addXp(
            (volumeMl / 10).round(),
          );
      AudioHapticsService.instance.onDrinkLogged();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚡ Quick-logged ${volumeMl.toStringAsFixed(0)}ml of ${beverage.name} [Shortcut ${index + 1}]',
          ),
          backgroundColor: beverage.primaryColor,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _logQuickWater(BuildContext context, WidgetRef ref) {
    const beverage = BeverageType.pureWater;
    const volumeMl = 250.0;
    ref.read(hydrationProvider.notifier).logDrink(
          beverage: beverage,
          volumeMl: volumeMl,
        );
    ref.read(animalHabitatProvider.notifier).addXp(25);
    AudioHapticsService.instance.onDrinkLogged();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('💧 Poured 250ml Pure Water [Space shortcut]'),
        backgroundColor: Colors.blueAccent,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.digit1): () =>
            _logBeverageByIndex(context, ref, 0),
        const SingleActivator(LogicalKeyboardKey.digit2): () =>
            _logBeverageByIndex(context, ref, 1),
        const SingleActivator(LogicalKeyboardKey.digit3): () =>
            _logBeverageByIndex(context, ref, 2),
        const SingleActivator(LogicalKeyboardKey.digit4): () =>
            _logBeverageByIndex(context, ref, 3),
        const SingleActivator(LogicalKeyboardKey.digit5): () =>
            _logBeverageByIndex(context, ref, 4),
        const SingleActivator(LogicalKeyboardKey.digit6): () =>
            _logBeverageByIndex(context, ref, 5),
        const SingleActivator(LogicalKeyboardKey.digit7): () =>
            _logBeverageByIndex(context, ref, 6),
        const SingleActivator(LogicalKeyboardKey.digit8): () =>
            _logBeverageByIndex(context, ref, 7),
        const SingleActivator(LogicalKeyboardKey.digit9): () =>
            _logBeverageByIndex(context, ref, 8),
        const SingleActivator(LogicalKeyboardKey.space): () =>
            _logQuickWater(context, ref),
        const SingleActivator(LogicalKeyboardKey.keyA): () =>
            AiCoachSheet.show(context),
        const SingleActivator(LogicalKeyboardKey.keyR): () =>
            SmartRemindersSheet.show(context),
        const SingleActivator(LogicalKeyboardKey.keyB): () =>
            BiomeCompanionSelectorSheet.show(context),
        const SingleActivator(LogicalKeyboardKey.keyP): () =>
            PredictiveAnalyticsSheet.show(context),
        const SingleActivator(LogicalKeyboardKey.keyG): () =>
            AchievementsGallerySheet.show(context),
        const SingleActivator(LogicalKeyboardKey.keyT): () =>
            ref.read(themeModeProvider.notifier).cycleTheme(),
        const SingleActivator(LogicalKeyboardKey.keyV): () =>
            VoiceCommandModal.show(context),
        const SingleActivator(LogicalKeyboardKey.keyX): () =>
            DataBackupModal.show(context),
        const SingleActivator(LogicalKeyboardKey.keyS): () =>
            PremiumStorefrontModal.show(context),
        const SingleActivator(LogicalKeyboardKey.keyW): () =>
            WidgetPreviewStudioModal.show(context),
        const SingleActivator(LogicalKeyboardKey.keyA, control: true, shift: true):
            () => AdminPortalScreen.show(context),
        const SingleActivator(LogicalKeyboardKey.keyA, meta: true, shift: true):
            () => AdminPortalScreen.show(context),
        const SingleActivator(LogicalKeyboardKey.slash): () =>
            KeyboardShortcutsModal.show(context),
        const SingleActivator(LogicalKeyboardKey.slash, shift: true): () =>
            KeyboardShortcutsModal.show(context),
        const SingleActivator(LogicalKeyboardKey.f1): () =>
            KeyboardShortcutsModal.show(context),
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        },
      },
      child: Focus(
        autofocus: true,
        child: child,
      ),
    );
  }
}
