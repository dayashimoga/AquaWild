import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/admin_audit_log_service.dart';
import '../../core/services/admin_broadcast_service.dart';
import '../../core/services/admin_monetization_analytics_service.dart';
import '../../domain/models/admin_analytics_models.dart';
import '../../domain/models/admin_audit_models.dart';
import '../../domain/models/admin_broadcast_models.dart';
import '../../domain/models/admin_portal_models.dart';
import '../../domain/models/monetization_models.dart';
import 'animal_habitat_controller.dart';
import 'monetization_controller.dart';

/// State of the AquaWild Administrative Command Center.
class AdminPortalState {
  final AdminGodModeConfig godMode;
  final List<AdminUserProfile> users;
  final String searchQuery;
  final String? selectedUserId;
  final List<AdminBeverageItem> beverages;
  final List<AdminAnimalItem> animals;
  final List<AdminFeatureFlag> featureFlags;
  final AdminEnvironmentConfig environmentConfig;
  final List<AdminAuditEntry> auditEntries;
  final MonetizationKpiSummary kpiSummary;
  final List<AdminBroadcastMessage> broadcasts;
  final bool isAuditChainValid;
  final bool isLoading;
  final String? statusMessage;
  final String? errorMessage;

  const AdminPortalState({
    required this.godMode,
    required this.users,
    this.searchQuery = '',
    this.selectedUserId,
    required this.beverages,
    required this.animals,
    required this.featureFlags,
    required this.environmentConfig,
    this.auditEntries = const [],
    required this.kpiSummary,
    this.broadcasts = const [],
    this.isAuditChainValid = true,
    this.isLoading = false,
    this.statusMessage,
    this.errorMessage,
  });

  /// The currently selected user profile, if any.
  AdminUserProfile? get selectedUser {
    if (selectedUserId == null) return null;
    return users.where((u) => u.id == selectedUserId).firstOrNull;
  }

  /// List of users matching the active search query (by display name, email, or id).
  List<AdminUserProfile> get filteredUsers {
    if (searchQuery.trim().isEmpty) return users;
    final query = searchQuery.trim().toLowerCase();
    return users.where((u) {
      return u.displayName.toLowerCase().contains(query) ||
          u.email.toLowerCase().contains(query) ||
          u.id.toLowerCase().contains(query);
    }).toList();
  }

  /// Subset of active enabled beverages.
  List<AdminBeverageItem> get enabledBeverages =>
      beverages.where((b) => b.isEnabled).toList();

  /// Subset of active enabled animal companions.
  List<AdminAnimalItem> get enabledAnimals =>
      animals.where((a) => a.isEnabled).toList();

  /// Checks if a feature flag is currently active.
  bool isFeatureEnabled(String flagKey) {
    final flag = featureFlags.where((f) => f.key == flagKey).firstOrNull;
    return flag?.isEnabled ?? false;
  }

