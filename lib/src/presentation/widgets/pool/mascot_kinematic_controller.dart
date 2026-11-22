import 'dart:math' as math;
import 'package:flutter/animation.dart';

/// Locomotion state phases for the kinematic mascot controller.
enum LocomotionState {
  idle,
  anticipating,
  swimming,
  landing,
}

/// Immutable snapshot of the mascot's instantaneous kinematic physics state.
class MascotKinematics {
  final Offset position;
  final Offset velocity;
  final double headingAngle;
  final double momentumTilt;
  final double verticalSquash; // 1.0 = normal, < 1.0 = crouch, > 1.0 = stretch
  final double landingBounce;
  final LocomotionState state;
  final bool shouldEmitWake;

  const MascotKinematics({
    required this.position,
    this.velocity = Offset.zero,
    this.headingAngle = 0.0,
    this.momentumTilt = 0.0,
    this.verticalSquash = 1.0,
    this.landingBounce = 0.0,
    this.state = LocomotionState.idle,
    this.shouldEmitWake = false,
  });

  MascotKinematics copyWith({
    Offset? position,
    Offset? velocity,
    double? headingAngle,
    double? momentumTilt,
    double? verticalSquash,
    double? landingBounce,
    LocomotionState? state,
    bool? shouldEmitWake,
  }) {
    return MascotKinematics(
      position: position ?? this.position,
      velocity: velocity ?? this.velocity,
      headingAngle: headingAngle ?? this.headingAngle,
      momentumTilt: momentumTilt ?? this.momentumTilt,
      verticalSquash: verticalSquash ?? this.verticalSquash,
      landingBounce: landingBounce ?? this.landingBounce,
      state: state ?? this.state,
      shouldEmitWake: shouldEmitWake ?? this.shouldEmitWake,
    );
  }
}

/// Kinematic locomotion controller orchestrating:
/// - Tap/click-to-move pathfinding with boundary clamping
/// - Pre-movement anticipation crouch and orientation alignment
/// - Smooth cubic eased swimming trajectory (`Curves.easeInOutCubic`)
/// - Inertial momentum tilt based on instantaneous velocity vector
/// - Trailing wake ripple triggers along the travel path
/// - Deceleration and damped harmonic landing bounce upon arrival
/// - Accessibility reduced-motion mode (instantaneous tranquil relocation)
class MascotKinematicController {
  Offset _currentPosition;
  Offset _startPosition;
  Offset _targetPosition;
  Offset _velocity = Offset.zero;

  double _headingAngle = 0.0;
  double _momentumTilt = 0.0;
  double _verticalSquash = 1.0;
  double _landingBounce = 0.0;
  LocomotionState _state = LocomotionState.idle;

  double _phaseTimer = 0.0;
  double _anticipationDuration = 0.14; // 140ms anticipation crouch
  double _swimDuration = 0.70; // Dynamically computed based on distance
  double _landingDuration = 0.32; // 320ms landing bounce
  double _distanceSinceLastWake = 0.0;
  bool _emitWakeThisFrame = false;

  MascotKinematicController({required Offset initialPosition})
      : _currentPosition = initialPosition,
        _startPosition = initialPosition,
        _targetPosition = initialPosition;

  MascotKinematics get state => MascotKinematics(
        position: _currentPosition,
        velocity: _velocity,
        headingAngle: _headingAngle,
        momentumTilt: _momentumTilt,
        verticalSquash: _verticalSquash,
        landingBounce: _landingBounce,
        state: _state,
        shouldEmitWake: _emitWakeThisFrame,
      );

  Offset get position => _currentPosition;
  LocomotionState get locomotionState => _state;
  bool get isMoving => _state != LocomotionState.idle;

  /// Orders the mascot to navigate towards [target], constrained within [boundaryRect].
  /// If [immediate] or reduced motion is true, snaps instantly to destination.
  void moveTo(
    Offset target, {
    required Rect boundaryRect,
    bool immediate = false,
  }) {
    final Offset clampedTarget = Offset(
      target.dx.clamp(boundaryRect.left, boundaryRect.right),
      target.dy.clamp(boundaryRect.top, boundaryRect.bottom),
    );

    if (immediate) {
      _currentPosition = clampedTarget;
      _startPosition = clampedTarget;
      _targetPosition = clampedTarget;
      _velocity = Offset.zero;
      _momentumTilt = 0.0;
      _verticalSquash = 1.0;
      _landingBounce = 0.0;
      _state = LocomotionState.idle;
      _emitWakeThisFrame = false;
      return;
    }

    final double distance = (clampedTarget - _currentPosition).distance;
    if (distance < 8.0) {
      return; // Already at target destination
    }

    _startPosition = _currentPosition;
    _targetPosition = clampedTarget;
    _phaseTimer = 0.0;
    _distanceSinceLastWake = 0.0;
    _emitWakeThisFrame = false;

    // Swim duration scaled by distance: ~380 px/sec cruising velocity
    _swimDuration = (distance / 380.0).clamp(0.40, 1.40);
    _anticipationDuration = 0.14;
    _landingDuration = 0.32;

    _state = LocomotionState.anticipating;
  }

