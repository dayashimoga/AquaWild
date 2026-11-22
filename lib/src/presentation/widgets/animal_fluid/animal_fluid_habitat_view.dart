import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/audio_haptics_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/beverage_type.dart';
import '../../controllers/animal_habitat_controller.dart';
import '../../controllers/hydration_controller.dart';
import 'animal_fluid_vessel_painter.dart';
import 'custom_numeric_keypad_modal.dart';
import 'interactive_pour_sheet.dart';
import 'wave_column_solver.dart';

/// Centerpiece interactive animal fluid vessel:
/// - 64-column coupled shallow-water wave solver
/// - Density-stratified multi-beverage liquid layers
/// - Splash wave impulses on new drink entry or tap
/// - Pour sheet & numeric keypad triggers
class AnimalFluidHabitatView extends ConsumerStatefulWidget {
  const AnimalFluidHabitatView({super.key});

  @override
  ConsumerState<AnimalFluidHabitatView> createState() =>
      _AnimalFluidHabitatViewState();
}

class _AnimalFluidHabitatViewState extends ConsumerState<AnimalFluidHabitatView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  late final WaveColumnSolver _waveSolver;
  double _timeSeconds = 0.0;
  int _lastEntryCount = 0;
  double _interactionPulse = 0.0;
  double _displayedFillFraction = 0.0;
  double _fillVelocity = 0.0;
  bool _hasInitializedFill = false;

  @override
  void initState() {
    super.initState();
    _waveSolver = WaveColumnSolver(columnCount: 64);
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _triggerSplash(double fillHeight, [int col = 32]) {
    _waveSolver.splash(col, 22.0);
    AudioHapticsService.instance.onDrinkLogged();
  }

  void _openPourSheet(BuildContext context, BeverageType beverage) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InteractivePourSheet(
        initialBeverage: beverage,
        onBeveragePourConfirmed: (selectedBev, volumeMl) {
          ref.read(hydrationProvider.notifier).logDrink(
                beverage: selectedBev,
                volumeMl: volumeMl,
              );
          ref.read(animalHabitatProvider.notifier).addXp(
                (volumeMl / 10).round(),
              );
          _triggerSplash(ref.read(hydrationProvider).goal.progressFraction);
        },
        onPourConfirmed: (_) {},
      ),
    );
  }

  void _openKeypadModal(BuildContext context, BeverageType beverage) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomNumericKeypadModal(
        beverage: beverage,
        onAmountConfirmed: (volumeMl) {
          ref.read(hydrationProvider.notifier).logDrink(
                beverage: beverage,
                volumeMl: volumeMl,
              );
          ref.read(animalHabitatProvider.notifier).addXp(
                (volumeMl / 10).round(),
              );
          _triggerSplash(ref.read(hydrationProvider).goal.progressFraction);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hydrationState = ref.watch(hydrationProvider);
    final habitatState = ref.watch(animalHabitatProvider);
    final activeAnimal = habitatState.activeAnimal;
    final progressFraction = hydrationState.goal.progressFraction;
    final bool reducedMotion = MediaQuery.disableAnimationsOf(context);

    // Initial sync of fill level
    if (!_hasInitializedFill) {
      _displayedFillFraction = progressFraction;
      _hasInitializedFill = true;
    }

    // Trigger splash wave whenever a new drink is logged
    if (hydrationState.entries.length > _lastEntryCount) {
      _lastEntryCount = hydrationState.entries.length;
      _triggerSplash(progressFraction);
    } else {
      _lastEntryCount = hydrationState.entries.length;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double vesselWidth = math.min(constraints.maxWidth * 0.88, 320.0);
        final double vesselHeight = vesselWidth * 1.15;

        return AnimatedBuilder(
          animation: _ticker,
          builder: (context, child) {
            _timeSeconds += 0.016;
            const double dt = 0.016;

            if (reducedMotion) {
              _displayedFillFraction = progressFraction;
              _fillVelocity = 0.0;
            } else {
              _waveSolver.step(dt: 1.0);
              _interactionPulse = math.max(0.0, _interactionPulse - 0.04);

              // Smooth critically-damped spring-damper interpolation for fill level
              final double fillDelta = progressFraction - _displayedFillFraction;
              if (fillDelta.abs() > 0.0005) {
                // Hooke's spring constant k=16.0, damping c=8.5 for smooth zero-overshoot rise
                final double springAcc =
                    (fillDelta * 16.0) - (_fillVelocity * 8.5);
                _fillVelocity += springAcc * dt;
                _displayedFillFraction += _fillVelocity * dt;

                // Continuous pour stream ripple excitation during active liquid level rise
                if (_fillVelocity.abs() > 0.02) {
                  final int rippleCol =
                      24 + ((_timeSeconds * 12).floor() % 16);
                  _waveSolver.splash(rippleCol, _fillVelocity * 2.8);
                }
              } else {
                _displayedFillFraction = progressFraction;
                _fillVelocity = 0.0;
              }
            }

            return Column(
              children: [
                // Animal Fluid Silhouette Vessel Canvas
                GestureDetector(
                  onTapDown: (details) {
                    final int col = ((details.localPosition.dx / vesselWidth) * 64)
                        .floor()
                        .clamp(0, 63);
                    _triggerSplash(progressFraction, col);
                    _interactionPulse = 1.0;
                  },
                  child: Semantics(
                    label:
                        '${activeAnimal.name} fluid container filled to ${hydrationState.goal.progressPercent} percent. Tap to slosh liquid waves.',
                    button: true,
                    child: SizedBox(
                      width: vesselWidth,
                      height: vesselHeight,
                      child: CustomPaint(
                        size: Size(vesselWidth, vesselHeight),
                        painter: AnimalFluidVesselPainter(
                          animalId: activeAnimal.id,
                          fillFraction: _displayedFillFraction,
                          stratifiedLayers: hydrationState.stratifiedLayers,
                          waveSolver: _waveSolver,
                          time: _timeSeconds,
                          accentColor: activeAnimal.accentColor,
                          reducedMotion: reducedMotion,
                          interactionPulse: _interactionPulse,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Interactive Custom Pour & Precision Keypad Action Row
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _openPourSheet(
                        context,
                        BeverageType.pureWater,
                      ),
                      icon: const Icon(Icons.water_drop, size: 16),
                      label: const Text('Custom Pour'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.cyanPrimary,
                        side: const BorderSide(color: AppColors.cyanPrimary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => _openKeypadModal(
                        context,
                        BeverageType.pureWater,
                      ),
                      icon: const Icon(Icons.dialpad, size: 16),
                      label: const Text('Exact Keypad'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
