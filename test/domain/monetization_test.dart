import 'package:aquawild/src/data/repositories/local_monetization_repository.dart';
import 'package:aquawild/src/data/repositories/monetization_repository.dart';
import 'package:aquawild/src/domain/models/exotic_animal.dart';
import 'package:aquawild/src/domain/models/monetization_models.dart';
import 'package:aquawild/src/presentation/controllers/animal_habitat_controller.dart';
import 'package:aquawild/src/presentation/controllers/monetization_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Monetization Domain Models & Catalog Tests', () {
    test('SubscriptionTier ID, display name, and parsing round-trips correctly', () {
      expect(SubscriptionTier.free.isPro, isFalse);
      expect(SubscriptionTier.proMonthly.isPro, isTrue);
      expect(SubscriptionTier.proAnnual.isPro, isTrue);
      expect(SubscriptionTier.proLifetime.isPro, isTrue);

      expect(SubscriptionTier.fromId('aquawild_pro_monthly'), equals(SubscriptionTier.proMonthly));
      expect(SubscriptionTier.fromId('pro_annual'), equals(SubscriptionTier.proAnnual));
      expect(SubscriptionTier.fromId('pro_lifetime'), equals(SubscriptionTier.proLifetime));
      expect(SubscriptionTier.fromId('unknown'), equals(SubscriptionTier.free));
    });

    test('SubscriptionStatus hasAccess evaluates active and gracePeriod', () {
      expect(SubscriptionStatus.active.hasAccess, isTrue);
      expect(SubscriptionStatus.gracePeriod.hasAccess, isTrue);
      expect(SubscriptionStatus.expired.hasAccess, isFalse);
      expect(SubscriptionStatus.cancelled.hasAccess, isFalse);

      expect(SubscriptionStatus.fromString('active'), equals(SubscriptionStatus.active));
      expect(SubscriptionStatus.fromString('grace_period'), equals(SubscriptionStatus.gracePeriod));
      expect(SubscriptionStatus.fromString('cancelled'), equals(SubscriptionStatus.cancelled));
      expect(SubscriptionStatus.fromString('expired'), equals(SubscriptionStatus.expired));
    });

    test('UserSubscription serialization round-trip', () {
      final now = DateTime(2026, 11, 22, 12, 0, 0);
      final sub = UserSubscription(
        userId: 'test_user_42',
        tier: SubscriptionTier.proAnnual,
        status: SubscriptionStatus.active,
        store: 'apple_app_store',
        originalTransactionId: 'tx_998877',
        startedAt: now,
        expiresAt: now.add(const Duration(days: 365)),
        autoRenew: true,
      );

      final json = sub.toJson();
      final parsed = UserSubscription.fromJson(json);

      expect(parsed.userId, equals(sub.userId));
      expect(parsed.tier, equals(SubscriptionTier.proAnnual));
      expect(parsed.status, equals(SubscriptionStatus.active));
      expect(parsed.isPro, isTrue);
      expect(parsed.store, equals('apple_app_store'));
      expect(parsed.originalTransactionId, equals('tx_998877'));
      expect(parsed.autoRenew, isTrue);
    });

    test('ProductSKU catalog contains all core IAP and Seasonal packs', () {
      expect(ProductSKU.catalog.length, greaterThanOrEqualTo(4));

      final deepSea = ProductSKU.findById('pack_deep_sea');
      expect(deepSea, isNotNull);
      expect(deepSea!.unlockedAnimalIds, containsAll(['sea_otter', 'bottlenose_dolphin', 'blue_ringed_octopus']));
      expect(deepSea.priceCents, equals(499));

      final alpine = ProductSKU.findById('pack_alpine_glacier');
      expect(alpine, isNotNull);
      expect(alpine!.unlockedAnimalIds, containsAll(['andean_llama', 'arctic_fox', 'emperor_penguin', 'snow_leopard']));

      final fxPack = ProductSKU.findById('pack_neon_bioluminescence');
      expect(fxPack, isNotNull);
      expect(fxPack!.unlockedThemeIds, contains('neon_bioluminescence'));

      final seasonalPass = ProductSKU.findById('pass_summer_splash');
      expect(seasonalPass, isNotNull);
      expect(seasonalPass!.kind, equals(EntitlementKind.seasonalPass));
    });
  });

  group('LocalMonetizationRepository Tests', () {
    test('Defaults to free subscription and empty entitlements', () async {
      final repo = LocalMonetizationRepository();
      final sub = await repo.getSubscription();
      final ents = await repo.getEntitlements();

      expect(sub.tier, equals(SubscriptionTier.free));
      expect(sub.isPro, isFalse);
      expect(ents, isEmpty);
    });

    test('Saves and reloads subscription and entitlements in-memory', () async {
      final repo = LocalMonetizationRepository();
      final now = DateTime.now();

      final proSub = UserSubscription(
        userId: 'user_1',
        tier: SubscriptionTier.proLifetime,
        status: SubscriptionStatus.active,
        startedAt: now,
      );
      await repo.saveSubscription(proSub);

      final reloadedSub = await repo.getSubscription();
      expect(reloadedSub.tier, equals(SubscriptionTier.proLifetime));
      expect(reloadedSub.isPro, isTrue);

      final entitlements = [
        UserEntitlement(
          sku: 'pack_deep_sea',
          kind: EntitlementKind.animalPack,
          grantedAt: now,
        ),
      ];
      await repo.saveEntitlements(entitlements);

      final reloadedEnts = await repo.getEntitlements();
      expect(reloadedEnts.length, equals(1));
      expect(reloadedEnts.first.sku, equals('pack_deep_sea'));

      await repo.clearAll();
      final clearedSub = await repo.getSubscription();
      final clearedEnts = await repo.getEntitlements();
      expect(clearedSub.tier, equals(SubscriptionTier.free));
      expect(clearedEnts, isEmpty);
    });
  });

  group('MonetizationController State & Purchase Engine Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          monetizationRepositoryProvider.overrideWithValue(
            LocalMonetizationRepository(),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initializes with Free Explorer tier', () {
      final state = container.read(monetizationProvider);
      expect(state.isPro, isFalse);
      expect(state.activeTier, equals(SubscriptionTier.free));
      expect(state.entitlements, isEmpty);
      expect(state.hasSeasonalPass, isFalse);
    });

    test('Evaluating isAnimalUnlocked for free user based on XP progression', () {
      final state = container.read(monetizationProvider);

      // Ruby the Red Panda is starter (0 XP)
      expect(state.isAnimalUnlocked('red_panda', 0), isTrue);
      // Capybara is starter (0 XP)
      expect(state.isAnimalUnlocked('capybara', 0), isTrue);
      // Axolotl is starter (0 XP)
      expect(state.isAnimalUnlocked('axolotl', 0), isTrue);

      // Kira the Snow Leopard requires 7500 XP
      expect(state.isAnimalUnlocked('snow_leopard', 0), isFalse);
      expect(state.isAnimalUnlocked('snow_leopard', 3500), isFalse);
      expect(state.isAnimalUnlocked('snow_leopard', 7500), isTrue);
      expect(state.isAnimalUnlocked('snow_leopard', 8000), isTrue);

      // Ollie the Sea Otter requires 1300 XP
      expect(state.isAnimalUnlocked('sea_otter', 0), isFalse);
      expect(state.isAnimalUnlocked('sea_otter', 1300), isTrue);
    });

    test('Subscribing to AquaWild Pro unlocks all companions, themes, and seasonal passes', () async {
      final notifier = container.read(monetizationProvider.notifier);

      final success = await notifier.subscribe(SubscriptionTier.proMonthly);
      expect(success, isTrue);

      final state = container.read(monetizationProvider);
      expect(state.isPro, isTrue);
      expect(state.activeTier, equals(SubscriptionTier.proMonthly));
      expect(state.hasSeasonalPass, isTrue);

      // All 10 companions are unlocked regardless of 0 XP
      for (final animal in ExoticAnimal.allAnimals) {
        expect(state.isAnimalUnlocked(animal.id, 0), isTrue,
            reason: '${animal.name} should be unlocked under Pro');
      }

      // Pro unlocks all themes
      expect(state.isThemeUnlocked('neon_bioluminescence'), isTrue);
      expect(state.isThemeUnlocked('minimal_zen'), isTrue);
      expect(state.isThemeUnlocked('cyber_ocean'), isTrue);

      // Cancel subscription sets autoRenew to false
      await notifier.cancelSubscription();
      final cancelledState = container.read(monetizationProvider);
      expect(cancelledState.subscription.autoRenew, isFalse);
    });

    test('Purchasing one-time animal pack unlocks only packaged companions', () async {
      final notifier = container.read(monetizationProvider.notifier);

      // Purchase Deep Sea Legends pack
      final success = await notifier.purchaseProduct('pack_deep_sea');
      expect(success, isTrue);

      final state = container.read(monetizationProvider);
      expect(state.isPro, isFalse); // Still free user, but has pack entitlement
      expect(state.entitlements.length, equals(1));
      expect(state.unlockedAnimalIds, containsAll(['sea_otter', 'bottlenose_dolphin', 'blue_ringed_octopus']));

      // Deep Sea companions unlocked at 0 XP
      expect(state.isAnimalUnlocked('sea_otter', 0), isTrue);
      expect(state.isAnimalUnlocked('bottlenose_dolphin', 0), isTrue);
      expect(state.isAnimalUnlocked('blue_ringed_octopus', 0), isTrue);

      // Other locked companions remain locked at 0 XP
      expect(state.isAnimalUnlocked('snow_leopard', 0), isFalse);
      expect(state.isAnimalUnlocked('arctic_fox', 0), isFalse);
    });

    test('Purchasing seasonal pass grants seasonal pass entitlement', () async {
      final notifier = container.read(monetizationProvider.notifier);

      expect(container.read(monetizationProvider).hasSeasonalPass, isFalse);

      final success = await notifier.purchaseProduct('pass_summer_splash');
      expect(success, isTrue);

      expect(container.read(monetizationProvider).hasSeasonalPass, isTrue);
    });

    test('Direct entitlement grant and revoke for admin God-Mode', () async {
      final notifier = container.read(monetizationProvider.notifier);

      await notifier.grantEntitlement(
        'pack_alpine_glacier',
        EntitlementKind.animalPack,
        source: 'admin_override',
      );

      var state = container.read(monetizationProvider);
      expect(state.isAnimalUnlocked('snow_leopard', 0), isTrue);
      expect(state.isAnimalUnlocked('arctic_fox', 0), isTrue);

      await notifier.revokeEntitlement('pack_alpine_glacier');
      state = container.read(monetizationProvider);
      expect(state.isAnimalUnlocked('snow_leopard', 0), isFalse);
      expect(state.isAnimalUnlocked('arctic_fox', 0), isFalse);
    });

    test('Reactive synchronization between MonetizationProvider and AnimalHabitatController', () async {
      // AnimalHabitatNotifier initially has starters unlocked
      final initialHabitat = container.read(animalHabitatProvider);
      expect(initialHabitat.unlockedAnimals.any((a) => a.id == 'snow_leopard'), isFalse);

      // Upgrade to Pro in MonetizationNotifier
      await container.read(monetizationProvider.notifier).subscribe(SubscriptionTier.proAnnual);

      // Allow microtask / listener callback to fire
      await Future<void>.delayed(Duration.zero);

      final updatedHabitat = container.read(animalHabitatProvider);
      // All 10 companions are now in unlockedAnimals
      expect(updatedHabitat.unlockedAnimals.length, equals(10));
      expect(updatedHabitat.unlockedAnimals.any((a) => a.id == 'snow_leopard'), isTrue);
      expect(updatedHabitat.unlockedAnimals.any((a) => a.id == 'blue_ringed_octopus'), isTrue);
    });
  });
}
