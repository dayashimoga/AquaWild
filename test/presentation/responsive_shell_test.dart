import 'package:aquawild/src/presentation/controllers/hydration_controller.dart';
import 'package:aquawild/src/presentation/screens/home/home_screen.dart';
import 'package:aquawild/src/presentation/widgets/shortcuts/keyboard_shortcuts_modal.dart';
import 'package:aquawild/src/presentation/widgets/voice/voice_command_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ResponsiveHomeShell & Multimodal Accessibility Tests', () {
    testWidgets('renders Compact Mobile layout on narrow screen (<700px)', (tester) async {
      tester.view.physicalSize = const Size(400, 850);
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

      // Should find mobile AppBar and FAB
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Net Hydration Today'), findsOneWidget);
      expect(find.text('Quick Log Beverage'), findsOneWidget);
      // NavigationRail should NOT be present on phone
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('renders Medium Tablet layout with NavigationRail (700px - 1100px)', (tester) async {
      tester.view.physicalSize = const Size(900, 900);
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

      // Should find NavigationRail on tablet
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.text('Net Hydration Today'), findsOneWidget);
      expect(find.text('Quick Log Beverage'), findsOneWidget);
      expect(find.text('AI Hydration Coach'), findsOneWidget);
    });

    testWidgets('renders Expanded Desktop 3-pane layout (>=1100px)', (tester) async {
      tester.view.physicalSize = const Size(1300, 900);
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

      // Should find Desktop Brand Header and 3 columns
      expect(find.text('AquaWild'), findsOneWidget);
      expect(find.text('Net Hydration Today'), findsOneWidget);
      expect(find.text('Today\'s Entries (0)'), findsNothing);
      expect(find.text('Biomes & Companions'), findsOneWidget);
      expect(find.text('AI Hydration Coach'), findsAtLeastNWidgets(1));
    });

    testWidgets('Keyboard shortcut Space quick-logs 250ml water', (tester) async {
      tester.view.physicalSize = const Size(400, 850);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      final initialEntries = container.read(hydrationProvider).entries.length;

      // Simulate Space key press
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump(const Duration(milliseconds: 100));

      final updatedEntries = container.read(hydrationProvider).entries.length;
      expect(updatedEntries, equals(initialEntries + 1));
      expect(container.read(hydrationProvider).entries.last.volumeMl, equals(250.0));
    });

    testWidgets('Keyboard shortcut Digit1 quick-logs first beverage', (tester) async {
      tester.view.physicalSize = const Size(400, 850);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      final initialEntries = container.read(hydrationProvider).entries.length;

      // Simulate Digit1 key press
      await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
      await tester.pump(const Duration(milliseconds: 100));

      final updatedEntries = container.read(hydrationProvider).entries.length;
      expect(updatedEntries, equals(initialEntries + 1));
    });

    testWidgets('VoiceCommandModal displays presets and speech input', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: VoiceCommandModal(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Voice Hydration Logger'), findsOneWidget);
      expect(find.text('Drank 250ml pure water'), findsOneWidget);

      // Tap preset
      await tester.tap(find.text('Drank 250ml pure water'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Log 250ml'), findsOneWidget);
    });

    testWidgets('KeyboardShortcutsModal displays key accelerators cheat-sheet', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KeyboardShortcutsModal(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Keyboard Accelerators & Shortcuts'), findsOneWidget);
      expect(find.text('1 - 9'), findsOneWidget);
      expect(find.text('Space'), findsOneWidget);
      expect(find.text('AI Hydration Coach'), findsOneWidget);
    });

    testWidgets('ResponsiveHomeShell applies dynamic biome ambient background decoration', (tester) async {
      tester.view.physicalSize = const Size(400, 850);
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

      final animatedContainerFinder = find.byWidgetPredicate(
        (widget) => widget is AnimatedContainer && widget.decoration is BoxDecoration,
      );
      expect(animatedContainerFinder, findsAtLeastNWidgets(1));

      final animatedContainer = tester.widget<AnimatedContainer>(animatedContainerFinder.first);
      final boxDecoration = animatedContainer.decoration as BoxDecoration;
      expect(boxDecoration.gradient, isNotNull);
      expect(boxDecoration.gradient is LinearGradient, isTrue);
    });
  });
}
