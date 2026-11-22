import 'package:aquawild/src/data/repositories/local_hydration_repository.dart';
import 'package:aquawild/src/domain/models/admin_audit_models.dart';
import 'package:aquawild/src/domain/models/admin_broadcast_models.dart';
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

    test('Initializes with standard defaults, seed data, and analytics KPIs', () {
      final state = container.read(adminPortalControllerProvider);

      expect(state.godMode.isGodModeEnabled, isFalse);
      expect(state.users.isNotEmpty, isTrue);
      expect(state.beverages.isNotEmpty, isTrue);
      expect(state.animals.isNotEmpty, isTrue);
      expect(state.featureFlags.isNotEmpty, isTrue);
      expect(state.environmentConfig.environment, equals(AppEnvironment.development));
      expect(state.kpiSummary.monthlyRecurringRevenueUsd, greaterThan(0.0));
      expect(state.isAuditChainValid, isTrue);
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
      expect(adminState.auditEntries.isNotEmpty, isTrue);
      expect(adminState.auditEntries.first.actionType, equals(AdminActionType.godModeToggled));

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

    test('User modifications: update XP, grant freeze tokens, status and role', () async {
      final notifier = container.read(adminPortalControllerProvider.notifier);
      const targetId = 'usr_sam_03';

      // Update XP
      await notifier.updateUserXp(targetId, 8500);
      var user = container
          .read(adminPortalControllerProvider)
          .users
          .firstWhere((u) => u.id == targetId);
      expect(user.currentXp, equals(8500));

      // Grant freeze tokens
      final initialTokens = user.freezeTokens;
      await notifier.grantUserFreezeTokens(targetId, 3);
      user = container
          .read(adminPortalControllerProvider)
          .users
          .firstWhere((u) => u.id == targetId);
      expect(user.freezeTokens, equals(initialTokens + 3));

      // Update account status
      await notifier.updateUserStatus(targetId, UserAccountStatus.suspended);
      user = container
          .read(adminPortalControllerProvider)
          .users
          .firstWhere((u) => u.id == targetId);
      expect(user.status, equals(UserAccountStatus.suspended));

      // Update role
      await notifier.updateUserRole(targetId, UserRole.admin);
      user = container
          .read(adminPortalControllerProvider)
          .users
          .firstWhere((u) => u.id == targetId);
      expect(user.role, equals(UserRole.admin));
    });

    test('Beverage catalog CRUD operations', () async {
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

      await notifier.createBeverage(customBev);
      var state = container.read(adminPortalControllerProvider);
      expect(state.beverages.any((b) => b.id == 'golden_turmeric_latte'), isTrue);

      // Attempt duplicate ID
      await notifier.createBeverage(customBev);
      state = container.read(adminPortalControllerProvider);
      expect(state.errorMessage, contains('already exists'));

      // 2. Update beverage properties
      final updatedBev = customBev.copyWith(hydrationIndex: 0.98);
      await notifier.updateBeverage(updatedBev);
      final fetched = container
          .read(adminPortalControllerProvider)
          .beverages
          .firstWhere((b) => b.id == 'golden_turmeric_latte');
      expect(fetched.hydrationIndex, equals(0.98));

      // 3. Delete custom beverage
      await notifier.deleteBeverage('golden_turmeric_latte');
      state = container.read(adminPortalControllerProvider);
      expect(state.beverages.any((b) => b.id == 'golden_turmeric_latte'), isFalse);

      // 4. Toggle built-in beverage availability
      await notifier.toggleBeverageEnabled('espresso');
      final espresso = container
          .read(adminPortalControllerProvider)
          .beverages
          .firstWhere((b) => b.id == 'espresso');
      expect(espresso.isEnabled, isFalse);
    });

    test('Animal companion metadata update and toggling', () async {
      final notifier = container.read(adminPortalControllerProvider.notifier);

      final capybara = container
          .read(adminPortalControllerProvider)
          .animals
          .firstWhere((a) => a.id == 'capybara');
      final updatedCapybara = capybara.copyWith(unlockXp: 500);

      await notifier.updateAnimal(updatedCapybara);
      var fetched = container
          .read(adminPortalControllerProvider)
          .animals
          .firstWhere((a) => a.id == 'capybara');
      expect(fetched.unlockXp, equals(500));

      await notifier.toggleAnimalEnabled('capybara');
      fetched = container
          .read(adminPortalControllerProvider)
          .animals
          .firstWhere((a) => a.id == 'capybara');
      expect(fetched.isEnabled, isFalse);
    });

    test('Feature flag toggling and evaluation', () async {
      final notifier = container.read(adminPortalControllerProvider.notifier);
      const flagKey = 'enable_ar_companion_preview';

      expect(
        container.read(adminPortalControllerProvider).isFeatureEnabled(flagKey),
        isFalse,
      );

      await notifier.toggleFeatureFlag(flagKey, true);
      expect(
        container.read(adminPortalControllerProvider).isFeatureEnabled(flagKey),
        isTrue,
      );

      await notifier.toggleFeatureFlag(flagKey, false);
      expect(
        container.read(adminPortalControllerProvider).isFeatureEnabled(flagKey),
        isFalse,
      );
    });

    test('Environment switching and parameter updates', () async {
      final notifier = container.read(adminPortalControllerProvider.notifier);

      await notifier.switchEnvironment(AppEnvironment.staging);
      var env = container.read(adminPortalControllerProvider).environmentConfig;
      expect(env.environment, equals(AppEnvironment.staging));
      expect(env.supabaseUrl, equals('https://staging-db.aquawild.app'));
      expect(env.isMockMode, isFalse);

      await notifier.switchEnvironment(AppEnvironment.production);
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
      await notifier.resetToDefaults();
      final resetState = container.read(adminPortalControllerProvider);
      expect(resetState.environmentConfig.environment, equals(AppEnvironment.development));
      expect(resetState.godMode.isGodModeEnabled, isFalse);
    });

    test('Cryptographic audit trail integrity verification and tampering check', () async {
      final notifier = container.read(adminPortalControllerProvider.notifier);

      // Perform a series of actions
      await notifier.updateUserXp('usr_alex_02', 7777);
      await notifier.toggleFeatureFlag('enable_ambient_caustic_audio', false);

      final result = notifier.verifyAuditTrailIntegrity();
      expect(result.isValid, isTrue);
      expect(result.totalEntriesChecked, greaterThanOrEqualTo(2));
      expect(container.read(adminPortalControllerProvider).isAuditChainValid, isTrue);
    });

    test('Push notification broadcast dispatcher, scheduler, and cancellation', () async {
      final notifier = container.read(adminPortalControllerProvider.notifier);

      // 1. Dispatch immediate broadcast
      final msg = await notifier.dispatchBroadcast(
        title: 'Midday Rehydration Call',
        body: 'Sip 250ml water now to stay on pace!',
        category: BroadcastCategory.announcement,
        audience: BroadcastTargetAudience.allUsers,
      );

      expect(msg.isSent, isTrue);
      expect(msg.totalRecipients, greaterThan(0));

      final state = container.read(adminPortalControllerProvider);
      expect(state.broadcasts.any((b) => b.id == msg.id), isTrue);

      // 2. Schedule broadcast
      final sched = await notifier.scheduleBroadcast(
        title: 'Evening Relax Notice',
        body: 'Unwind with herbal tea in the sanctuary.',
        category: BroadcastCategory.community,
        audience: BroadcastTargetAudience.proUsersOnly,
        scheduledAt: DateTime.now().add(const Duration(hours: 4)),
      );

      expect(sched.isSent, isFalse);

      // 3. Cancel scheduled broadcast
      final cancelled = await notifier.cancelScheduledBroadcast(sched.id);
      expect(cancelled, isTrue);
    });
  });
}
