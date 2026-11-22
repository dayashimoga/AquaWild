import 'package:aquawild/src/domain/models/animal_evolution_stage.dart';
import 'package:aquawild/src/domain/models/exotic_animal.dart';
import 'package:aquawild/src/domain/models/hydration_biome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Exotic Animal & Biome Domain Tests', () {
    test('All 10 exotic animals are registered with 4 evolution stages', () {
      expect(ExoticAnimal.allAnimals.length, equals(10));

      final expectedAnimals = [
        'red_panda',
        'capybara',
        'axolotl',
        'sea_otter',
        'andean_llama',
        'arctic_fox',
        'emperor_penguin',
        'bottlenose_dolphin',
        'blue_ringed_octopus',
        'snow_leopard',
      ];

      for (final id in expectedAnimals) {
        final animal = ExoticAnimal.findById(id);
        expect(animal.id, equals(id));
        expect(animal.evolutionStages.length, equals(4));
        expect(animal.evolutionStages.first.stageNumber, equals(1));
        expect(animal.evolutionStages.last.stageNumber, equals(4));
      }
    });

    test('Ruby the Red Panda is the starter animal with 0 unlock XP', () {
      final ruby = ExoticAnimal.findById('red_panda');
      expect(ruby.unlockXp, equals(0));
      expect(ruby.name, contains('Red Panda'));
    });

    test('All 10 exotic animals map to accurate avatar emojis without fallback', () {
      final expectedEmojis = {
        'red_panda': '🦊',
        'capybara': '🦫',
        'axolotl': '🦎',
        'sea_otter': '🦦',
        'andean_llama': '🦙',
        'arctic_fox': '🐺',
        'emperor_penguin': '🐧',
        'bottlenose_dolphin': '🐬',
        'blue_ringed_octopus': '🐙',
        'snow_leopard': '🐆',
      };

      for (final entry in expectedEmojis.entries) {
        final animal = ExoticAnimal.findById(entry.key);
        expect(animal.avatarEmoji, equals(entry.value));
        expect(animal.avatarEmoji, isNot(equals('🐾')));
      }

      // Legacy aliases
      const legacyDolphin = ExoticAnimal(
        id: 'pink_river_dolphin',
        name: 'Legacy Dolphin',
        scientificName: 'Inia geoffrensis',
        lore: 'Legacy',
        habitatBiomeId: 'kelp_forest_lagoon',
        unlockXp: 0,
        accentColor: Color(0xFF4FC3F7),
        defaultCapacityMl: 2700,
        evolutionStages: AnimalEvolutionStage.defaultStages,
        nativeHabitat: 'Amazon',
      );
      expect(legacyDolphin.avatarEmoji, equals('🐬'));

      const legacyOctopus = ExoticAnimal(
        id: 'bioluminescent_octopus',
        name: 'Legacy Octopus',
        scientificName: 'Octopus',
        lore: 'Legacy',
        habitatBiomeId: 'bioluminescent_cenote',
        unlockXp: 0,
        accentColor: Color(0xFF00E5FF),
        defaultCapacityMl: 2500,
        evolutionStages: AnimalEvolutionStage.defaultStages,
        nativeHabitat: 'Reef',
      );
      expect(legacyOctopus.avatarEmoji, equals('🐙'));
    });

    test('All 6 living hydration biomes are registered with valid palettes', () {
      expect(HydrationBiome.allBiomes.length, equals(6));

      for (final biome in HydrationBiome.allBiomes) {
        expect(biome.skyGradient.length, greaterThanOrEqualTo(2));
        expect(biome.nativeAnimalIds.isNotEmpty, isTrue);
      }
    });
  });
}
