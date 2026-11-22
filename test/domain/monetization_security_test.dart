import 'dart:convert';
import 'package:aquawild/src/core/security/monetization_security_service.dart';
import 'package:aquawild/src/core/security/receipt_verification_service.dart';
import 'package:aquawild/src/data/repositories/local_monetization_repository.dart';
import 'package:aquawild/src/domain/models/monetization_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MonetizationSecurityService securityService;
  late ReceiptVerificationService receiptService;

  setUp(() {
    securityService = MonetizationSecurityService(
      customSecret: 'test_secret_0x123456789',
    );
    receiptService = ReceiptVerificationService(
      signingSecret: 'test_receipt_secret_0x987654321',
    );
  });

  group('MonetizationSecurityService Cryptographic Tamper Defense Tests', () {
    test('Signs and verifies valid subscription payload cleanly', () {
      final now = DateTime.now();
      final sub = UserSubscription(
        userId: 'alice_123',
        tier: SubscriptionTier.proAnnual,
        status: SubscriptionStatus.active,
        startedAt: now,
        expiresAt: now.add(const Duration(days: 365)),
      );

      final rawJson = jsonEncode(sub.toJson());
      final sealed = securityService.signPayload(rawJson);

      expect(sealed, contains('"signature"'));
      expect(sealed, contains('"payload"'));
      expect(sealed, contains('"timestamp"'));
      expect(sealed, contains('"salt"'));

      final result = securityService.verifyAndExtract<UserSubscription>(
        sealed,
        (json) => UserSubscription.fromJson(json),
      );

      expect(result.isValid, isTrue);
      expect(result.status, equals(SecurityValidationResult.valid));
      expect(result.data, isNotNull);
      expect(result.data!.tier, equals(SubscriptionTier.proAnnual));
      expect(result.data!.userId, equals('alice_123'));
    });

    test('Detects client-side tampering with subscription payload JSON', () {
      final now = DateTime.now();
      final sub = UserSubscription(
        userId: 'bob_456',
        tier: SubscriptionTier.free,
        status: SubscriptionStatus.active,
        startedAt: now,
      );

      final rawJson = jsonEncode(sub.toJson());
      final sealed = securityService.signPayload(rawJson);

      // Malicious user tampers with the payload string to give themselves lifetime access!
      final tampered = sealed.replaceAll(
        'free',
        'aquawild_pro_lifetime',
      );

      final result = securityService.verifyAndExtract<UserSubscription>(
        tampered,
        (json) => UserSubscription.fromJson(json),
      );

      expect(result.isValid, isFalse);
      expect(result.status, equals(SecurityValidationResult.tampered));
      expect(result.data, isNull);
      expect(result.errorMessage, contains('Cryptographic signature mismatch'));
    });

    test('Detects client-side tampering with entitlement list JSON', () {
      final entitlements = [
        UserEntitlement(
          sku: 'pack_deep_sea',
          kind: EntitlementKind.animalPack,
          grantedAt: DateTime.now(),
        ),
      ];

      final rawJson = jsonEncode(entitlements.map((e) => e.toJson()).toList());
      final sealed = securityService.signPayload(rawJson);

      // Malicious user attempts to add an unpurchased pass
      final tampered = sealed.replaceAll('pack_deep_sea', 'pass_summer_splash');

      final result =
          securityService.verifyAndExtractList<UserEntitlement>(
        tampered,
        (json) => UserEntitlement.fromJson(json),
      );

      expect(result.isValid, isFalse);
      expect(result.status, equals(SecurityValidationResult.tampered));
      expect(result.data, isNull);
    });

    test('Detects clock rollback or future timestamp manipulation', () {
      final now = DateTime.now();
      final sub = UserSubscription(
        userId: 'charlie_789',
        tier: SubscriptionTier.proMonthly,
        status: SubscriptionStatus.active,
        startedAt: now,
      );

      final rawJson = jsonEncode(sub.toJson());
      // Timestamp set 5 hours into the future
      final futureTs = now.add(const Duration(hours: 5));
      final sealed = securityService.signPayload(
        rawJson,
        timestamp: futureTs,
      );

      final result = securityService.verifyAndExtract<UserSubscription>(
        sealed,
        (json) => UserSubscription.fromJson(json),
        currentClock: now,
      );

      expect(result.isValid, isFalse);
      expect(result.status, equals(SecurityValidationResult.clockRollbackDetected));
    });

    test('Gracefully identifies and handles legacy unsigned JSON format', () {
      final sub = UserSubscription(
        userId: 'legacy_user',
        tier: SubscriptionTier.proLifetime,
        status: SubscriptionStatus.active,
        startedAt: DateTime.now(),
      );

      final rawLegacyJson = jsonEncode(sub.toJson());

      final result = securityService.verifyAndExtract<UserSubscription>(
        rawLegacyJson,
        (json) => UserSubscription.fromJson(json),
      );

      expect(result.isValid, isTrue);
      expect(result.status, equals(SecurityValidationResult.legacyUnsigned));
      expect(result.data!.tier, equals(SubscriptionTier.proLifetime));
    });
  });

  group('ReceiptVerificationService & Store Security Tests', () {
    test('Verifies authentic sandbox receipt cleanly', () {
      final receipt = receiptService.createSandboxReceipt(
        productId: 'aquawild_pro_annual',
        transactionId: 'tx_apple_1001',
        store: 'apple_app_store',
      );

      final result = receiptService.verifyReceipt(receipt);
      expect(result.isValid, isTrue);
      expect(result.status, equals(ReceiptValidationStatus.verified));
      expect(result.verifiedReceipt, isNotNull);
      expect(receiptService.isTransactionRedeemed('tx_apple_1001'), isTrue);
    });

    test('Rejects forged receipt with invalid signature', () {
      final forgedReceipt = PurchaseReceipt(
        transactionId: 'tx_forged_999',
        productId: 'aquawild_pro_lifetime',
        purchaseDate: DateTime(2026, 11, 22),
        store: 'google_play',
        signature: 'invalid_deadbeef_signature',
      );

      final result = receiptService.verifyReceipt(forgedReceipt);
      expect(result.isValid, isFalse);
      expect(result.status, equals(ReceiptValidationStatus.invalidSignature));
      expect(result.message, contains('signature verification failed'));
    });

    test('Rejects bundle ID mismatch', () {
      final validSignature = receiptService.generateSignature(
        bundleId: 'com.malicious.fakeapp',
        productId: 'pack_deep_sea',
        transactionId: 'tx_fake_001',
        purchaseDate: DateTime(2026, 11, 22),
      );

      final fakeBundleReceipt = PurchaseReceipt(
        transactionId: 'tx_fake_001',
        productId: 'pack_deep_sea',
        purchaseDate: DateTime(2026, 11, 22),
        store: 'apple_app_store',
        bundleId: 'com.malicious.fakeapp',
        signature: validSignature,
      );

      final result = receiptService.verifyReceipt(fakeBundleReceipt);
      expect(result.isValid, isFalse);
      expect(result.status, equals(ReceiptValidationStatus.bundleMismatch));
    });

    test('Prevents replay attacks on one-time IAP products', () {
      final receipt = receiptService.createSandboxReceipt(
        productId: 'pack_deep_sea',
        transactionId: 'tx_replay_single_use_777',
      );

      // First verification succeeds
      final first = receiptService.verifyReceipt(receipt);
      expect(first.isValid, isTrue);

      // Second attempt with exact same transaction ID is rejected as already redeemed
      final replay = receiptService.verifyReceipt(receipt);
      expect(replay.isValid, isFalse);
      expect(replay.status, equals(ReceiptValidationStatus.alreadyRedeemed));
    });

    test('Allows subscription renewals with same transaction ID when allowed', () {
      final subReceipt = receiptService.createSandboxReceipt(
        productId: 'aquawild_pro_monthly',
        transactionId: 'tx_sub_recurring_888',
      );

      final first = receiptService.verifyReceipt(
        subReceipt,
        allowReplayForSubscriptions: true,
      );
      expect(first.isValid, isTrue);

      final renewal = receiptService.verifyReceipt(
        subReceipt,
        allowReplayForSubscriptions: true,
      );
      expect(renewal.isValid, isTrue);
    });
  });

  group('Offline Grace Period & Effective Status Tests', () {
    test('Subscription before expiration is active with Pro access', () {
      final now = DateTime.now();
      final sub = UserSubscription(
        userId: 'user_active',
        tier: SubscriptionTier.proAnnual,
        status: SubscriptionStatus.active,
        startedAt: now.subtract(const Duration(days: 30)),
        expiresAt: now.add(const Duration(days: 335)),
      );

      expect(sub.isPro, isTrue);
      expect(sub.isInGracePeriod, isFalse);
      expect(sub.isPastGracePeriod, isFalse);
      expect(sub.effectiveStatus, equals(SubscriptionStatus.active));
    });

    test('Subscription expired 24h ago enters 72-hour offline grace period with access preserved', () {
      final now = DateTime.now();
      final sub = UserSubscription(
        userId: 'user_grace',
        tier: SubscriptionTier.proMonthly,
        status: SubscriptionStatus.active,
        startedAt: now.subtract(const Duration(days: 31)),
        // Expired 24 hours ago
        expiresAt: now.subtract(const Duration(hours: 24)),
      );

      expect(sub.isInGracePeriod, isTrue);
      expect(sub.isPastGracePeriod, isFalse);
      expect(sub.effectiveStatus, equals(SubscriptionStatus.gracePeriod));
      expect(sub.isPro, isTrue, reason: 'Grace period preserves Pro access offline');
    });

    test('Subscription expired 80h ago exceeds 72-hour grace period and loses Pro access', () {
      final now = DateTime.now();
      final sub = UserSubscription(
        userId: 'user_expired',
        tier: SubscriptionTier.proMonthly,
        status: SubscriptionStatus.active,
        startedAt: now.subtract(const Duration(days: 34)),
        // Expired 80 hours ago (grace period is 72h)
        expiresAt: now.subtract(const Duration(hours: 80)),
      );

      expect(sub.isInGracePeriod, isFalse);
      expect(sub.isPastGracePeriod, isTrue);
      expect(sub.effectiveStatus, equals(SubscriptionStatus.expired));
      expect(sub.isPro, isFalse, reason: 'Past grace period loses Pro access');
    });

    test('Lifetime subscription never enters grace period and never expires', () {
      final now = DateTime.now();
      final sub = UserSubscription(
        userId: 'user_lifetime',
        tier: SubscriptionTier.proLifetime,
        status: SubscriptionStatus.active,
        startedAt: now.subtract(const Duration(days: 100)),
        expiresAt: null,
      );

      expect(sub.isPro, isTrue);
      expect(sub.isInGracePeriod, isFalse);
      expect(sub.effectiveStatus, equals(SubscriptionStatus.active));
    });
  });

  group('LocalMonetizationRepository Security & Tamper Resistance Tests', () {
    test('Persists sealed envelope and rejects tampered SharedPreferences data', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = LocalMonetizationRepository(prefs, securityService);

      // Save valid annual Pro subscription
      final now = DateTime.now();
      final proSub = UserSubscription(
        userId: 'david_101',
        tier: SubscriptionTier.proAnnual,
        status: SubscriptionStatus.active,
        startedAt: now,
        expiresAt: now.add(const Duration(days: 365)),
      );

      await repo.saveSubscription(proSub);

      // Verify stored string is a sealed envelope
      final storedRaw = prefs.getString('aquawild_user_subscription');
      expect(storedRaw, isNotNull);
      expect(storedRaw, contains('"signature"'));

      // Clean read returns verified subscription
      final freshRepo = LocalMonetizationRepository(prefs, securityService);
      final loaded = await freshRepo.getSubscription();
      expect(loaded.isPro, isTrue);
      expect(loaded.tier, equals(SubscriptionTier.proAnnual));

      // Malicious actor tampers with stored string directly
      final tampered = storedRaw!.replaceAll(
        'aquawild_pro_annual',
        'aquawild_pro_lifetime',
      );
      await prefs.setString('aquawild_user_subscription', tampered);

      // New repository instance reading tampered storage rejects forged data
      final tamperedRepo = LocalMonetizationRepository(prefs, securityService);
      final fallback = await tamperedRepo.getSubscription();
      expect(fallback.isPro, isFalse);
      expect(fallback.tier, equals(SubscriptionTier.free));
    });

    test('Automatically migrates legacy unsealed data forward with cryptographic stamp', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // Seed unsealed legacy raw subscription JSON
      final legacySub = UserSubscription(
        userId: 'legacy_101',
        tier: SubscriptionTier.proLifetime,
        status: SubscriptionStatus.active,
        startedAt: DateTime.now(),
      );
      await prefs.setString(
        'aquawild_user_subscription',
        jsonEncode(legacySub.toJson()),
      );

      // Read with secure repository
      final repo = LocalMonetizationRepository(prefs, securityService);
      final loaded = await repo.getSubscription();

      expect(loaded.isPro, isTrue);
      expect(loaded.tier, equals(SubscriptionTier.proLifetime));

      // Allow microtask to save forward migration
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Stored data should now be sealed envelope
      final updatedRaw = prefs.getString('aquawild_user_subscription')!;
      expect(updatedRaw, contains('"signature"'));
    });
  });
}
