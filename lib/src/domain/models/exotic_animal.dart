import 'package:flutter/material.dart';
import 'animal_evolution_stage.dart';

/// Exotic animal companion whose silhouette serves as the dynamic hydration vessel
class ExoticAnimal {
  final String id;
  final String name;
  final String scientificName;
  final String lore;
  final String habitatBiomeId;
  final int unlockXp;
  final Color accentColor;
  final int defaultCapacityMl;
  final List<AnimalEvolutionStage> evolutionStages;
  final String nativeHabitat;

  const ExoticAnimal({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.lore,
    required this.habitatBiomeId,
    required this.unlockXp,
    required this.accentColor,
    required this.defaultCapacityMl,
    required this.evolutionStages,
    required this.nativeHabitat,
  });

  String get species => scientificName;
  String get description => lore;
  int get primaryColorHex => accentColor.toARGB32();

  /// Mascot avatar emoji based on species
  String get avatarEmoji {
    switch (id) {
      case 'red_panda':
        return '🦊';
      case 'capybara':
        return '🦫';
      case 'axolotl':
        return '🦎';
      case 'sea_otter':
        return '🦦';
      case 'andean_llama':
        return '🦙';
      case 'arctic_fox':
        return '🐺';
      case 'emperor_penguin':
        return '🐧';
      case 'bottlenose_dolphin':
      case 'pink_river_dolphin':
        return '🐬';
      case 'blue_ringed_octopus':
      case 'bioluminescent_octopus':
        return '🐙';
      case 'snow_leopard':
        return '🐆';
      case 'golden_lion_tamarin':
        return '🐒';
      case 'reticulated_giraffe':
        return '🦒';
      default:
        return '🐾';
    }
  }

