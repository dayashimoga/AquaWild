import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/beverage_type.dart';
import '../../../domain/models/hydration_biome.dart';
import '../../../domain/models/hydration_entry.dart';
import '../../controllers/ai_coach_controller.dart';
import '../../controllers/animal_habitat_controller.dart';
import '../../controllers/biome_controller.dart';
import '../../controllers/hydration_controller.dart';
import '../../widgets/ai/ai_coach_sheet.dart';
import '../../widgets/analytics/predictive_analytics_sheet.dart';
import '../../widgets/animal_fluid/animal_fluid_habitat_view.dart';
import '../../widgets/backup/data_backup_modal.dart';
import '../../widgets/beverages/beverage_customizer_modal.dart';
import '../../widgets/biomes/biome_companion_selector_sheet.dart';
import '../../widgets/biomes/companion_evolution_modal.dart';
import '../../widgets/environmental/weather_activity_bar.dart';
import '../../widgets/gamification/achievements_gallery_sheet.dart';
import '../../widgets/gamification/streak_badge_chip.dart';
import '../../widgets/monetization/premium_storefront_modal.dart';
import '../../widgets/reminders/smart_reminders_sheet.dart';
import '../../widgets/shortcuts/keyboard_shortcuts_modal.dart';
import '../../widgets/sync/sync_status_indicator.dart';
import '../../widgets/theme/theme_switcher_button.dart';
import '../../widgets/voice/voice_command_modal.dart';
import '../../widgets/widgets_preview/widget_preview_studio_modal.dart';

/// Responsive cross-platform layout shell adapting across Compact (Phone),
/// Medium (Tablet/Foldable), and Expanded (Desktop/Web/4K) screen breakpoints.
class ResponsiveHomeShell extends ConsumerWidget {
  const ResponsiveHomeShell({super.key});

  static const double compactBreakpoint = 700.0;
  static const double expandedBreakpoint = 1100.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biomeState = ref.watch(biomeProvider);
    final activeBiome = biomeState.activeBiome;
    final isReducedMotion = MediaQuery.disableAnimationsOf(context);

