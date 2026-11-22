import 'package:aquawild/src/domain/models/beverage_type.dart';
import 'package:aquawild/src/domain/models/exotic_animal.dart';
import 'package:aquawild/src/domain/models/fluid_layer.dart';
import 'package:aquawild/src/presentation/widgets/animal_fluid/animal_fluid_habitat_view.dart';
import 'package:aquawild/src/presentation/widgets/animal_fluid/animal_fluid_vessel_painter.dart';
import 'package:aquawild/src/presentation/widgets/animal_fluid/wave_column_solver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnimalFluidVesselPainter Interactive Animations Tests', () {
    final waveSolver = WaveColumnSolver(columnCount: 64);
    final List<FluidLayer> stratifiedLayers = [
      const FluidLayer(
        beverage: BeverageType.pureWater,
        volumeMl: 500,
        fractionOfTotal: 0.6,
        relativeDensity: 1.0,
      ),
      const FluidLayer(
        beverage: BeverageType.greenTea,
        volumeMl: 300,
        fractionOfTotal: 0.4,
        relativeDensity: 1.008,
      ),
    ];

    testWidgets('Paints Cappy the Capybara with thermal yuzus and steam without errors',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(300, 345),
              painter: AnimalFluidVesselPainter(
                animalId: 'capybara',
                fillFraction: 0.65,
                stratifiedLayers: stratifiedLayers,
                waveSolver: waveSolver,
                time: 2.5,
                accentColor: const Color(0xFF8D6E63),
                interactionPulse: 0.8,
              ),
            ),
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is CustomPaint && w.painter is AnimalFluidVesselPainter,
        ),
        findsOneWidget,
      );
    });

    testWidgets('Paints Lottie the Axolotl with bioluminescent gills and spores without errors',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(300, 345),
              painter: AnimalFluidVesselPainter(
                animalId: 'axolotl',
                fillFraction: 0.5,
                stratifiedLayers: stratifiedLayers,
                waveSolver: waveSolver,
                time: 1.2,
                accentColor: const Color(0xFFF48FB1),
                interactionPulse: 1.0,
              ),
            ),
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is CustomPaint && w.painter is AnimalFluidVesselPainter,
        ),
        findsOneWidget,
      );
    });

    testWidgets('Paints Ruby the Red Panda mascot features cleanly',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(300, 345),
              painter: AnimalFluidVesselPainter(
                animalId: 'red_panda',
                fillFraction: 0.4,
                stratifiedLayers: stratifiedLayers,
                waveSolver: waveSolver,
                time: 0.5,
                accentColor: const Color(0xFFD84315),
                interactionPulse: 0.0,
              ),
            ),
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is CustomPaint && w.painter is AnimalFluidVesselPainter,
        ),
        findsOneWidget,
      );
    });

    testWidgets('Supports reduced-motion accessibility mode without throwing',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(300, 345),
              painter: AnimalFluidVesselPainter(
                animalId: 'axolotl',
                fillFraction: 0.75,
                stratifiedLayers: stratifiedLayers,
                waveSolver: waveSolver,
                time: 3.0,
                accentColor: const Color(0xFFF48FB1),
                reducedMotion: true,
                interactionPulse: 0.0,
              ),
            ),
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is CustomPaint && w.painter is AnimalFluidVesselPainter,
        ),
        findsOneWidget,
      );
    });

    testWidgets('AnimalFluidHabitatView mounts and responds to tap gesture with wave impulse',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AnimalFluidHabitatView(),
            ),
          ),
        ),
      );

      expect(find.byType(AnimalFluidHabitatView), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      // Tap on the fluid silhouette vessel to excite waves and interaction pulse
      await tester.tap(find.byType(CustomPaint).first);
      await tester.pump(const Duration(milliseconds: 32));

      expect(find.text('Custom Pour'), findsOneWidget);
      expect(find.text('Exact Keypad'), findsOneWidget);
    });

    test('Starter companions include Capybara and Axolotl with 0 unlock XP', () {
      final capy = ExoticAnimal.allAnimals.firstWhere((a) => a.id == 'capybara');
      final axo = ExoticAnimal.allAnimals.firstWhere((a) => a.id == 'axolotl');
      final redPanda = ExoticAnimal.allAnimals.firstWhere((a) => a.id == 'red_panda');

      expect(capy.unlockXp, 0);
      expect(axo.unlockXp, 0);
      expect(redPanda.unlockXp, 0);
      expect(capy.habitatBiomeId, 'thermal_yuzu_onsen');
      expect(axo.habitatBiomeId, 'bioluminescent_cenote');
    });
  });
}
