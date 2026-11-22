import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/admin_audit_models.dart';

/// Service managing an immutable, append-only cryptographic audit trail.
/// Every administrative mutation is chained to the previous entry via SHA-256.
class AdminAuditLogService {
  final SharedPreferences? _prefs;
  static const String _storageKey = 'aquawild_admin_audit_trail_v1';

  final List<AdminAuditEntry> _entries = [];

  AdminAuditLogService({SharedPreferences? prefs}) : _prefs = prefs {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    if (_prefs == null) return;
    final jsonList = _prefs.getStringList(_storageKey);
    if (jsonList != null && jsonList.isNotEmpty) {
      for (final raw in jsonList) {
        try {
          final map = jsonDecode(raw) as Map<String, dynamic>;
          _entries.add(AdminAuditEntry.fromMap(map));
        } catch (_) {
          // Ignore corrupted entries in storage
        }
      }
    }
  }

  Future<void> _persistToStorage() async {
    if (_prefs == null) return;
    final serialized = _entries.map((e) => jsonEncode(e.toMap())).toList();
    await _prefs.setStringList(_storageKey, serialized);
  }

  /// Appends a new immutable action to the cryptographic audit trail.
  Future<AdminAuditEntry> recordAction({
    required String operatorId,
    required String operatorEmail,
    required AdminActionType actionType,
    required String targetEntityId,
    required String description,
    String? previousValue,
    String? newValue,
    String clientIp = '127.0.0.1 (Local Session)',
    String platformInfo = 'AquaWild Admin Desktop/Web',
  }) async {
    final now = DateTime.now();
    final previousHash = _entries.isEmpty
        ? AdminAuditEntry.genesisHash
        : _entries.last.entryHash;
    final id = 'audit_${now.millisecondsSinceEpoch}_${_entries.length + 1}';

    final entryHash = AdminAuditEntry.computeHash(
      previousEntryHash: previousHash,
      id: id,
      timestamp: now,
      operatorId: operatorId,
      actionType: actionType,
      targetEntityId: targetEntityId,
      description: description,
      previousValue: previousValue,
      newValue: newValue,
    );

    final entry = AdminAuditEntry(
      id: id,
      timestamp: now,
      operatorId: operatorId,
      operatorEmail: operatorEmail,
      actionType: actionType,
      targetEntityId: targetEntityId,
      description: description,
      previousValue: previousValue,
      newValue: newValue,
      clientIp: clientIp,
      platformInfo: platformInfo,
      previousEntryHash: previousHash,
      entryHash: entryHash,
    );

    _entries.add(entry);
    await _persistToStorage();
    return entry;
  }

  /// Returns recent audit entries in reverse chronological order.
  List<AdminAuditEntry> getEntries({
    int limit = 100,
    AdminActionType? filterAction,
    String? operatorFilter,
    String? targetEntityFilter,
  }) {
    Iterable<AdminAuditEntry> filtered = _entries.reversed;

    if (filterAction != null) {
      filtered = filtered.where((e) => e.actionType == filterAction);
    }
    if (operatorFilter != null && operatorFilter.trim().isNotEmpty) {
      final q = operatorFilter.trim().toLowerCase();
      filtered = filtered.where((e) =>
          e.operatorId.toLowerCase().contains(q) ||
          e.operatorEmail.toLowerCase().contains(q));
    }
    if (targetEntityFilter != null && targetEntityFilter.trim().isNotEmpty) {
      final q = targetEntityFilter.trim().toLowerCase();
      filtered =
          filtered.where((e) => e.targetEntityId.toLowerCase().contains(q));
    }

    return filtered.take(limit).toList();
  }

  /// Cryptographically verifies the entire audit log hash chain from genesis to head.
  AuditVerificationResult verifyTrailIntegrity() {
    if (_entries.isEmpty) {
      return AuditVerificationResult.valid(0);
    }

    for (int i = 0; i < _entries.length; i++) {
      final current = _entries[i];

      // 1. Verify previous hash chaining
      final expectedPrev = i == 0
          ? AdminAuditEntry.genesisHash
          : _entries[i - 1].entryHash;
      if (current.previousEntryHash != expectedPrev) {
        return AuditVerificationResult.compromised(
          index: i,
          entryId: current.id,
          totalChecked: i,
          reason: 'Chain link broken: previousEntryHash does not match previous block hash.',
        );
      }

      // 2. Verify cryptographic payload hash
      if (!current.verifyIntegrity()) {
        return AuditVerificationResult.compromised(
          index: i,
          entryId: current.id,
          totalChecked: i,
          reason: 'Payload signature mismatch: entry contents have been altered.',
        );
      }
    }

    return AuditVerificationResult.valid(_entries.length);
  }

  /// Total count of immutable audit records.
  int get totalEntriesCount => _entries.length;

  /// Clear in-memory entries (for unit testing isolation only).
  void clearMemoryForTest() {
    _entries.clear();
  }
}

/// Riverpod provider for the Admin Audit Log Service.
final adminAuditLogServiceProvider = Provider<AdminAuditLogService>((ref) {
  return AdminAuditLogService();
});
