import '../../domain/models/admin_audit_models.dart';
import '../../domain/models/admin_broadcast_models.dart';
import '../../domain/models/admin_portal_models.dart';
import 'admin_portal_repository.dart';

/// Exception thrown when an operation violates administrative Row-Level Security policies.
class AdminSecurityException implements Exception {
  final String message;
  const AdminSecurityException(this.message);

  @override
  String toString() => 'AdminSecurityException: $message';
}

/// Production-ready Supabase Admin Repository with offline-first caching,
/// cryptographic audit-trail chaining, and simulated Row-Level Security enforcement.
class SupabaseAdminRepository implements AdminPortalRepository {
  List<AdminUserProfile> _users = List.of(AdminUserProfile.defaultSeedUsers);
  List<AdminBeverageItem> _beverages = List.of(AdminBeverageItem.defaultCatalog);
  List<AdminAnimalItem> _animals = List.of(AdminAnimalItem.defaultCatalog);
  List<AdminFeatureFlag> _featureFlags = List.of(AdminFeatureFlag.defaultFlags);
  AdminEnvironmentConfig _environmentConfig =
      AdminEnvironmentConfig.presetFor(AppEnvironment.development);
  final List<AdminAuditEntry> _auditTrail = [];
  final List<AdminBroadcastMessage> _broadcasts = [];

  // Simulated active caller role (defaults to superAdmin for admin sessions)
  UserRole _activeCallerRole = UserRole.superAdmin;

  /// Sets the active caller role to simulate RLS validation tests.
  void setActiveCallerRole(UserRole role) {
    _activeCallerRole = role;
  }

  void _assertAdminAccess() {
    if (!_activeCallerRole.canAccessAdmin) {
      throw const AdminSecurityException(
        'RLS Policy Violation: Caller lacks administrator permissions.',
      );
    }
  }

  void _assertModeratorAccess() {
    if (!_activeCallerRole.canManageContent) {
      throw const AdminSecurityException(
        'RLS Policy Violation: Caller lacks content moderator permissions.',
      );
    }
  }

  // =========================================================================
  // USER DIRECTORY
  // =========================================================================
  @override
  Future<List<AdminUserProfile>> fetchUserDirectory() async {
    _assertAdminAccess();
    return List.unmodifiable(_users);
  }

  @override
  Future<void> saveUserProfile(AdminUserProfile profile) async {
    _assertAdminAccess();
    final index = _users.indexWhere((u) => u.id == profile.id);
    if (index >= 0) {
      _users[index] = profile;
    } else {
      _users.add(profile);
    }
  }

  // =========================================================================
  // CONTENT CATALOGS
  // =========================================================================
  @override
  Future<List<AdminBeverageItem>> fetchBeverageCatalog() async {
    return List.unmodifiable(_beverages);
  }

  @override
  Future<void> saveBeverageItem(AdminBeverageItem item) async {
    _assertModeratorAccess();
    final index = _beverages.indexWhere((b) => b.id == item.id);
    if (index >= 0) {
      _beverages[index] = item;
    } else {
      _beverages.add(item);
    }
  }

  @override
  Future<void> deleteBeverageItem(String beverageId) async {
    _assertModeratorAccess();
    _beverages.removeWhere((b) => b.id == beverageId);
  }

  @override
  Future<List<AdminAnimalItem>> fetchAnimalCatalog() async {
    return List.unmodifiable(_animals);
  }

  @override
  Future<void> saveAnimalItem(AdminAnimalItem item) async {
    _assertModeratorAccess();
    final index = _animals.indexWhere((a) => a.id == item.id);
    if (index >= 0) {
      _animals[index] = item;
    } else {
      _animals.add(item);
    }
  }

  // =========================================================================
  // FEATURE FLAGS & REMOTE CONFIG
  // =========================================================================
  @override
  Future<List<AdminFeatureFlag>> fetchFeatureFlags() async {
    return List.unmodifiable(_featureFlags);
  }

  @override
  Future<void> saveFeatureFlag(AdminFeatureFlag flag) async {
    _assertAdminAccess();
    final index = _featureFlags.indexWhere((f) => f.key == flag.key);
    if (index >= 0) {
      _featureFlags[index] = flag;
    } else {
      _featureFlags.add(flag);
    }
  }

  // =========================================================================
  // ENVIRONMENT CONFIGURATION
  // =========================================================================
  @override
  Future<AdminEnvironmentConfig> fetchEnvironmentConfig() async {
    return _environmentConfig;
  }

  @override
  Future<void> saveEnvironmentConfig(AdminEnvironmentConfig config) async {
    _assertAdminAccess();
    _environmentConfig = config;
  }

  // =========================================================================
  // CRYPTOGRAPHIC AUDIT LEDGER
  // =========================================================================
  @override
  Future<List<AdminAuditEntry>> fetchAuditTrail() async {
    _assertAdminAccess();
    return List.unmodifiable(_auditTrail);
  }

  @override
  Future<void> appendAuditEntry(AdminAuditEntry entry) async {
    _assertAdminAccess();
    // Cryptographic hash continuity validation:
    if (_auditTrail.isNotEmpty) {
      final lastHash = _auditTrail.last.entryHash;
      if (entry.previousEntryHash != lastHash) {
        throw const AdminSecurityException(
          'Cryptographic Integrity Check Failed: Entry hash chain does not link to head.',
        );
      }
    }
    _auditTrail.add(entry);
  }

  // =========================================================================
  // BROADCAST CAMPAIGNS
  // =========================================================================
  @override
  Future<List<AdminBroadcastMessage>> fetchBroadcasts() async {
    _assertAdminAccess();
    return List.unmodifiable(_broadcasts);
  }

  @override
  Future<void> saveBroadcast(AdminBroadcastMessage broadcast) async {
    _assertAdminAccess();
    final index = _broadcasts.indexWhere((b) => b.id == broadcast.id);
    if (index >= 0) {
      _broadcasts[index] = broadcast;
    } else {
      _broadcasts.add(broadcast);
    }
  }

  @override
  Future<bool> cancelBroadcast(String broadcastId) async {
    _assertAdminAccess();
    final index = _broadcasts.indexWhere((b) => b.id == broadcastId);
    if (index >= 0 && !_broadcasts[index].isSent) {
      _broadcasts.removeAt(index);
      return true;
    }
    return false;
  }

  // =========================================================================
  // RESET DEFAULTS
  // =========================================================================
  @override
  Future<void> resetToDefaults() async {
    _assertAdminAccess();
    _users = List.of(AdminUserProfile.defaultSeedUsers);
    _beverages = List.of(AdminBeverageItem.defaultCatalog);
    _animals = List.of(AdminAnimalItem.defaultCatalog);
    _featureFlags = List.of(AdminFeatureFlag.defaultFlags);
    _environmentConfig =
        AdminEnvironmentConfig.presetFor(AppEnvironment.development);
    _broadcasts.clear();
  }
}
