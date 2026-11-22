import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/monetization_models.dart';
import 'local_monetization_repository.dart';

/// Riverpod provider for persistent monetization repository
final monetizationRepositoryProvider = Provider<MonetizationRepository>((ref) {
  return LocalMonetizationRepository();
});

/// Contract for persistent monetization storage, subscriptions, and IAP entitlements
abstract class MonetizationRepository {
  /// Retrieves the active user subscription (defaults to free tier)
  Future<UserSubscription> getSubscription();

  /// Persists the user subscription state
  Future<void> saveSubscription(UserSubscription subscription);

  /// Retrieves the list of purchased or granted one-time entitlements
  Future<List<UserEntitlement>> getEntitlements();

  /// Persists the list of one-time entitlements
  Future<void> saveEntitlements(List<UserEntitlement> entitlements);

  /// Clears monetization records (for testing or user account reset)
  Future<void> clearAll();
}
