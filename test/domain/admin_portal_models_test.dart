import 'package:aquawild/src/domain/models/admin_portal_models.dart';
import 'package:aquawild/src/domain/models/beverage_type.dart';
import 'package:aquawild/src/domain/models/exotic_animal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Admin Portal Models Unit Tests', () {
    test('UserRole permissions and string conversion', () {
      expect(UserRole.standard.canAccessAdmin, isFalse);
      expect(UserRole.pro.canAccessAdmin, isFalse);
      expect(UserRole.moderator.canAccessAdmin, isFalse);
      expect(UserRole.admin.canAccessAdmin, isTrue);
      expect(UserRole.superAdmin.canAccessAdmin, isTrue);

      expect(UserRole.moderator.canManageContent, isTrue);
      expect(UserRole.admin.canManageUsers, isTrue);
      expect(UserRole.superAdmin.canSwitchEnvironment, isTrue);
      expect(UserRole.admin.canSwitchEnvironment, isFalse);

      expect(UserRole.fromString('superAdmin'), equals(UserRole.superAdmin));
      expect(UserRole.fromString('ADMIN'), equals(UserRole.admin));
      expect(UserRole.fromString('unknown'), equals(UserRole.standard));
      expect(UserRole.fromString(null), equals(UserRole.standard));
    });

    test('UserAccountStatus string conversion and display names', () {
      expect(UserAccountStatus.active.displayName, equals('Active'));
      expect(UserAccountStatus.suspended.displayName, equals('Suspended'));
      expect(
        UserAccountStatus.pendingVerification.displayName,
        equals('Pending Verification'),
      );

      expect(
        UserAccountStatus.fromString('suspended'),
        equals(UserAccountStatus.suspended),
      );
      expect(
        UserAccountStatus.fromString('invalid'),
        equals(UserAccountStatus.active),
      );
    });

    test('AdminUserProfile serialization and copyWith', () {
      final now = DateTime(2026, 11, 22, 10, 0);
      final profile = AdminUserProfile(
        id: 'usr_test_123',
        email: 'test@aquawild.app',
        displayName: 'Test Operator',
        role: UserRole.admin,
        status: UserAccountStatus.active,
        currentXp: 5000,
        streakCount: 12,
        freezeTokens: 3,
        activeCompanionId: 'red_panda',
        isPro: true,
        createdAt: now,
        lastActiveAt: now,
      );

      final map = profile.toMap();
      expect(map['id'], equals('usr_test_123'));
      expect(map['role'], equals('admin'));
      expect(map['status'], equals('active'));
      expect(map['currentXp'], equals(5000));

      final restored = AdminUserProfile.fromMap(map);
      expect(restored.id, equals(profile.id));
      expect(restored.email, equals(profile.email));
      expect(restored.role, equals(UserRole.admin));
      expect(restored.status, equals(UserAccountStatus.active));
      expect(restored.currentXp, equals(5000));
      expect(restored.streakCount, equals(12));
      expect(restored.isPro, isTrue);

      final updated = profile.copyWith(
        currentXp: 6000,
        role: UserRole.superAdmin,
      );
      expect(updated.currentXp, equals(6000));
      expect(updated.role, equals(UserRole.superAdmin));
      expect(updated.email, equals(profile.email));
    });

    test('AdminGodModeConfig presets and serialization', () {
      const standard = AdminGodModeConfig.standard;
      expect(standard.isGodModeEnabled, isFalse);
      expect(standard.unlockAllCompanions, isFalse);
      expect(standard.forceProStatus, isFalse);

      const unlocked = AdminGodModeConfig.fullUnlocked;
      expect(unlocked.isGodModeEnabled, isTrue);
      expect(unlocked.unlockAllCompanions, isTrue);
      expect(unlocked.unlockAllBiomes, isTrue);
      expect(unlocked.unlockAllThemes, isTrue);
      expect(unlocked.forceProStatus, isTrue);
      expect(unlocked.infiniteStreakFreezes, isTrue);
      expect(unlocked.maxEvolutionStages, isTrue);

      final map = unlocked.toMap();
      final restored = AdminGodModeConfig.fromMap(map);
      expect(restored.isGodModeEnabled, isTrue);
      expect(restored.unlockAllCompanions, isTrue);
      expect(restored.forceProStatus, isTrue);
    });

    test('AdminBeverageItem default catalog and serialization', () {
      final catalog = AdminBeverageItem.defaultCatalog;
      expect(catalog.length, equals(BeverageType.defaultBeverages.length));

      final water = catalog.firstWhere((b) => b.id == 'pure_water');
      expect(water.name, equals('Pure Spring Water'));
      expect(water.hydrationIndex, equals(1.0));
      expect(water.density, equals(1.0));
      expect(water.isEnabled, isTrue);
      expect(water.isCustom, isFalse);

      final map = water.toMap();
      final restored = AdminBeverageItem.fromMap(map);
      expect(restored.id, equals(water.id));
      expect(restored.name, equals(water.name));
      expect(restored.hydrationIndex, equals(1.0));
    });

    test('AdminAnimalItem default catalog and serialization', () {
      final catalog = AdminAnimalItem.defaultCatalog;
      expect(catalog.length, equals(ExoticAnimal.allAnimals.length));

      final redPanda = catalog.firstWhere((a) => a.id == 'red_panda');
      expect(redPanda.name, contains('Ruby'));
      expect(redPanda.unlockXp, equals(0));
      expect(redPanda.tier, equals('Starter'));
      expect(redPanda.isEnabled, isTrue);

      final map = redPanda.toMap();
      final restored = AdminAnimalItem.fromMap(map);
      expect(restored.id, equals(redPanda.id));
      expect(restored.name, equals(redPanda.name));
      expect(restored.species, equals(redPanda.species));
    });

    test('AdminFeatureFlag categories, defaults and serialization', () {
      final flags = AdminFeatureFlag.defaultFlags;
      expect(flags.length, greaterThanOrEqualTo(5));

      final waveFlag = flags.firstWhere((f) => f.key == 'enable_high_precision_waves');
      expect(waveFlag.isEnabled, isTrue);
      expect(waveFlag.category, equals(FeatureFlagCategory.core));

      final map = waveFlag.toMap();
      final restored = AdminFeatureFlag.fromMap(map);
      expect(restored.key, equals('enable_high_precision_waves'));
      expect(restored.isEnabled, isTrue);
      expect(restored.category, equals(FeatureFlagCategory.core));
    });

    test('AppEnvironment presets and environment config serialization', () {
      expect(AppEnvironment.development.displayName, contains('Development'));
      expect(AppEnvironment.staging.displayName, contains('Staging'));
      expect(AppEnvironment.production.displayName, contains('Production'));

      final devConfig = AdminEnvironmentConfig.presetFor(AppEnvironment.development);
      expect(devConfig.isMockMode, isTrue);
      expect(devConfig.supabaseUrl, equals('http://127.0.0.1:54321'));

      final prodConfig = AdminEnvironmentConfig.presetFor(AppEnvironment.production);
      expect(prodConfig.isMockMode, isFalse);
      expect(prodConfig.supabaseUrl, equals('https://api.aquawild.app'));

      final map = devConfig.toMap();
      final restored = AdminEnvironmentConfig.fromMap(map);
      expect(restored.environment, equals(AppEnvironment.development));
      expect(restored.isMockMode, isTrue);
      expect(restored.supabaseUrl, equals('http://127.0.0.1:54321'));
    });
  });
}
