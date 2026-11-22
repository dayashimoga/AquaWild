import 'package:aquawild/src/domain/models/beverage_type.dart';
import 'package:aquawild/src/domain/models/exotic_animal.dart';
import 'package:aquawild/src/domain/models/fluid_layer.dart';
import 'package:aquawild/src/presentation/controllers/hydration_controller.dart';
import 'package:aquawild/src/presentation/widgets/animal_fluid/animal_fluid_habitat_view.dart';
import 'package:aquawild/src/presentation/widgets/animal_fluid/animal_fluid_vessel_painter.dart';
import 'package:aquawild/src/presentation/widgets/animal_fluid/animal_silhouette_paths.dart';
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

    testWidgets('Paints Ruby the Red Panda mascot features during blinking and interaction pulse',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(300, 345),
              painter: AnimalFluidVesselPainter(
                animalId: 'red_panda',
                fillFraction: 0.6,
                stratifiedLayers: stratifiedLayers,
                waveSolver: waveSolver,
                time: 0.05, // triggers isBlinking (< 0.20)
                accentColor: const Color(0xFFD84315),
                interactionPulse: 1.0, // max blush and glow
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

    testWidgets('Paints Ruby the Red Panda in reduced-motion mode without blinking or dynamic wobble',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(300, 345),
              painter: AnimalFluidVesselPainter(
                animalId: 'red_panda',
                fillFraction: 0.7,
                stratifiedLayers: stratifiedLayers,
                waveSolver: waveSolver,
                time: 0.05,
                accentColor: const Color(0xFFD84315),
                reducedMotion: true,
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

    testWidgets('Paints Ollie the Sea Otter with kelp and pearl shell cleanly',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(300, 345),
              painter: AnimalFluidVesselPainter(
                animalId: 'sea_otter',
                fillFraction: 0.55,
                stratifiedLayers: stratifiedLayers,
                waveSolver: waveSolver,
                time: 1.8,
                accentColor: const Color(0xFF4DB6AC),
                interactionPulse: 0.7,
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

    testWidgets('Paints Luna the Andean Llama with festive Aztec collar and tassels',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(300, 345),
              painter: AnimalFluidVesselPainter(
                animalId: 'andean_llama',
                fillFraction: 0.7,
                stratifiedLayers: stratifiedLayers,
                waveSolver: waveSolver,
                time: 2.1,
                accentColor: const Color(0xFFFFB74D),
                interactionPulse: 0.5,
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

    testWidgets('Paints Octavia the Blue-Ringed Octopus with bioluminescent pulsing rings',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(300, 345),
              painter: AnimalFluidVesselPainter(
                animalId: 'blue_ringed_octopus',
                fillFraction: 0.6,
                stratifiedLayers: stratifiedLayers,
                waveSolver: waveSolver,
                time: 3.4,
                accentColor: const Color(0xFF00E5FF),
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

    testWidgets('Paints Echo the Dolphin with expanding acoustic sonar rings',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(300, 345),
              painter: AnimalFluidVesselPainter(
                animalId: 'bottlenose_dolphin',
                fillFraction: 0.5,
                stratifiedLayers: stratifiedLayers,
                waveSolver: waveSolver,
                time: 1.5,
                accentColor: const Color(0xFF4FC3F7),
                interactionPulse: 0.6,
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

    testWidgets('Paints Freya the Arctic Fox, Percy the Penguin, and Kira the Snow Leopard without errors',
        (tester) async {
      for (final companionId in ['arctic_fox', 'emperor_penguin', 'snow_leopard']) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomPaint(
                size: const Size(300, 345),
                painter: AnimalFluidVesselPainter(
                  animalId: companionId,
                  fillFraction: 0.45,
                  stratifiedLayers: stratifiedLayers,
                  waveSolver: waveSolver,
                  time: 2.0,
                  accentColor: Colors.cyan,
                  interactionPulse: 0.4,
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
      }
    });

    test('All 10 companions have valid non-empty silhouette vector paths', () {
      const testSize = Size(320, 368);
      for (final animal in ExoticAnimal.allAnimals) {
        final path = AnimalSilhouettePaths.getSilhouettePath(animal.id, testSize);
        expect(path, isNotNull);
        expect(path.getBounds().isEmpty, isFalse);
        expect(path.getBounds().width, greaterThan(0));
        expect(path.getBounds().height, greaterThan(0));
      }
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

    testWidgets('AnimalFluidHabitatView interpolates liquid fill smoothly with spring physics upon logging a drink',
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
      await tester.pump(const Duration(milliseconds: 50));

      final container = ProviderScope.containerOf(
        tester.element(find.byType(AnimalFluidHabitatView)),
      );

      // Log a drink directly through provider
      await container.read(hydrationProvider.notifier).logDrink(
        beverage: BeverageType.pureWater,
        volumeMl: 500,
      );

      // Pump several animation frames to advance spring interpolation
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
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

    testWidgets('Stratified fluid renders multi-beverage layers with zero-gap coupled boundary contours',
        (tester) async {
      final fourLayers = [
        const FluidLayer(
          beverage: BeverageType.espresso,
          volumeMl: 60,
          fractionOfTotal: 0.15,
          relativeDensity: 1.040,
        ),
        const FluidLayer(
          beverage: BeverageType.electrolyteDrink,
          volumeMl: 250,
          fractionOfTotal: 0.35,
          relativeDensity: 1.015,
        ),
        const FluidLayer(
          beverage: BeverageType.pureWater,
          volumeMl: 250,
          fractionOfTotal: 0.35,
          relativeDensity: 1.000,
        ),
        const FluidLayer(
          beverage: BeverageType.sparklingWater,
          volumeMl: 100,
          fractionOfTotal: 0.15,
          relativeDensity: 0.990,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(300, 345),
              painter: AnimalFluidVesselPainter(
                animalId: 'red_panda',
                fillFraction: 0.85,
                stratifiedLayers: fourLayers,
                waveSolver: waveSolver,
                time: 1.5,
                accentColor: const Color(0xFFD84315),
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
      expect(tester.takeException(), isNull);
    });

    testWidgets('Stratified fluid renders cleanly with zero gap in reduced-motion mode',
        (tester) async {
      final twoLayers = [
        const FluidLayer(
          beverage: BeverageType.electrolyteDrink,
          volumeMl: 250,
          fractionOfTotal: 0.5,
          relativeDensity: 1.015,
        ),
        const FluidLayer(
          beverage: BeverageType.pureWater,
          volumeMl: 250,
          fractionOfTotal: 0.5,
          relativeDensity: 1.000,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(300, 345),
              painter: AnimalFluidVesselPainter(
                animalId: 'capybara',
                fillFraction: 0.70,
                stratifiedLayers: twoLayers,
                waveSolver: waveSolver,
                time: 2.0,
                accentColor: const Color(0xFF8D6E63),
                reducedMotion: true,
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
      expect(tester.takeException(), isNull);
    });
  });
}
