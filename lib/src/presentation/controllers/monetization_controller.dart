import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/security/receipt_verification_service.dart';
import '../../data/repositories/monetization_repository.dart';
import '../../domain/models/exotic_animal.dart';
import '../../domain/models/monetization_models.dart';

/// Riverpod provider for purchase receipt validation service
final receiptVerificationServiceProvider =
    Provider<ReceiptVerificationService>((ref) {
  return ReceiptVerificationService();
});

/// Riverpod provider for active monetization state and purchase controller
final monetizationProvider =
    NotifierProvider<MonetizationNotifier, MonetizationState>(
  MonetizationNotifier.new,
);

/// Immutable UI state for subscriptions, IAP entitlements, and catalog
class MonetizationState {
  final UserSubscription subscription;
  final List<UserEntitlement> entitlements;
  final List<ProductSKU> availableProducts;
  final bool isLoading;
  final String? errorMessage;

  const MonetizationState({
    required this.subscription,
    this.entitlements = const [],
    this.availableProducts = ProductSKU.catalog,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isPro => subscription.isPro;
  bool get isInGracePeriod => subscription.isInGracePeriod;
  SubscriptionTier get activeTier => subscription.tier;

  /// Set of animal IDs unlocked via IAP packs or Pro
  Set<String> get unlockedAnimalIds {
    if (isPro) {
      return ExoticAnimal.allAnimals.map((a) => a.id).toSet();
    }
    final Set<String> result = {};
    for (final ent in entitlements) {
      final product = ProductSKU.findById(ent.sku);
      if (product != null) {
        result.addAll(product.unlockedAnimalIds);
      }
    }
    return result;
  }

  /// Set of theme IDs unlocked via IAP packs or Pro
  Set<String> get unlockedThemeIds {
    if (isPro) {
      return {'neon_bioluminescence', 'minimal_zen', 'cyber_ocean'};
    }
    final Set<String> result = {};
    for (final ent in entitlements) {
      final product = ProductSKU.findById(ent.sku);
      if (product != null) {
        result.addAll(product.unlockedThemeIds);
      }
    }
    return result;
  }

  /// Whether user holds an active seasonal pass (or Pro)
  bool get hasSeasonalPass {
    if (isPro) return true;
    return entitlements.any((e) => e.kind == EntitlementKind.seasonalPass);
  }

  /// Evaluates whether a companion is unlocked via Pro, IAP pack, or XP progression
  bool isAnimalUnlocked(String animalId, int userXp) {
    if (isPro) return true;
    if (unlockedAnimalIds.contains(animalId)) return true;
    final animal = ExoticAnimal.findById(animalId);
    return userXp >= animal.unlockXp;
  }

  /// Evaluates whether a theme is unlocked via Pro or IAP pack
  bool isThemeUnlocked(String themeId) {
    if (isPro) return true;
    return unlockedThemeIds.contains(themeId);
  }

  MonetizationState copyWith({
    UserSubscription? subscription,
    List<UserEntitlement>? entitlements,
    List<ProductSKU>? availableProducts,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MonetizationState(
      subscription: subscription ?? this.subscription,
      entitlements: entitlements ?? this.entitlements,
      availableProducts: availableProducts ?? this.availableProducts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// State notifier managing user subscriptions, one-time IAP purchases, and entitlements
class MonetizationNotifier extends Notifier<MonetizationState> {
  MonetizationRepository get _repository =>
      ref.read(monetizationRepositoryProvider);
  ReceiptVerificationService get _receiptService =>
      ref.read(receiptVerificationServiceProvider);

  @override
  MonetizationState build() {
    final now = DateTime.now();
    final initialState = MonetizationState(
      subscription: UserSubscription(
        userId: 'local_user',
        tier: SubscriptionTier.free,
        status: SubscriptionStatus.active,
        startedAt: now,
      ),
      entitlements: const [],
      availableProducts: ProductSKU.catalog,
    );

    Future.microtask(() => loadState());
    return initialState;
  }

  /// Loads subscription and entitlements from local repository
  Future<void> loadState() async {
    state = state.copyWith(isLoading: true);
    try {
      final sub = await _repository.getSubscription();
      final ents = await _repository.getEntitlements();
      if (!ref.mounted) return;
      state = state.copyWith(
        subscription: sub,
        entitlements: ents,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load monetization state: $e',
      );
    }
  }

  /// Upgrades or modifies the user's active subscription tier
  Future<bool> subscribe(
    SubscriptionTier tier, {
    String store = 'sandbox',
    String? transactionId,
  }) async {
    if (tier == SubscriptionTier.free) {
      return cancelSubscription();
    }

    state = state.copyWith(isLoading: true);
    final now = DateTime.now();
    DateTime? expiresAt;

    switch (tier) {
      case SubscriptionTier.proMonthly:
        expiresAt = now.add(const Duration(days: 30));
        break;
      case SubscriptionTier.proAnnual:
        expiresAt = now.add(const Duration(days: 365));
        break;
      case SubscriptionTier.proLifetime:
        expiresAt = null; // No expiration for lifetime purchase
        break;
      case SubscriptionTier.free:
        break;
    }

    final txId = transactionId ?? 'tx_${now.millisecondsSinceEpoch}';
    final receipt = _receiptService.createSandboxReceipt(
      productId: tier.id,
      transactionId: txId,
      store: store,
    );
    final verification = _receiptService.verifyReceipt(
      receipt,
      allowReplayForSubscriptions: true,
    );
    if (!verification.isValid) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Receipt verification failed: ${verification.message}',
      );
      return false;
    }

    final newSubscription = UserSubscription(
      userId: state.subscription.userId,
      tier: tier,
      status: SubscriptionStatus.active,
      store: store,
      originalTransactionId: txId,
      startedAt: now,
      expiresAt: expiresAt,
      autoRenew: tier != SubscriptionTier.proLifetime,
    );

    try {
      await _repository.saveSubscription(newSubscription);
      if (!ref.mounted) return true;
      state = state.copyWith(
        subscription: newSubscription,
        isLoading: false,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Subscription upgrade failed: $e',
      );
      return false;
    }
  }

  /// Cancels recurring billing while keeping access until period ends
  Future<bool> cancelSubscription() async {
    state = state.copyWith(isLoading: true);
    final updated = state.subscription.copyWith(
      autoRenew: false,
      status: state.subscription.tier == SubscriptionTier.free
          ? SubscriptionStatus.active
          : SubscriptionStatus.cancelled,
    );

    try {
      await _repository.saveSubscription(updated);
      if (!ref.mounted) return true;
      state = state.copyWith(
        subscription: updated,
        isLoading: false,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Subscription cancellation failed: $e',
      );
      return false;
    }
  }

  /// Purchases a one-time product SKU (e.g. Deep Sea Legends animal pack)
  Future<bool> purchaseProduct(
    String skuId, {
    String source = 'iap',
  }) async {
    final product = ProductSKU.findById(skuId);
    if (product == null) {
      state = state.copyWith(errorMessage: 'Unknown product SKU: $skuId');
      return false;
    }

    // Check if already owned
    if (state.entitlements.any((e) => e.sku == skuId)) {
      return true; // Idempotent success
    }

    final txId = 'tx_${skuId}_${DateTime.now().millisecondsSinceEpoch}';
    final receipt = _receiptService.createSandboxReceipt(
      productId: skuId,
      transactionId: txId,
      store: source,
    );
    final verification = _receiptService.verifyReceipt(receipt);
    if (!verification.isValid) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Receipt validation failed: ${verification.message}',
      );
      return false;
    }

    state = state.copyWith(isLoading: true);
    final newEntitlement = UserEntitlement(
      sku: skuId,
      kind: product.kind,
      source: source,
      grantedAt: DateTime.now(),
    );

    final updatedList = [...state.entitlements, newEntitlement];

    try {
      await _repository.saveEntitlements(updatedList);
      if (!ref.mounted) return true;
      state = state.copyWith(
        entitlements: updatedList,
        isLoading: false,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Purchase failed: $e',
      );
      return false;
    }
  }

  /// Grants an entitlement directly (e.g. via God-Mode / admin portal / promo)
  Future<void> grantEntitlement(
    String skuId,
    EntitlementKind kind, {
    String source = 'admin_override',
  }) async {
    if (state.entitlements.any((e) => e.sku == skuId)) return;

    final ent = UserEntitlement(
      sku: skuId,
      kind: kind,
      source: source,
      grantedAt: DateTime.now(),
    );
    final updated = [...state.entitlements, ent];
    await _repository.saveEntitlements(updated);
    if (!ref.mounted) return;
    state = state.copyWith(entitlements: updated);
  }

  /// Revokes an entitlement directly
  Future<void> revokeEntitlement(String skuId) async {
    final updated = state.entitlements.where((e) => e.sku != skuId).toList();
    await _repository.saveEntitlements(updated);
    if (!ref.mounted) return;
    state = state.copyWith(entitlements: updated);
  }

  /// Restores purchases from repository
  Future<bool> restorePurchases() async {
    state = state.copyWith(isLoading: true);
    await loadState();
    return true;
  }

  /// Clears all monetization state (for testing / account reset)
  Future<void> resetToFree() async {
    await _repository.clearAll();
    final now = DateTime.now();
    if (!ref.mounted) return;
    state = MonetizationState(
      subscription: UserSubscription(
        userId: 'local_user',
        tier: SubscriptionTier.free,
        status: SubscriptionStatus.active,
        startedAt: now,
      ),
      entitlements: const [],
      availableProducts: ProductSKU.catalog,
    );
  }
}
