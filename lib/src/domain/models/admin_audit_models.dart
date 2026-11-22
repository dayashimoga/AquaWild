import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Standard administrative action types recorded in the tamper-evident audit log.
enum AdminActionType {
  godModeToggled,
  userXpAdjusted,
  userStatusChanged,
  userRoleChanged,
  freezeTokensGranted,
  beverageCreated,
  beverageUpdated,
  beverageDeleted,
  animalUpdated,
  featureFlagToggled,
  environmentSwitched,
  notificationBroadcasted,
  entitlementGranted,
  entitlementRevoked,
  configurationReset;

  String get displayName {
    switch (this) {
      case godModeToggled:
        return 'God-Mode Toggled';
      case userXpAdjusted:
        return 'User XP Adjusted';
      case userStatusChanged:
        return 'User Status Changed';
      case userRoleChanged:
        return 'User Role Changed';
      case freezeTokensGranted:
        return 'Freeze Tokens Granted';
      case beverageCreated:
        return 'Beverage Created';
      case beverageUpdated:
        return 'Beverage Updated';
      case beverageDeleted:
        return 'Beverage Deleted';
      case animalUpdated:
        return 'Animal Companion Updated';
      case featureFlagToggled:
        return 'Feature Flag Toggled';
      case environmentSwitched:
        return 'Environment Switched';
      case notificationBroadcasted:
        return 'Notification Broadcasted';
      case entitlementGranted:
        return 'Entitlement Granted';
      case entitlementRevoked:
        return 'Entitlement Revoked';
      case configurationReset:
        return 'Configuration Reset';
    }
  }

  static AdminActionType fromString(String? value) {
    return AdminActionType.values.firstWhere(
      (e) => e.name.toLowerCase() == (value ?? '').toLowerCase(),
      orElse: () => AdminActionType.godModeToggled,
    );
  }
}

/// Immutable, tamper-evident cryptographic audit log entry.
/// Entries are linked in an append-only hash chain:
/// H_i = SHA256(H_{i-1} || id || timestamp || operatorId || actionType || targetEntityId || description || previousValue || newValue)
@immutable
class AdminAuditEntry {
  static const String genesisHash =
      '0000000000000000000000000000000000000000000000000000000000000000';

  final String id;
  final DateTime timestamp;
  final String operatorId;
  final String operatorEmail;
  final AdminActionType actionType;
  final String targetEntityId;
  final String description;
  final String? previousValue;
  final String? newValue;
  final String clientIp;
  final String platformInfo;
  final String previousEntryHash;
  final String entryHash;

  const AdminAuditEntry({
    required this.id,
    required this.timestamp,
    required this.operatorId,
    required this.operatorEmail,
    required this.actionType,
    required this.targetEntityId,
    required this.description,
    this.previousValue,
    this.newValue,
    this.clientIp = '127.0.0.1 (Local Session)',
    this.platformInfo = 'AquaWild Admin Desktop/Web',
    required this.previousEntryHash,
    required this.entryHash,
  });

  /// Computes the deterministic SHA-256 hash for an entry given its contents and the previous hash.
  static String computeHash({
    required String previousEntryHash,
    required String id,
    required DateTime timestamp,
    required String operatorId,
    required AdminActionType actionType,
    required String targetEntityId,
    required String description,
    String? previousValue,
    String? newValue,
  }) {
    final payload = [
      previousEntryHash,
      id,
      timestamp.millisecondsSinceEpoch.toString(),
      operatorId,
      actionType.name,
      targetEntityId,
      description,
      previousValue ?? 'null',
      newValue ?? 'null',
    ].join(':');

    return sha256.convert(utf8.encode(payload)).toString();
  }

  /// Verifies that this entry's hash matches its contents and previousEntryHash.
  bool verifyIntegrity() {
    final expected = computeHash(
      previousEntryHash: previousEntryHash,
      id: id,
      timestamp: timestamp,
      operatorId: operatorId,
      actionType: actionType,
      targetEntityId: targetEntityId,
      description: description,
      previousValue: previousValue,
      newValue: newValue,
    );
    return entryHash == expected;
  }

  AdminAuditEntry copyWith({
    String? id,
    DateTime? timestamp,
    String? operatorId,
    String? operatorEmail,
    AdminActionType? actionType,
    String? targetEntityId,
    String? description,
    String? previousValue,
    String? newValue,
    String? clientIp,
    String? platformInfo,
    String? previousEntryHash,
    String? entryHash,
  }) {
    return AdminAuditEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      operatorId: operatorId ?? this.operatorId,
      operatorEmail: operatorEmail ?? this.operatorEmail,
      actionType: actionType ?? this.actionType,
      targetEntityId: targetEntityId ?? this.targetEntityId,
      description: description ?? this.description,
      previousValue: previousValue ?? this.previousValue,
      newValue: newValue ?? this.newValue,
      clientIp: clientIp ?? this.clientIp,
      platformInfo: platformInfo ?? this.platformInfo,
      previousEntryHash: previousEntryHash ?? this.previousEntryHash,
      entryHash: entryHash ?? this.entryHash,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'operatorId': operatorId,
      'operatorEmail': operatorEmail,
      'actionType': actionType.name,
      'targetEntityId': targetEntityId,
      'description': description,
      'previousValue': previousValue,
      'newValue': newValue,
      'clientIp': clientIp,
      'platformInfo': platformInfo,
      'previousEntryHash': previousEntryHash,
      'entryHash': entryHash,
    };
  }

  factory AdminAuditEntry.fromMap(Map<String, dynamic> map) {
    return AdminAuditEntry(
      id: map['id'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      operatorId: map['operatorId'] as String? ?? 'operator_root',
      operatorEmail: map['operatorEmail'] as String? ?? 'admin@aquawild.internal',
      actionType: AdminActionType.fromString(map['actionType'] as String?),
      targetEntityId: map['targetEntityId'] as String? ?? 'system',
      description: map['description'] as String? ?? '',
      previousValue: map['previousValue'] as String?,
      newValue: map['newValue'] as String?,
      clientIp: map['clientIp'] as String? ?? '127.0.0.1 (Local Session)',
      platformInfo:
          map['platformInfo'] as String? ?? 'AquaWild Admin Desktop/Web',
      previousEntryHash:
          map['previousEntryHash'] as String? ?? AdminAuditEntry.genesisHash,
      entryHash: map['entryHash'] as String? ?? '',
    );
  }
}

/// Result of an audit trail verification sweep.
class AuditVerificationResult {
  final bool isValid;
  final int totalEntriesChecked;
  final int? compromisedIndex;
  final String? compromisedEntryId;
  final String message;

  const AuditVerificationResult({
    required this.isValid,
    required this.totalEntriesChecked,
    this.compromisedIndex,
    this.compromisedEntryId,
    required this.message,
  });

  factory AuditVerificationResult.valid(int totalEntries) {
    return AuditVerificationResult(
      isValid: true,
      totalEntriesChecked: totalEntries,
      message: 'Audit chain intact: all $totalEntries entries verified cryptographically.',
    );
  }

  factory AuditVerificationResult.compromised({
    required int index,
    required String entryId,
    required int totalChecked,
    required String reason,
  }) {
    return AuditVerificationResult(
      isValid: false,
      totalEntriesChecked: totalChecked,
      compromisedIndex: index,
      compromisedEntryId: entryId,
      message: 'Audit chain compromised at entry #$index ($entryId): $reason',
    );
  }
}
