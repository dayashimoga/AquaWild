import 'package:aquawild/src/core/theme/app_colors.dart';
import 'package:aquawild/src/domain/models/beverage_type.dart';
import 'package:aquawild/src/domain/models/hydration_entry.dart';
import 'package:aquawild/src/presentation/controllers/animal_habitat_controller.dart';
import 'package:aquawild/src/presentation/controllers/biome_controller.dart';
import 'package:aquawild/src/presentation/controllers/hydration_controller.dart';
import 'package:aquawild/src/presentation/widgets/animal_fluid/animal_fluid_habitat_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Main Hydration & Exotic Animal Habitat Dashboard
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hydrationState = ref.watch(hydrationProvider);
    final habitatState = ref.watch(animalHabitatProvider);
    final biomeState = ref.watch(biomeProvider);
    final goal = hydrationState.goal;
    final activeAnimal = habitatState.activeAnimal;
    final activeBiome = biomeState.activeBiome;

    final progressPct = goal.progressPercent;
    final netMl = goal.netHydrationMl.toStringAsFixed(0);
    final targetMl = goal.effectiveGoalMl;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              activeAnimal.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${activeBiome.name} • ${habitatState.currentStage.title}',
              style: TextStyle(
                fontSize: 12,
                color: activeAnimal.accentColor,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Chip(
                avatar: const Icon(Icons.bolt, size: 16, color: Colors.amber),
                label: Text('${habitatState.userXp} XP'),
                backgroundColor: AppColors.cardGlassDark,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main Interactive Progress Card
              Semantics(
                label:
                    '${activeAnimal.name} hydration status: $netMl of $targetMl milliliters, $progressPct percent complete',
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Net Hydration Today',
                              style: TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$netMl / $targetMl ml',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.cyanPrimary,
                              ),
                            ),
                            Text(
                              '${goal.remainingMl.toStringAsFixed(0)} ml remaining',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(
                                value: goal.progressFraction,
                                strokeWidth: 5.5,
                                backgroundColor: AppColors.oceanDeep,
                                color: AppColors.cyanPrimary,
                              ),
                            ),
                            Text(
                              '$progressPct%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Hero Feature: Animated Exotic Animal Fluid Habitat Vessel
              const AnimalFluidHabitatView(),
              const SizedBox(height: 20),

              // Quick Log Beverage Dock
              const Text(
                'Quick Log Beverage',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 104,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: BeverageType.allBeverages.length,
                  separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 12),
                  itemBuilder: (BuildContext context, int index) {
                    final bev = BeverageType.allBeverages[index];
                    return InkWell(
                      onTap: () {
                        final defaultVol = bev.presetVolumesMl.first.toDouble();
                        ref.read(hydrationProvider.notifier).logDrink(
                              beverage: bev,
                              volumeMl: defaultVol,
                            );
                        ref.read(animalHabitatProvider.notifier).addXp(
                              (defaultVol / 10).round(),
                            );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 90,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.cardGlassDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: bev.primaryColor.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 17,
                              backgroundColor: bev.primaryColor.withValues(alpha: 0.2),
                              child: Icon(
                                Icons.local_drink_rounded,
                                size: 18,
                                color: bev.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              bev.name.split(' ').first,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '+${bev.presetVolumesMl.first}ml',
                              style: TextStyle(
                                fontSize: 10,
                                color: bev.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Companion Evolution & Habitat Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.pets,
                            color: activeAnimal.accentColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Evolution Stage: ${habitatState.currentStage.title}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        habitatState.currentStage.cosmeticPerk,
                        style: const TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: habitatState.stageProgressFraction,
                        backgroundColor: AppColors.oceanDeep,
                        color: activeAnimal.accentColor,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${habitatState.xpUntilNextStage} XP needed for next stage',
                        style: const TextStyle(fontSize: 11, color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              // Recent logs count & clear action
              if (hydrationState.entries.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Today\'s Entries (${hydrationState.entries.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(hydrationRepositoryProvider).clearTodayEntries();
                        ref.read(hydrationProvider.notifier).loadToday();
                      },
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: hydrationState.entries.length,
                  itemBuilder: (BuildContext context, int index) {
                    final HydrationEntry entry = hydrationState.entries[index];
                    final bev = entry.beverage;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: bev.primaryColor.withValues(alpha: 0.2),
                        child: Icon(Icons.water_drop, color: bev.primaryColor, size: 18),
                      ),
                      title: Text(bev.name),
                      subtitle: Text(
                        '${entry.volumeMl.toStringAsFixed(0)}ml • Net: ${entry.netHydrationMl.toStringAsFixed(0)}ml',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: () {
                          ref.read(hydrationProvider.notifier).removeEntry(entry.id);
                        },
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
