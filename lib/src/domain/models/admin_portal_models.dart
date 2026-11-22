import 'package:flutter/foundation.dart';
import 'beverage_type.dart';
import 'exotic_animal.dart';

/// Role-based access control (RBAC) tiers for the administrative workspace.
enum UserRole {
  standard,
  pro,
  moderator,
  admin,
  superAdmin;

  bool get canAccessAdmin => this == admin || this == superAdmin;
  bool get canManageUsers => this == admin || this == superAdmin;
  bool get canManageContent =>
      this == moderator || this == admin || this == superAdmin;
  bool get canSwitchEnvironment => this == superAdmin;

  String get displayName {
    switch (this) {
      case standard:
        return 'Standard User';
      case pro:
        return 'AquaWild Pro';
      case moderator:
        return 'Content Moderator';
      case admin:
        return 'System Administrator';
      case superAdmin:
        return 'Super Administrator (Root)';
    }
  }

  static UserRole fromString(String? value) {
    return UserRole.values.firstWhere(
      (e) => e.name.toLowerCase() == (value ?? '').toLowerCase(),
      orElse: () => UserRole.standard,
    );
  }
}

/// Account state of a registered user.
enum UserAccountStatus {
  active,
  suspended,
  pendingVerification;

  String get displayName {
    switch (this) {
      case active:
        return 'Active';
      case suspended:
        return 'Suspended';
      case pendingVerification:
        return 'Pending Verification';
    }
  }

  static UserAccountStatus fromString(String? value) {
    return UserAccountStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == (value ?? '').toLowerCase(),
      orElse: () => UserAccountStatus.active,
    );
  }
}

/// Admin representation of a registered user profile.
@immutable
class AdminUserProfile {
  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final UserAccountStatus status;
  final int currentXp;
  final int streakCount;
  final int freezeTokens;
  final String activeCompanionId;
  final bool isPro;
  final DateTime createdAt;
  final DateTime lastActiveAt;