    return AnimatedContainer(
      duration: isReducedMotion
          ? Duration.zero
          : const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
      decoration: _buildBiomeBackgroundDecoration(activeBiome, context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          if (width >= expandedBreakpoint) {
            return _buildExpandedDesktopLayout(context, ref);
          } else if (width >= compactBreakpoint) {
            return _buildMediumTabletLayout(context, ref);
          } else {
            return _buildCompactMobileLayout(context, ref);
          }
        },
      ),
    );
  }

  // =========================================================================
  // 1. COMPACT (MOBILE) LAYOUT (< 700px)
  // =========================================================================
  Widget _buildCompactMobileLayout(BuildContext context, WidgetRef ref) {
    final habitatState = ref.watch(animalHabitatProvider);
    final biomeState = ref.watch(biomeProvider);
    final activeAnimal = habitatState.activeAnimal;
    final activeBiome = biomeState.activeBiome;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.pets_rounded),
          tooltip: 'Companions & Biomes',
          onPressed: () => BiomeCompanionSelectorSheet.show(context),
        ),
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
          const StreakBadgeChip(),
          const ThemeSwitcherButton(),
          IconButton(
            icon: const Icon(Icons.workspace_premium_rounded, color: Colors.amberAccent),
            tooltip: 'AquaWild Pro Store',
            onPressed: () => PremiumStorefrontModal.show(context),
          ),
          PopupMenuButton<String>(
            tooltip: 'More Options',
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (val) {
              switch (val) {
                case 'widgets':
                  WidgetPreviewStudioModal.show(context);
                  break;
                case 'backup':
                  DataBackupModal.show(context);
                  break;
                case 'analytics':
                  PredictiveAnalyticsSheet.show(context);
                  break;
                case 'shortcuts':
                  KeyboardShortcutsModal.show(context);
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'widgets',
                child: Row(
                  children: [
                    Icon(Icons.widgets_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Widget Studio'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'analytics',
                child: Row(
                  children: [
                    Icon(Icons.bar_chart_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Predictive Analytics'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'backup',
                child: Row(
                  children: [
                    Icon(Icons.backup_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Backup & Export'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'shortcuts',
                child: Row(
                  children: [
                    Icon(Icons.keyboard_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Keyboard Shortcuts'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Voice Command Logger',
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.black,
        onPressed: () => VoiceCommandModal.show(context),
        child: const Icon(Icons.mic),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildNetHydrationCard(context, ref),
              const SizedBox(height: 12),
              const WeatherActivityBar(),
              const SizedBox(height: 12),
              const AnimalFluidHabitatView(),
              const SizedBox(height: 18),
              _buildQuickLogDock(context, ref),
              const SizedBox(height: 18),
              _buildCompanionEvolutionCard(context, ref),
              const SizedBox(height: 16),
              _buildTodayEntriesList(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 2. MEDIUM (TABLET / SPLIT) LAYOUT (700px - 1100px)
  // =========================================================================
  Widget _buildMediumTabletLayout(BuildContext context, WidgetRef ref) {
    final habitatState = ref.watch(animalHabitatProvider);
    final biomeState = ref.watch(biomeProvider);
    final activeAnimal = habitatState.activeAnimal;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Row(
          children: [
            // Tablet Navigation Rail
            NavigationRail(
              backgroundColor: Colors.transparent,
              selectedIndex: 0,
              labelType: NavigationRailLabelType.selected,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: CircleAvatar(
                  backgroundColor:
                      activeAnimal.accentColor.withValues(alpha: 0.2),
                  child:
                      Icon(Icons.water_drop, color: activeAnimal.accentColor),
                ),
              ),
              trailing: Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const ThemeSwitcherButton(),
                    IconButton(
                      icon: const Icon(Icons.workspace_premium_rounded, color: Colors.amberAccent),
                      tooltip: 'AquaWild Pro Store',
                      onPressed: () => PremiumStorefrontModal.show(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.widgets_outlined),
                      tooltip: 'Widget Studio',
                      onPressed: () => WidgetPreviewStudioModal.show(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.keyboard_outlined),
                      tooltip: 'Shortcuts Guide',
                      onPressed: () => KeyboardShortcutsModal.show(context),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_rounded),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Habitat'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.pets_rounded),
                  label: Text('Biomes'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.psychology_rounded),
                  label: Text('AI Coach'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.alarm_rounded),
                  label: Text('Reminders'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.bar_chart_rounded),
                  label: Text('Analytics'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.military_tech_rounded),
                  label: Text('Badges'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.mic_rounded),
                  label: Text('Voice'),
                ),
              ],
              onDestinationSelected: (index) {
                switch (index) {
                  case 1:
                    BiomeCompanionSelectorSheet.show(context);
                    break;
                  case 2:
                    AiCoachSheet.show(context);
                    break;
                  case 3:
                    SmartRemindersSheet.show(context);
                    break;
                  case 4:
                    PredictiveAnalyticsSheet.show(context);
                    break;
                  case 5:
                    AchievementsGallerySheet.show(context);
                    break;
                  case 6:
                    VoiceCommandModal.show(context);
                    break;
                }
              },
            ),
            const VerticalDivider(width: 1, thickness: 1),

            // Two-Column Tablet Workspace
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Tablet Column: Fluid Vessel & Quick Logging
                  Expanded(
                    flex: 6,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activeAnimal.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${biomeState.activeBiome.name} • ${habitatState.currentStage.title}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: activeAnimal.accentColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const StreakBadgeChip(),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildNetHydrationCard(context, ref),
                          const SizedBox(height: 16),
                          const AnimalFluidHabitatView(),
                          const SizedBox(height: 16),
                          _buildQuickLogDock(context, ref),
                        ],
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1, thickness: 1),

                  // Right Tablet Column: Weather, AI, Evolution, Logs
                  Expanded(
                    flex: 5,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const WeatherActivityBar(),
                          const SizedBox(height: 14),
                          _buildAiCoachCard(context, ref),
                          const SizedBox(height: 14),
                          _buildCompanionEvolutionCard(context, ref),
                          const SizedBox(height: 14),
                          _buildTodayEntriesList(context, ref),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 3. EXPANDED (DESKTOP / WEB) COMMAND CENTER LAYOUT (>= 1100px)
  // =========================================================================
  Widget _buildExpandedDesktopLayout(BuildContext context, WidgetRef ref) {
    final habitatState = ref.watch(animalHabitatProvider);
    final biomeState = ref.watch(biomeProvider);
    final activeAnimal = habitatState.activeAnimal;
    final activeBiome = biomeState.activeBiome;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Row(
          children: [
            // Left Command Deck (260px)
            SizedBox(
              width: 260,
              child: Container(
                color: Theme.of(context).cardColor.withValues(alpha: 0.3),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand Title
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor:
                              AppColors.cyanPrimary.withValues(alpha: 0.2),
                          child: const Icon(
                            Icons.water_drop,
                            color: AppColors.cyanPrimary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'AquaWild',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Active Companion Pill
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cardGlassDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: activeAnimal.accentColor.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor:
                                activeAnimal.accentColor.withValues(alpha: 0.2),
                            child: Icon(
                              Icons.pets,
                              color: activeAnimal.accentColor,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activeAnimal.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${activeBiome.name} • Stage ${habitatState.currentStage.stageNumber}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: activeAnimal.accentColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick Navigation List
                    Expanded(
                      child: ListView(
                        children: [
                          _buildDesktopNavTile(
                            icon: Icons.pets_rounded,
                            title: 'Biomes & Companions',
                            shortcut: 'B',
                            onTap: () =>
                                BiomeCompanionSelectorSheet.show(context),
                          ),
                          _buildDesktopNavTile(
                            icon: Icons.psychology_rounded,
                            title: 'AI Hydration Coach',
                            shortcut: 'A',
                            onTap: () => AiCoachSheet.show(context),
                          ),
                          _buildDesktopNavTile(
                            icon: Icons.alarm_rounded,
                            title: 'Smart Reminders',
                            shortcut: 'R',
                            onTap: () => SmartRemindersSheet.show(context),
                          ),
                          _buildDesktopNavTile(
                            icon: Icons.bar_chart_rounded,
                            title: 'Predictive Analytics',
                            shortcut: 'P',
                            onTap: () =>
                                PredictiveAnalyticsSheet.show(context),
                          ),
                          _buildDesktopNavTile(
                            icon: Icons.military_tech_rounded,
                            title: 'Achievements & XP',
                            shortcut: 'G',
                            onTap: () =>
                                AchievementsGallerySheet.show(context),
                          ),
                          _buildDesktopNavTile(
                            icon: Icons.mic_rounded,
                            title: 'Voice Logger',
                            shortcut: 'V',
                            onTap: () => VoiceCommandModal.show(context),
                          ),
                          _buildDesktopNavTile(
                            icon: Icons.workspace_premium_rounded,
                            title: 'AquaWild Store',
                            shortcut: 'S',
                            onTap: () => PremiumStorefrontModal.show(context),
                          ),
                          _buildDesktopNavTile(
                            icon: Icons.widgets_outlined,
                            title: 'Widget Studio',
                            shortcut: 'W',
                            onTap: () => WidgetPreviewStudioModal.show(context),
                          ),
                          _buildDesktopNavTile(
                            icon: Icons.backup_outlined,
                            title: 'Backup & Export',
                            shortcut: 'X',
                            onTap: () => DataBackupModal.show(context),
                          ),
                          _buildDesktopNavTile(
                            icon: Icons.keyboard_outlined,
                            title: 'Keyboard Shortcuts',
                            shortcut: '?',
                            onTap: () =>
                                KeyboardShortcutsModal.show(context),
                          ),
                        ],
                      ),
                    ),

                    // Footer with Theme Switcher & Cloud Sync
                    const Divider(),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SyncStatusIndicator(),
                        ThemeSwitcherButton(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const VerticalDivider(width: 1, thickness: 1),

            // Center Interaction Deck (Flex: 6)
            Expanded(
              flex: 6,
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildNetHydrationCard(context, ref),
                    const SizedBox(height: 20),
                    const AnimalFluidHabitatView(),
                    const SizedBox(height: 24),
                    _buildQuickLogDock(context, ref),
                  ],
                ),
              ),
            ),
            const VerticalDivider(width: 1, thickness: 1),

            // Right Telemetry Deck (380px)
            SizedBox(
              width: 380,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const WeatherActivityBar(),
                    const SizedBox(height: 16),
                    _buildAiCoachCard(context, ref),
                    const SizedBox(height: 16),
                    _buildCompanionEvolutionCard(context, ref),
                    const SizedBox(height: 16),
                    _buildTodayEntriesList(context, ref),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // REUSABLE SUB-COMPONENTS
  // =========================================================================

  /// Generates a fluid ambient atmospheric background gradient derived from the
  /// active biome's sky gradient and ambient colors, alpha-blended with the theme.
  BoxDecoration _buildBiomeBackgroundDecoration(
    HydrationBiome biome,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final topColor = biome.skyGradient.isNotEmpty
        ? biome.skyGradient.first.withValues(alpha: isDark ? 0.35 : 0.12)
        : biome.ambientColor.withValues(alpha: isDark ? 0.25 : 0.08);
    final midColor = biome.skyGradient.length > 1
        ? biome.skyGradient[1].withValues(alpha: isDark ? 0.20 : 0.06)
        : biome.ambientColor.withValues(alpha: isDark ? 0.15 : 0.04);
    final baseColor = theme.scaffoldBackgroundColor;

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.alphaBlend(topColor, baseColor),
          Color.alphaBlend(midColor, baseColor),
          baseColor,
        ],
        stops: const [0.0, 0.45, 1.0],
      ),
    );
  }

  Widget _buildDesktopNavTile({
    required IconData icon,
    required String title,
    required String shortcut,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      leading: Icon(icon, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 13)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          shortcut,
          style: const TextStyle(
            fontSize: 10,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildNetHydrationCard(BuildContext context, WidgetRef ref) {
    final hydrationState = ref.watch(hydrationProvider);
    final habitatState = ref.watch(animalHabitatProvider);
    final goal = hydrationState.goal;
    final activeAnimal = habitatState.activeAnimal;
    final progressPct = goal.progressPercent;
    final netMl = goal.netHydrationMl.toStringAsFixed(0);
    final targetMl = goal.effectiveGoalMl;

    return Semantics(
      label:
          '${activeAnimal.name} hydration status: $netMl of $targetMl milliliters, $progressPct percent complete',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          'Net Hydration Today',
                          style: TextStyle(color: Colors.white70),
                        ),
                        SyncStatusIndicator(),
                      ],
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
              ),
              const SizedBox(width: 8),
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
    );
  }

  Widget _buildQuickLogDock(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Quick Log Beverage',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 20),
              tooltip: 'Craft Custom Beverage',
              onPressed: () => BeverageCustomizerModal.show(context),
            ),
            Text(
              'Keys [1-9]',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.primary,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: BeverageType.allBeverages.length + 1,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index == BeverageType.allBeverages.length) {
                return InkWell(
                  onTap: () => BeverageCustomizerModal.show(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 90,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.cardGlassDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white24,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white12,
                          child: Icon(
                            Icons.add_rounded,
                            size: 18,
                            color: AppColors.cyanPrimary,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Custom',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Craft Drink',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final bev = BeverageType.allBeverages[index];
              final hasShortcut = index < 9;

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
                  child: Stack(
                    children: [
                      if (hasShortcut)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontSize: 9,
                                fontFamily: 'monospace',
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor:
                                bev.primaryColor.withValues(alpha: 0.2),
                            child: Icon(
                              Icons.local_drink_rounded,
                              size: 16,
                              color: bev.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            bev.name.split(' ').first,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '+${bev.presetVolumesMl.first}ml',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              color: bev.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAiCoachCard(BuildContext context, WidgetRef ref) {
    final aiState = ref.watch(aiCoachProvider);
    final recommendation = aiState.recommendation;
    final message = recommendation?.companionMessage ??
        'Staying hydrated throughout the day boosts cognitive clarity and vital metabolism.';
    final suggestedBeverage =
        recommendation?.suggestedBeverage ?? BeverageType.pureWater;
    final suggestedVolume = recommendation?.suggestedVolumeMl ?? 250.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.psychology,
                  color: AppColors.cyanPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'AI Hydration Coach',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.open_in_new, size: 16),
                  tooltip: 'Open AI Coach Dialogue',
                  onPressed: () => AiCoachSheet.show(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(hydrationProvider.notifier).logDrink(
                      beverage: suggestedBeverage,
                      volumeMl: suggestedVolume,
                    );
                ref.read(animalHabitatProvider.notifier).addXp(
                      (suggestedVolume / 10).round(),
                    );
              },
              icon: const Icon(Icons.water_drop, size: 16),
              label: Text(
                'Log ${suggestedVolume.toStringAsFixed(0)}ml ${suggestedBeverage.name}',
                style: const TextStyle(fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: suggestedBeverage.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanionEvolutionCard(BuildContext context, WidgetRef ref) {
    final habitatState = ref.watch(animalHabitatProvider);
    final activeAnimal = habitatState.activeAnimal;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => CompanionEvolutionModal.show(
          context,
          animal: activeAnimal,
          stage: habitatState.currentStage,
          totalXp: habitatState.userXp,
        ),
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
                  Expanded(
                    child: Text(
                      'Evolution Stage: ${habitatState.currentStage.title}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: activeAnimal.accentColor,
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
                '${habitatState.xpUntilNextStage} XP needed for next stage • Tap to view perks',
                style: const TextStyle(fontSize: 11, color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayEntriesList(BuildContext context, WidgetRef ref) {
    final hydrationState = ref.watch(hydrationProvider);

    if (hydrationState.entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Today\'s Entries (${hydrationState.entries.length})',
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
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
                child:
                    Icon(Icons.water_drop, color: bev.primaryColor, size: 18),
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
    );
  }
}