  AdminPortalState copyWith({
    AdminGodModeConfig? godMode,
    List<AdminUserProfile>? users,
    String? searchQuery,
    String? selectedUserId,
    bool clearSelectedUser = false,
    List<AdminBeverageItem>? beverages,
    List<AdminAnimalItem>? animals,
    List<AdminFeatureFlag>? featureFlags,
    AdminEnvironmentConfig? environmentConfig,
    List<AdminAuditEntry>? auditEntries,
    MonetizationKpiSummary? kpiSummary,
    List<AdminBroadcastMessage>? broadcasts,
    bool? isAuditChainValid,
    bool? isLoading,
    String? statusMessage,
    String? errorMessage,
    bool clearStatusMessage = false,
    bool clearErrorMessage = false,
  }) {
    return AdminPortalState(
      godMode: godMode ?? this.godMode,
      users: users ?? this.users,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedUserId: clearSelectedUser
          ? null
          : (selectedUserId ?? this.selectedUserId),
      beverages: beverages ?? this.beverages,
      animals: animals ?? this.animals,
      featureFlags: featureFlags ?? this.featureFlags,
      environmentConfig: environmentConfig ?? this.environmentConfig,
      auditEntries: auditEntries ?? this.auditEntries,
      kpiSummary: kpiSummary ?? this.kpiSummary,
      broadcasts: broadcasts ?? this.broadcasts,
      isAuditChainValid: isAuditChainValid ?? this.isAuditChainValid,
      isLoading: isLoading ?? this.isLoading,
      statusMessage: clearStatusMessage
          ? null
          : (statusMessage ?? this.statusMessage),
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Riverpod 3 Notifier managing the administrative state, God-Mode overrides,
/// user directory, content catalogs, dynamic feature flags, audit logs, and notification campaigns.
class AdminPortalNotifier extends Notifier<AdminPortalState> {
  late final AdminAuditLogService _auditService;
  late final AdminMonetizationTelemetryService _telemetryService;
  late final AdminNotificationBroadcastService _broadcastService;

  @override
  AdminPortalState build() {
    _auditService = ref.read(adminAuditLogServiceProvider);
    _telemetryService = ref.read(adminMonetizationTelemetryServiceProvider);
    _broadcastService = ref.read(adminNotificationBroadcastServiceProvider);

    final seedUsers = AdminUserProfile.defaultSeedUsers;
    final kpis = _telemetryService.calculateKpis(
      users: seedUsers,
      products: ProductSKU.catalog,
      activeLocalSubscription: ref.read(monetizationProvider).subscription,
    );

    return AdminPortalState(
      godMode: AdminGodModeConfig.standard,
      users: seedUsers,
      beverages: AdminBeverageItem.defaultCatalog,
      animals: AdminAnimalItem.defaultCatalog,
      featureFlags: AdminFeatureFlag.defaultFlags,
      environmentConfig:
          AdminEnvironmentConfig.presetFor(AppEnvironment.development),
      auditEntries: _auditService.getEntries(),
      kpiSummary: kpis,
      broadcasts: _broadcastService.getBroadcasts(),
      isAuditChainValid: true,
    );
  }

  /// Toggles master God-Mode override.
  /// When activated, all animals, biomes, themes, and Pro features are unlocked instantly.
  Future<void> toggleGodMode(bool enable) async {
    state = state.copyWith(isLoading: true);

    if (enable) {
      const unlockedConfig = AdminGodModeConfig.fullUnlocked;

      // 1. Upgrade monetization to Pro Lifetime
      await ref.read(monetizationProvider.notifier).subscribe(
            SubscriptionTier.proLifetime,
            store: 'admin_override',
          );

      // 2. Grant all IAP product pack entitlements
      for (final product in ProductSKU.catalog) {
        await ref.read(monetizationProvider.notifier).grantEntitlement(
              product.id,
              product.kind,
              source: 'admin_override',
            );
      }

      // 3. Grant generous XP to unlock all evolution stages
      await ref.read(animalHabitatProvider.notifier).addXp(25000);

      // 4. Log cryptographic audit trail entry
      await _auditService.recordAction(
        operatorId: 'operator_root',
        operatorEmail: 'daya@aquawild.internal',
        actionType: AdminActionType.godModeToggled,
        targetEntityId: 'system_god_mode',
        description: 'Master God-Mode enabled: All features, animals, biomes and Pro unlocked',
        previousValue: 'disabled',
        newValue: 'enabled',
      );

      if (!ref.mounted) return;
      state = state.copyWith(
        godMode: unlockedConfig,
        auditEntries: _auditService.getEntries(),
        isLoading: false,
        statusMessage:
            '⚡ God Mode Activated: All 10 companions, biomes, themes & Pro lifetime privileges granted.',
        clearErrorMessage: true,
      );
    } else {
      // Revert monetization to standard Free tier
      await ref.read(monetizationProvider.notifier).resetToFree();

      // Log cryptographic audit trail entry
      await _auditService.recordAction(
        operatorId: 'operator_root',
        operatorEmail: 'daya@aquawild.internal',
        actionType: AdminActionType.godModeToggled,
        targetEntityId: 'system_god_mode',
        description: 'Master God-Mode disabled: Reverted to standard client permissions',
        previousValue: 'enabled',
        newValue: 'disabled',
      );

      if (!ref.mounted) return;
      state = state.copyWith(
        godMode: AdminGodModeConfig.standard,
        auditEntries: _auditService.getEntries(),
        isLoading: false,
        statusMessage:
            '🔒 God Mode Deactivated: Reverted to standard client permissions.',
        clearErrorMessage: true,
      );
    }

    _refreshKpis();
  }

  /// Fine-grained God-Mode configuration updates.
  void updateGodModeConfig(AdminGodModeConfig config) {
    state = state.copyWith(
      godMode: config,
      statusMessage: 'God-Mode overrides updated.',
      clearErrorMessage: true,
    );
  }

  /// Updates live search query for filtering users.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Selects a user profile for inspection and management.
  void selectUser(String? userId) {
    if (userId == null) {
      state = state.copyWith(clearSelectedUser: true);
    } else {
      state = state.copyWith(selectedUserId: userId);
    }
  }

  /// Adjusts a user's hydration XP in the directory.
  Future<void> updateUserXp(String userId, int newXp) async {
    int prevXp = 0;
    final updatedUsers = state.users.map((u) {
      if (u.id == userId) {
        prevXp = u.currentXp;
        return u.copyWith(currentXp: newXp.clamp(0, 1000000));
      }
      return u;
    }).toList();

    await _auditService.recordAction(
      operatorId: 'operator_root',
      operatorEmail: 'daya@aquawild.internal',
      actionType: AdminActionType.userXpAdjusted,
      targetEntityId: userId,
      description: 'Adjusted hydration XP for user $userId',
      previousValue: '$prevXp XP',
      newValue: '$newXp XP',
    );

    state = state.copyWith(
      users: updatedUsers,
      auditEntries: _auditService.getEntries(),
      statusMessage: 'Updated XP to $newXp for user $userId.',
      clearErrorMessage: true,
    );
  }

  /// Grants protective streak freeze tokens to a user.
  Future<void> grantUserFreezeTokens(String userId, int tokensToAdd) async {
    int prevTokens = 0;
    int newTokens = 0;

    final updatedUsers = state.users.map((u) {
      if (u.id == userId) {
        prevTokens = u.freezeTokens;
        newTokens = (prevTokens + tokensToAdd).clamp(0, 99);
        return u.copyWith(freezeTokens: newTokens);
      }
      return u;
    }).toList();

    await _auditService.recordAction(
      operatorId: 'operator_root',
      operatorEmail: 'daya@aquawild.internal',
      actionType: AdminActionType.freezeTokensGranted,
      targetEntityId: userId,
      description: 'Granted $tokensToAdd freeze tokens to $userId',
      previousValue: '$prevTokens tokens',
      newValue: '$newTokens tokens',
    );

    state = state.copyWith(
      users: updatedUsers,
      auditEntries: _auditService.getEntries(),
      statusMessage: 'Granted $tokensToAdd freeze tokens to user $userId.',
      clearErrorMessage: true,
    );
  }

  /// Modifies a user's account status (active, suspended, pendingVerification).
  Future<void> updateUserStatus(String userId, UserAccountStatus status) async {
    String? prevStatus;
    final updatedUsers = state.users.map((u) {
      if (u.id == userId) {
        prevStatus = u.status.name;
        return u.copyWith(status: status);
      }
      return u;
    }).toList();

    await _auditService.recordAction(
      operatorId: 'operator_root',
      operatorEmail: 'daya@aquawild.internal',
      actionType: AdminActionType.userStatusChanged,
      targetEntityId: userId,
      description: 'Account status updated to ${status.displayName} for user $userId',
      previousValue: prevStatus,
      newValue: status.name,
    );

    state = state.copyWith(
      users: updatedUsers,
      auditEntries: _auditService.getEntries(),
      statusMessage: 'Account status updated to ${status.displayName} for $userId.',
      clearErrorMessage: true,
    );
  }

  /// Modifies a user's role-based access control level.
  Future<void> updateUserRole(String userId, UserRole role) async {
    String? prevRole;
    final updatedUsers = state.users.map((u) {
      if (u.id == userId) {
        prevRole = u.role.name;
        return u.copyWith(
          role: role,
          isPro: role == UserRole.pro || role == UserRole.superAdmin,
        );
      }
      return u;
    }).toList();

    await _auditService.recordAction(
      operatorId: 'operator_root',
      operatorEmail: 'daya@aquawild.internal',
      actionType: AdminActionType.userRoleChanged,
      targetEntityId: userId,
      description: 'User role updated to ${role.displayName} for $userId',
      previousValue: prevRole,
      newValue: role.name,
    );

    state = state.copyWith(
      users: updatedUsers,
      auditEntries: _auditService.getEntries(),
      statusMessage: 'User role updated to ${role.displayName} for $userId.',
      clearErrorMessage: true,
    );

    _refreshKpis();
  }

  /// Updates or edits a beverage item's hydration science or physical properties.
  Future<void> updateBeverage(AdminBeverageItem item) async {
    final index = state.beverages.indexWhere((b) => b.id == item.id);
    if (index >= 0) {
      final prev = state.beverages[index];
      final updated = List<AdminBeverageItem>.from(state.beverages);
      updated[index] = item;

      await _auditService.recordAction(
        operatorId: 'operator_root',
        operatorEmail: 'daya@aquawild.internal',
        actionType: AdminActionType.beverageUpdated,
        targetEntityId: item.id,
        description: 'Updated beverage parameter profile for ${item.name}',
        previousValue: 'Hydration: ${prev.hydrationIndex}, Density: ${prev.density}',
        newValue: 'Hydration: ${item.hydrationIndex}, Density: ${item.density}',
      );

      state = state.copyWith(
        beverages: updated,
        auditEntries: _auditService.getEntries(),
        statusMessage: 'Beverage "${item.name}" updated successfully.',
        clearErrorMessage: true,
      );
    }
  }

  /// Adds a custom beverage to the catalog.
  Future<void> createBeverage(AdminBeverageItem item) async {
    if (state.beverages.any((b) => b.id == item.id)) {
      state = state.copyWith(
        errorMessage: 'Beverage ID "${item.id}" already exists.',
      );
      return;
    }
    final updated = [...state.beverages, item.copyWith(isCustom: true)];

    await _auditService.recordAction(
      operatorId: 'operator_root',
      operatorEmail: 'daya@aquawild.internal',
      actionType: AdminActionType.beverageCreated,
      targetEntityId: item.id,
      description: 'Created custom beverage "${item.name}" (${item.category})',
      previousValue: null,
      newValue: item.id,
    );

    state = state.copyWith(
      beverages: updated,
      auditEntries: _auditService.getEntries(),
      statusMessage: 'Custom beverage "${item.name}" created.',
      clearErrorMessage: true,
    );
  }

  /// Deletes a custom beverage or disables a built-in beverage.
  Future<void> deleteBeverage(String beverageId) async {
    final target = state.beverages.where((b) => b.id == beverageId).firstOrNull;
    if (target == null) return;

    if (target.isCustom) {
      final updated = state.beverages.where((b) => b.id != beverageId).toList();

      await _auditService.recordAction(
        operatorId: 'operator_root',
        operatorEmail: 'daya@aquawild.internal',
        actionType: AdminActionType.beverageDeleted,
        targetEntityId: beverageId,
        description: 'Deleted custom beverage "${target.name}"',
        previousValue: target.id,
        newValue: null,
      );

      state = state.copyWith(
        beverages: updated,
        auditEntries: _auditService.getEntries(),
        statusMessage: 'Custom beverage "${target.name}" removed.',
        clearErrorMessage: true,
      );
    } else {
      await toggleBeverageEnabled(beverageId);
    }
  }

  /// Toggles whether a beverage is available in client pour decks.
  Future<void> toggleBeverageEnabled(String beverageId) async {
    bool? newStatus;
    final updated = state.beverages.map((b) {
      if (b.id == beverageId) {
        newStatus = !b.isEnabled;
        return b.copyWith(isEnabled: newStatus);
      }
      return b;
    }).toList();

    await _auditService.recordAction(
      operatorId: 'operator_root',
      operatorEmail: 'daya@aquawild.internal',
      actionType: AdminActionType.beverageUpdated,
      targetEntityId: beverageId,
      description: 'Toggled beverage availability for $beverageId to $newStatus',
      previousValue: (!newStatus!).toString(),
      newValue: newStatus.toString(),
    );

    state = state.copyWith(
      beverages: updated,
      auditEntries: _auditService.getEntries(),
      statusMessage: 'Toggled beverage availability for $beverageId.',
      clearErrorMessage: true,
    );
  }

  /// Updates companion metadata, unlock XP, or active tier.
  Future<void> updateAnimal(AdminAnimalItem item) async {
    final index = state.animals.indexWhere((a) => a.id == item.id);
    if (index >= 0) {
      final prev = state.animals[index];
      final updated = List<AdminAnimalItem>.from(state.animals);
      updated[index] = item;

      await _auditService.recordAction(
        operatorId: 'operator_root',
        operatorEmail: 'daya@aquawild.internal',
        actionType: AdminActionType.animalUpdated,
        targetEntityId: item.id,
        description: 'Updated animal companion metadata for ${item.name}',
        previousValue: 'XP: ${prev.unlockXp}, Tier: ${prev.tier}',
        newValue: 'XP: ${item.unlockXp}, Tier: ${item.tier}',
      );

      state = state.copyWith(
        animals: updated,
        auditEntries: _auditService.getEntries(),
        statusMessage: 'Companion "${item.name}" updated.',
        clearErrorMessage: true,
      );
    }
  }

  /// Toggles companion availability in sanctuary selector.
  Future<void> toggleAnimalEnabled(String animalId) async {
    bool? newStatus;
    final updated = state.animals.map((a) {
      if (a.id == animalId) {
        newStatus = !a.isEnabled;
        return a.copyWith(isEnabled: newStatus);
      }
      return a;
    }).toList();

    await _auditService.recordAction(
      operatorId: 'operator_root',
      operatorEmail: 'daya@aquawild.internal',
      actionType: AdminActionType.animalUpdated,
      targetEntityId: animalId,
      description: 'Toggled companion availability for $animalId to $newStatus',
      previousValue: (!newStatus!).toString(),
      newValue: newStatus.toString(),
    );

    state = state.copyWith(
      animals: updated,
      auditEntries: _auditService.getEntries(),
      statusMessage: 'Toggled companion availability for $animalId.',
      clearErrorMessage: true,
    );
  }

  /// Toggles a dynamic feature flag at runtime.
  Future<void> toggleFeatureFlag(String flagKey, bool isEnabled) async {
    final updated = state.featureFlags.map((f) {
      if (f.key == flagKey) {
        return f.copyWith(isEnabled: isEnabled);
      }
      return f;
    }).toList();

    await _auditService.recordAction(
      operatorId: 'operator_root',
      operatorEmail: 'daya@aquawild.internal',
      actionType: AdminActionType.featureFlagToggled,
      targetEntityId: flagKey,
      description: 'Feature flag "$flagKey" set to $isEnabled',
      previousValue: (!isEnabled).toString(),
      newValue: isEnabled.toString(),
    );

    state = state.copyWith(
      featureFlags: updated,
      auditEntries: _auditService.getEntries(),
      statusMessage: 'Feature flag "$flagKey" set to $isEnabled.',
      clearErrorMessage: true,
    );
  }

  /// Switches target backend environment (Development, Staging, Production).
  Future<void> switchEnvironment(AppEnvironment newEnv) async {
    final prevEnv = state.environmentConfig.environment.name;
    final preset = AdminEnvironmentConfig.presetFor(newEnv);

    await _auditService.recordAction(
      operatorId: 'operator_root',
      operatorEmail: 'daya@aquawild.internal',
      actionType: AdminActionType.environmentSwitched,
      targetEntityId: newEnv.name,
      description: 'Switched environment to ${newEnv.displayName}',
      previousValue: prevEnv,
      newValue: newEnv.name,
    );

    state = state.copyWith(
      environmentConfig: preset,
      auditEntries: _auditService.getEntries(),
      statusMessage: 'Switched target environment to ${newEnv.displayName}.',
      clearErrorMessage: true,
    );
  }

  /// Customizes active environment connection parameters.
  void updateEnvironmentConfig(AdminEnvironmentConfig config) {
    state = state.copyWith(
      environmentConfig: config,
      statusMessage: 'Environment configuration parameters updated.',
      clearErrorMessage: true,
    );
  }

  /// Dispatches an immediate push broadcast announcement.
  Future<AdminBroadcastMessage> dispatchBroadcast({
    required String title,
    required String body,
    required BroadcastCategory category,
    required BroadcastTargetAudience audience,
    String actionRoute = '/home',
  }) async {
    final message = await _broadcastService.dispatchImmediate(
      title: title,
      body: body,
      category: category,
      targetAudience: audience,
      actionRoute: actionRoute,
      userDirectory: state.users,
    );

    await _auditService.recordAction(
      operatorId: 'operator_root',
      operatorEmail: 'daya@aquawild.internal',
      actionType: AdminActionType.notificationBroadcasted,
      targetEntityId: message.id,
      description: 'Dispatched broadcast "$title" to ${audience.displayName} (${message.totalRecipients} recipients)',
      previousValue: null,
      newValue: message.id,
    );

    state = state.copyWith(
      broadcasts: _broadcastService.getBroadcasts(),
      auditEntries: _auditService.getEntries(),
      statusMessage:
          'Broadcast dispatched to ${message.totalRecipients} users successfully.',
      clearErrorMessage: true,
    );

    return message;
  }

  /// Schedules a future push broadcast announcement.
  Future<AdminBroadcastMessage> scheduleBroadcast({
    required String title,
    required String body,
    required BroadcastCategory category,
    required BroadcastTargetAudience audience,
    required DateTime scheduledAt,
    String actionRoute = '/home',
  }) async {
    final message = await _broadcastService.scheduleBroadcast(
      title: title,
      body: body,
      category: category,
      targetAudience: audience,
      scheduledAt: scheduledAt,
      actionRoute: actionRoute,
      userDirectory: state.users,
    );

    await _auditService.recordAction(
      operatorId: 'operator_root',
      operatorEmail: 'daya@aquawild.internal',
      actionType: AdminActionType.notificationBroadcasted,
      targetEntityId: message.id,
      description: 'Scheduled broadcast "$title" for ${scheduledAt.toIso8601String()}',
      previousValue: null,
      newValue: message.id,
    );

    state = state.copyWith(
      broadcasts: _broadcastService.getBroadcasts(),
      auditEntries: _auditService.getEntries(),
      statusMessage:
          'Broadcast scheduled for ${scheduledAt.toLocal().toString().split('.').first}.',
      clearErrorMessage: true,
    );

    return message;
  }

  /// Cancels a scheduled broadcast.
  Future<bool> cancelScheduledBroadcast(String broadcastId) async {
    final success = await _broadcastService.cancelScheduled(broadcastId);
    if (success) {
      await _auditService.recordAction(
        operatorId: 'operator_root',
        operatorEmail: 'daya@aquawild.internal',
        actionType: AdminActionType.notificationBroadcasted,
        targetEntityId: broadcastId,
        description: 'Cancelled scheduled broadcast $broadcastId',
        previousValue: broadcastId,
        newValue: 'cancelled',
      );

      state = state.copyWith(
        broadcasts: _broadcastService.getBroadcasts(),
        auditEntries: _auditService.getEntries(),
        statusMessage: 'Scheduled broadcast $broadcastId cancelled.',
        clearErrorMessage: true,
      );
    }
    return success;
  }

  /// Cryptographically verifies the integrity of the audit log chain.
  AuditVerificationResult verifyAuditTrailIntegrity() {
    final result = _auditService.verifyTrailIntegrity();
    state = state.copyWith(isAuditChainValid: result.isValid);
    return result;
  }

  /// Recalculates monetization and telemetry KPIs.
  void _refreshKpis() {
    final kpis = _telemetryService.calculateKpis(
      users: state.users,
      products: ProductSKU.catalog,
      activeLocalSubscription: ref.read(monetizationProvider).subscription,
    );
    state = state.copyWith(kpiSummary: kpis);
  }

  /// Public trigger to recompute analytics KPIs.
  void refreshKpiSummary() => _refreshKpis();

  /// Clears any transient status or error messages.
  void clearMessages() {
    state = state.copyWith(
      clearStatusMessage: true,
      clearErrorMessage: true,
    );
  }

  /// Restores all admin catalogs, flags, and environments to factory defaults.
  Future<void> resetToDefaults() async {
    final seedUsers = AdminUserProfile.defaultSeedUsers;
    final kpis = _telemetryService.calculateKpis(
      users: seedUsers,
      products: ProductSKU.catalog,
      activeLocalSubscription: ref.read(monetizationProvider).subscription,
    );

    await _auditService.recordAction(
      operatorId: 'operator_root',
      operatorEmail: 'daya@aquawild.internal',
      actionType: AdminActionType.configurationReset,
      targetEntityId: 'admin_portal_all',
      description: 'Restored admin portal catalogs, feature flags, and environments to factory defaults',
      previousValue: null,
      newValue: 'factory_defaults',
    );

    state = AdminPortalState(
      godMode: AdminGodModeConfig.standard,
      users: seedUsers,
      beverages: AdminBeverageItem.defaultCatalog,
      animals: AdminAnimalItem.defaultCatalog,
      featureFlags: AdminFeatureFlag.defaultFlags,
      environmentConfig:
          AdminEnvironmentConfig.presetFor(AppEnvironment.development),
      auditEntries: _auditService.getEntries(),
      kpiSummary: kpis,
      broadcasts: _broadcastService.getBroadcasts(),
      isAuditChainValid: true,
      statusMessage: 'Admin portal restored to baseline factory defaults.',
    );
  }
}

/// Riverpod provider for the Admin Portal controller.
final adminPortalControllerProvider =
    NotifierProvider<AdminPortalNotifier, AdminPortalState>(
  AdminPortalNotifier.new,
);

/// Riverpod provider alias for admin state.
final adminPortalProvider = adminPortalControllerProvider;
