import 'package:aquawild/src/core/services/audio_haptics_service.dart';
import 'package:aquawild/src/domain/models/exotic_animal.dart';
import 'package:aquawild/src/domain/models/hydration_biome.dart';
import 'package:aquawild/src/presentation/controllers/animal_habitat_controller.dart';
import 'package:aquawild/src/presentation/controllers/biome_controller.dart';
import 'package:aquawild/src/presentation/widgets/biomes/companion_avatar_renderer.dart';
import 'package:aquawild/src/presentation/widgets/biomes/companion_evolution_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Modal sheet to explore, switch, and evolve exotic animal companions and living biomes.
class BiomeCompanionSelectorSheet extends ConsumerWidget {
  const BiomeCompanionSelectorSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BiomeCompanionSelectorSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitat = ref.watch(animalHabitatProvider);
    final biome = ref.watch(biomeProvider);
    final activeAnimal = habitat.activeAnimal;
    final activeBiome = biome.activeBiome;

    return DefaultTabController(
      length: 2,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF0C192E).withValues(alpha: 0.98),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 20),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF162947),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const TabBar(
                indicatorColor: Color(0xFF00E5FF),
                labelColor: Color(0xFF00E5FF),
                unselectedLabelColor: Colors.white60,
                tabs: [
                  Tab(icon: Icon(Icons.pets_rounded, size: 18), text: 'Companions (10)'),
                  Tab(icon: Icon(Icons.terrain_rounded, size: 18), text: 'Living Biomes (6)'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab Views
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Animal Companions & Evolution Stages
                  _buildCompanionsTab(context, ref, habitat, activeAnimal),

                  // Tab 2: Living Biomes Gallery
                  _buildBiomesTab(context, ref, biome, activeBiome),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanionsTab(
    BuildContext context,
    WidgetRef ref,
    AnimalHabitatState habitat,
    ExoticAnimal activeAnimal,
  ) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        // Evolution Stage Banner for Active Companion
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => CompanionEvolutionModal.show(
            context,
            animal: activeAnimal,
            stage: habitat.currentStage,
            totalXp: habitat.userXp,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: activeAnimal.accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: activeAnimal.accentColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CompanionAvatarRenderer(
                  animal: activeAnimal,
                  stage: habitat.currentStage,
                  size: 64,
                  isSelected: true,
                  showAura: true,
                  showBadge: true,
                  animate: false,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Active: ${activeAnimal.name}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: activeAnimal.accentColor.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              habitat.currentStage.title,
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activeAnimal.lore,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: habitat.stageProgressFraction,
                        backgroundColor: Colors.white12,
                        color: activeAnimal.accentColor,
                        minHeight: 5,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${habitat.userXp} XP • ${habitat.xpUntilNextStage > 0 ? "${habitat.xpUntilNextStage} XP to next evolution" : "Max Stage Reached!"}',
                        style: const TextStyle(color: Colors.white60, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 10 Animal Companions Grid/List
        ...ExoticAnimal.allAnimals.map((animal) {
          final isSelected = animal.id == activeAnimal.id;
          final isUnlocked = habitat.userXp >= animal.unlockXp;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF162947)
                  : const Color(0xFF111F36).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? const Color(0xFF00E5FF) : Colors.white10,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: ListTile(
              leading: CompanionAvatarRenderer(
                animal: animal,
                stage: isSelected ? habitat.currentStage : animal.evolutionStages.first,
                size: 50,
                isUnlocked: isUnlocked,
                isSelected: isSelected,
                showAura: isSelected || isUnlocked,
                showBadge: true,
              ),
              title: Text(
                animal.name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Text(
                '${animal.scientificName} • ${animal.nativeHabitat}',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
              trailing: isSelected
                  ? const Chip(
                      label: Text('Active', style: TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold)),
                      backgroundColor: Color(0xFF00E5FF),
                    )
                  : (isUnlocked
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A5F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          ),
                          onPressed: () {
                            AudioHapticsService.playTap();
                            ref.read(animalHabitatProvider.notifier).selectAnimal(animal.id);
                            ref.read(biomeProvider.notifier).selectBiome(animal.habitatBiomeId);
                          },
                          child: const Text('Select', style: TextStyle(fontSize: 11)),
                        )
                      : Text(
                          '🔒 ${animal.unlockXp} XP',
                          style: const TextStyle(color: Colors.white38, fontSize: 11),
                        )),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBiomesTab(
    BuildContext context,
    WidgetRef ref,
    BiomeState biomeState,
    HydrationBiome activeBiome,
  ) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        ...HydrationBiome.allBiomes.map((b) {
          final isSelected = b.id == activeBiome.id;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF162947)
                  : const Color(0xFF111F36).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? const Color(0xFF00E5FF) : Colors.white10,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: b.skyGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              title: Text(
                b.name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Text(
                b.description,
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
              trailing: isSelected
                  ? const Chip(
                      label: Text('Current', style: TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold)),
                      backgroundColor: Color(0xFF00E5FF),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A5F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      onPressed: () {
                        AudioHapticsService.playTap();
                        ref.read(biomeProvider.notifier).selectBiome(b.id);
                      },
                      child: const Text('Travel', style: TextStyle(fontSize: 11)),
                    ),
            ),
          );
        }),
      ],
    );
  }
}