  const AdminUserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    required this.status,
    required this.currentXp,
    required this.streakCount,
    required this.freezeTokens,
    required this.activeCompanionId,
    required this.isPro,
    required this.createdAt,
    required this.lastActiveAt,
  });

  AdminUserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    UserRole? role,
    UserAccountStatus? status,
    int? currentXp,
    int? streakCount,
    int? freezeTokens,
    String? activeCompanionId,
    bool? isPro,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return AdminUserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      status: status ?? this.status,
      currentXp: currentXp ?? this.currentXp,
      streakCount: streakCount ?? this.streakCount,
      freezeTokens: freezeTokens ?? this.freezeTokens,
      activeCompanionId: activeCompanionId ?? this.activeCompanionId,
      isPro: isPro ?? this.isPro,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'role': role.name,
      'status': status.name,
      'currentXp': currentXp,
      'streakCount': streakCount,
      'freezeTokens': freezeTokens,
      'activeCompanionId': activeCompanionId,
      'isPro': isPro,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
    };
  }

  factory AdminUserProfile.fromMap(Map<String, dynamic> map) {
    return AdminUserProfile(
      id: map['id'] as String? ?? '',
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'User',
      role: UserRole.fromString(map['role'] as String?),
      status: UserAccountStatus.fromString(map['status'] as String?),
      currentXp: (map['currentXp'] as num?)?.toInt() ?? 0,
      streakCount: (map['streakCount'] as num?)?.toInt() ?? 0,
      freezeTokens: (map['freezeTokens'] as num?)?.toInt() ?? 0,
      activeCompanionId: map['activeCompanionId'] as String? ?? 'red_panda',
      isPro: map['isPro'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      lastActiveAt: map['lastActiveAt'] != null
          ? DateTime.tryParse(map['lastActiveAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Default mock directory seed for development and admin portal inspection.
  static List<AdminUserProfile> get defaultSeedUsers => [
        AdminUserProfile(
          id: 'usr_daya_01',
          email: 'daya@aquawild.internal',
          displayName: 'Daya (System Architect)',
          role: UserRole.superAdmin,
          status: UserAccountStatus.active,
          currentXp: 15400,
          streakCount: 42,
          freezeTokens: 5,
          activeCompanionId: 'red_panda',
          isPro: true,
          createdAt: DateTime(2026, 1, 15),
          lastActiveAt: DateTime.now(),
        ),
        AdminUserProfile(
          id: 'usr_alex_02',
          email: 'alex.rivera@example.com',
          displayName: 'Alex Rivera',
          role: UserRole.pro,
          status: UserAccountStatus.active,
          currentXp: 4800,
          streakCount: 14,
          freezeTokens: 2,
          activeCompanionId: 'capybara',
          isPro: true,
          createdAt: DateTime(2026, 2, 1),
          lastActiveAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        AdminUserProfile(
          id: 'usr_sam_03',
          email: 'sam.ocean@watermail.org',
          displayName: 'Samira Ocean',
          role: UserRole.standard,
          status: UserAccountStatus.active,
          currentXp: 1200,
          streakCount: 5,
          freezeTokens: 1,
          activeCompanionId: 'axolotl',
          isPro: false,
          createdAt: DateTime(2026, 2, 10),
          lastActiveAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        AdminUserProfile(
          id: 'usr_test_04',
          email: 'qa.lead@aquawild.test',
          displayName: 'QA Automation Lead',
          role: UserRole.moderator,
          status: UserAccountStatus.active,
          currentXp: 9500,
          streakCount: 28,
          freezeTokens: 4,
          activeCompanionId: 'sea_otter',
          isPro: true,
          createdAt: DateTime(2026, 1, 20),
          lastActiveAt: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        AdminUserProfile(
          id: 'usr_bot_05',
          email: 'flagged.spammer@tempmail.ninja',
          displayName: 'Suspended Account 05',
          role: UserRole.standard,
          status: UserAccountStatus.suspended,
          currentXp: 40,
          streakCount: 0,
          freezeTokens: 0,
          activeCompanionId: 'red_panda',
          isPro: false,
          createdAt: DateTime(2026, 2, 18),
          lastActiveAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];
}

/// God-Mode configuration providing developer/operator master overrides.
@immutable
class AdminGodModeConfig {
  final bool isGodModeEnabled;
  final bool unlockAllCompanions;
  final bool unlockAllBiomes;
  final bool unlockAllThemes;
  final bool forceProStatus;
  final bool infiniteStreakFreezes;
  final bool maxEvolutionStages;

  const AdminGodModeConfig({
    this.isGodModeEnabled = false,
    this.unlockAllCompanions = false,
    this.unlockAllBiomes = false,
    this.unlockAllThemes = false,
    this.forceProStatus = false,
    this.infiniteStreakFreezes = false,
    this.maxEvolutionStages = false,
  });

  /// Preset where God Mode is completely disabled (production client mode).
  static const standard = AdminGodModeConfig(
    isGodModeEnabled: false,
    unlockAllCompanions: false,
    unlockAllBiomes: false,
    unlockAllThemes: false,
    forceProStatus: false,
    infiniteStreakFreezes: false,
    maxEvolutionStages: false,
  );

  /// Preset where all features, companions, and entitlements are instantly granted.
  static const fullUnlocked = AdminGodModeConfig(
    isGodModeEnabled: true,
    unlockAllCompanions: true,
    unlockAllBiomes: true,
    unlockAllThemes: true,
    forceProStatus: true,
    infiniteStreakFreezes: true,
    maxEvolutionStages: true,
  );

  AdminGodModeConfig copyWith({
    bool? isGodModeEnabled,
    bool? unlockAllCompanions,
    bool? unlockAllBiomes,
    bool? unlockAllThemes,
    bool? forceProStatus,
    bool? infiniteStreakFreezes,
    bool? maxEvolutionStages,
  }) {
    return AdminGodModeConfig(
      isGodModeEnabled: isGodModeEnabled ?? this.isGodModeEnabled,
      unlockAllCompanions: unlockAllCompanions ?? this.unlockAllCompanions,
      unlockAllBiomes: unlockAllBiomes ?? this.unlockAllBiomes,
      unlockAllThemes: unlockAllThemes ?? this.unlockAllThemes,
      forceProStatus: forceProStatus ?? this.forceProStatus,
      infiniteStreakFreezes:
          infiniteStreakFreezes ?? this.infiniteStreakFreezes,
      maxEvolutionStages: maxEvolutionStages ?? this.maxEvolutionStages,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isGodModeEnabled': isGodModeEnabled,
      'unlockAllCompanions': unlockAllCompanions,
      'unlockAllBiomes': unlockAllBiomes,
      'unlockAllThemes': unlockAllThemes,
      'forceProStatus': forceProStatus,
      'infiniteStreakFreezes': infiniteStreakFreezes,
      'maxEvolutionStages': maxEvolutionStages,
    };
  }

  factory AdminGodModeConfig.fromMap(Map<String, dynamic> map) {
    return AdminGodModeConfig(
      isGodModeEnabled: map['isGodModeEnabled'] as bool? ?? false,
      unlockAllCompanions: map['unlockAllCompanions'] as bool? ?? false,
      unlockAllBiomes: map['unlockAllBiomes'] as bool? ?? false,
      unlockAllThemes: map['unlockAllThemes'] as bool? ?? false,
      forceProStatus: map['forceProStatus'] as bool? ?? false,
      infiniteStreakFreezes: map['infiniteStreakFreezes'] as bool? ?? false,
      maxEvolutionStages: map['maxEvolutionStages'] as bool? ?? false,
    );
  }
}

/// Catalog entry for beverages editable in the Admin Portal.
@immutable
class AdminBeverageItem {
  final String id;
  final String name;
  final String category;
  final double hydrationIndex;
  final double caffeineMgPer100Ml;
  final double electrolytesMgPer100Ml;
  final double sugarGramsPer100Ml;
  final double density;
  final double viscosity;
  final String colorHex;
  final bool isCustom;
  final bool isEnabled;

  const AdminBeverageItem({
    required this.id,
    required this.name,
    required this.category,
    required this.hydrationIndex,
    required this.caffeineMgPer100Ml,
    required this.electrolytesMgPer100Ml,
    required this.sugarGramsPer100Ml,
    required this.density,
    required this.viscosity,
    required this.colorHex,
    this.isCustom = false,
    this.isEnabled = true,
  });

  AdminBeverageItem copyWith({
    String? id,
    String? name,
    String? category,
    double? hydrationIndex,
    double? caffeineMgPer100Ml,
    double? electrolytesMgPer100Ml,
    double? sugarGramsPer100Ml,
    double? density,
    double? viscosity,
    String? colorHex,
    bool? isCustom,
    bool? isEnabled,
  }) {
    return AdminBeverageItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      hydrationIndex: hydrationIndex ?? this.hydrationIndex,
      caffeineMgPer100Ml: caffeineMgPer100Ml ?? this.caffeineMgPer100Ml,
      electrolytesMgPer100Ml:
          electrolytesMgPer100Ml ?? this.electrolytesMgPer100Ml,
      sugarGramsPer100Ml: sugarGramsPer100Ml ?? this.sugarGramsPer100Ml,
      density: density ?? this.density,
      viscosity: viscosity ?? this.viscosity,
      colorHex: colorHex ?? this.colorHex,
      isCustom: isCustom ?? this.isCustom,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'hydrationIndex': hydrationIndex,
      'caffeineMgPer100Ml': caffeineMgPer100Ml,
      'electrolytesMgPer100Ml': electrolytesMgPer100Ml,
      'sugarGramsPer100Ml': sugarGramsPer100Ml,
      'density': density,
      'viscosity': viscosity,
      'colorHex': colorHex,
      'isCustom': isCustom,
      'isEnabled': isEnabled,
    };
  }

  factory AdminBeverageItem.fromMap(Map<String, dynamic> map) {
    return AdminBeverageItem(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Beverage',
      category: map['category'] as String? ?? 'water',
      hydrationIndex: (map['hydrationIndex'] as num?)?.toDouble() ?? 1.0,
      caffeineMgPer100Ml:
          (map['caffeineMgPer100Ml'] as num?)?.toDouble() ?? 0.0,
      electrolytesMgPer100Ml:
          (map['electrolytesMgPer100Ml'] as num?)?.toDouble() ?? 0.0,
      sugarGramsPer100Ml:
          (map['sugarGramsPer100Ml'] as num?)?.toDouble() ?? 0.0,
      density: (map['density'] as num?)?.toDouble() ?? 1.0,
      viscosity: (map['viscosity'] as num?)?.toDouble() ?? 1.0,
      colorHex: map['colorHex'] as String? ?? '#00D4FF',
      isCustom: map['isCustom'] as bool? ?? false,
      isEnabled: map['isEnabled'] as bool? ?? true,
    );
  }

  /// Initial catalog populated from real AquaWild default beverages.
  static List<AdminBeverageItem> get defaultCatalog {
    return BeverageType.defaultBeverages.map((bev) {
      final hex =
          '#${bev.primaryColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
      return AdminBeverageItem(
        id: bev.id,
        name: bev.name,
        category: bev.category.name,
        hydrationIndex: bev.hydrationIndex,
        caffeineMgPer100Ml: bev.caffeineMgPer100ml,
        electrolytesMgPer100Ml: bev.electrolytesMgPer100ml,
        sugarGramsPer100Ml: bev.sugarGramsPer100ml,
        density: bev.density,
        viscosity: bev.viscosity,
        colorHex: hex,
        isCustom: false,
        isEnabled: true,
      );
    }).toList();
  }
}

/// Catalog entry for animal companions editable in the Admin Portal.
@immutable
class AdminAnimalItem {
  final String id;
  final String name;
  final String species;
  final int unlockXp;
  final String biomeId;
  final String tier;
  final bool isPremiumOnly;
  final bool isEnabled;

  const AdminAnimalItem({
    required this.id,
    required this.name,
    required this.species,
    required this.unlockXp,
    required this.biomeId,
    required this.tier,
    this.isPremiumOnly = false,
    this.isEnabled = true,
  });

  AdminAnimalItem copyWith({
    String? id,
    String? name,
    String? species,
    int? unlockXp,
    String? biomeId,
    String? tier,
    bool? isPremiumOnly,
    bool? isEnabled,
  }) {
    return AdminAnimalItem(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      unlockXp: unlockXp ?? this.unlockXp,
      biomeId: biomeId ?? this.biomeId,
      tier: tier ?? this.tier,
      isPremiumOnly: isPremiumOnly ?? this.isPremiumOnly,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'unlockXp': unlockXp,
      'biomeId': biomeId,
      'tier': tier,
      'isPremiumOnly': isPremiumOnly,
      'isEnabled': isEnabled,
    };
  }

  factory AdminAnimalItem.fromMap(Map<String, dynamic> map) {
    return AdminAnimalItem(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Animal',
      species: map['species'] as String? ?? 'Companion',
      unlockXp: (map['unlockXp'] as num?)?.toInt() ?? 0,
      biomeId: map['biomeId'] as String? ?? 'bamboo_misty_springs',
      tier: map['tier'] as String? ?? 'Starter',
      isPremiumOnly: map['isPremiumOnly'] as bool? ?? false,
      isEnabled: map['isEnabled'] as bool? ?? true,
    );
  }

  /// Initial catalog populated from all 10 real AquaWild companions.
  static List<AdminAnimalItem> get defaultCatalog {
    return ExoticAnimal.allAnimals.map((animal) {
      final isPremium = animal.unlockXp > 2000;
      final tier = animal.unlockXp == 0
          ? 'Starter'
          : animal.unlockXp <= 2000
              ? 'Midland Explorer'
              : 'Apex Legend';
      return AdminAnimalItem(
        id: animal.id,
        name: animal.name,
        species: animal.species,
        unlockXp: animal.unlockXp,
        biomeId: animal.habitatBiomeId,
        tier: tier,
        isPremiumOnly: isPremium,
        isEnabled: true,
      );
    }).toList();
  }
}

/// Category grouping for dynamic feature flags.
enum FeatureFlagCategory {
  core,
  experimental,
  monetization,
  ui,
  ai;

  String get displayName {
    switch (this) {
      case core:
        return 'Core Engine';
      case experimental:
        return 'Experimental Labs';
      case monetization:
        return 'Monetization & Store';
      case ui:
        return 'UI & Visuals';
      case ai:
        return 'AI & Intelligence';
    }
  }
}

/// Dynamic runtime feature flag toggle.
@immutable
class AdminFeatureFlag {
  final String key;
  final String title;
  final String description;
  final bool isEnabled;
  final FeatureFlagCategory category;
  final bool defaultValue;

  const AdminFeatureFlag({
    required this.key,
    required this.title,
    required this.description,
    required this.isEnabled,
    required this.category,
    required this.defaultValue,
  });

  AdminFeatureFlag copyWith({
    String? key,
    String? title,
    String? description,
    bool? isEnabled,
    FeatureFlagCategory? category,
    bool? defaultValue,
  }) {
    return AdminFeatureFlag(
      key: key ?? this.key,
      title: title ?? this.title,
      description: description ?? this.description,
      isEnabled: isEnabled ?? this.isEnabled,
      category: category ?? this.category,
      defaultValue: defaultValue ?? this.defaultValue,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'title': title,
      'description': description,
      'isEnabled': isEnabled,
      'category': category.name,
      'defaultValue': defaultValue,
    };
  }

  factory AdminFeatureFlag.fromMap(Map<String, dynamic> map) {
    return AdminFeatureFlag(
      key: map['key'] as String? ?? '',
      title: map['title'] as String? ?? 'Flag',
      description: map['description'] as String? ?? '',
      isEnabled: map['isEnabled'] as bool? ?? false,
      category: FeatureFlagCategory.values.firstWhere(
        (c) => c.name.toLowerCase() == (map['category'] as String? ?? '').toLowerCase(),
        orElse: () => FeatureFlagCategory.core,
      ),
      defaultValue: map['defaultValue'] as bool? ?? false,
    );
  }

  static List<AdminFeatureFlag> get defaultFlags => const [
        AdminFeatureFlag(
          key: 'enable_high_precision_waves',
          title: 'High-Precision Wave Physics',
          description:
              'Renders 64-column coupled shallow-water wave physics with zero-gap interfacial meniscus lines.',
          isEnabled: true,
          category: FeatureFlagCategory.core,
          defaultValue: true,
        ),
        AdminFeatureFlag(
          key: 'enable_ai_coach_v2',
          title: 'AI Hydration Coach v2',
          description:
              'Dynamic circadian and environmental prompt engine with automatic reactive synchronization.',
          isEnabled: true,
          category: FeatureFlagCategory.ai,
          defaultValue: true,
        ),
        AdminFeatureFlag(
          key: 'enable_native_widgets_v2',
          title: 'Native Home/Lock Screen Widgets',
          description:
              'Broadcasts telemetry snapshots to Android Glance and iOS WidgetKit live activity bridges.',
          isEnabled: true,
          category: FeatureFlagCategory.core,
          defaultValue: true,
        ),
        AdminFeatureFlag(
          key: 'enable_ambient_caustic_audio',
          title: 'Hydro-Acoustic Spatial Audio',
          description:
              'Plays synthesized relaxing water caustics and fluid pour audio feedback.',
          isEnabled: true,
          category: FeatureFlagCategory.ui,
          defaultValue: true,
        ),
        AdminFeatureFlag(
          key: 'enable_storefront_discounts',
          title: 'Dynamic Storefront Promotions',
          description:
              'Enables seasonal banner discounts and promotional trial pricing in Storefront Modal.',
          isEnabled: true,
          category: FeatureFlagCategory.monetization,
          defaultValue: true,
        ),
        AdminFeatureFlag(
          key: 'enable_ar_companion_preview',
          title: 'AR Companion Preview (Labs)',
          description:
              'Renders animated 3D/AR companion models in real-world spatial environments.',
          isEnabled: false,
          category: FeatureFlagCategory.experimental,
          defaultValue: false,
        ),
        AdminFeatureFlag(
          key: 'enable_social_habit_circles',
          title: 'Social Hydration Circles (Labs)',
          description:
              'Allows opt-in peer hydration tracking and collective sanctuary reforestation goals.',
          isEnabled: false,
          category: FeatureFlagCategory.experimental,
          defaultValue: false,
        ),
      ];
}

/// Target backend deployment environment.
enum AppEnvironment {
  development,
  staging,
  production;

  String get displayName {
    switch (this) {
      case development:
        return 'Development (Local Sandbox)';
      case staging:
        return 'Staging (QA Preview)';
      case production:
        return 'Production (Global CDN)';
    }
  }

  String get badgeColorHex {
    switch (this) {
      case development:
        return '#00E5FF'; // Cyan
      case staging:
        return '#FFD600'; // Amber
      case production:
        return '#00E676'; // Emerald
    }
  }

  static AppEnvironment fromString(String? value) {
    return AppEnvironment.values.firstWhere(
      (e) => e.name.toLowerCase() == (value ?? '').toLowerCase(),
      orElse: () => AppEnvironment.development,
    );
  }
}

/// Environment configuration detailing API endpoints, security keys, and mock state.
@immutable
class AdminEnvironmentConfig {
  final AppEnvironment environment;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final bool isMockMode;
  final int apiTimeoutSeconds;

  const AdminEnvironmentConfig({
    required this.environment,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    this.isMockMode = true,
    this.apiTimeoutSeconds = 10,
  });

  AdminEnvironmentConfig copyWith({
    AppEnvironment? environment,
    String? supabaseUrl,
    String? supabaseAnonKey,
    bool? isMockMode,
    int? apiTimeoutSeconds,
  }) {
    return AdminEnvironmentConfig(
      environment: environment ?? this.environment,
      supabaseUrl: supabaseUrl ?? this.supabaseUrl,
      supabaseAnonKey: supabaseAnonKey ?? this.supabaseAnonKey,
      isMockMode: isMockMode ?? this.isMockMode,
      apiTimeoutSeconds: apiTimeoutSeconds ?? this.apiTimeoutSeconds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'environment': environment.name,
      'supabaseUrl': supabaseUrl,
      'supabaseAnonKey': supabaseAnonKey,
      'isMockMode': isMockMode,
      'apiTimeoutSeconds': apiTimeoutSeconds,
    };
  }

  factory AdminEnvironmentConfig.fromMap(Map<String, dynamic> map) {
    return AdminEnvironmentConfig(
      environment: AppEnvironment.fromString(map['environment'] as String?),
      supabaseUrl: map['supabaseUrl'] as String? ?? 'http://127.0.0.1:54321',
      supabaseAnonKey: map['supabaseAnonKey'] as String? ?? 'mock-anon-key',
      isMockMode: map['isMockMode'] as bool? ?? true,
      apiTimeoutSeconds: (map['apiTimeoutSeconds'] as num?)?.toInt() ?? 10,
    );
  }

  /// Preset configurations for each environment tier.
  static AdminEnvironmentConfig presetFor(AppEnvironment env) {
    switch (env) {
      case AppEnvironment.development:
        return const AdminEnvironmentConfig(
          environment: AppEnvironment.development,
          supabaseUrl: 'http://127.0.0.1:54321',
          supabaseAnonKey: 'mock_local_dev_key_aquawild',
          isMockMode: true,
          apiTimeoutSeconds: 5,
        );
      case AppEnvironment.staging:
        return const AdminEnvironmentConfig(
          environment: AppEnvironment.staging,
          supabaseUrl: 'https://staging-db.aquawild.app',
          supabaseAnonKey: 'sb_staging_anon_sample_key',
          isMockMode: false,
          apiTimeoutSeconds: 15,
        );
      case AppEnvironment.production:
        return const AdminEnvironmentConfig(
          environment: AppEnvironment.production,
          supabaseUrl: 'https://api.aquawild.app',
          supabaseAnonKey: 'sb_production_anon_sample_key',
          isMockMode: false,
          apiTimeoutSeconds: 20,
        );
    }
  }
}
