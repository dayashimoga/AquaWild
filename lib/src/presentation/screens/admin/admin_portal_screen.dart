import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/admin_broadcast_models.dart';
import '../../../domain/models/admin_portal_models.dart';
import '../../../domain/models/beverage_type.dart';
import '../../controllers/admin_portal_controller.dart';
import '../../controllers/animal_habitat_controller.dart';
import '../../controllers/hydration_controller.dart';

/// Navigation tabs available within the Admin Portal.
enum AdminPortalTab {
  overview('KPI Overview', Icons.insights_rounded),
  godMode('God Mode', Icons.bolt_rounded),
  users('User Directory', Icons.people_alt_rounded),
  catalog('Content Catalog', Icons.inventory_2_rounded),
  flags('Feature Flags', Icons.flag_rounded),
  environment('Environment', Icons.dns_rounded),
  auditTrail('Audit Trail', Icons.verified_user_rounded),
  broadcasts('Broadcasts', Icons.campaign_rounded);

  final String label;
  final IconData icon;
  const AdminPortalTab(this.label, this.icon);
}

/// Production-ready Hydro-Glass Multi-Module Admin Portal Screen.
///
/// Supports responsive 6-platform layouts (sidebar rail on desktop/tablet,
/// horizontal pill deck on mobile), complete live controls for all 7 modules,
/// tamper-evident audit verification, and direct state mutation.
class AdminPortalScreen extends ConsumerStatefulWidget {
  const AdminPortalScreen({super.key});

  /// Presents the Admin Portal as a modal dialog or full-screen sheet.
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const Dialog.fullscreen(
        child: AdminPortalScreen(),
      ),
    );
  }

  @override
  ConsumerState<AdminPortalScreen> createState() => _AdminPortalScreenState();
}

