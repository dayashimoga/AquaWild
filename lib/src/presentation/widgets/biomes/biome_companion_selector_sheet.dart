import 'dart:async';
import 'package:aquawild/src/core/services/audio_haptics_service.dart';
import 'package:aquawild/src/domain/models/exotic_animal.dart';
import 'package:aquawild/src/domain/models/hydration_biome.dart';
import 'package:aquawild/src/domain/models/monetization_models.dart';
import 'package:aquawild/src/presentation/controllers/animal_habitat_controller.dart';
import 'package:aquawild/src/presentation/controllers/biome_controller.dart';
import 'package:aquawild/src/presentation/controllers/monetization_controller.dart';
import 'package:aquawild/src/presentation/widgets/biomes/companion_avatar_renderer.dart';
import 'package:aquawild/src/presentation/widgets/biomes/companion_evolution_modal.dart';
import 'package:aquawild/src/presentation/widgets/monetization/premium_storefront_modal.dart';
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
    final monetization = ref.watch(monetizationProvider);
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
                  _buildCompanionsTab(context, ref, habitat, activeAnimal, monetization),

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
    MonetizationState monetization,
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

        // AquaWild Pro Promotional Banner
        if (!monetization.isPro) ...[
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              unawaited(AudioHapticsService.playTap());
              PremiumStorefrontModal.show(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B2C4B), Color(0xFF2E1B4B)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.6)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.workspace_premium_rounded, color: Colors.amberAccent, size: 22),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Unlock All 10 Companions with Pro',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text(
                          'Instant sanctuary access, all biomes & premium themes',
                          style: TextStyle(color: Colors.white60, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'UPGRADE',
                      style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],

        // 10 Animal Companions Grid/List
        ...ExoticAnimal.allAnimals.map((animal) {
          final isSelected = animal.id == activeAnimal.id;
          final isUnlocked = monetization.isAnimalUnlocked(animal.id, habitat.userXp);

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
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              child: ListTile(
              onTap: isUnlocked
                  ? () {
                      unawaited(AudioHapticsService.playTap());
                      ref.read(animalHabitatProvider.notifier).selectAnimal(animal.id);
                      ref.read(biomeProvider.notifier).selectBiome(animal.habitatBiomeId);
                    }
                  : () => _showCompanionUnlockDialog(
                        context,
                        ref,
                        animal,
                        habitat.userXp,
                        monetization,
                      ),
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
                            unawaited(AudioHapticsService.playTap());
                            ref.read(animalHabitatProvider.notifier).selectAnimal(animal.id);
                            ref.read(biomeProvider.notifier).selectBiome(animal.habitatBiomeId);
                          },
                          child: const Text('Select', style: TextStyle(fontSize: 11)),
                        )
                      : OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0x66FFD700)),
                            foregroundColor: Colors.amberAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                          onPressed: () => _showCompanionUnlockDialog(
                            context,
                            ref,
                            animal,
                            habitat.userXp,
                            monetization,
                          ),
                          child: Text(
                            '🔒 ${animal.unlockXp} XP',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        )),
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showCompanionUnlockDialog(
    BuildContext context,
    WidgetRef ref,
    ExoticAnimal animal,
    int userXp,
    MonetizationState monetization,
  ) {
    final remainingXp = (animal.unlockXp - userXp).clamp(0, animal.unlockXp);
    final progress = (userXp / animal.unlockXp).clamp(0.0, 1.0);

    // Find if there is an IAP pack that unlocks this animal
    ProductSKU? matchingPack;
    try {
      matchingPack = monetization.availableProducts.firstWhere(
        (p) => p.unlockedAnimalIds.contains(animal.id),
      );
    } catch (_) {
      matchingPack = null;
    }

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0C192E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: animal.accentColor.withValues(alpha: 0.5)),
          ),
          title: Row(
            children: [
              CompanionAvatarRenderer(
                animal: animal,
                stage: animal.evolutionStages.first,
                size: 44,
                isUnlocked: false,
                showBadge: false,
                animate: false,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      animal.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${animal.scientificName} • ${animal.nativeHabitat}',
                      style: const TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                animal.lore,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 16),

              // Path A: Earn via Hydration
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF14243C),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.water_drop_outlined, color: Color(0xFF00E5FF), size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Path A: Earn with Hydration',
                          style: TextStyle(
                            color: Color(0xFF00E5FF),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white12,
                      color: const Color(0xFF00E5FF),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$userXp / ${animal.unlockXp} XP ($remainingXp XP remaining)',
                      style: const TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Path B: Instant Unlock
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1F3B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x669D4EDD)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.workspace_premium_rounded, color: Colors.amberAccent, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Path B: Instant Unlock',
                          style: TextStyle(
                            color: Colors.amberAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Access immediately with AquaWild Pro, or unlock via an expedition pack.',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
            ),
            if (matchingPack != null)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A5F),
                  foregroundColor: const Color(0xFF00E5FF),
                ),
                onPressed: () async {
                  Navigator.of(dialogCtx).pop();
                  unawaited(AudioHapticsService.playTap());
                  await ref
                      .read(monetizationProvider.notifier)
                      .purchaseProduct(matchingPack!.id);
                },
                child: Text('Get ${matchingPack.title}', style: const TextStyle(fontSize: 11)),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                PremiumStorefrontModal.show(context);
              },
              child: const Text('Open Store', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
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
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(18),
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
            ),
          );
        }),
      ],
    );
  }
}