  /// Advances physics simulation by delta time [dt] in seconds.
  void update(double dt, {bool reducedMotion = false}) {
    if (reducedMotion) {
      if (_state != LocomotionState.idle) {
        _currentPosition = _targetPosition;
        _startPosition = _targetPosition;
        _velocity = Offset.zero;
        _momentumTilt = 0.0;
        _verticalSquash = 1.0;
        _landingBounce = 0.0;
        _state = LocomotionState.idle;
      }
      _emitWakeThisFrame = false;
      return;
    }

    _emitWakeThisFrame = false;

    switch (_state) {
      case LocomotionState.idle:
        _velocity = Offset.zero;
        _momentumTilt = _lerpDouble(_momentumTilt, 0.0, 0.15);
        _verticalSquash = _lerpDouble(_verticalSquash, 1.0, 0.15);
        _landingBounce = _lerpDouble(_landingBounce, 0.0, 0.15);
        break;

      case LocomotionState.anticipating:
        _phaseTimer += dt;
        final double progress =
            (_phaseTimer / _anticipationDuration).clamp(0.0, 1.0);

        // Anticipation crouch: slight downward squash into water cushion
        _verticalSquash = 1.0 - math.sin(progress * math.pi) * 0.08;
        _landingBounce = 0.0;

        // Smoothly orient heading towards target trajectory
        final double targetHeading =
            (_targetPosition - _currentPosition).direction;
        _headingAngle = _lerpAngle(_headingAngle, targetHeading, progress * 0.6);

        if (_phaseTimer >= _anticipationDuration) {
          _state = LocomotionState.swimming;
          _phaseTimer = 0.0;
          _distanceSinceLastWake = 0.0;
          _emitWakeThisFrame = true; // Initial thrust wake
        }
        break;

      case LocomotionState.swimming:
        _phaseTimer += dt;
        final double progress = (_phaseTimer / _swimDuration).clamp(0.0, 1.0);
        final double easedProgress = Curves.easeInOutCubic.transform(progress);

        final Offset prevPosition = _currentPosition;
        _currentPosition =
            Offset.lerp(_startPosition, _targetPosition, easedProgress)!;

        final double safeDt = dt > 0.0001 ? dt : 0.016;
        _velocity = (_currentPosition - prevPosition) / safeDt;

        if (_velocity.distanceSquared > 1.0) {
          _headingAngle = _velocity.direction;
        }

        // Momentum tilt: lean into the horizontal velocity vector
        final double targetTilt = (_velocity.dx / 400.0).clamp(-0.22, 0.22);
        _momentumTilt = _lerpDouble(_momentumTilt, targetTilt, 0.25);

        // Hydrodynamic stretch during cruising speed
        _verticalSquash =
            1.0 + (_velocity.distance / 500.0).clamp(0.0, 0.06);

        // Periodic wake trail emission along trajectory
        final double stepDistance =
            (_currentPosition - prevPosition).distance;
        _distanceSinceLastWake += stepDistance;
        if (_distanceSinceLastWake >= 26.0) {
          _emitWakeThisFrame = true;
          _distanceSinceLastWake = 0.0;
        }

        if (_phaseTimer >= _swimDuration) {
          _state = LocomotionState.landing;
          _phaseTimer = 0.0;
          _currentPosition = _targetPosition;
          _emitWakeThisFrame = true; // Arrival ripple
        }
        break;

      case LocomotionState.landing:
        _phaseTimer += dt;
        final double progress =
            (_phaseTimer / _landingDuration).clamp(0.0, 1.0);

        // Damped harmonic bounce settling vertically into water
        final double decay = math.exp(-progress * 4.5);
        _landingBounce = decay * math.sin(progress * math.pi * 3.0) * 10.0;

        _momentumTilt = _lerpDouble(_momentumTilt, 0.0, 0.20);
        _verticalSquash =
            1.0 + decay * math.cos(progress * math.pi * 2.0) * 0.05;
        _velocity = Offset.zero;

        if (_phaseTimer >= _landingDuration) {
          _state = LocomotionState.idle;
          _phaseTimer = 0.0;
          _landingBounce = 0.0;
          _verticalSquash = 1.0;
          _momentumTilt = 0.0;
        }
        break;
    }
  }

  static double _lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }

  static double _lerpAngle(double a, double b, double t) {
    double diff = (b - a) % (2 * math.pi);
    if (diff > math.pi) diff -= 2 * math.pi;
    if (diff < -math.pi) diff += 2 * math.pi;
    return a + diff * t;
  }
}
