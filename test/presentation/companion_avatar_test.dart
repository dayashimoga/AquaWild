import 'package:aquawild/src/domain/models/animal_evolution_stage.dart';
import 'package:aquawild/src/domain/models/exotic_animal.dart';
import 'package:aquawild/src/presentation/widgets/animal_fluid/animal_silhouette_paths.dart';
import 'package:aquawild/src/presentation/widgets/biomes/companion_avatar_renderer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CompanionAvatarRenderer & Evolution Aura Tests', () {
    testWidgets('Renders all 10 companions cleanly in CompanionAvatarRenderer',
        (tester) async {
      for (final animal in ExoticAnimal.allAnimals) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: CompanionAvatarRenderer(
                  animal: animal,
                  size: 56,
                  isSelected: animal.id == 'red_panda',
                  isUnlocked: true,
                  showAura: true,
                  showBadge: true,
                ),
              ),
            ),
          ),
        );

        expect(find.byType(CompanionAvatarRenderer), findsOneWidget);
        expect(find.text(animal.avatarEmoji), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Renders all 4 Evolution Stage Auras correctly',
        (tester) async {
      final ruby = ExoticAnimal.allAnimals.first;

      for (final stage in AnimalEvolutionStage.defaultStages) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: CompanionAvatarRenderer(
                  animal: ruby,
                  stage: stage,
                  size: 110,
                  isSelected: true,
                  isUnlocked: true,
                  showAura: true,
                  showBadge: true,
                  animate: true,
                ),
              ),
            ),
          ),
        );

        expect(find.byType(CompanionAvatarRenderer), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Renders locked state with frosted overlay and lock icon',
        (tester) async {
      final snowLeopard = ExoticAnimal.allAnimals.firstWhere(
        (a) => a.id == 'snow_leopard',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CompanionAvatarRenderer(
                animal: snowLeopard,
                size: 52,
                isUnlocked: false,
                isSelected: false,
                showAura: false,
                showBadge: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
      expect(find.text(snowLeopard.avatarEmoji), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Renders cleanly under reduced-motion accessibility mode',
        (tester) async {
      final octopus = ExoticAnimal.allAnimals.firstWhere(
        (a) => a.id == 'blue_ringed_octopus',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: Center(
                child: CompanionAvatarRenderer(
                  animal: octopus,
                  stage: AnimalEvolutionStage.defaultStages.last,
                  size: 80,
                  isSelected: true,
                  isUnlocked: true,
                  showAura: true,
                  animate: true,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CompanionAvatarRenderer), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Provides accessible semantics tree annotations',
        (tester) async {
      final capybara = ExoticAnimal.allAnimals.firstWhere(
        (a) => a.id == 'capybara',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CompanionAvatarRenderer(
                animal: capybara,
                stage: AnimalEvolutionStage.defaultStages[1],
                size: 64,
                isSelected: true,
                isUnlocked: true,
              ),
            ),
          ),
        ),
      );

      final semanticsFinder = find.byWidgetPredicate(
        (w) =>
            w is Semantics &&
            w.properties.label != null &&
            w.properties.label!.contains('Cappy the Capybara') &&
            w.properties.label!.contains('Explorer') &&
            w.properties.label!.contains('Active companion'),
      );
      expect(semanticsFinder, findsOneWidget);
    });
  });

  group('Stage 4: 10-Animal Comprehensive Ecosystem Regression Suite', () {
    test('All 10 companions have valid non-empty silhouette vector paths at multiple viewports',
        () {
      final testSizes = [
        const Size(32, 32),
        const Size(56, 56),
        const Size(120, 120),
        const Size(300, 345),
        const Size(800, 600),
      ];

      for (final animal in ExoticAnimal.allAnimals) {
        for (final size in testSizes) {
          final path =
              AnimalSilhouettePaths.getSilhouettePath(animal.id, size);
          expect(path, isNotNull);
          final bounds = path.getBounds();
          expect(bounds.isEmpty, isFalse);
          expect(bounds.width, greaterThan(0));
          expect(bounds.height, greaterThan(0));
          expect(bounds.width, lessThanOrEqualTo(size.width * 1.05));
          expect(bounds.height, lessThanOrEqualTo(size.height * 1.05));
        }
      }
    });

    test('All 10 companions have unique IDs, names, biomes, and authentic emojis',
        () {
      final ids = <String>{};
      final names = <String>{};
      final emojis = <String>{};

      for (final animal in ExoticAnimal.allAnimals) {
        expect(ids.add(animal.id), isTrue, reason: 'Duplicate ID: ${animal.id}');
        expect(names.add(animal.name), isTrue, reason: 'Duplicate Name: ${animal.name}');
        expect(emojis.add(animal.avatarEmoji), isTrue, reason: 'Duplicate Emoji: ${animal.avatarEmoji}');
        expect(animal.avatarEmoji, isNot('🐾'), reason: 'Unmapped avatar emoji fallback for ${animal.id}');
        expect(animal.accentColor.toARGB32(), isNot(0));
        expect(animal.defaultCapacityMl, greaterThanOrEqualTo(2000));
        expect(animal.evolutionStages.length, equals(4));
      }

      expect(ids.length, equals(10));
    });
  });
}