class _AdminPortalScreenState extends ConsumerState<AdminPortalScreen> {
  AdminPortalTab _activeTab = AdminPortalTab.overview;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleExit(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminPortalProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
          tooltip: 'Exit Admin Portal',
          onPressed: () => _handleExit(context),
        ),
        titleSpacing: isDesktop ? NavigationToolbar.kMiddleSpacing : 8,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.cyanAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.4)),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                isDesktop ? 'AquaWild Mission Control' : 'Mission Control',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Environment Indicator Chip
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getEnvColor(adminState.environmentConfig.environment)
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getEnvColor(adminState.environmentConfig.environment),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: _getEnvColor(adminState.environmentConfig.environment),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    adminState.environmentConfig.environment.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _getEnvColor(adminState.environmentConfig.environment),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // God Mode Active Indicator
          if (adminState.godMode.isGodModeEnabled)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amberAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amberAccent),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, size: 14, color: Colors.amberAccent),
                    SizedBox(width: 4),
                    Text(
                      'GOD MODE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.amberAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(width: 8),

          // Reset to Defaults Button
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded, color: Colors.white70),
            tooltip: 'Reset Admin Data to Defaults',
            onPressed: () => _confirmResetToDefaults(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Status & Error Snack Banners
            if (adminState.statusMessage != null)
              _buildMessageBanner(
                message: adminState.statusMessage!,
                isError: false,
                onDismiss: () =>
                    ref.read(adminPortalProvider.notifier).clearMessages(),
              ),
            if (adminState.errorMessage != null)
              _buildMessageBanner(
                message: adminState.errorMessage!,
                isError: true,
                onDismiss: () =>
                    ref.read(adminPortalProvider.notifier).clearMessages(),
              ),

            // Main Content Area (Responsive Split)
            Expanded(
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildDesktopSidebar(),
                        const VerticalDivider(width: 1, color: Color(0xFF1F2937)),
                        Expanded(child: _buildActiveModuleView(adminState)),
                      ],
                    )
                  : Column(
                      children: [
                        _buildMobileTabBar(),
                        const Divider(height: 1, color: Color(0xFF1F2937)),
                        Expanded(child: _buildActiveModuleView(adminState)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getEnvColor(AppEnvironment env) {
    switch (env) {
      case AppEnvironment.production:
        return Colors.greenAccent;
      case AppEnvironment.staging:
        return Colors.amberAccent;
      case AppEnvironment.development:
        return Colors.cyanAccent;
    }
  }

  Widget _buildMessageBanner({
    required String message,
    required bool isError,
    required VoidCallback onDismiss,
  }) {
    final bg = isError ? Colors.redAccent : Colors.tealAccent;
    final fg = isError ? Colors.white : Colors.black87;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: bg.withValues(alpha: 0.9),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: fg,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: fg, size: 18),
            onPressed: onDismiss,
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSidebar() {
    return Container(
      width: 240,
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView(
        children: AdminPortalTab.values.map((tab) {
          final isSelected = _activeTab == tab;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Material(
              color: isSelected
                  ? Colors.cyanAccent.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              child: ListTile(
                leading: Icon(
                  tab.icon,
                  color: isSelected ? Colors.cyanAccent : Colors.white60,
                  size: 20,
                ),
                title: Text(
                  tab.label,
                  style: TextStyle(
                    color: isSelected ? Colors.cyanAccent : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: isSelected
                      ? BorderSide(color: Colors.cyanAccent.withValues(alpha: 0.3))
                      : BorderSide.none,
                ),
                dense: true,
                onTap: () => setState(() => _activeTab = tab),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileTabBar() {
    return Container(
      color: const Color(0xFF0F172A),
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        children: AdminPortalTab.values.map((tab) {
          final isSelected = _activeTab == tab;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              avatar: Icon(
                tab.icon,
                size: 16,
                color: isSelected ? Colors.black87 : Colors.white70,
              ),
              label: Text(tab.label),
              selected: isSelected,
              selectedColor: Colors.cyanAccent,
              backgroundColor: const Color(0xFF1E293B),
              labelStyle: TextStyle(
                color: isSelected ? Colors.black87 : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              onSelected: (_) => setState(() => _activeTab = tab),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActiveModuleView(AdminPortalState state) {
    switch (_activeTab) {
      case AdminPortalTab.overview:
        return _buildKpiOverview(state);
      case AdminPortalTab.godMode:
        return _buildGodModeView(state);
      case AdminPortalTab.users:
        return _buildUserDirectoryView(state);
      case AdminPortalTab.catalog:
        return _buildCatalogView(state);
      case AdminPortalTab.flags:
        return _buildFeatureFlagsView(state);
      case AdminPortalTab.environment:
        return _buildEnvironmentView(state);
      case AdminPortalTab.auditTrail:
        return _buildAuditTrailView(state);
      case AdminPortalTab.broadcasts:
        return _buildBroadcastsView(state);
    }
  }

  // =========================================================================
  // 1. KPI OVERVIEW MODULE
  // =========================================================================
  Widget _buildKpiOverview(AdminPortalState state) {
    final kpis = state.kpiSummary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              const Text(
                'Financial & Monetization Telemetry',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: Colors.cyanAccent,
                ),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh KPIs'),
                onPressed: () =>
                    ref.read(adminPortalProvider.notifier).refreshKpiSummary(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // KPI Cards Grid
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildKpiCard(
                title: 'Monthly Recurring Revenue (MRR)',
                value: kpis.formattedMrr,
                subtitle: 'ARR: ${kpis.formattedArr}',
                color: Colors.greenAccent,
                icon: Icons.attach_money_rounded,
              ),
              _buildKpiCard(
                title: 'Active Pro Subscribers',
                value: '${kpis.activeProUsersCount}',
                subtitle: 'Total registered: ${kpis.totalUsersCount}',
                color: Colors.cyanAccent,
                icon: Icons.star_rounded,
              ),
              _buildKpiCard(
                title: 'Average Revenue Per User (ARPU)',
                value: kpis.formattedArpu,
                subtitle: 'Across total registered base',
                color: Colors.amberAccent,
                icon: Icons.trending_up_rounded,
              ),
              _buildKpiCard(
                title: 'Conversion Rate',
                value: '${kpis.trialToPaidConversionRate.toStringAsFixed(1)}%',
                subtitle: 'Paid / Total users',
                color: Colors.purpleAccent,
                icon: Icons.percent_rounded,
              ),
            ],
          ),
          const SizedBox(height: 28),

          // SKU Breakdown Table
          const Text(
            'Product SKU Performance Matrix',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1F2937)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: kpis.skuBreakdown.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: Color(0xFF1F2937)),
              itemBuilder: (context, index) {
                final sku = kpis.skuBreakdown[index];
                return ListTile(
                  title: Text(
                    sku.productName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'SKU: ${sku.sku} • Active Subs: ${sku.activeSubscriberCount}',
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${sku.grossRevenueUsd.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${sku.totalUnitsSold} units sold',
                        style:
                            const TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 2. GOD MODE & DEVELOPER OVERRIDES MODULE
  // =========================================================================
  Widget _buildGodModeView(AdminPortalState state) {
    final godMode = state.godMode;
    final notifier = ref.read(adminPortalProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Master God Mode Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: godMode.isGodModeEnabled
                    ? [const Color(0xFF78350F), const Color(0xFF1E1B4B)]
                    : [const Color(0xFF111827), const Color(0xFF1F2937)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: godMode.isGodModeEnabled
                    ? Colors.amberAccent
                    : Colors.white12,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.bolt_rounded,
                  size: 40,
                  color: godMode.isGodModeEnabled
                      ? Colors.amberAccent
                      : Colors.white38,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Master God Mode Override',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        godMode.isGodModeEnabled
                            ? 'All companions, biomes, and Pro perks are forcefully unlocked.'
                            : 'Standard user access restrictions and store validation are active.',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: godMode.isGodModeEnabled,
                  activeThumbColor: Colors.amberAccent,
                  onChanged: (val) => notifier.toggleGodMode(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Individual Subsystem Overrides',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Individual Toggles
          _buildOverrideSwitchTile(
            title: 'Force Pro Subscription Status',
            subtitle: 'Bypasses IAP store receipt checks, grants Pro everywhere',
            value: godMode.forceProStatus,
            onChanged: (val) => notifier.updateGodModeConfig(
              godMode.copyWith(forceProStatus: val),
            ),
          ),
          _buildOverrideSwitchTile(
            title: 'Unlock All Biome Habitats',
            subtitle: 'Makes Arctic, Bamboo, Savannah, Deep Ocean immediately selectable',
            value: godMode.unlockAllBiomes,
            onChanged: (val) => notifier.updateGodModeConfig(
              godMode.copyWith(unlockAllBiomes: val),
            ),
          ),
          _buildOverrideSwitchTile(
            title: 'Unlock All Companions',
            subtitle: 'Enables all 12 exotic animals regardless of XP requirements',
            value: godMode.unlockAllCompanions,
            onChanged: (val) => notifier.updateGodModeConfig(
              godMode.copyWith(unlockAllCompanions: val),
            ),
          ),
          _buildOverrideSwitchTile(
            title: 'Unlock All Hydro Themes',
            subtitle: 'Unlocks Cyberpunk Glow, Deep Trench, and high-contrast modes',
            value: godMode.unlockAllThemes,
            onChanged: (val) => notifier.updateGodModeConfig(
              godMode.copyWith(unlockAllThemes: val),
            ),
          ),
          _buildOverrideSwitchTile(
            title: 'Infinite Streak Freezes',
            subtitle: 'Guarantees freeze tokens are never consumed upon missed logs',
            value: godMode.infiniteStreakFreezes,
            onChanged: (val) => notifier.updateGodModeConfig(
              godMode.copyWith(infiniteStreakFreezes: val),
            ),
          ),
          _buildOverrideSwitchTile(
            title: 'Max Companion Evolution Stages',
            subtitle: 'Forces all companions to render in their Elder / Mythic visual forms',
            value: godMode.maxEvolutionStages,
            onChanged: (val) => notifier.updateGodModeConfig(
              godMode.copyWith(maxEvolutionStages: val),
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Interactive Hydration & Milestone Simulation',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Simulation Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1F2937)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Instant Milestone Trigger',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildMilestoneButton(
                        '💧 25% Goal', 500, BeverageType.pureWater),
                    _buildMilestoneButton(
                        '🌊 50% Goal', 1000, BeverageType.pureWater),
                    _buildMilestoneButton(
                        '⭐ 75% Goal', 1500, BeverageType.coconutWater),
                    _buildMilestoneButton(
                        '🎉 100% Goal Met', 2000, BeverageType.herbalTea),
                    _buildMilestoneButton(
                        '🔥 150% Overflow', 3000, BeverageType.pureWater),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverrideSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: Colors.cyanAccent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneButton(
      String label, double volumeMl, BeverageType beverage) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.cyanAccent,
        side: const BorderSide(color: Colors.cyanAccent),
      ),
      onPressed: () {
        ref.read(hydrationProvider.notifier).logDrink(
              beverage: beverage,
              volumeMl: volumeMl,
            );
        ref.read(animalHabitatProvider.notifier).addXp((volumeMl / 10).round());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '⚡ Simulated ${volumeMl.toStringAsFixed(0)}ml milestone beverage log!'),
            backgroundColor: Colors.cyan,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Text(label),
    );
  }

  // =========================================================================
  // 3. USER DIRECTORY MODULE
  // =========================================================================
  Widget _buildUserDirectoryView(AdminPortalState state) {
    final notifier = ref.read(adminPortalProvider.notifier);
    final users = state.filteredUsers;

    return Column(
      children: [
        // Search & Filter Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search users by name, email, or user ID...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon:
                        const Icon(Icons.search, color: Colors.cyanAccent),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white54),
                            onPressed: () {
                              _searchController.clear();
                              notifier.setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFF111827),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF1F2937)),
                    ),
                  ),
                  onChanged: (val) => notifier.setSearchQuery(val),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF1F2937)),
                ),
                child: Text(
                  '${users.length} Users',
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // User Directory List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: users.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final user = users[index];
              final isSuspended = user.status == UserAccountStatus.suspended;

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSuspended ? Colors.redAccent : const Color(0xFF1F2937),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: user.role == UserRole.superAdmin
                          ? Colors.redAccent.withValues(alpha: 0.2)
                          : Colors.cyanAccent.withValues(alpha: 0.2),
                      child: Text(
                        user.displayName.isNotEmpty
                            ? user.displayName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: user.role == UserRole.superAdmin
                              ? Colors.redAccent
                              : Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                user.displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildRoleBadge(user.role),
                              const SizedBox(width: 6),
                              _buildStatusBadge(user.status),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.email,
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'XP: ${user.currentXp} • Streak: ${user.streakCount}d • Freezes: ${user.freezeTokens} • Pro: ${user.isPro ? "Yes" : "No"}',
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 11),
                          ),
                        ],
                      ),
                    ),

                    // User Actions
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white70),
                      onSelected: (action) =>
                          _handleUserAction(context, user, action),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit_xp',
                          child: Text('Edit Experience Points (XP)'),
                        ),
                        const PopupMenuItem(
                          value: 'grant_freezes',
                          child: Text('Grant Freeze Tokens (+3)'),
                        ),
                        PopupMenuItem(
                          value: 'toggle_status',
                          child: Text(isSuspended
                              ? 'Activate Account'
                              : 'Suspend Account'),
                        ),
                        const PopupMenuItem(
                          value: 'change_role',
                          child: Text('Change User Role'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRoleBadge(UserRole role) {
    Color color;
    switch (role) {
      case UserRole.superAdmin:
        color = Colors.redAccent;
        break;
      case UserRole.admin:
        color = Colors.blueAccent;
        break;
      case UserRole.moderator:
        color = Colors.tealAccent;
        break;
      case UserRole.pro:
        color = Colors.amberAccent;
        break;
      case UserRole.standard:
        color = Colors.grey;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 0.8),
      ),
      child: Text(
        role.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(UserAccountStatus status) {
    Color color;
    switch (status) {
      case UserAccountStatus.active:
        color = Colors.greenAccent;
        break;
      case UserAccountStatus.suspended:
        color = Colors.redAccent;
        break;
      case UserAccountStatus.pendingVerification:
        color = Colors.yellowAccent;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.name,
        style: TextStyle(
          color: color,
          fontSize: 10,
        ),
      ),
    );
  }

  void _handleUserAction(
      BuildContext context, AdminUserProfile user, String action) {
    final notifier = ref.read(adminPortalProvider.notifier);

    switch (action) {
      case 'edit_xp':
        _showEditXpDialog(context, user);
        break;
      case 'grant_freezes':
        notifier.grantUserFreezeTokens(user.id, 3);
        break;
      case 'toggle_status':
        final newStatus = user.status == UserAccountStatus.suspended
            ? UserAccountStatus.active
            : UserAccountStatus.suspended;
        notifier.updateUserStatus(user.id, newStatus);
        break;
      case 'change_role':
        _showChangeRoleDialog(context, user);
        break;
    }
  }

  void _showEditXpDialog(BuildContext context, AdminUserProfile user) {
    final controller = TextEditingController(text: user.currentXp.toString());
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('Adjust XP for ${user.displayName}',
            style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'New XP Value',
            labelStyle: TextStyle(color: Colors.cyanAccent),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newXp = int.tryParse(controller.text) ?? user.currentXp;
              ref.read(adminPortalProvider.notifier).updateUserXp(user.id, newXp);
              Navigator.pop(ctx);
            },
            child: const Text('Save XP'),
          ),
        ],
      ),
    );
  }

  void _showChangeRoleDialog(BuildContext context, AdminUserProfile user) {
    showDialog<void>(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('Select Role for ${user.displayName}',
            style: const TextStyle(color: Colors.white)),
        children: UserRole.values.map((role) {
          return SimpleDialogOption(
            onPressed: () {
              ref.read(adminPortalProvider.notifier).updateUserRole(user.id, role);
              Navigator.pop(ctx);
            },
            child: Text(role.name.toUpperCase(),
                style: const TextStyle(color: Colors.cyanAccent)),
          );
        }).toList(),
      ),
    );
  }

  // =========================================================================
  // 4. CONTENT CATALOG MODULE (BEVERAGES & COMPANIONS)
  // =========================================================================
  Widget _buildCatalogView(AdminPortalState state) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.local_drink), text: 'Beverages Catalog'),
              Tab(icon: Icon(Icons.pets), text: 'Animal Companions'),
            ],
            indicatorColor: Colors.cyanAccent,
            labelColor: Colors.cyanAccent,
            unselectedLabelColor: Colors.white60,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildBeveragesList(state),
                _buildAnimalsList(state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeveragesList(AdminPortalState state) {
    final notifier = ref.read(adminPortalProvider.notifier);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.beverages.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final bev = state.beverages[index];
        final color = Color(int.parse(bev.colorHex.replaceFirst('#', '0xFF')));

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF1F2937)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.25),
                child: Icon(Icons.water_drop, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bev.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Hydration: ${bev.hydrationIndex}x • Caffeine: ${bev.caffeineMgPer100Ml}mg • Electrolytes: ${bev.electrolytesMgPer100Ml}mg',
                      style:
                          const TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Switch(
                value: bev.isEnabled,
                activeThumbColor: Colors.cyanAccent,
                onChanged: (_) => notifier.toggleBeverageEnabled(bev.id),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimalsList(AdminPortalState state) {
    final notifier = ref.read(adminPortalProvider.notifier);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.animals.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final animal = state.animals[index];

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF1F2937)),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFF1E293B),
                child: Icon(Icons.pets, color: Colors.amberAccent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          animal.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (animal.isPremiumOnly)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.amberAccent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'PRO',
                              style: TextStyle(
                                  color: Colors.amberAccent,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      'Biome: ${animal.biomeId} • Tier: ${animal.tier} • Unlock XP: ${animal.unlockXp}',
                      style:
                          const TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Switch(
                value: animal.isEnabled,
                activeThumbColor: Colors.cyanAccent,
                onChanged: (_) => notifier.toggleAnimalEnabled(animal.id),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================================
  // 5. FEATURE FLAGS MODULE
  // =========================================================================
  Widget _buildFeatureFlagsView(AdminPortalState state) {
    final notifier = ref.read(adminPortalProvider.notifier);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.featureFlags.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final flag = state.featureFlags[index];

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF1F2937)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          flag.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            flag.category.name.toUpperCase(),
                            style: const TextStyle(
                                color: Colors.cyanAccent, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      flag.description,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Key: ${flag.key}',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: flag.isEnabled,
                activeThumbColor: Colors.cyanAccent,
                onChanged: (val) =>
                    notifier.toggleFeatureFlag(flag.key, val),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================================
  // 6. MULTI-ENVIRONMENT SWITCHER MODULE
  // =========================================================================
  Widget _buildEnvironmentView(AdminPortalState state) {
    final notifier = ref.read(adminPortalProvider.notifier);
    final currentEnv = state.environmentConfig.environment;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Target Backend Environment Configuration',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Switching environments swaps Supabase endpoints, connection pools, and client credentials.',
            style: TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Environment Cards
          ...AppEnvironment.values.map((env) {
            final isSelected = env == currentEnv;
            final color = _getEnvColor(env);

            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => notifier.switchEnvironment(env),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : const Color(0xFF1F2937),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: isSelected ? color : Colors.white38,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            env.name.toUpperCase(),
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getEnvDescription(env),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ACTIVE',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 24),
          const Text(
            'Active Endpoint Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1F2937)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Supabase URL', state.environmentConfig.supabaseUrl),
                const SizedBox(height: 8),
                _buildDetailRow('Mock Storage Mode',
                    state.environmentConfig.isMockMode ? 'Enabled' : 'Disabled'),
                const SizedBox(height: 8),
                _buildDetailRow('API Timeout',
                    '${state.environmentConfig.apiTimeoutSeconds} seconds'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getEnvDescription(AppEnvironment env) {
    switch (env) {
      case AppEnvironment.development:
        return 'Local mock storage, instant response, debug flags enabled.';
      case AppEnvironment.staging:
        return 'Staging Supabase instance, sandbox payment processing.';
      case AppEnvironment.production:
        return 'Live Supabase production cluster, real payment verification.';
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 12)),
      ],
    );
  }

  // =========================================================================
  // 7. SECURITY AUDIT TRAIL MODULE
  // =========================================================================
  Widget _buildAuditTrailView(AdminPortalState state) {
    final notifier = ref.read(adminPortalProvider.notifier);

    return Column(
      children: [
        // Integrity Verification Header
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF0F172A),
          child: Row(
            children: [
              Icon(
                state.isAuditChainValid
                    ? Icons.verified_user_rounded
                    : Icons.warning_amber_rounded,
                color: state.isAuditChainValid
                    ? Colors.greenAccent
                    : Colors.redAccent,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.isAuditChainValid
                          ? 'Audit Chain Intact & Cryptographically Verified'
                          : 'Warning: Hash Chain Integrity Compromised',
                      style: TextStyle(
                        color: state.isAuditChainValid
                            ? Colors.greenAccent
                            : Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${state.auditEntries.length} total immutable audit records stored in SHA-256 chain.',
                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: Colors.cyanAccent,
                ),
                icon: const Icon(Icons.shield_outlined, size: 16),
                label: const Text('Verify Chain'),
                onPressed: () {
                  final res = notifier.verifyAuditTrailIntegrity();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(res.isValid
                          ? '✅ Verified ${res.totalEntriesChecked} audit entries! Chain hash integrity 100% intact.'
                          : '❌ Integrity check failed at entry ${res.compromisedEntryId}'),
                      backgroundColor:
                          res.isValid ? Colors.teal : Colors.redAccent,
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // Audit Entries Table / List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.auditEntries.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final entry = state.auditEntries[index];

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF1F2937)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.actionType.name,
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          entry.timestamp.toIso8601String().substring(11, 19),
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.description,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Operator: ${entry.operatorEmail} • Target: ${entry.targetEntityId}',
                      style:
                          const TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hash: ${entry.entryHash.length >= 16 ? entry.entryHash.substring(0, 16) : entry.entryHash}...',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 8. NOTIFICATION BROADCAST CENTER MODULE
  // =========================================================================
  Widget _buildBroadcastsView(AdminPortalState state) {
    final notifier = ref.read(adminPortalProvider.notifier);
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Compose Notification Broadcast',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Broadcast Composer Form
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1F2937)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Broadcast Title',
                    labelStyle: TextStyle(color: Colors.cyanAccent),
                    hintText: 'e.g. Weekend Hydration Challenge Live!',
                    hintStyle: TextStyle(color: Colors.white38),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bodyController,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Message Body',
                    labelStyle: TextStyle(color: Colors.cyanAccent),
                    hintText: 'Keep your companion hydrated to earn double XP...',
                    hintStyle: TextStyle(color: Colors.white38),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.schedule_send),
                      label: const Text('Schedule (+1h)'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.amberAccent,
                        side: const BorderSide(color: Colors.amberAccent),
                      ),
                      onPressed: () {
                        if (titleController.text.trim().isEmpty) return;
                        notifier.scheduleBroadcast(
                          title: titleController.text.trim(),
                          body: bodyController.text.trim(),
                          scheduledAt:
                              DateTime.now().add(const Duration(hours: 1)),
                          category: BroadcastCategory.challenge,
                          audience: BroadcastTargetAudience.allUsers,
                        );
                        titleController.clear();
                        bodyController.clear();
                      },
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.send_rounded),
                      label: const Text('Send Immediately'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: Colors.black87,
                      ),
                      onPressed: () {
                        if (titleController.text.trim().isEmpty) return;
                        notifier.dispatchBroadcast(
                          title: titleController.text.trim(),
                          body: bodyController.text.trim(),
                          category: BroadcastCategory.announcement,
                          audience: BroadcastTargetAudience.allUsers,
                        );
                        titleController.clear();
                        bodyController.clear();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          const Text(
            'Broadcast Dispatches & History',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.broadcasts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final b = state.broadcasts[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF1F2937)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: b.isSent
                          ? Colors.greenAccent.withValues(alpha: 0.2)
                          : Colors.amberAccent.withValues(alpha: 0.2),
                      child: Icon(
                        b.isSent ? Icons.check : Icons.schedule,
                        color: b.isSent
                            ? Colors.greenAccent
                            : Colors.amberAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            b.body,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Status: ${b.isSent ? "Delivered" : "Scheduled"} • Audience: ${b.targetAudience.displayName}',
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    if (!b.isSent)
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.redAccent),
                        tooltip: 'Cancel scheduled broadcast',
                        onPressed: () => notifier.cancelScheduledBroadcast(b.id),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _confirmResetToDefaults(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Reset All Admin Settings?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will reset God Mode, catalogs, feature flags, and environment back to initial seed defaults.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              ref.read(adminPortalProvider.notifier).resetToDefaults();
              Navigator.pop(ctx);
            },
            child: const Text('Reset to Defaults'),
          ),
        ],
      ),
    );
  }
}
