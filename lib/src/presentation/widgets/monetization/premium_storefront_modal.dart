import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/audio_haptics_service.dart';
import '../../../domain/models/monetization_models.dart';
import '../../controllers/monetization_controller.dart';

/// Glassmorphic premium storefront modal displaying AquaWild Pro subscriptions,
/// a la carte IAP unlock packs, seasonal expedition passes, and restore purchases flow.
class PremiumStorefrontModal extends ConsumerStatefulWidget {
  const PremiumStorefrontModal({super.key});

  /// Displays the storefront as a responsive modal sheet
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PremiumStorefrontModal(),
    );
  }

  @override
  ConsumerState<PremiumStorefrontModal> createState() =>
      _PremiumStorefrontModalState();
}

class _PremiumStorefrontModalState extends ConsumerState<PremiumStorefrontModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  SubscriptionTier _selectedTier = SubscriptionTier.proAnnual;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final monetization = ref.watch(monetizationProvider);
    final isPro = monetization.isPro;
    final isReducedMotion = MediaQuery.disableAnimationsOf(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1526).withValues(alpha: 0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x6600E5FF),
            blurRadius: 32,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
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
          const SizedBox(height: 12),

          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0x33FFD700),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x66FFD700)),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.amberAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'AquaWild Store',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isPro) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E5FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'PRO ACTIVE',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const Text(
                        'Subscriptions, Animal Packs & Exclusive Themes',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  tooltip: 'Close Store',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Store Tab Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF162947),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF00E5FF),
                labelColor: const Color(0xFF00E5FF),
                unselectedLabelColor: Colors.white60,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.stars_rounded, size: 18),
                    text: 'AquaWild Pro',
                  ),
                  Tab(
                    icon: Icon(Icons.shopping_bag_outlined, size: 18),
                    text: 'Packs & Passes',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Error banner if any
          if (monetization.errorMessage != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.redAccent),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      monetization.errorMessage!,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Pro Subscriptions & Feature Matrix
                _buildProSubscriptionTab(context, monetization, isReducedMotion),

                // Tab 2: A La Carte Packs & Seasonal Passes
                _buildPacksTab(context, monetization),
              ],
            ),
          ),

          // Footer: Restore Purchases & Legal Disclaimers
          _buildFooter(context, monetization),
        ],
      ),
    );
  }

  Widget _buildProSubscriptionTab(
    BuildContext context,
    MonetizationState monetization,
    bool isReducedMotion,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      physics: const BouncingScrollPhysics(),
      children: [
        // Flagship Hero Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0052D4), Color(0xFF4364F7), Color(0xFF6FB1FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x334364F7),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'UNLIMITED SANCTUARY ACCESS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'All Platforms',
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Unlock All 10 Living Companions & Future Drops',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Instant access to all biomes, premium themes, advanced electrolyte science, and unlimited predictive AI coaching.',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Subscription Plans
        const Text(
          'Select Membership Plan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        _buildPlanCard(
          tier: SubscriptionTier.proAnnual,
          title: 'Annual Pass',
          priceFormatted: '\$19.99 / year',
          equivalentMonthly: '\$1.66 / mo',
          badgeText: 'SAVE 44% • POPULAR',
          badgeColor: Colors.amberAccent,
          isRecommended: true,
          monetization: monetization,
        ),
        const SizedBox(height: 8),

        _buildPlanCard(
          tier: SubscriptionTier.proMonthly,
          title: 'Monthly Pass',
          priceFormatted: '\$2.99 / month',
          equivalentMonthly: null,
          badgeText: 'FLEXIBLE',
          badgeColor: const Color(0xFF00E5FF),
          isRecommended: false,
          monetization: monetization,
        ),
        const SizedBox(height: 8),

        _buildPlanCard(
          tier: SubscriptionTier.proLifetime,
          title: 'Lifetime Sanctuary Access',
          priceFormatted: '\$49.99 one-time',
          equivalentMonthly: 'Pay Once • Forever Access',
          badgeText: 'BEST VALUE',
          badgeColor: Colors.purpleAccent,
          isRecommended: false,
          monetization: monetization,
        ),
        const SizedBox(height: 16),

        // Action Subscribe Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5FF),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            onPressed: monetization.isLoading
                ? null
                : () async {
                    unawaited(AudioHapticsService.playTap());
                    final success = await ref
                        .read(monetizationProvider.notifier)
                        .subscribe(_selectedTier);
                    if (context.mounted && success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Successfully unlocked AquaWild Pro (${_selectedTier.title})!',
                          ),
                          backgroundColor: Colors.teal,
                        ),
                      );
                    }
                  },
            child: monetization.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : Text(
                    monetization.isPro
                        ? 'Manage / Switch to ${_selectedTier.title}'
                        : 'Unlock AquaWild Pro Now',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),

        // Feature Comparison Grid
        const Text(
          'AquaWild Free vs Pro Comparison',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        _buildComparisonTable(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPlanCard({
    required SubscriptionTier tier,
    required String title,
    required String priceFormatted,
    required String? equivalentMonthly,
    required String badgeText,
    required Color badgeColor,
    required bool isRecommended,
    required MonetizationState monetization,
  }) {
    final isSelected = _selectedTier == tier;
    final isCurrent = monetization.subscription.tier == tier && monetization.isPro;

    return Semantics(
      button: true,
      label: '$title, $priceFormatted, $badgeText',
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          unawaited(AudioHapticsService.playTap());
          setState(() => _selectedTier = tier);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E3A5F) : const Color(0xFF122238),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF00E5FF) : Colors.white12,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF00E5FF) : Colors.white38,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF00E5FF),
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: badgeColor.withValues(alpha: 0.6),
                            ),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.green),
                            ),
                            child: const Text(
                              'CURRENT',
                              style: TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (equivalentMonthly != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        equivalentMonthly,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                priceFormatted,
                style: const TextStyle(
                  color: Color(0xFF00E5FF),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonTable() {
    final features = [
      ('10 Exotic Companions', 'Earn via XP', 'All Unlocked Instantly'),
      ('Living Biomes (6)', 'Earn via XP', 'All Unlocked Instantly'),
      ('Premium Themes & FX', 'Basic Only', 'Neon, Zen & Cyber Ocean'),
      ('Electrolyte Science', 'Standard', 'Deep Bioavailability Analysis'),
      ('Predictive AI Coach', 'Daily Insights', 'Unlimited Realtime Telemetry'),
      ('Cloud Sync & Widgets', 'Local Only', 'Cross-Device & Widgets'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111E33),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF162742),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'Feature',
                    style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Free',
                    style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'AquaWild Pro',
                    style: TextStyle(color: Color(0xFF00E5FF), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        f.$1,
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        f.$2,
                        style: const TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF00E5FF), size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              f.$3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPacksTab(BuildContext context, MonetizationState monetization) {
    final products = monetization.availableProducts;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      physics: const BouncingScrollPhysics(),
      children: [
        const Text(
          'A La Carte Packs & Seasonal Passes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Own packs forever with a one-time purchase, or access everything with AquaWild Pro.',
          style: TextStyle(color: Colors.white60, fontSize: 11),
        ),
        const SizedBox(height: 14),

        ...products.map((product) {
          final isOwned = monetization.isPro ||
              monetization.entitlements.any((e) => e.sku == product.id);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isOwned
                  ? const Color(0xFF14243C)
                  : const Color(0xFF111F36),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isOwned ? Colors.green.withValues(alpha: 0.5) : Colors.white12,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            product.kind == EntitlementKind.seasonalPass
                                ? Icons.explore_rounded
                                : (product.kind == EntitlementKind.animationPack
                                    ? Icons.auto_awesome_rounded
                                    : Icons.pets_rounded),
                            color: const Color(0xFF00E5FF),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              product.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (product.badgeText.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0x3300E5FF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0x6600E5FF)),
                        ),
                        child: Text(
                          product.badgeText,
                          style: const TextStyle(
                            color: Color(0xFF00E5FF),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  product.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.priceFormatted,
                      style: const TextStyle(
                        color: Color(0xFF00E5FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (isOwned)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check, size: 12, color: Colors.greenAccent),
                            SizedBox(width: 4),
                            Text(
                              'OWNED',
                              style: TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A5F),
                          foregroundColor: const Color(0xFF00E5FF),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: Color(0x4400E5FF)),
                          ),
                        ),
                        onPressed: monetization.isLoading
                            ? null
                            : () async {
                                unawaited(AudioHapticsService.playTap());
                                final success = await ref
                                    .read(monetizationProvider.notifier)
                                    .purchaseProduct(product.id);
                                if (context.mounted && success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Unlocked ${product.title}!'),
                                      backgroundColor: Colors.teal,
                                    ),
                                  );
                                }
                              },
                        child: const Text('Purchase', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, MonetizationState monetization) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF070F1B),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.restore_rounded, size: 16),
                label: const Text('Restore Purchases', style: TextStyle(fontSize: 11)),
                style: TextButton.styleFrom(foregroundColor: Colors.white70),
                onPressed: monetization.isLoading
                    ? null
                    : () async {
                        unawaited(AudioHapticsService.playTap());
                        await ref
                            .read(monetizationProvider.notifier)
                            .restorePurchases();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Purchases successfully restored.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
              ),
              Text(
                monetization.isPro
                    ? 'AquaWild Pro Active'
                    : 'Free Tier Active',
                style: TextStyle(
                  color: monetization.isPro ? const Color(0xFF00E5FF) : Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Subscriptions auto-renew unless cancelled at least 24 hours before the end of the current period. Manage anytime in account settings.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 9),
          ),
        ],
      ),
    );
  }
}