  /// Catalog of 10 handcrafted exotic animal companions
  static const List<ExoticAnimal> allAnimals = [
    ExoticAnimal(
      id: 'red_panda',
      name: 'Ruby the Red Panda',
      scientificName: 'Ailurus fulgens',
      lore: 'Playful cloud-forest guardian who lounges serenely in highland springs.',
      habitatBiomeId: 'bamboo_misty_springs',
      unlockXp: 0, // Default starter companion
      accentColor: Color(0xFFD84315),
      defaultCapacityMl: 2500,
      evolutionStages: AnimalEvolutionStage.defaultStages,
      nativeHabitat: 'Himalayan Temperate Cloud Forests',
    ),
    ExoticAnimal(
      id: 'capybara',
      name: 'Cappy the Capybara',
      scientificName: 'Hydrochoerus hydrochaeris',
      lore: 'The undisputed zen master of hot springs, radiating tranquility and balanced hydration.',
      habitatBiomeId: 'thermal_yuzu_onsen',
      unlockXp: 0, // Unlocked starter companion for onsen zen
      accentColor: Color(0xFF8D6E63),
      defaultCapacityMl: 2600,
      evolutionStages: AnimalEvolutionStage.defaultStages,
      nativeHabitat: 'South American Wetland Basins',
    ),
    ExoticAnimal(
      id: 'axolotl',
      name: 'Lottie the Axolotl',
      scientificName: 'Ambystoma mexicanum',
      lore: 'Mystic ancient water spirit whose feathery gills shimmer with bioluminescence.',
      habitatBiomeId: 'bioluminescent_cenote',
      unlockXp: 0, // Unlocked starter companion for bioluminescent magic
      accentColor: Color(0xFFF48FB1),
      defaultCapacityMl: 2400,
      evolutionStages: AnimalEvolutionStage.defaultStages,
      nativeHabitat: 'Lake Xochimilco Subsurface Canals',
    ),
    ExoticAnimal(
      id: 'sea_otter',
      name: 'Ollie the Sea Otter',
      scientificName: 'Enhydra lutris',
      lore: 'Ebullient kelp-dweller who floats on waves holding precious stones and refreshing drops.',
      habitatBiomeId: 'kelp_forest_lagoon',
      unlockXp: 1300,
      accentColor: Color(0xFF4DB6AC),
      defaultCapacityMl: 2500,
      evolutionStages: AnimalEvolutionStage.defaultStages,
      nativeHabitat: 'Pacific Coastal Giant Kelp Forests',
    ),
    ExoticAnimal(
      id: 'andean_llama',
      name: 'Luna the Andean Llama',
      scientificName: 'Lama glama',
      lore: 'Stoic high-altitude explorer thriving across mountain mists and glacial brooks.',
      habitatBiomeId: 'andean_cloud_oasis',
      unlockXp: 2000,
      accentColor: Color(0xFFFFB74D),
      defaultCapacityMl: 2800,
      evolutionStages: AnimalEvolutionStage.defaultStages,
      nativeHabitat: 'High Altiplano Andean Plateau',
    ),
    ExoticAnimal(
      id: 'arctic_fox',
      name: 'Freya the Arctic Fox',
      scientificName: 'Vulpes lagopus',
      lore: 'Fleet tundra runner with a snow-white coat reflecting aurora borealis ripples.',
      habitatBiomeId: 'aurora_glacier',
      unlockXp: 2800,
      accentColor: Color(0xFFE0F7FA),
      defaultCapacityMl: 2400,
      evolutionStages: AnimalEvolutionStage.defaultStages,
      nativeHabitat: 'Subpolar Tundra & Sea Ice',
    ),
    ExoticAnimal(
      id: 'emperor_penguin',
      name: 'Percy the Emperor Penguin',
      scientificName: 'Aptenodytes forsteri',
      lore: 'Noble deep-diver traversing frigid waters with hydrodynamic grace.',
      habitatBiomeId: 'aurora_glacier',
      unlockXp: 3700,
      accentColor: Color(0xFFFFD54F),
      defaultCapacityMl: 2600,
      evolutionStages: AnimalEvolutionStage.defaultStages,
      nativeHabitat: 'Antarctic Coastal Pack Ice',
    ),
    ExoticAnimal(
      id: 'bottlenose_dolphin',
      name: 'Echo the Dolphin',
      scientificName: 'Tursiops truncatus',
      lore: 'Joyous marine acrobat communicating through crystal-clear acoustic wave rings.',
      habitatBiomeId: 'kelp_forest_lagoon',
      unlockXp: 4800,
      accentColor: Color(0xFF4FC3F7),
      defaultCapacityMl: 2700,
      evolutionStages: AnimalEvolutionStage.defaultStages,
      nativeHabitat: 'Warm Pelagic Waters & Coral Lagoons',
    ),
    ExoticAnimal(
      id: 'blue_ringed_octopus',
      name: 'Octavia the Octopus',
      scientificName: 'Hapalochlaena lunulata',
      lore: 'Enigmatic deep-reef guardian pulsing with neon blue rings when hydrated.',
      habitatBiomeId: 'bioluminescent_cenote',
      unlockXp: 6000,
      accentColor: Color(0xFF00E5FF),
      defaultCapacityMl: 2500,
      evolutionStages: AnimalEvolutionStage.defaultStages,
      nativeHabitat: 'Indo-Pacific Tide Pools & Reefs',
    ),
    ExoticAnimal(
      id: 'snow_leopard',
      name: 'Kira the Snow Leopard',
      scientificName: 'Panthera uncia',
      lore: 'The Ghost of the Mountains sipping glacial meltwater atop crystalline peaks.',
      habitatBiomeId: 'aurora_glacier',
      unlockXp: 7500,
      accentColor: Color(0xFFB0BEC5),
      defaultCapacityMl: 3000,
      evolutionStages: AnimalEvolutionStage.defaultStages,
      nativeHabitat: 'Central Asian Rugged Glacial Crags',
    ),
  ];

  static ExoticAnimal findById(String id) {
    return allAnimals.firstWhere(
      (a) => a.id == id,
      orElse: () => allAnimals.first,
    );
  }
}
