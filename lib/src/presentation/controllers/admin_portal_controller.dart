import 'package:flutter_riverpod/flutter_riverpod.dart';
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
/// user directory, content catalogs, dynamic feature flags, and environment switching.
class AdminPortalNotifier extends Notifier<AdminPortalState> {
  @override
  AdminPortalState build() {
    return AdminPortalState(
      godMode: AdminGodModeConfig.standard,
      users: AdminUserProfile.defaultSeedUsers,
      beverages: AdminBeverageItem.defaultCatalog,
      animals: AdminAnimalItem.defaultCatalog,
      featureFlags: AdminFeatureFlag.defaultFlags,
      environmentConfig:
          AdminEnvironmentConfig.presetFor(AppEnvironment.development),
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
            store: 'admin_god_mode',
          );

      // 2. Grant all IAP product pack entitlements
      for (final product in ProductSKU.catalog) {
        await ref.read(monetizationProvider.notifier).grantEntitlement(
              product.id,
              product.kind,
              source: 'admin_god_mode',
            );
      }

      // 3. Grant generous XP to unlock all evolution stages
      await ref.read(animalHabitatProvider.notifier).addXp(25000);

      if (!ref.mounted) return;
      state = state.copyWith(
        godMode: unlockedConfig,
        isLoading: false,
        statusMessage:
            '⚡ God Mode Activated: All 10 companions, biomes, themes & Pro lifetime privileges granted.',
        clearErrorMessage: true,
      );
    } else {
      // Revert monetization to standard Free tier
      await ref.read(monetizationProvider.notifier).resetToFree();

      if (!ref.mounted) return;
      state = state.copyWith(
        godMode: AdminGodModeConfig.standard,
        isLoading: false,
        statusMessage:
            '🔒 God Mode Deactivated: Reverted to standard client permissions.',
        clearErrorMessage: true,
      );
    }
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
  void updateUserXp(String userId, int newXp) {
    final updatedUsers = state.users.map((u) {
      if (u.id == userId) {
        return u.copyWith(currentXp: newXp.clamp(0, 1000000));
      }
      return u;
    }).toList();

    state = state.copyWith(
      users: updatedUsers,
      statusMessage: 'Updated XP to $newXp for user $userId.',
      clearErrorMessage: true,
    );
  }

  /// Grants protective streak freeze tokens to a user.
  void grantUserFreezeTokens(String userId, int tokensToAdd) {
    final updatedUsers = state.users.map((u) {
      if (u.id == userId) {
        final current = u.freezeTokens;
        return u.copyWith(freezeTokens: (current + tokensToAdd).clamp(0, 99));
      }
      return u;
    }).toList();

    state = state.copyWith(
      users: updatedUsers,
      statusMessage: 'Granted $tokensToAdd freeze tokens to user $userId.',
      clearErrorMessage: true,
    );
  }

  /// Modifies a user's account status (active, suspended, pendingVerification).
  void updateUserStatus(String userId, UserAccountStatus status) {
    final updatedUsers = state.users.map((u) {
      if (u.id == userId) {
        return u.copyWith(status: status);
      }
      return u;
    }).toList();

    state = state.copyWith(
      users: updatedUsers,
      statusMessage: 'Account status updated to ${status.displayName} for $userId.',
      clearErrorMessage: true,
    );
  }

  /// Modifies a user's role-based access control level.
  void updateUserRole(String userId, UserRole role) {
    final updatedUsers = state.users.map((u) {
      if (u.id == userId) {
        return u.copyWith(
          role: role,
          isPro: role == UserRole.pro || role == UserRole.superAdmin,
        );
      }
      return u;
    }).toList();

    state = state.copyWith(
      users: updatedUsers,
      statusMessage: 'User role updated to ${role.displayName} for $userId.',
      clearErrorMessage: true,
    );
  }

  /// Updates or edits a beverage item's hydration science or physical properties.
  void updateBeverage(AdminBeverageItem item) {
    final index = state.beverages.indexWhere((b) => b.id == item.id);
    if (index >= 0) {
      final updated = List<AdminBeverageItem>.from(state.beverages);
      updated[index] = item;
      state = state.copyWith(
        beverages: updated,
        statusMessage: 'Beverage "${item.name}" updated successfully.',
        clearErrorMessage: true,
      );
    }
  }

