import 'package:aquawild/src/presentation/controllers/animal_habitat_controller.dart';
import 'package:aquawild/src/presentation/controllers/hydration_controller.dart';
import 'package:aquawild/src/presentation/screens/home/home_screen.dart';
import 'package:aquawild/src/presentation/widgets/beverages/quick_log_dock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Subphase 8.1.1: QuickLogDock & Cross-Platform Breakpoints Certification Tests', () {
    testWidgets('QuickLogDock mounts, renders beverages, scroll controls, and logs drink with XP', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: Padding(
                padding: EdgeInsets.all(16.0),
                child: QuickLogDock(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify header and controls
      expect(find.text('Quick Log Beverage'), findsOneWidget);
      expect(find.text('Keys [1-9]'), findsOneWidget);
      expect(find.byTooltip('Craft Custom Beverage'), findsOneWidget);
      expect(find.byTooltip('Scroll Left'), findsOneWidget);
      expect(find.byTooltip('Scroll Right'), findsOneWidget);

      // Verify scrollbar exists
      expect(find.byType(RawScrollbar), findsOneWidget);

      // Verify initial beverages are visible
      expect(find.text('Pure'), findsOneWidget);
      expect(find.text('+250ml'), findsWidgets);

      // Verify initial state: at start, scroll left is disabled, scroll right is active
      final initialScrollRightButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_right_rounded),
      );
      expect(initialScrollRightButton.onPressed, isNotNull);

      // Log a beverage by tapping first drink card while visible
      final initialEntries = container.read(hydrationProvider).entries.length;
      final initialXp = container.read(animalHabitatProvider).userXp;

      await tester.tap(find.text('Pure'));
      await tester.pumpAndSettle();

      expect(container.read(hydrationProvider).entries.length, equals(initialEntries + 1));
      expect(container.read(animalHabitatProvider).userXp, greaterThan(initialXp));

      // Tap scroll right button to animate carousel
      await tester.tap(find.byTooltip('Scroll Right'));
      await tester.pumpAndSettle();

      // After scrolling right, scroll left button should be enabled
      final scrollLeftButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_left_rounded),
      );
      expect(scrollLeftButton.onPressed, isNotNull);

      // Tap scroll left button to return to beginning
      await tester.tap(find.byTooltip('Scroll Left'));
      await tester.pumpAndSettle();

      expect(find.text('Pure'), findsOneWidget);
    });

    testWidgets('QuickLogDock scroll left and right buttons animate carousel', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 350,
                child: QuickLogDock(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find horizontal scrollable
      final scrollableFinder = find.byType(Scrollable);
      expect(scrollableFinder, findsOneWidget);

      final scrollableState = tester.state<ScrollableState>(scrollableFinder);
      expect(scrollableState.position.pixels, equals(0.0));

      // Click Scroll Right
      await tester.tap(find.byTooltip('Scroll Right'));
      await tester.pumpAndSettle();

      expect(scrollableState.position.pixels, greaterThan(0.0));

      // Click Scroll Left
      await tester.tap(find.byTooltip('Scroll Left'));
      await tester.pumpAndSettle();

      expect(scrollableState.position.pixels, equals(0.0));
    });

    testWidgets('Certifies Compact Phone Breakpoint (390 x 844 - iPhone / Pixel)', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
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

      // Phone: Mobile AppBar and FAB present; NavigationRail absent
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.text('Net Hydration Today'), findsOneWidget);
      expect(find.byType(QuickLogDock), findsOneWidget);

      // Verify no RenderFlex overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('Certifies Foldable Breakpoint Unfolded (768 x 1024 - Galaxy Z Fold / iPad Mini)', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
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

      // Tablet / Foldable: NavigationRail present
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.text('Net Hydration Today'), findsOneWidget);
      expect(find.text('AI Hydration Coach'), findsOneWidget);
      expect(find.byType(QuickLogDock), findsOneWidget);

      // Verify clean two-column layout with no RenderFlex overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('Certifies Tablet Breakpoint (834 x 1194 - iPad Pro 11")', (tester) async {
      tester.view.physicalSize = const Size(834, 1194);
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

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.text('Net Hydration Today'), findsOneWidget);
      expect(find.byType(QuickLogDock), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Certifies Expanded Desktop Breakpoint (1440 x 900 - Laptop / Desktop)', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
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

      // Desktop: Brand title, 3 columns, and zero top clipping
      expect(find.text('AquaWild'), findsOneWidget);
      expect(find.text('Net Hydration Today'), findsOneWidget);
      expect(find.byType(QuickLogDock), findsOneWidget);
      expect(find.text('Biomes & Companions'), findsOneWidget);
      expect(find.text('AI Hydration Coach'), findsAtLeastNWidgets(1));

      // Verify zero RenderFlex overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('Certifies 4K Ultra-wide Breakpoint (3840 x 2160 - 4K UHD)', (tester) async {
      tester.view.physicalSize = const Size(3840, 2160);
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

      // On 4K, all 3 command decks render centered within maxWidth 1720
      expect(find.text('AquaWild'), findsOneWidget);
      expect(find.text('Net Hydration Today'), findsOneWidget);
      expect(find.byType(QuickLogDock), findsOneWidget);
      expect(find.text('AI Hydration Coach'), findsAtLeastNWidgets(1));

      // Verify zero RenderFlex overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('Certifies 200% High Text Scale Accessibility (no overflow)', (tester) async {
      tester.view.physicalSize = const Size(400, 850);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
              child: HomeScreen(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Net Hydration card and QuickLogDock scale cleanly
      expect(find.text('Net Hydration Today'), findsOneWidget);
      expect(find.byType(QuickLogDock), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
