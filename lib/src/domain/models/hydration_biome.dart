import 'package:flutter/material.dart';

/// Hydration biomes representing living ecosystems that evolve as user tracks hydration
class HydrationBiome {
  final String id;
  final String name;
  final String subtitle;
  final String description;
  final Color ambientColor;
  final Color waterCausticColor;
  final List<Color> skyGradient;
  final String soundscapeName;
  final int unlockXp;
  final List<String> nativeAnimalIds;

  const HydrationBiome({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.ambientColor,
    required this.waterCausticColor,
    required this.skyGradient,
    required this.soundscapeName,
    required this.unlockXp,
    required this.nativeAnimalIds,
  });

  /// Catalog of 6 living hydration biomes
  static const List<HydrationBiome> allBiomes = [
    HydrationBiome(
      id: 'bamboo_misty_springs',
      name: 'Bamboo Misty Springs',
      subtitle: 'Tranquil Highland Valley',
      description: 'Morning mist filtering through tall emerald bamboo over mineral hot springs.',
      ambientColor: Color(0xFF2E7D32),
      waterCausticColor: Color(0xFF80E27E),
      skyGradient: [Color(0xFF004D40), Color(0xFF00796B)],
      soundscapeName: 'Zen Bamboo Waterwheel & Distant Flute',
      unlockXp: 0,
      nativeAnimalIds: ['red_panda'],
    ),
    HydrationBiome(
      id: 'thermal_yuzu_onsen',
      name: 'Thermal Yuzu Onsen',
      subtitle: 'Volcanic Cedar Baths',
      description: 'Steam rising from rustic cedar tubs infused with floating golden yuzu fruit.',
      ambientColor: Color(0xFFE65100),
      waterCausticColor: Color(0xFFFFCC80),
      skyGradient: [Color(0xFF3E2723), Color(0xFF5D4037)],
      soundscapeName: 'Warm Bubbling Spring & Cedar Wind Chimes',
      unlockXp: 300,
      nativeAnimalIds: ['capybara'],
    ),
    HydrationBiome(
      id: 'bioluminescent_cenote',
      name: 'Bioluminescent Cenote',
      subtitle: 'Subterranean Crystal Grotto',
      description: 'Sunken cavern with stalactites, glowing algae, and iridescent subterranean pools.',
      ambientColor: Color(0xFF00E5FF),
      waterCausticColor: Color(0xFF18FFFF),
      skyGradient: [Color(0xFF0B132B), Color(0xFF001E3D)],
      soundscapeName: 'Echoing Grotto Waterdrops & Ambient Chimes',
      unlockXp: 750,
      nativeAnimalIds: ['axolotl', 'blue_ringed_octopus'],
    ),
    HydrationBiome(
      id: 'kelp_forest_lagoon',
      name: 'Kelp Forest Lagoon',
      subtitle: 'Sunlit Coastal Sanctuary',
      description: 'Towering underwater kelp canopies swaying with gentle Pacific tidal currents.',
      ambientColor: Color(0xFF00897B),
      waterCausticColor: Color(0xFF80CBC4),
      skyGradient: [Color(0xFF00251A), Color(0xFF004D40)],
      soundscapeName: 'Rhythmic Ocean Swell & Underwater Bubbles',
      unlockXp: 1300,
      nativeAnimalIds: ['sea_otter', 'bottlenose_dolphin'],
    ),
    HydrationBiome(
      id: 'andean_cloud_oasis',
      name: 'Andean Cloud Oasis',
      subtitle: 'High-Altitude Mirador',
      description: 'Rolling clouds kissing alpine lagoons surrounded by lupines and quartz rocks.',
      ambientColor: Color(0xFFF57C00),
      waterCausticColor: Color(0xFFFFE082),
      skyGradient: [Color(0xFF263238), Color(0xFF37474F)],
      soundscapeName: 'Highland Breeze & Pan Flute Harmonics',
      unlockXp: 2000,
      nativeAnimalIds: ['andean_llama'],
    ),
    HydrationBiome(
      id: 'aurora_glacier',
      name: 'Aurora Glacier',
      subtitle: 'Crystalline Polar Fjords',
      description: 'Mirror-like polar ice shelves illuminated by celestial green and violet auroras.',
      ambientColor: Color(0xFF80DEEA),
      waterCausticColor: Color(0xFFE0F7FA),
      skyGradient: [Color(0xFF1A237E), Color(0xFF0D47A1)],
      soundscapeName: 'Singing Polar Ice & Gentle Aurora Shimmer',
      unlockXp: 2800,
      nativeAnimalIds: ['arctic_fox', 'emperor_penguin', 'snow_leopard'],
    ),
  ];

  static HydrationBiome findById(String id) {
    return allBiomes.firstWhere(
      (b) => b.id == id,
      orElse: () => allBiomes.first,
    );
  }
}
