import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aquawild/src/core/services/admin_audit_log_service.dart';
import 'package:aquawild/src/core/services/admin_broadcast_service.dart';
import 'package:aquawild/src/core/services/admin_monetization_analytics_service.dart';
import 'package:aquawild/src/data/repositories/admin_portal_repository.dart';
import 'package:aquawild/src/data/repositories/supabase_admin_repository.dart';
import 'package:aquawild/src/domain/models/admin_audit_models.dart';
import 'package:aquawild/src/domain/models/admin_broadcast_models.dart';
import 'package:aquawild/src/domain/models/admin_portal_models.dart';
import 'package:aquawild/src/presentation/controllers/admin_portal_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Supabase Admin Portal Schema & Repository Integration Tests', () {
    late ProviderContainer container;
    late SupabaseAdminRepository repository;
    late AdminPortalNotifier notifier;

    setUp(() async {
      repository = SupabaseAdminRepository();
      container = ProviderContainer(
        overrides: [
          adminPortalRepositoryProvider.overrideWithValue(repository),
          adminAuditLogServiceProvider.overrideWithValue(AdminAuditLogService()),
          adminNotificationBroadcastServiceProvider
              .overrideWithValue(AdminNotificationBroadcastService()),
          adminMonetizationTelemetryServiceProvider
              .overrideWithValue(const AdminMonetizationTelemetryService()),
        ],
      );

      // Settle Riverpod microtasks
      await pumpEventQueue();
      notifier = container.read(adminPortalProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('User directory mutations propagate to SupabaseAdminRepository and audit log',
        () async {
      final initialUsers = await repository.fetchUserDirectory();
      expect(initialUsers, isNotEmpty);
      final targetUserId = initialUsers.first.id;

      // 1. Update User XP
      await notifier.updateUserXp(targetUserId, 25000);
      var state = container.read(adminPortalProvider);
      expect(state.selectedUser?.currentXp ?? state.users.first.currentXp, equals(25000));

      // Verify persisted in repository
      final repoUsersAfterXp = await repository.fetchUserDirectory();
      expect(
        repoUsersAfterXp.firstWhere((u) => u.id == targetUserId).currentXp,
        equals(25000),
      );

      // 2. Grant Freeze Tokens
      await notifier.grantUserFreezeTokens(targetUserId, 5);
      state = container.read(adminPortalProvider);
      final updatedUser = state.users.firstWhere((u) => u.id == targetUserId);
      expect(updatedUser.freezeTokens, equals(10)); // 5 initial + 5 granted

      final repoUsersAfterTokens = await repository.fetchUserDirectory();
      expect(
        repoUsersAfterTokens.firstWhere((u) => u.id == targetUserId).freezeTokens,
        equals(10),
      );

      // 3. Update User Account Status
      await notifier.updateUserStatus(targetUserId, UserAccountStatus.suspended);
      state = container.read(adminPortalProvider);
      expect(
        state.users.firstWhere((u) => u.id == targetUserId).status,
        equals(UserAccountStatus.suspended),
      );

      // 4. Update User Role
      await notifier.updateUserRole(targetUserId, UserRole.admin);
      state = container.read(adminPortalProvider);
      expect(
        state.users.firstWhere((u) => u.id == targetUserId).role,
        equals(UserRole.admin),
      );
    });

    test('Content Catalog mutations propagate to SupabaseAdminRepository',
        () async {
      final initialBeverages = await repository.fetchBeverageCatalog();
      expect(initialBeverages, isNotEmpty);
      final targetBev = initialBeverages.first;

      // Update Beverage parameter
      final modifiedBev = targetBev.copyWith(
        hydrationIndex: 1.25,
        caffeineMgPer100Ml: 10.0,
      );
      await notifier.updateBeverage(modifiedBev);

      final repoBevs = await repository.fetchBeverageCatalog();
      final updatedBev = repoBevs.firstWhere((b) => b.id == targetBev.id);
      expect(updatedBev.hydrationIndex, equals(1.25));
      expect(updatedBev.caffeineMgPer100Ml, equals(10.0));

      // Create Custom Beverage
      const customBev = AdminBeverageItem(
        id: 'electrolyte_hyper_boost',
        name: 'Hyper-Electrolyte Ionic Surge',
        category: 'Sports & Performance',
        hydrationIndex: 1.4,
        caffeineMgPer100Ml: 0.0,
        electrolytesMgPer100Ml: 320.0,
        sugarGramsPer100Ml: 2.0,
        density: 1.025,
        viscosity: 1.01,
        colorHex: '#00F0FF',
        isCustom: true,
        isEnabled: true,
      );
      await notifier.createBeverage(customBev);

      final repoBevsAfterCreate = await repository.fetchBeverageCatalog();
      expect(
        repoBevsAfterCreate.any((b) => b.id == 'electrolyte_hyper_boost'),
        isTrue,
      );

      // Delete Custom Beverage
      await notifier.deleteBeverage('electrolyte_hyper_boost');
      final repoBevsAfterDelete = await repository.fetchBeverageCatalog();
      expect(
        repoBevsAfterDelete.any((b) => b.id == 'electrolyte_hyper_boost'),
        isFalse,
      );

      // Animal Catalog Toggle
      final initialAnimals = await repository.fetchAnimalCatalog();
      final targetAnimal = initialAnimals.first;
      await notifier.toggleAnimalEnabled(targetAnimal.id);

      final state = container.read(adminPortalProvider);
      final animalInState = state.animals.firstWhere((a) => a.id == targetAnimal.id);
      expect(animalInState.isEnabled, isFalse);
    });

    test('Feature flags and environment switcher synchronize with repository',
        () async {
      // Toggle flag
      const flagKey = 'enable_high_precision_waves';
      await notifier.toggleFeatureFlag(flagKey, false);

      final state = container.read(adminPortalProvider);
      expect(state.isFeatureEnabled(flagKey), isFalse);

      final repoFlags = await repository.fetchFeatureFlags();
      expect(
        repoFlags.firstWhere((f) => f.key == flagKey).isEnabled,
        isFalse,
      );

      // Switch environment to Staging
      await notifier.switchEnvironment(AppEnvironment.staging);
      final envState = container.read(adminPortalProvider).environmentConfig;
      expect(envState.environment, equals(AppEnvironment.staging));

      final repoEnv = await repository.fetchEnvironmentConfig();
      expect(repoEnv.environment, equals(AppEnvironment.staging));
    });

    test('Cryptographic audit trail maintains unbroken SHA-256 hash chaining',
        () async {
      await notifier.updateUserXp('usr_daya_01', 30000);
      await notifier.grantUserFreezeTokens('usr_daya_01', 3);
      await notifier.toggleGodMode(true);

      final state = container.read(adminPortalProvider);
      expect(state.auditEntries.length, greaterThanOrEqualTo(3));

      // Cryptographic verification of audit trail
      final verification = notifier.verifyAuditTrailIntegrity();
      expect(verification.isValid, isTrue);
      expect(verification.totalEntriesChecked, greaterThanOrEqualTo(3));
      expect(state.isAuditChainValid, isTrue);

      // Inspect hash chaining: H_i.previousEntryHash == H_{i-1}.entryHash
      final entries = state.auditEntries;
      for (int i = 0; i < entries.length - 1; i++) {
        // Since entries are displayed reverse-chronologically (newest first):
        final newer = entries[i];
        final older = entries[i + 1];
        expect(newer.previousEntryHash, equals(older.entryHash));
      }
    });

    test('Notification broadcast campaigns support immediate dispatch and scheduling',
        () async {
      // Immediate dispatch
      final immediateMsg = await notifier.dispatchBroadcast(
        title: 'Mission Launch Alert',
        body: 'AquaWild Mission Control is now live on Supabase!',
        category: BroadcastCategory.announcement,
        audience: BroadcastTargetAudience.allUsers,
      );

      expect(immediateMsg.isSent, isTrue);
      expect(immediateMsg.totalRecipients, greaterThan(0));

      final repoBroadcasts = await repository.fetchBroadcasts();
      expect(repoBroadcasts.any((b) => b.id == immediateMsg.id), isTrue);

      // Schedule future dispatch
      final scheduledMsg = await notifier.scheduleBroadcast(
        title: 'Circadian Peak Reminder',
        body: 'Optimal hydration window is now active.',
        category: BroadcastCategory.challenge,
        audience: BroadcastTargetAudience.allUsers,
        scheduledAt: DateTime.now().add(const Duration(hours: 2)),
      );

      expect(scheduledMsg.isSent, isFalse);

      // Cancel scheduled broadcast
      final cancelled = await notifier.cancelScheduledBroadcast(scheduledMsg.id);
      expect(cancelled, isTrue);
    });

    test('Row-Level Security (RLS) simulation rejects unauthorized caller roles',
        () async {
      // Set caller to standard non-admin user
      repository.setActiveCallerRole(UserRole.standard);

      // Standard user cannot fetch user directory
      expect(
        () => repository.fetchUserDirectory(),
        throwsA(isA<AdminSecurityException>()),
      );

      // Standard user cannot toggle feature flags
      const flag = AdminFeatureFlag(
        key: 'hack_flag',
        title: 'Unauthorized Hack',
        description: 'Should fail',
        isEnabled: true,
        category: FeatureFlagCategory.experimental,
        defaultValue: false,
      );
      expect(
        () => repository.saveFeatureFlag(flag),
        throwsA(isA<AdminSecurityException>()),
      );

      // Standard user cannot append audit logs directly
      final spoofedEntry = AdminAuditEntry(
        id: 'spoofed_01',
        timestamp: DateTime.now(),
        operatorId: 'hacker',
        operatorEmail: 'attacker@evil.com',
        actionType: AdminActionType.godModeToggled,
        targetEntityId: 'system',
        description: 'Spoofed log entry',
        previousEntryHash: AdminAuditEntry.genesisHash,
        entryHash: 'fake_hash',
      );
      expect(
        () => repository.appendAuditEntry(spoofedEntry),
        throwsA(isA<AdminSecurityException>()),
      );

      // Content Moderator can update beverages, but cannot update user roles
      repository.setActiveCallerRole(UserRole.moderator);
      const bevItem = AdminBeverageItem(
        id: 'chamomile_tea',
        name: 'Chamomile Bloom',
        category: 'Tea',
        hydrationIndex: 0.95,
        caffeineMgPer100Ml: 0.0,
        electrolytesMgPer100Ml: 40.0,
        sugarGramsPer100Ml: 0.0,
        density: 1.0,
        viscosity: 1.0,
        colorHex: '#FFDD88',
        isCustom: false,
        isEnabled: true,
      );

      // Beverage save succeeds for moderator
      await expectLater(repository.saveBeverageItem(bevItem), completes);

      // But saving user profile fails for moderator
      final profile = AdminUserProfile.defaultSeedUsers.first;
      expect(
        () => repository.saveUserProfile(profile),
        throwsA(isA<AdminSecurityException>()),
      );
    });
  });
}
