import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/security/monetization_security_service.dart';
import '../../domain/models/monetization_models.dart';
import 'monetization_repository.dart';

/// Production-grade local offline-first repository for subscriptions and IAP entitlements
/// with cryptographic tamper-detection and 72-hour offline grace period enforcement
class LocalMonetizationRepository implements MonetizationRepository {
  final SharedPreferences? _prefs;
  final MonetizationSecurityService _securityService;

  // In-memory cache for zero-latency synchronous access and unit test execution
  UserSubscription? _cachedSubscription;
  final List<UserEntitlement> _cachedEntitlements = [];

  static const String _subscriptionKey = 'aquawild_user_subscription';
  static const String _entitlementsKey = 'aquawild_user_entitlements';

  LocalMonetizationRepository([
    this._prefs,
    MonetizationSecurityService? securityService,
  ]) : _securityService = securityService ?? MonetizationSecurityService();

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

    final verification = _securityService.verifyAndExtract<UserSubscription>(
      raw,
      (map) => UserSubscription.fromJson(map),
    );

    switch (verification.status) {
      case SecurityValidationResult.valid:
        _cachedSubscription = verification.data;
        return _cachedSubscription!;

      case SecurityValidationResult.legacyUnsigned:
        // Forward migrate legacy unsealed subscription with a signature
        _cachedSubscription = verification.data;
        if (_cachedSubscription != null) {
          unawaited(saveSubscription(_cachedSubscription!));
        }
        return _cachedSubscription!;

      case SecurityValidationResult.tampered:
      case SecurityValidationResult.clockRollbackDetected:
      case SecurityValidationResult.corrupted:
        // Local tampering detected or invalid data: reset safely to free tier
        final cleanFree = UserSubscription(
          userId: 'local_user',
          tier: SubscriptionTier.free,
          status: SubscriptionStatus.active,
          startedAt: DateTime.now(),
        );
        _cachedSubscription = cleanFree;
        unawaited(saveSubscription(cleanFree));
        return cleanFree;
    }
  }

  @override
  Future<void> saveSubscription(UserSubscription subscription) async {
    _cachedSubscription = subscription;
    if (_prefs != null) {
      final payload = jsonEncode(subscription.toJson());
      final sealedEnvelope = _securityService.signPayload(payload);
      await _prefs.setString(_subscriptionKey, sealedEnvelope);
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

    final verification =
        _securityService.verifyAndExtractList<UserEntitlement>(
      raw,
      (item) => UserEntitlement.fromJson(item),
    );

    switch (verification.status) {
      case SecurityValidationResult.valid:
        _cachedEntitlements
          ..clear()
          ..addAll(verification.data ?? []);
        return List.unmodifiable(_cachedEntitlements);

      case SecurityValidationResult.legacyUnsigned:
        _cachedEntitlements
          ..clear()
          ..addAll(verification.data ?? []);
        unawaited(saveEntitlements(_cachedEntitlements));
        return List.unmodifiable(_cachedEntitlements);

      case SecurityValidationResult.tampered:
      case SecurityValidationResult.clockRollbackDetected:
      case SecurityValidationResult.corrupted:
        // Local tampering detected on entitlements: purge compromised list
        _cachedEntitlements.clear();
        unawaited(saveEntitlements(_cachedEntitlements));
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
      final payload = jsonEncode(list);
      final sealedEnvelope = _securityService.signPayload(payload);
      await _prefs.setString(_entitlementsKey, sealedEnvelope);
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
