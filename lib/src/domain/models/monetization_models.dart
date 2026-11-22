/// Subscription tiers supported by AquaWild
enum SubscriptionTier {
  free,
  proMonthly,
  proAnnual,
  proLifetime;

  String get id {
    switch (this) {
      case SubscriptionTier.free:
        return 'free';
      case SubscriptionTier.proMonthly:
        return 'aquawild_pro_monthly';
      case SubscriptionTier.proAnnual:
        return 'aquawild_pro_annual';
      case SubscriptionTier.proLifetime:
        return 'aquawild_pro_lifetime';
    }
  }

  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free Explorer';
      case SubscriptionTier.proMonthly:
        return 'AquaWild Pro (Monthly)';
      case SubscriptionTier.proAnnual:
        return 'AquaWild Pro (Annual)';
      case SubscriptionTier.proLifetime:
        return 'AquaWild Pro (Lifetime)';
    }
  }

  bool get isPro => this != SubscriptionTier.free;

  static SubscriptionTier fromId(String? id) {
    switch (id) {
      case 'aquawild_pro_monthly':
      case 'pro_monthly':
        return SubscriptionTier.proMonthly;
      case 'aquawild_pro_annual':
      case 'pro_annual':
        return SubscriptionTier.proAnnual;
      case 'aquawild_pro_lifetime':
      case 'pro_lifetime':
        return SubscriptionTier.proLifetime;
      default:
        return SubscriptionTier.free;
    }
  }
}

/// Lifecycle status of a subscription
enum SubscriptionStatus {
  active,
  gracePeriod,
  expired,
  cancelled;

  bool get hasAccess =>
      this == SubscriptionStatus.active ||
      this == SubscriptionStatus.gracePeriod;

  static SubscriptionStatus fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'active':
        return SubscriptionStatus.active;
      case 'grace_period':
      case 'graceperiod':
        return SubscriptionStatus.gracePeriod;
      case 'cancelled':
      case 'canceled':
        return SubscriptionStatus.cancelled;
      default:
        return SubscriptionStatus.expired;
    }
  }
}

/// User's active subscription record
class UserSubscription {
  final String userId;
  final SubscriptionTier tier;
  final SubscriptionStatus status;
  final String store; // 'apple_app_store', 'google_play', 'stripe', 'sandbox'
  final String? originalTransactionId;
  final DateTime startedAt;
  final DateTime? expiresAt;
  final bool autoRenew;

  const UserSubscription({
    required this.userId,
    this.tier = SubscriptionTier.free,
    this.status = SubscriptionStatus.active,
    this.store = 'sandbox',
    this.originalTransactionId,
    required this.startedAt,
    this.expiresAt,
    this.autoRenew = true,
  });

  bool get isPro => tier.isPro && status.hasAccess;

  int? get daysRemaining {
    if (expiresAt == null) return null;
    final diff = expiresAt!.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  UserSubscription copyWith({
    String? userId,
    SubscriptionTier? tier,
    SubscriptionStatus? status,
    String? store,
    String? originalTransactionId,
    DateTime? startedAt,
    DateTime? expiresAt,
    bool? autoRenew,
  }) {
    return UserSubscription(
      userId: userId ?? this.userId,
      tier: tier ?? this.tier,
      status: status ?? this.status,
      store: store ?? this.store,
      originalTransactionId:
          originalTransactionId ?? this.originalTransactionId,
      startedAt: startedAt ?? this.startedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      autoRenew: autoRenew ?? this.autoRenew,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'tier': tier.id,
        'status': status.name,
        'store': store,
        'original_transaction_id': originalTransactionId,
        'started_at': startedAt.toIso8601String(),
        'expires_at': expiresAt?.toIso8601String(),
        'auto_renew': autoRenew,
      };

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      userId: json['user_id'] as String? ?? '',
      tier: SubscriptionTier.fromId(json['tier'] as String?),
      status: SubscriptionStatus.fromString(json['status'] as String?),
      store: json['store'] as String? ?? 'sandbox',
      originalTransactionId: json['original_transaction_id'] as String?,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : DateTime.now(),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      autoRenew: json['auto_renew'] as bool? ?? true,
    );
  }
}

/// Category of unlockable one-time entitlement
enum EntitlementKind {
  animalPack,
  themePack,
  animationPack,
  seasonalPass;

  static EntitlementKind fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'animal_pack':
      case 'animalpack':
        return EntitlementKind.animalPack;
      case 'theme_pack':
      case 'themepack':
        return EntitlementKind.themePack;
      case 'animation_pack':
      case 'animationpack':
        return EntitlementKind.animationPack;
      case 'seasonal_pass':
      case 'seasonalpass':
        return EntitlementKind.seasonalPass;
      default:
        return EntitlementKind.animalPack;
    }
  }
}

