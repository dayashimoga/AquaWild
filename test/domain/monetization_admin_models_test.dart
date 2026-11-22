import 'package:aquawild/src/domain/models/admin_models.dart';
import 'package:aquawild/src/domain/models/monetization_models.dart';
import 'package:aquawild/src/domain/models/out_of_app_telemetry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Monetization & Entitlement Models Tests', () {
    test('SubscriptionTier identifies Pro status and serializes cleanly', () {
      expect(SubscriptionTier.free.isPro, isFalse);
      expect(SubscriptionTier.proMonthly.isPro, isTrue);
      expect(SubscriptionTier.proAnnual.isPro, isTrue);
      expect(SubscriptionTier.proLifetime.isPro, isTrue);

      expect(SubscriptionTier.fromId('aquawild_pro_monthly'),
          equals(SubscriptionTier.proMonthly));
      expect(SubscriptionTier.fromId('aquawild_pro_annual'),
          equals(SubscriptionTier.proAnnual));
      expect(SubscriptionTier.fromId('aquawild_pro_lifetime'),
          equals(SubscriptionTier.proLifetime));
      expect(SubscriptionTier.fromId('unknown'), equals(SubscriptionTier.free));
    });

    test('UserSubscription handles expiration, access and JSON round-trip', () {
      final now = DateTime.now();
      final sub = UserSubscription(
        userId: 'user-123',
        tier: SubscriptionTier.proAnnual,
        status: SubscriptionStatus.active,
        startedAt: now,
        expiresAt: now.add(const Duration(days: 30)),
        originalTransactionId: 'txn-999',
      );

      expect(sub.isPro, isTrue);
      expect(sub.daysRemaining, greaterThanOrEqualTo(29));

      final json = sub.toJson();
      final restored = UserSubscription.fromJson(json);

      expect(restored.userId, equals('user-123'));
      expect(restored.tier, equals(SubscriptionTier.proAnnual));
      expect(restored.status, equals(SubscriptionStatus.active));
      expect(restored.originalTransactionId, equals('txn-999'));
      expect(restored.isPro, isTrue);
    });

    test('UserSubscription grace period maintains access', () {
      final sub = UserSubscription(
        userId: 'user-grace',
        tier: SubscriptionTier.proMonthly,
        status: SubscriptionStatus.gracePeriod,
        startedAt: DateTime.now(),
      );

      expect(sub.isPro, isTrue);
      expect(SubscriptionStatus.gracePeriod.hasAccess, isTrue);
      expect(SubscriptionStatus.expired.hasAccess, isFalse);
    });

    test('ProductSKU catalog holds expected unlock packs', () {
      final deepSea = ProductSKU.findById('pack_deep_sea');
      expect(deepSea, isNotNull);
      expect(deepSea!.unlockedAnimalIds,
          containsAll(['sea_otter', 'bottlenose_dolphin', 'blue_ringed_octopus']));
      expect(deepSea.priceCents, equals(499));

      final alpine = ProductSKU.findById('pack_alpine_glacier');
      expect(alpine, isNotNull);
      expect(alpine!.unlockedAnimalIds.length, equals(4));

      expect(ProductSKU.findById('non_existent'), isNull);
    });

    test('UserEntitlement serializes and deserializes cleanly', () {
      final now = DateTime.now();
      final ent = UserEntitlement(
        sku: 'pack_deep_sea',
        kind: EntitlementKind.animalPack,
        source: 'iap',
        grantedAt: now,
      );

      final json = ent.toJson();
      final restored = UserEntitlement.fromJson(json);

      expect(restored.sku, equals('pack_deep_sea'));
      expect(restored.kind, equals(EntitlementKind.animalPack));
      expect(restored.source, equals('iap'));
    });
  });

  group('Out-of-App Telemetry & Budget Calculation Tests', () {
    test('HydrationBudgetSummary calculates remaining, caffeine and electrolytes', () {
      const budget = HydrationBudgetSummary(
        targetMl: 2500.0,
        netConsumedMl: 1650.0,
        caffeineConsumedMg: 120.0,
        electrolytesConsumedMg: 350.0,
        streakDays: 14,
        streakFreezesAvailable: 2,
      );

      expect(budget.remainingMl, equals(850.0));
      expect(budget.progressPercent, equals(66));
      expect(budget.caffeineBudgetRemainingMg, equals(280.0));
      expect(budget.electrolyteScorePercent, equals(70));
    });

    test('OutOfAppTelemetrySnapshot generates notification title and body', () {
      final snapshot = OutOfAppTelemetrySnapshot(
        timestamp: DateTime.now(),
        budget: const HydrationBudgetSummary(
          targetMl: 2000.0,
          netConsumedMl: 1500.0,
          streakDays: 7,
          streakFreezesAvailable: 1,
        ),
        activeCompanionId: 'red_panda',
        activeCompanionName: 'Ruby the Red Panda',
        companionStageTitle: 'Explorer',
        userXp: 450,
        xpUntilNextStage: 300,
        activeBiomeName: 'Bamboo Misty Springs',
      );

      expect(snapshot.notificationTitle, contains('75% of Goal'));
      expect(snapshot.notificationTitle, contains('500ml remaining'));
      expect(snapshot.notificationBody, contains('Ruby the Red Panda'));
      expect(snapshot.notificationBody, contains('7 days'));
      expect(snapshot.notificationBody, contains('1 🛡️'));

      final json = snapshot.toJson();
      final restored = OutOfAppTelemetrySnapshot.fromJson(json);

      expect(restored.activeCompanionId, equals('red_panda'));
      expect(restored.budget.progressPercent, equals(75));
    });
  });

  group('Admin Models & Audit Ledger Tests', () {
    test('RemoteConfigFlag serialization and modification', () {
      final flag = RemoteConfigFlag(
        key: 'enable_high_precision_waves',
        value: {'sub_steps': 8},
        description: 'Wave solver sub-step count',
        environment: 'all',
        isActive: true,
        updatedAt: DateTime.now(),
      );

      final json = flag.toJson();
      final restored = RemoteConfigFlag.fromJson(json);

      expect(restored.key, equals('enable_high_precision_waves'));
      expect(restored.value['sub_steps'], equals(8));
      expect(restored.isActive, isTrue);

      final updated = flag.copyWith(isActive: false);
      expect(updated.isActive, isFalse);
    });

    test('AdminAuditEntry records immutable audit events', () {
      final now = DateTime.now();
      final entry = AdminAuditEntry(
        id: 'audit-001',
        actorId: 'admin-uuid',
        actorEmail: 'architect@aquawild.internal',
        action: 'GOD_MODE_TOGGLE',
        targetResource: 'GLOBAL_ENTITLEMENTS',
        details: {'previous': false, 'new': true},
        environment: 'dev',
        ipAddress: '127.0.0.1',
        timestamp: now,
      );

      final json = entry.toJson();
      final restored = AdminAuditEntry.fromJson(json);

      expect(restored.id, equals('audit-001'));
      expect(restored.actorEmail, equals('architect@aquawild.internal'));
      expect(restored.action, equals('GOD_MODE_TOGGLE'));
      expect(restored.details['new'], isTrue);
      expect(restored.environment, equals('dev'));
    });

    test('AdminEnvironment parses modes correctly', () {
      expect(AdminEnvironment.fromString('dev'), equals(AdminEnvironment.development));
      expect(AdminEnvironment.fromString('staging'), equals(AdminEnvironment.staging));
      expect(AdminEnvironment.fromString('prod'), equals(AdminEnvironment.production));
      expect(AdminEnvironment.fromString('other'), equals(AdminEnvironment.production));

      expect(AdminEnvironment.development.label, equals('DEV'));
      expect(AdminEnvironment.staging.label, equals('STAGING'));
      expect(AdminEnvironment.production.label, equals('PROD'));
    });
  });
}
