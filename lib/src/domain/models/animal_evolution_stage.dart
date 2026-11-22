import 'package:flutter/material.dart';

/// Evolution progression stage for an exotic animal
class AnimalEvolutionStage {
  final int stageNumber; // 1 (Hatchling/Cub) to 4 (Mythic Spirit)
  final String title;
  final int requiredXp;
  final Color auraColor;
  final String auraEffectDescription;
  final String cosmeticPerk;

  const AnimalEvolutionStage({
    required this.stageNumber,
    required this.title,
    required this.requiredXp,
    required this.auraColor,
    required this.auraEffectDescription,
    required this.cosmeticPerk,
  });

  static const List<AnimalEvolutionStage> defaultStages = [
    AnimalEvolutionStage(
      stageNumber: 1,
      title: 'Hatchling',
      requiredXp: 0,
      auraColor: Color(0x3300E5FF),
      auraEffectDescription: 'Gentle morning dew particles',
      cosmeticPerk: 'Playful splash animations',
    ),
    AnimalEvolutionStage(
      stageNumber: 2,
      title: 'Explorer',
      requiredXp: 400,
      auraColor: Color(0x6600E5FF),
      auraEffectDescription: 'Bioluminescent droplet shimmer',
      cosmeticPerk: 'Aviator sunglasses & water trail',
    ),
    AnimalEvolutionStage(
      stageNumber: 3,
      title: 'Guardian',
      requiredXp: 1200,
      auraColor: Color(0x9900E5FF),
      auraEffectDescription: 'Iridescent caustic halo',
      cosmeticPerk: 'Floating tropical lotus float ring',
    ),
    AnimalEvolutionStage(
      stageNumber: 4,
      title: 'Mythic Spirit',
      requiredXp: 3000,
      auraColor: Color(0xCC00E5FF),
      auraEffectDescription: 'Cosmic celestial water aurora',
      cosmeticPerk: 'Starfall ripples & glowing crown',
    ),
  ];
}