/// User's one-time entitlement record (e.g. purchased animal pack)
class UserEntitlement {
  final String sku;
  final EntitlementKind kind;
  final String source; // 'iap', 'admin_override', 'promo_code'
  final DateTime grantedAt;

  const UserEntitlement({
    required this.sku,
    required this.kind,
    this.source = 'iap',
    required this.grantedAt,
  });

  Map<String, dynamic> toJson() => {
        'sku': sku,
        'kind': kind.name,
        'source': source,
        'granted_at': grantedAt.toIso8601String(),
      };

  factory UserEntitlement.fromJson(Map<String, dynamic> json) {
    return UserEntitlement(
      sku: json['sku'] as String? ?? '',
      kind: EntitlementKind.fromString(json['kind'] as String?),
      source: json['source'] as String? ?? 'iap',
      grantedAt: json['granted_at'] != null
          ? DateTime.parse(json['granted_at'] as String)
          : DateTime.now(),
    );
  }
}

/// Commercial Store Product SKU catalog definition
class ProductSKU {
  final String id;
  final String title;
  final String description;
  final String priceFormatted;
  final int priceCents;
  final EntitlementKind kind;
  final List<String> unlockedAnimalIds;
  final List<String> unlockedThemeIds;
  final String badgeText;

  const ProductSKU({
    required this.id,
    required this.title,
    required this.description,
    required this.priceFormatted,
    required this.priceCents,
    required this.kind,
    this.unlockedAnimalIds = const [],
    this.unlockedThemeIds = const [],
    this.badgeText = '',
  });

  /// Standard catalog of AquaWild IAPs and Unlock Packs
  static const List<ProductSKU> catalog = [
    ProductSKU(
      id: 'pack_deep_sea',
      title: 'Deep Sea Legends Pack',
      description:
          'Instantly unlock Ollie the Sea Otter, Echo the Dolphin, and Octavia the Blue-Ringed Octopus with exclusive underwater caustics.',
      priceFormatted: '\$4.99',
      priceCents: 499,
      kind: EntitlementKind.animalPack,
      unlockedAnimalIds: ['sea_otter', 'bottlenose_dolphin', 'blue_ringed_octopus'],
      badgeText: '3 Companions',
    ),
    ProductSKU(
      id: 'pack_alpine_glacier',
      title: 'Alpine Glacier Expedition Pack',
      description:
          'Unlock Luna the Llama, Freya the Arctic Fox, Percy the Penguin, and Kira the Snow Leopard.',
      priceFormatted: '\$6.99',
      priceCents: 699,
      kind: EntitlementKind.animalPack,
      unlockedAnimalIds: [
        'andean_llama',
        'arctic_fox',
        'emperor_penguin',
        'snow_leopard'
      ],
      badgeText: '4 Companions',
    ),
    ProductSKU(
      id: 'pack_neon_bioluminescence',
      title: 'Neon Bioluminescence FX Pack',
      description:
          'Electrifying neon caustics, glowing plankton spore trails, and shimmering fluid wave shaders.',
      priceFormatted: '\$2.99',
      priceCents: 299,
      kind: EntitlementKind.animationPack,
      unlockedThemeIds: ['neon_bioluminescence'],
      badgeText: 'FX Shader',
    ),
    ProductSKU(
      id: 'pack_minimal_zen',
      title: 'Minimal Zen Theme Pack',
      description:
          'Warm organic bamboo, natural sand, stone caustics, and onsen thermal vapor aesthetics.',
      priceFormatted: '\$2.99',
      priceCents: 299,
      kind: EntitlementKind.themePack,
      unlockedThemeIds: ['minimal_zen'],
      badgeText: 'Zen Theme',
    ),
    ProductSKU(
      id: 'pack_cyber_ocean',
      title: 'Cyber Ocean Synthwave Pack',
      description:
          'Synthwave oceanic deep tones, electric violet caustics, and cyber aqua glow.',
      priceFormatted: '\$2.99',
      priceCents: 299,
      kind: EntitlementKind.themePack,
      unlockedThemeIds: ['cyber_ocean'],
      badgeText: 'Cyber Theme',
    ),
    ProductSKU(
      id: 'pass_summer_splash',
      title: 'Summer Splash Expedition Pass',
      description:
          'Exclusive seasonal quests, double XP boosts, golden yuzu floating bath companions, and limited-edition badges.',
      priceFormatted: '\$7.99',
      priceCents: 799,
      kind: EntitlementKind.seasonalPass,
      badgeText: 'Seasonal Pass',
    ),
  ];

  static ProductSKU? findById(String skuId) {
    try {
      return catalog.firstWhere((p) => p.id == skuId);
    } catch (_) {
      return null;
    }
  }
}
