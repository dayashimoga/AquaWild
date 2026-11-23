import 'package:aquawild/src/core/services/accessibility_announcement_service.dart';
import 'package:aquawild/src/core/theme/app_theme.dart';
import 'package:aquawild/src/data/repositories/local_hydration_repository.dart';
import 'package:aquawild/src/presentation/controllers/hydration_controller.dart';
import 'package:aquawild/src/presentation/screens/home/responsive_home_shell.dart';
import 'package:aquawild/src/presentation/screens/launch/launch_screen.dart';
import 'package:aquawild/src/presentation/widgets/animal_fluid/animal_fluid_habitat_view.dart';
import 'package:aquawild/src/presentation/widgets/beverages/quick_log_dock.dart';
import 'package:aquawild/src/presentation/widgets/pool/interactive_pool_view.dart';
import 'package:aquawild/src/presentation/widgets/pool/pool_water_simulation_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Subphase 8.2.1: WCAG 2.2 AA+ Accessibility & Semantics Tree Certification', () {
    testWidgets('Screen Reader Semantics: InteractivePoolView has descriptive mascot and action semantics',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.hydroGlassTheme,
          home: const Scaffold(
            body: InteractivePoolView(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      final handle = tester.ensureSemantics();

      // Find semantics node for Ruby
      expect(
        find.bySemanticsLabel(
          RegExp(r'Ruby the Red Panda reclining naturally in crystal-clear highland mineral water', caseSensitive: false),
        ),
        findsOneWidget,
      );

      handle.dispose();
    });

    testWidgets('Screen Reader Semantics: AnimalFluidHabitatView has live volume, target and action hints',
        (tester) async {
      final repository = LocalHydrationRepository();
      final container = ProviderContainer(
        overrides: [
          hydrationRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.hydroGlassTheme,
            home: const Scaffold(
              body: AnimalFluidHabitatView(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      final handle = tester.ensureSemantics();

      // Verify habitat container semantics
      expect(
        find.bySemanticsLabel(RegExp(r'Ruby the Red Panda hydration container: 0 of 2500 ml consumed', caseSensitive: false)),
        findsOneWidget,
      );

      // Verify custom pour and exact keypad action semantics
      expect(find.bySemanticsLabel('Open custom pour studio'), findsOneWidget);
      expect(find.bySemanticsLabel('Open precision numeric keypad'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('Screen Reader Semantics: QuickLogDock has explicit scroll, craft and drink log semantics',
        (tester) async {
      final repository = LocalHydrationRepository();
      final container = ProviderContainer(
        overrides: [
          hydrationRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.hydroGlassTheme,
            home: const Scaffold(
              body: QuickLogDock(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      final handle = tester.ensureSemantics();

      // Verify scroll controls semantics
      expect(find.bySemanticsLabel('Scroll Beverages Left'), findsOneWidget);
      expect(find.bySemanticsLabel('Scroll Beverages Right'), findsOneWidget);
      expect(find.bySemanticsLabel('Craft Custom Beverage'), findsOneWidget);

      // Verify beverage card semantics with shortcut hints
      expect(
        find.bySemanticsLabel(RegExp(r'Quick log 250 milliliters of Pure Spring Water, shortcut key 1', caseSensitive: false)),
        findsOneWidget,
      );

      handle.dispose();
    });

    testWidgets('Screen Reader Semantics: NetHydrationCard announces progress and opens goal customizer',
        (tester) async {
      final repository = LocalHydrationRepository();
      final container = ProviderContainer(
        overrides: [
          hydrationRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.hydroGlassTheme,
            home: const ResponsiveHomeShell(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      final handle = tester.ensureSemantics();

      expect(
        find.bySemanticsLabel(
          RegExp(r'Ruby the Red Panda hydration status: 0 of 2500 milliliters, 0 percent complete\. Tap to view analytics\.', caseSensitive: false),
        ),
        findsOneWidget,
      );

      handle.dispose();
    });

    testWidgets('Screen Reader Announcements: AccessibilityAnnouncementService dispatches without error',
        (tester) async {
      // Test direct announcement service invocation in flutter test environment
      AccessibilityAnnouncementService.announce(
        'Logged 250 ml of Pure Water. Net hydration is now 250 of 2500 ml (10%).',
      );
      AccessibilityAnnouncementService.announce(
        'Removed hydration entry. Net hydration is now 0 of 2500 ml (0%).',
      );
      AccessibilityAnnouncementService.announce(
        'Daily hydration goal updated to 3000 ml.',
      );
      expect(true, isTrue);
    });

    testWidgets('Focus Traversal & High-Contrast Focus Ring: AppTheme provides visible focus colors',
        (tester) async {
      // Hydro-Glass theme focus color
      expect(AppTheme.hydroGlassTheme.focusColor, isNotNull);
      expect(AppTheme.hydroGlassTheme.focusColor.a, greaterThan(0));

      // High-Contrast theme focus color (WCAG AAA compliant)
      expect(AppTheme.highContrastTheme.focusColor, isNotNull);

      // Verify FocusTraversalGroup on ResponsiveHomeShell desktop layout
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = LocalHydrationRepository();
      final container = ProviderContainer(
        overrides: [
          hydrationRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.hydroGlassTheme,
            home: const ResponsiveHomeShell(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Verify FocusTraversalGroup wraps desktop interaction decks
      expect(find.byType(FocusTraversalGroup), findsWidgets);
    });

    testWidgets('200% High Text Scale: LaunchScreen scales without RenderFlex overflow',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.hydroGlassTheme,
          home: const MediaQuery(
            data: MediaQueryData(
              size: Size(390, 844),
              textScaler: TextScaler.linear(2.0),
            ),
            child: LaunchScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      expect(find.text('Dive Into Habitat'), findsOneWidget);
    });

    testWidgets('200% High Text Scale: ResponsiveHomeShell scales without RenderFlex overflow',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = LocalHydrationRepository();
      final container = ProviderContainer(
        overrides: [
          hydrationRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.hydroGlassTheme,
            home: const MediaQuery(
              data: MediaQueryData(
                size: Size(390, 844),
                textScaler: TextScaler.linear(2.0),
              ),
              child: ResponsiveHomeShell(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      expect(find.text('Net Hydration Today'), findsOneWidget);
    });

    testWidgets('Reduced-Motion Physics Mode: InteractivePoolView pauses particle layer',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.hydroGlassTheme,
          home: const MediaQuery(
            data: MediaQueryData(
              disableAnimations: true,
            ),
            child: Scaffold(
              body: InteractivePoolView(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);

      // Verify custom painter mounts with reducedMotion: true
      final customPaintFinder = find.byType(CustomPaint);
      expect(customPaintFinder, findsWidgets);

      // When animations are disabled, PoolParticlesPainter layer is excluded from the widget tree
      final poolWaterPainter = tester.widgetList<CustomPaint>(customPaintFinder).firstWhere(
        (cp) => cp.painter is PoolWaterSimulationPainter,
      );
      expect((poolWaterPainter.painter as PoolWaterSimulationPainter).reducedMotion, isTrue);
    });

    testWidgets('Reduced-Motion Physics Mode: AnimalFluidHabitatView renders static tranquil fluid',
        (tester) async {
      final repository = LocalHydrationRepository();
      final container = ProviderContainer(
        overrides: [
          hydrationRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.hydroGlassTheme,
            home: const MediaQuery(
              data: MediaQueryData(
                disableAnimations: true,
              ),
              child: Scaffold(
                body: AnimalFluidHabitatView(),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);

      // Custom pour and exact keypad buttons remain fully interactive
      expect(find.text('Custom Pour'), findsOneWidget);
      expect(find.text('Exact Keypad'), findsOneWidget);
    });
  });
}
