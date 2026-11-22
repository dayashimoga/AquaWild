import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/monetization_models.dart';
import 'monetization_repository.dart';

/// Production-grade local offline-first repository for subscriptions and IAP entitlements
class LocalMonetizationRepository implements MonetizationRepository {
  final SharedPreferences? _prefs;

  // In-memory cache for zero-latency synchronous access and unit test execution
  UserSubscription? _cachedSubscription;
  final List<UserEntitlement> _cachedEntitlements = [];

  static const String _subscriptionKey = 'aquawild_user_subscription';
  static const String _entitlementsKey = 'aquawild_user_entitlements';

  LocalMonetizationRepository([this._prefs]);

  @override
  Future<UserSubscription> getSubscription() async {
    if (_cachedSubscription != null) {
      return _cachedSubscription!;
    }

    if (_prefs == null) {
      _cachedSubscription = UserSubscription(
        userId: 'local_user',
        tier: SubscriptionTier.free,
        status: SubscriptionStatus.active,
        startedAt: DateTime.now(),
      );
      return _cachedSubscription!;
    }

    final raw = _prefs.getString(_subscriptionKey);
    if (raw == null || raw.isEmpty) {
      _cachedSubscription = UserSubscription(
        userId: 'local_user',
        tier: SubscriptionTier.free,
        status: SubscriptionStatus.active,
        startedAt: DateTime.now(),
      );
      return _cachedSubscription!;
    }

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _cachedSubscription = UserSubscription.fromJson(map);
      return _cachedSubscription!;
    } catch (_) {
      _cachedSubscription = UserSubscription(
        userId: 'local_user',
        tier: SubscriptionTier.free,
        status: SubscriptionStatus.active,
        startedAt: DateTime.now(),
      );
      return _cachedSubscription!;
    }
  }

  @override
  Future<void> saveSubscription(UserSubscription subscription) async {
    _cachedSubscription = subscription;
    if (_prefs != null) {
      final raw = jsonEncode(subscription.toJson());
      await _prefs.setString(_subscriptionKey, raw);
    }
  }

  @override
  Future<List<UserEntitlement>> getEntitlements() async {
    if (_prefs == null) {
      return List.unmodifiable(_cachedEntitlements);
    }

    final raw = _prefs.getString(_entitlementsKey);
    if (raw == null || raw.isEmpty) {
      return List.unmodifiable(_cachedEntitlements);
    }

    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      _cachedEntitlements
        ..clear()
        ..addAll(
          list.map((item) => UserEntitlement.fromJson(item as Map<String, dynamic>)),
        );
      return List.unmodifiable(_cachedEntitlements);
    } catch (_) {
      return List.unmodifiable(_cachedEntitlements);
    }
  }

  @override
  Future<void> saveEntitlements(List<UserEntitlement> entitlements) async {
    _cachedEntitlements
      ..clear()
      ..addAll(entitlements);

    if (_prefs != null) {
      final list = entitlements.map((e) => e.toJson()).toList();
      await _prefs.setString(_entitlementsKey, jsonEncode(list));
    }
  }

  @override
  Future<void> clearAll() async {
    _cachedSubscription = UserSubscription(
      userId: 'local_user',
      tier: SubscriptionTier.free,
      status: SubscriptionStatus.active,
      startedAt: DateTime.now(),
    );
    _cachedEntitlements.clear();

    if (_prefs != null) {
      await _prefs.remove(_subscriptionKey);
      await _prefs.remove(_entitlementsKey);
    }
  }
}
