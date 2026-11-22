import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/admin_audit_models.dart';
import '../../domain/models/admin_broadcast_models.dart';
import '../../domain/models/admin_portal_models.dart';
import 'supabase_admin_repository.dart';

/// Riverpod provider for the Admin Portal Repository.
final adminPortalRepositoryProvider = Provider<AdminPortalRepository>((ref) {
  return SupabaseAdminRepository();
});

/// Abstract data contract for administrative portal persistence and Supabase integration.
abstract class AdminPortalRepository {
  /// Fetches the directory of registered users and their RBAC profiles.
  Future<List<AdminUserProfile>> fetchUserDirectory();

  /// Updates or saves an administrative user profile (XP, freezes, status, role).
  Future<void> saveUserProfile(AdminUserProfile profile);

  /// Fetches the beverage catalog configuration.
  Future<List<AdminBeverageItem>> fetchBeverageCatalog();

  /// Saves or updates a beverage item.
  Future<void> saveBeverageItem(AdminBeverageItem item);

  /// Deletes a beverage item by its identifier.
  Future<void> deleteBeverageItem(String beverageId);

  /// Fetches the animal companion catalog configuration.
  Future<List<AdminAnimalItem>> fetchAnimalCatalog();

  /// Saves or updates an animal companion item.
  Future<void> saveAnimalItem(AdminAnimalItem item);

  /// Fetches dynamic runtime feature flags.
  Future<List<AdminFeatureFlag>> fetchFeatureFlags();

  /// Saves or toggles a feature flag.
  Future<void> saveFeatureFlag(AdminFeatureFlag flag);

  /// Fetches the active backend environment configuration.
  Future<AdminEnvironmentConfig> fetchEnvironmentConfig();

  /// Persists the active backend environment configuration.
  Future<void> saveEnvironmentConfig(AdminEnvironmentConfig config);

  /// Fetches the immutable cryptographic audit trail.
  Future<List<AdminAuditEntry>> fetchAuditTrail();

  /// Appends a new tamper-evident hash-chained audit record.
  Future<void> appendAuditEntry(AdminAuditEntry entry);

  /// Fetches all broadcast campaigns (dispatched and scheduled).
  Future<List<AdminBroadcastMessage>> fetchBroadcasts();

  /// Saves or schedules a notification broadcast campaign.
  Future<void> saveBroadcast(AdminBroadcastMessage broadcast);

  /// Cancels an existing scheduled broadcast campaign.
  Future<bool> cancelBroadcast(String broadcastId);

  /// Resets all administrative data back to factory seed defaults.
  Future<void> resetToDefaults();
}
