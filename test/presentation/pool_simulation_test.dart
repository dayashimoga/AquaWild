import 'package:aquawild/src/presentation/widgets/pool/floating_red_panda_painter.dart';
import 'package:aquawild/src/presentation/widgets/pool/interactive_pool_view.dart';
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
  });
}