  /// Adds a custom beverage to the catalog.
  void createBeverage(AdminBeverageItem item) {
    if (state.beverages.any((b) => b.id == item.id)) {
      state = state.copyWith(
        errorMessage: 'Beverage ID "${item.id}" already exists.',
      );
      return;
    }
    final updated = [...state.beverages, item.copyWith(isCustom: true)];
    state = state.copyWith(
      beverages: updated,
      statusMessage: 'Custom beverage "${item.name}" created.',
      clearErrorMessage: true,
    );
  }

  /// Deletes a custom beverage or disables a built-in beverage.
  void deleteBeverage(String beverageId) {
    final target = state.beverages.where((b) => b.id == beverageId).firstOrNull;
    if (target == null) return;

    if (target.isCustom) {
      final updated = state.beverages.where((b) => b.id != beverageId).toList();
      state = state.copyWith(
        beverages: updated,
        statusMessage: 'Custom beverage "${target.name}" removed.',
        clearErrorMessage: true,
      );
    } else {
      // Built-in beverages are disabled rather than hard-deleted to preserve referential integrity
      toggleBeverageEnabled(beverageId);
    }
  }

  /// Toggles whether a beverage is available in client pour decks.
  void toggleBeverageEnabled(String beverageId) {
    final updated = state.beverages.map((b) {
      if (b.id == beverageId) {
        return b.copyWith(isEnabled: !b.isEnabled);
      }
      return b;
    }).toList();

    state = state.copyWith(
      beverages: updated,
      statusMessage: 'Toggled beverage availability for $beverageId.',
      clearErrorMessage: true,
    );
  }

  /// Updates companion metadata, unlock XP, or active tier.
  void updateAnimal(AdminAnimalItem item) {
    final index = state.animals.indexWhere((a) => a.id == item.id);
    if (index >= 0) {
      final updated = List<AdminAnimalItem>.from(state.animals);
      updated[index] = item;
      state = state.copyWith(
        animals: updated,
        statusMessage: 'Companion "${item.name}" updated.',
        clearErrorMessage: true,
      );
    }
  }

  /// Toggles companion availability in sanctuary selector.
  void toggleAnimalEnabled(String animalId) {
    final updated = state.animals.map((a) {
      if (a.id == animalId) {
        return a.copyWith(isEnabled: !a.isEnabled);
      }
      return a;
    }).toList();

    state = state.copyWith(
      animals: updated,
      statusMessage: 'Toggled companion availability for $animalId.',
      clearErrorMessage: true,
    );
  }

  /// Toggles a dynamic feature flag at runtime.
  void toggleFeatureFlag(String flagKey, bool isEnabled) {
    final updated = state.featureFlags.map((f) {
      if (f.key == flagKey) {
        return f.copyWith(isEnabled: isEnabled);
      }
      return f;
    }).toList();

    state = state.copyWith(
      featureFlags: updated,
      statusMessage: 'Feature flag "$flagKey" set to $isEnabled.',
      clearErrorMessage: true,
    );
  }

  /// Switches target backend environment (Development, Staging, Production).
  void switchEnvironment(AppEnvironment newEnv) {
    final preset = AdminEnvironmentConfig.presetFor(newEnv);
    state = state.copyWith(
      environmentConfig: preset,
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

  /// Clears any transient status or error messages.
  void clearMessages() {
    state = state.copyWith(
      clearStatusMessage: true,
      clearErrorMessage: true,
    );
  }

  /// Restores all admin catalogs, flags, and environments to factory defaults.
  void resetToDefaults() {
    state = AdminPortalState(
      godMode: AdminGodModeConfig.standard,
      users: AdminUserProfile.defaultSeedUsers,
      beverages: AdminBeverageItem.defaultCatalog,
      animals: AdminAnimalItem.defaultCatalog,
      featureFlags: AdminFeatureFlag.defaultFlags,
      environmentConfig:
          AdminEnvironmentConfig.presetFor(AppEnvironment.development),
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
