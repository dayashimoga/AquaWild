import 'package:aquawild/src/presentation/widgets/pool/mascot_kinematic_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MascotKinematicController Kinematic Locomotion Tests', () {
    const boundary = Rect.fromLTRB(100, 100, 500, 500);

    test('Initializes in idle state at initial position', () {
      final controller = MascotKinematicController(
        initialPosition: const Offset(250, 250),
      );

      final state = controller.state;
      expect(state.position, equals(const Offset(250, 250)));
      expect(state.state, equals(LocomotionState.idle));
      expect(state.velocity, equals(Offset.zero));
      expect(state.momentumTilt, equals(0.0));
      expect(state.verticalSquash, equals(1.0));
      expect(state.landingBounce, equals(0.0));
      expect(state.shouldEmitWake, isFalse);
    });

    test('moveTo clamps destination within boundary rect', () {
      final controller = MascotKinematicController(
        initialPosition: const Offset(250, 250),
      );

      // Target far beyond boundaries (0, 999) -> should clamp to (100, 500)
      controller.moveTo(const Offset(0, 999), boundaryRect: boundary);

      expect(controller.locomotionState, equals(LocomotionState.anticipating));

      // Advance physics through anticipation and swimming to arrival
      controller.update(0.15); // Finishes anticipation, starts swimming
      expect(controller.locomotionState, equals(LocomotionState.swimming));

      controller.update(1.50); // Finishes swim
      expect(controller.position.dx, equals(100.0));
      expect(controller.position.dy, equals(500.0));
    });

    test('Anticipation phase applies subtle crouch and heading orientation', () {
      final controller = MascotKinematicController(
        initialPosition: const Offset(200, 200),
      );

      controller.moveTo(const Offset(400, 200), boundaryRect: boundary);
      expect(controller.locomotionState, equals(LocomotionState.anticipating));

      // Halfway through 140ms anticipation (at 70ms)
      controller.update(0.07);
      final state = controller.state;

      expect(state.state, equals(LocomotionState.anticipating));
      // Crouch should be below 1.0 (squash into water cushion)
      expect(state.verticalSquash, lessThan(1.0));
      expect(state.verticalSquash, greaterThan(0.90));
    });

    test('Swimming phase executes cubic eased path with momentum tilt & wake ripples', () {
      final controller = MascotKinematicController(
        initialPosition: const Offset(150, 250),
      );

      controller.moveTo(const Offset(450, 250), boundaryRect: boundary);
      controller.update(0.15); // Enter swimming phase

      expect(controller.locomotionState, equals(LocomotionState.swimming));

      bool detectedWake = false;
      double peakTilt = 0.0;

      // Advance in small 16ms delta steps (120 FPS simulation)
      for (int i = 0; i < 40; i++) {
        controller.update(0.016);
        final state = controller.state;
        if (state.shouldEmitWake) detectedWake = true;
        if (state.momentumTilt.abs() > peakTilt.abs()) {
          peakTilt = state.momentumTilt;
        }
      }

      // Should have leaned right (+ tilt) and emitted wake ripples
      expect(detectedWake, isTrue);
      expect(peakTilt, greaterThan(0.05));
    });

    test('Landing phase executes damped harmonic bounce before settling to idle', () {
      final controller = MascotKinematicController(
        initialPosition: const Offset(200, 200),
      );

      controller.moveTo(const Offset(280, 200), boundaryRect: boundary);
      controller.update(0.15); // End anticipation
      controller.update(1.50); // End swim -> enter landing

      expect(controller.locomotionState, equals(LocomotionState.landing));

      // Advance through landing bounce
      controller.update(0.08);
      expect(controller.state.landingBounce.abs(), greaterThan(0.5));

      // Finish landing duration (320ms total)
      controller.update(0.35);
      expect(controller.locomotionState, equals(LocomotionState.idle));
      expect(controller.state.landingBounce, equals(0.0));
      expect(controller.state.verticalSquash, equals(1.0));
      expect(controller.state.momentumTilt, equals(0.0));
    });

    test('Reduced-motion mode immediately snaps to target without momentum or bounce', () {
      final controller = MascotKinematicController(
        initialPosition: const Offset(200, 200),
      );

      controller.moveTo(
        const Offset(400, 400),
        boundaryRect: boundary,
        immediate: true,
      );

      final state = controller.state;
      expect(state.position, equals(const Offset(400, 400)));
      expect(state.state, equals(LocomotionState.idle));
      expect(state.velocity, equals(Offset.zero));
      expect(state.landingBounce, equals(0.0));
      expect(state.verticalSquash, equals(1.0));
    });

    test('Smooth retargeting in flight updates trajectory smoothly', () {
      final controller = MascotKinematicController(
        initialPosition: const Offset(200, 200),
      );

      controller.moveTo(const Offset(400, 200), boundaryRect: boundary);
      controller.update(0.15); // In swimming
      controller.update(0.20); // Mid-flight

      final midFlightPos = controller.position;
      expect(midFlightPos.dx, greaterThan(200.0));

      // Retarget to a different destination
      controller.moveTo(const Offset(200, 400), boundaryRect: boundary);
      expect(controller.locomotionState, equals(LocomotionState.anticipating));
      expect(controller.position, equals(midFlightPos)); // No jump
    });
  });
}
