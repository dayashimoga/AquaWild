import 'package:aquawild/src/data/repositories/local_hydration_repository.dart';
import 'package:aquawild/src/domain/models/admin_portal_models.dart';
import 'package:aquawild/src/presentation/controllers/admin_portal_controller.dart';
import 'package:aquawild/src/presentation/controllers/animal_habitat_controller.dart';
import 'package:aquawild/src/presentation/controllers/hydration_controller.dart';
import 'package:aquawild/src/presentation/controllers/monetization_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdminPortalController Unit & Integration Tests', () {
    late ProviderContainer container;
    late LocalHydrationRepository hydrationRepo;

    setUp(() async {
      hydrationRepo = LocalHydrationRepository();
      container = ProviderContainer(
        overrides: [
          hydrationRepositoryProvider.overrideWithValue(hydrationRepo),
        ],
      );
      // Keep controllers alive
      container.listen(adminPortalControllerProvider, (_, _) {});
      container.listen(monetizationProvider, (_, _) {});
      container.listen(animalHabitatProvider, (_, _) {});
      await pumpEventQueue();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initializes with standard defaults and seed data', () {
      final state = container.read(adminPortalControllerProvider);

      expect(state.godMode.isGodModeEnabled, isFalse);
      expect(state.users.isNotEmpty, isTrue);
      expect(state.beverages.isNotEmpty, isTrue);
      expect(state.animals.isNotEmpty, isTrue);
      expect(state.featureFlags.isNotEmpty, isTrue);
      expect(state.environmentConfig.environment, equals(AppEnvironment.development));
      expect(state.isLoading, isFalse);
    });

    test('Toggling God-Mode activates Pro status, pack entitlements, and grants XP', () async {
      final notifier = container.read(adminPortalControllerProvider.notifier);

      // Verify initial monetization state is Free
      var monetization = container.read(monetizationProvider);
      expect(monetization.isPro, isFalse);

      // 1. Activate God-Mode
      await notifier.toggleGodMode(true);
      await pumpEventQueue();

      final adminState = container.read(adminPortalControllerProvider);
      expect(adminState.godMode.isGodModeEnabled, isTrue);
      expect(adminState.statusMessage, contains('God Mode Activated'));

      // Check monetization is now Pro Lifetime
      monetization = container.read(monetizationProvider);
      expect(monetization.isPro, isTrue);
      expect(monetization.entitlements.length, greaterThanOrEqualTo(5));

      // 2. Deactivate God-Mode
      await notifier.toggleGodMode(false);
      await pumpEventQueue();

      final deactivatedState = container.read(adminPortalControllerProvider);
      expect(deactivatedState.godMode.isGodModeEnabled, isFalse);
      expect(deactivatedState.statusMessage, contains('God Mode Deactivated'));

      monetization = container.read(monetizationProvider);
      expect(monetization.isPro, isFalse);
    });

    test('User search filtering and profile selection', () {
      final notifier = container.read(adminPortalControllerProvider.notifier);

      // Initial all users
      expect(container.read(adminPortalControllerProvider).filteredUsers.length, equals(5));

      // Search by name
      notifier.setSearchQuery('Alex');
      var filtered = container.read(adminPortalControllerProvider).filteredUsers;
      expect(filtered.length, equals(1));
      expect(filtered.first.displayName, contains('Alex'));

      // Search by email
      notifier.setSearchQuery('tempmail');
      filtered = container.read(adminPortalControllerProvider).filteredUsers;
      expect(filtered.length, equals(1));
      expect(filtered.first.id, equals('usr_bot_05'));

      // Clear search
      notifier.setSearchQuery('');
      expect(container.read(adminPortalControllerProvider).filteredUsers.length, equals(5));

      // Select user
      notifier.selectUser('usr_daya_01');
      var state = container.read(adminPortalControllerProvider);
      expect(state.selectedUser, isNotNull);
      expect(state.selectedUser!.id, equals('usr_daya_01'));

      // Deselect user
      notifier.selectUser(null);
      state = container.read(adminPortalControllerProvider);
      expect(state.selectedUser, isNull);
    });

    test('User modifications: update XP, grant freeze tokens, status and role', () {
      final notifier = container.read(adminPortalControllerProvider.notifier);
      const targetId = 'usr_sam_03';

      // Update XP
      notifier.updateUserXp(targetId, 8500);
      var user = container
          .read(adminPortalControllerProvider)
          .users
          .firstWhere((u) => u.id == targetId);
      expect(user.currentXp, equals(8500));

      // Grant freeze tokens
      final initialTokens = user.freezeTokens;
      notifier.grantUserFreezeTokens(targetId, 3);
      user = container
          .read(adminPortalControllerProvider)
          .users
          .firstWhere((u) => u.id == targetId);
      expect(user.freezeTokens, equals(initialTokens + 3));

      // Update account status
      notifier.updateUserStatus(targetId, UserAccountStatus.suspended);
      user = container
          .read(adminPortalControllerProvider)
          .users
          .firstWhere((u) => u.id == targetId);
      expect(user.status, equals(UserAccountStatus.suspended));

      // Update role
      notifier.updateUserRole(targetId, UserRole.admin);
      user = container
          .read(adminPortalControllerProvider)
          .users
          .firstWhere((u) => u.id == targetId);
      expect(user.role, equals(UserRole.admin));
    });

    test('Beverage catalog CRUD operations', () {
      final notifier = container.read(adminPortalControllerProvider.notifier);

      // 1. Create custom beverage
      const customBev = AdminBeverageItem(
        id: 'golden_turmeric_latte',
        name: 'Golden Turmeric Elixir',
        category: 'wellness',
        hydrationIndex: 0.95,
        caffeineMgPer100Ml: 0.0,
        electrolytesMgPer100Ml: 80.0,
        sugarGramsPer100Ml: 4.5,
        density: 1.025,
        viscosity: 1.15,
        colorHex: '#FFB300',
        isCustom: true,
      );

      notifier.createBeverage(customBev);
      var state = container.read(adminPortalControllerProvider);
      expect(state.beverages.any((b) => b.id == 'golden_turmeric_latte'), isTrue);

      // Attempt duplicate ID
      notifier.createBeverage(customBev);
      state = container.read(adminPortalControllerProvider);
      expect(state.errorMessage, contains('already exists'));

      // 2. Update beverage properties
      final updatedBev = customBev.copyWith(hydrationIndex: 0.98);
      notifier.updateBeverage(updatedBev);
      final fetched = container
          .read(adminPortalControllerProvider)
          .beverages
          .firstWhere((b) => b.id == 'golden_turmeric_latte');
      expect(fetched.hydrationIndex, equals(0.98));

      // 3. Delete custom beverage
      notifier.deleteBeverage('golden_turmeric_latte');
      state = container.read(adminPortalControllerProvider);
      expect(state.beverages.any((b) => b.id == 'golden_turmeric_latte'), isFalse);

      // 4. Toggle built-in beverage availability
      notifier.toggleBeverageEnabled('espresso');
      final espresso = container
          .read(adminPortalControllerProvider)
          .beverages
          .firstWhere((b) => b.id == 'espresso');
      expect(espresso.isEnabled, isFalse);
    });

    test('Animal companion metadata update and toggling', () {
      final notifier = container.read(adminPortalControllerProvider.notifier);

      final capybara = container
          .read(adminPortalControllerProvider)
          .animals
          .firstWhere((a) => a.id == 'capybara');
      final updatedCapybara = capybara.copyWith(unlockXp: 500);

      notifier.updateAnimal(updatedCapybara);
      var fetched = container
          .read(adminPortalControllerProvider)
          .animals
          .firstWhere((a) => a.id == 'capybara');
      expect(fetched.unlockXp, equals(500));

      notifier.toggleAnimalEnabled('capybara');
      fetched = container
          .read(adminPortalControllerProvider)
          .animals
          .firstWhere((a) => a.id == 'capybara');
      expect(fetched.isEnabled, isFalse);
    });

    test('Feature flag toggling and evaluation', () {
      final notifier = container.read(adminPortalControllerProvider.notifier);
      const flagKey = 'enable_ar_companion_preview';

      expect(
        container.read(adminPortalControllerProvider).isFeatureEnabled(flagKey),
        isFalse,
      );

      notifier.toggleFeatureFlag(flagKey, true);
      expect(
        container.read(adminPortalControllerProvider).isFeatureEnabled(flagKey),
        isTrue,
      );

      notifier.toggleFeatureFlag(flagKey, false);
      expect(
        container.read(adminPortalControllerProvider).isFeatureEnabled(flagKey),
        isFalse,
      );
    });

    test('Environment switching and parameter updates', () {
      final notifier = container.read(adminPortalControllerProvider.notifier);

      notifier.switchEnvironment(AppEnvironment.staging);
      var env = container.read(adminPortalControllerProvider).environmentConfig;
      expect(env.environment, equals(AppEnvironment.staging));
      expect(env.supabaseUrl, equals('https://staging-db.aquawild.app'));
      expect(env.isMockMode, isFalse);

      notifier.switchEnvironment(AppEnvironment.production);
      env = container.read(adminPortalControllerProvider).environmentConfig;
      expect(env.environment, equals(AppEnvironment.production));
      expect(env.supabaseUrl, equals('https://api.aquawild.app'));

      // Custom parameters
      final custom = env.copyWith(apiTimeoutSeconds: 30);
      notifier.updateEnvironmentConfig(custom);
      expect(
        container.read(adminPortalControllerProvider).environmentConfig.apiTimeoutSeconds,
        equals(30),
      );

      // Reset to defaults
      notifier.resetToDefaults();
      final resetState = container.read(adminPortalControllerProvider);
      expect(resetState.environmentConfig.environment, equals(AppEnvironment.development));
      expect(resetState.godMode.isGodModeEnabled, isFalse);
    });
  });
}
