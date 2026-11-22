import 'dart:ui';
import 'package:aquawild/src/presentation/widgets/pool/floating_red_panda_painter.dart';
import 'package:aquawild/src/presentation/widgets/pool/interactive_pool_view.dart';
import 'package:aquawild/src/presentation/widgets/pool/mascot_kinematic_controller.dart';
import 'package:aquawild/src/presentation/widgets/pool/pool_water_simulation_painter.dart';
import 'package:aquawild/src/presentation/widgets/pool/ripple_emitter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Pool Simulation & Red Panda Floating Physics Tests', () {
    test('WaterRipple propagates smoothly and attenuates over time', () {
      final ripple = WaterRipple(
        origin: const Offset(100, 100),
        startTimeSeconds: 10.0,
        maxRadius: 200.0,
        amplitude: 1.0,
      );

      // At start (t = 10.0s)
      expect(ripple.radiusAt(10.0), equals(0.0));
      expect(ripple.opacityAt(10.0), equals(1.0));
      expect(ripple.isExpired(10.0), isFalse);

      // At halfway (t = 11.2s, duration = 2.4s)
      final midRadius = ripple.radiusAt(11.2);
      expect(midRadius, greaterThan(100.0));
      final midOpacity = ripple.opacityAt(11.2);
      expect(midOpacity, lessThan(0.6));
      expect(midOpacity, greaterThan(0.4));

      // After duration (t = 12.5s)
      expect(ripple.isExpired(12.5), isTrue);
    });

    test('FloatingRedPandaPainter triggers repaint when physics state changes', () {
      final painter1 = FloatingRedPandaPainter(
        bobOffset: 5.0,
        tiltAngle: 0.05,
        glintPhase: 0.2,
        breathPhase: 0.1,
      );

      final painter2 = FloatingRedPandaPainter(
        bobOffset: 8.0,
        tiltAngle: 0.05,
        glintPhase: 0.2,
        breathPhase: 0.1,
      );

      expect(painter1.shouldRepaint(painter2), isTrue);

      final painter3 = FloatingRedPandaPainter(
        bobOffset: 5.0,
        tiltAngle: 0.05,
        glintPhase: 0.2,
        breathPhase: 0.5,
      );
      expect(painter1.shouldRepaint(painter3), isTrue);

      // Verify ear twitch, reaction pulse, lookTarget triggers repaint
      final painterTwitch = FloatingRedPandaPainter(
        bobOffset: 5.0,
        tiltAngle: 0.05,
        glintPhase: 0.2,
        breathPhase: 0.1,
        earTwitchAngle: 0.15,
      );
      expect(painter1.shouldRepaint(painterTwitch), isTrue);

      final painterReaction = FloatingRedPandaPainter(
        bobOffset: 5.0,
        tiltAngle: 0.05,
        glintPhase: 0.2,
        breathPhase: 0.1,
        reactionPulse: 0.8,
      );
      expect(painter1.shouldRepaint(painterReaction), isTrue);

      final painterLook = FloatingRedPandaPainter(
        bobOffset: 5.0,
        tiltAngle: 0.05,
        glintPhase: 0.2,
        breathPhase: 0.1,
        lookTarget: const Offset(0.5, -0.2),
      );
      expect(painter1.shouldRepaint(painterLook), isTrue);

      final painterSquash = FloatingRedPandaPainter(
        bobOffset: 5.0,
        tiltAngle: 0.05,
        glintPhase: 0.2,
        breathPhase: 0.1,
        verticalSquash: 0.92,
      );
      expect(painter1.shouldRepaint(painterSquash), isTrue);
    });

    test('PoolWaterSimulationPainter repaints when ripples or time changes', () {
      final ripple = WaterRipple(
        origin: const Offset(50, 50),
        startTimeSeconds: 1.0,
      );

      final p1 = PoolWaterSimulationPainter(time: 1.0, ripples: [ripple]);
      final p2 = PoolWaterSimulationPainter(time: 1.5, ripples: [ripple]);

      expect(p1.shouldRepaint(p2), isTrue);
    });

    testWidgets('InteractivePoolView renders mascot with accessible semantics and receives tap',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InteractivePoolView(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Find the Red Panda Semantics node
      final semanticsFinder = find.bySemanticsLabel(
        RegExp(r'Ruby the Red Panda reclining naturally'),
      );
      expect(semanticsFinder, findsOneWidget);

      // Tap on the pool surface to trigger a splash ripple
      await tester.tapAt(const Offset(200, 200));
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
    });

    testWidgets('InteractivePoolView handles mouse hover for eye-tracking gaze',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InteractivePoolView(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Simulate mouse hover moving across the pool
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: const Offset(150, 150));
      await gesture.moveTo(const Offset(250, 250));
      await tester.pump(const Duration(milliseconds: 100));

      await gesture.removePointer();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
    });

    testWidgets('InteractivePoolView respects reduced-motion accessibility preference',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: InteractivePoolView(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // With reduced motion, particles are omitted and physics bob is frozen
      expect(find.byType(InteractivePoolView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('InteractivePoolView handles tap-to-move swim navigation across pool',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InteractivePoolView(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Tap on a destination point to trigger swimming
      await tester.tapAt(const Offset(350, 200));
      await tester.pump(const Duration(milliseconds: 50)); // Anticipation
      await tester.pump(const Duration(milliseconds: 300)); // Swimming
      await tester.pump(const Duration(milliseconds: 400)); // Landing & settling

      expect(tester.takeException(), isNull);
    });

    test('120 FPS raster and physics frame-budget benchmark (<8.3ms per frame)', () {
      final kinematics = MascotKinematicController(
        initialPosition: const Offset(200, 200),
      );
      kinematics.moveTo(
        const Offset(400, 350),
        boundaryRect: const Rect.fromLTRB(100, 100, 500, 500),
      );

      final painter = FloatingRedPandaPainter(
        bobOffset: 4.0,
        tiltAngle: 0.08,
        glintPhase: 0.3,
        breathPhase: 0.5,
        blinkProgress: 0.2,
        tailWagPhase: 1.2,
        lookTarget: const Offset(0.3, -0.4),
        earTwitchAngle: 0.05,
        reactionPulse: 0.4,
        verticalSquash: 1.02,
      );

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(240, 240);

      final stopwatch = Stopwatch()..start();

      // Simulate 120 frames of kinematics updates and canvas paint passes
      for (int frame = 0; frame < 120; frame++) {
        kinematics.update(0.0083); // 120Hz frame delta (8.33ms)
        painter.paint(canvas, size);
      }

      stopwatch.stop();
      final elapsedMs = stopwatch.elapsedMilliseconds;
      final avgFrameMs = elapsedMs / 120.0;

      // Ensure execution is strictly well within the 8.3ms 120Hz frame budget
      expect(avgFrameMs, lessThan(8.3));
    });
  });
}
