import 'package:aquawild/src/presentation/screens/admin/admin_portal_screen.dart';
import 'package:aquawild/src/presentation/screens/home/home_screen.dart';
import 'package:aquawild/src/presentation/widgets/ai/ai_coach_sheet.dart';
import 'package:aquawild/src/presentation/widgets/analytics/predictive_analytics_sheet.dart';
import 'package:aquawild/src/presentation/widgets/animal_fluid/animal_fluid_habitat_view.dart';
import 'package:aquawild/src/presentation/widgets/backup/data_backup_modal.dart';
import 'package:aquawild/src/presentation/widgets/beverages/quick_log_dock.dart';
import 'package:aquawild/src/presentation/widgets/biomes/biome_companion_selector_sheet.dart';
import 'package:aquawild/src/presentation/widgets/gamification/achievements_gallery_sheet.dart';
import 'package:aquawild/src/presentation/widgets/monetization/premium_storefront_modal.dart';
import 'package:aquawild/src/presentation/widgets/pool/interactive_pool_view.dart';
import 'package:aquawild/src/presentation/widgets/reminders/smart_reminders_sheet.dart';
import 'package:aquawild/src/presentation/widgets/shortcuts/aqua_wild_shortcuts_wrapper.dart';
import 'package:aquawild/src/presentation/widgets/shortcuts/keyboard_shortcuts_modal.dart';
import 'package:aquawild/src/presentation/widgets/voice/voice_command_modal.dart';
import 'package:aquawild/src/presentation/widgets/widgets_preview/widget_preview_studio_modal.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Subphase 8.1.2: Multi-Platform Input Parity & High-DPI Certification Tests', () {
    testWidgets('Global Shortcuts: S opens Store, W opens Widget Studio, Esc dismisses modal', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: AquaWildShortcutsWrapper(
              child: Scaffold(
                body: Center(child: Text('Shortcuts Test Canvas')),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Press 'S' -> should open PremiumStorefrontModal
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.byType(PremiumStorefrontModal), findsOneWidget);

      // Press 'Escape' -> should dismiss modal
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.byType(PremiumStorefrontModal), findsNothing);

      // Press 'W' -> should open WidgetPreviewStudioModal
      await tester.sendKeyEvent(LogicalKeyboardKey.keyW);
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.byType(WidgetPreviewStudioModal), findsOneWidget);

      // Press 'Escape' -> dismiss
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.byType(WidgetPreviewStudioModal), findsNothing);
    });

    testWidgets('Global Shortcuts: Ctrl+Shift+A and Cmd+Shift+A open Admin Portal', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AquaWildShortcutsWrapper(
              child: Scaffold(
                body: Center(child: Text('Admin Accelerator Canvas')),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Trigger Ctrl+Shift+A
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.byType(AdminPortalScreen), findsOneWidget);

      // Dismiss with Escape
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.byType(AdminPortalScreen), findsNothing);
    });

    testWidgets('Global Shortcuts: Navigation shortcuts B, A, R, P, G, V, X, and ? open respective modals', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AquaWildShortcutsWrapper(
              child: Scaffold(
                body: Center(child: Text('Nav Accelerators Canvas')),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // 'B' -> Biome & Companion Selector
      await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(BiomeCompanionSelectorSheet), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump(const Duration(milliseconds: 150));

      // 'A' -> AI Coach
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(AiCoachSheet), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump(const Duration(milliseconds: 150));

      // 'R' -> Smart Reminders
      await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(SmartRemindersSheet), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump(const Duration(milliseconds: 150));

      // 'P' -> Predictive Analytics
      await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(PredictiveAnalyticsSheet), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump(const Duration(milliseconds: 150));

      // 'G' -> Achievements & Badges
      await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(AchievementsGallerySheet), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump(const Duration(milliseconds: 150));

      // 'V' -> Voice Logger
      await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(VoiceCommandModal), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump(const Duration(milliseconds: 150));

      // 'X' -> Backup & Export
      await tester.sendKeyEvent(LogicalKeyboardKey.keyX);
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(DataBackupModal), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump(const Duration(milliseconds: 150));

      // '?' (Shift + Slash) -> Keyboard Shortcuts Modal
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.slash);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(KeyboardShortcutsModal), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump(const Duration(milliseconds: 150));
    });

    testWidgets('Pointer & Mouse Parity: InteractivePoolView mouse hover, click cursor & tapping impulse', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InteractivePoolView(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Verify MouseRegion with click cursor
      final mouseRegionFinder = find.byType(MouseRegion);
      expect(mouseRegionFinder, findsAtLeastNWidgets(1));

      final poolMouseRegion = tester.widget<MouseRegion>(
        find.descendant(
          of: find.byType(InteractivePoolView),
          matching: find.byType(MouseRegion),
        ).first,
      );
      expect(poolMouseRegion.cursor, equals(SystemMouseCursors.click));

      // Hover mouse over pool
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);

      await gesture.moveTo(const Offset(200, 200));
      await tester.pump(const Duration(milliseconds: 50));

      // Tap pool with mouse
      await gesture.down(const Offset(200, 200));
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
    });

    testWidgets('Pointer & Mouse Parity: AnimalFluidHabitatView mouse hover cursor & click sloshing', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: AnimalFluidHabitatView(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Verify MouseRegion with click cursor exists
      final mouseRegionFinder = find.descendant(
        of: find.byType(AnimalFluidHabitatView),
        matching: find.byType(MouseRegion),
      );
      expect(mouseRegionFinder, findsAtLeastNWidgets(1));

      final habitatMouseRegion = tester.widget<MouseRegion>(mouseRegionFinder.first);
      expect(habitatMouseRegion.cursor, equals(SystemMouseCursors.click));

      // Tap vessel to trigger splash
      await tester.tap(find.byType(AnimalFluidHabitatView));
      await tester.pump(const Duration(milliseconds: 50));

      expect(tester.takeException(), isNull);
    });

    testWidgets('High-DPI Scale 1.0 (Standard Desktop)', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(QuickLogDock), findsOneWidget);
      expect(find.byType(AnimalFluidHabitatView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('High-DPI Scale 1.5 (Windows 150% Display Scaling)', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.5;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(QuickLogDock), findsOneWidget);
      expect(find.byType(AnimalFluidHabitatView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('High-DPI Scale 2.0 (Retina Display / iPad Pro / Mac)', (tester) async {
      tester.view.physicalSize = const Size(2048, 1536);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(QuickLogDock), findsOneWidget);
      expect(find.byType(AnimalFluidHabitatView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('High-DPI Scale 3.0 (Flagship Smartphone 3x Density)', (tester) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(QuickLogDock), findsOneWidget);
      expect(find.byType(AnimalFluidHabitatView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
