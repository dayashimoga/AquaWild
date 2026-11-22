import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/beverage_type.dart';
import '../../../domain/models/fluid_layer.dart';
import '../../../domain/models/hydration_entry.dart';
import '../../controllers/animal_habitat_controller.dart';
import '../../controllers/biome_controller.dart';
import '../../controllers/hydration_controller.dart';

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
              // Main Interactive Progress & Animal Habitat Card
              Semantics(
                label:
                    '${activeAnimal.name} hydration status: $netMl of $targetMl milliliters, $progressPct percent complete',
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Net Hydration',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$netMl / $targetMl ml',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.cyanPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 64,
                                  height: 64,
                                  child: CircularProgressIndicator(
                                    value: goal.progressFraction,
                                    strokeWidth: 6,
                                    backgroundColor: AppColors.oceanDeep,
                                    color: AppColors.cyanPrimary,
                                  ),
                                ),
                                Text(
                                  '$progressPct%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Stratified fluid layer summary bar
                        if (hydrationState.stratifiedLayers.isNotEmpty) ...[
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Fluid Stratification (Density Layered):',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white60,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              height: 16,
                              child: Row(
                                children: hydrationState.stratifiedLayers.map((FluidLayer layer) {
                                  return Expanded(
                                    flex: (layer.volumeMl * 10).round().clamp(1, 10000),
                                    child: Container(
                                      color: layer.beverage.primaryColor,
                                      margin: const EdgeInsets.symmetric(horizontal: 0.5),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ] else ...[
                          const Text(
                            'Companion vessel is empty. Log your first drink below!',
                            style: TextStyle(fontSize: 13, color: Colors.white38),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Quick Log Beverage Dock
              const Text(
                'Quick Log Beverage',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
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
                        // Also sync XP to animal habitat
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
                              radius: 18,
                              backgroundColor: bev.primaryColor.withValues(alpha: 0.2),
                              child: Icon(
                                Icons.local_drink_rounded,
                                size: 20,
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
              const SizedBox(height: 24),

              // Companion Evolution & Habitat Preview
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
