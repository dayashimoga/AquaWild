import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Validation outcomes for local monetization security checks
enum SecurityValidationResult {
  valid,
  tampered,
  clockRollbackDetected,
  corrupted,
  legacyUnsigned,
}

/// Generic container returning decrypted/verified data and security status
class SecurityVerificationResult<T> {
  final SecurityValidationResult status;
  final T? data;
  final String? errorMessage;

  const SecurityVerificationResult({
    required this.status,
    this.data,
    this.errorMessage,
  });

  bool get isValid =>
      status == SecurityValidationResult.valid ||
      status == SecurityValidationResult.legacyUnsigned;

  bool get isTampered => status == SecurityValidationResult.tampered;
  bool get isLegacy => status == SecurityValidationResult.legacyUnsigned;
}

/// Cryptographic service providing tamper detection, HMAC-SHA256 signature stamping,
/// and clock manipulation defense for local monetization persistence
class MonetizationSecurityService {
  final String _baseSecret;

  // Salt prefix embedded for obfuscation
  static const String _defaultPepper = 'aquawild_sec_v1_0x7f4a9b';

  MonetizationSecurityService({String? customSecret})
      : _baseSecret = customSecret ?? _defaultPepper;

  /// Wraps raw JSON in a tamper-evident HMAC-SHA256 security envelope
  String signPayload(
    String rawJson, {
    String? customSalt,
    DateTime? timestamp,
  }) {
    final ts = (timestamp ?? DateTime.now()).millisecondsSinceEpoch;
    final salt = customSalt ?? _generateSalt(ts);
    final signature = _computeHmac(rawJson, salt, ts);

    final envelope = <String, dynamic>{
      'version': 1,
      'payload': rawJson,
      'signature': signature,
      'timestamp': ts,
      'salt': salt,
    };

    return jsonEncode(envelope);
  }

  /// Verifies the cryptographic envelope and deserializes the payload if authentic
  SecurityVerificationResult<T> verifyAndExtract<T>(
    String rawStored,
    T Function(Map<String, dynamic> json) parser, {
    DateTime? currentClock,
  }) {
    if (rawStored.trim().isEmpty) {
      return const SecurityVerificationResult(
        status: SecurityValidationResult.corrupted,
        errorMessage: 'Empty payload',
      );
    }

    Map<String, dynamic> map;
    try {
      final decoded = jsonDecode(rawStored);
      if (decoded is! Map<String, dynamic>) {
        return const SecurityVerificationResult(
          status: SecurityValidationResult.corrupted,
          errorMessage: 'Payload is not a JSON object',
        );
      }
      map = decoded;
    } catch (e) {
      return SecurityVerificationResult(
        status: SecurityValidationResult.corrupted,
        errorMessage: 'Invalid JSON: $e',
      );
    }

    // Check if this is an envelope or legacy raw model
    final isEnvelope = map.containsKey('version') &&
        map.containsKey('payload') &&
        map.containsKey('signature') &&
        map.containsKey('timestamp') &&
        map.containsKey('salt');

    if (!isEnvelope) {
      // Legacy unsigned format - allow forward migration
      try {
        final parsed = parser(map);
        return SecurityVerificationResult(
          status: SecurityValidationResult.legacyUnsigned,
          data: parsed,
          errorMessage: 'Unsigned legacy format requires forward migration',
        );
      } catch (e) {
        return SecurityVerificationResult(
          status: SecurityValidationResult.corrupted,
          errorMessage: 'Legacy format parsing failed: $e',
        );
      }
    }

    final payloadStr = map['payload'] as String? ?? '';
    final signature = map['signature'] as String? ?? '';
    final timestamp = map['timestamp'] as int? ?? 0;
    final salt = map['salt'] as String? ?? '';

    // Clock rollback defense: if stored timestamp is significantly in the future (>2h)
    final nowMs = (currentClock ?? DateTime.now()).millisecondsSinceEpoch;
    const maxFutureSkewMs = 2 * 60 * 60 * 1000; // 2 hours
    if (timestamp > nowMs + maxFutureSkewMs) {
      return const SecurityVerificationResult(
        status: SecurityValidationResult.clockRollbackDetected,
        errorMessage: 'Clock rollback or future timestamp tampering detected',
      );
    }

    // Compute expected HMAC
    final expectedSignature = _computeHmac(payloadStr, salt, timestamp);
    if (!_constantTimeEquals(signature, expectedSignature)) {
      return const SecurityVerificationResult(
        status: SecurityValidationResult.tampered,
        errorMessage:
            'Cryptographic signature mismatch: local storage tampering detected',
      );
    }

    // Deserialize verified payload
    try {
      final payloadJson = jsonDecode(payloadStr) as Map<String, dynamic>;
      final parsed = parser(payloadJson);
      return SecurityVerificationResult(
        status: SecurityValidationResult.valid,
        data: parsed,
      );
    } catch (e) {
      return SecurityVerificationResult(
        status: SecurityValidationResult.corrupted,
        errorMessage: 'Verified payload deserialization failed: $e',
      );
    }
  }

  /// Verifies a list-based payload envelope (e.g. for UserEntitlement lists)
  SecurityVerificationResult<List<T>> verifyAndExtractList<T>(
    String rawStored,
    T Function(Map<String, dynamic> json) parser, {
    DateTime? currentClock,
  }) {
    if (rawStored.trim().isEmpty) {
      return const SecurityVerificationResult(
        status: SecurityValidationResult.valid,
        data: [],
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(rawStored);
    } catch (e) {
      return SecurityVerificationResult(
        status: SecurityValidationResult.corrupted,
        errorMessage: 'Invalid JSON: $e',
      );
    }

    // Check if legacy raw list
    if (decoded is List) {
      try {
        final list = decoded
            .map((item) => parser(item as Map<String, dynamic>))
            .toList();
        return SecurityVerificationResult(
          status: SecurityValidationResult.legacyUnsigned,
          data: list,
          errorMessage: 'Unsigned legacy list requires forward migration',
        );
      } catch (e) {
        return SecurityVerificationResult(
          status: SecurityValidationResult.corrupted,
          errorMessage: 'Legacy list parsing failed: $e',
        );
      }
    }

    if (decoded is! Map<String, dynamic>) {
      return const SecurityVerificationResult(
        status: SecurityValidationResult.corrupted,
        errorMessage: 'Payload is neither envelope nor list',
      );
    }

    final isEnvelope = decoded.containsKey('version') &&
        decoded.containsKey('payload') &&
        decoded.containsKey('signature');

    if (!isEnvelope) {
      return const SecurityVerificationResult(
        status: SecurityValidationResult.corrupted,
        errorMessage: 'Malformed envelope structure',
      );
    }

    final payloadStr = decoded['payload'] as String? ?? '';
    final signature = decoded['signature'] as String? ?? '';
    final timestamp = decoded['timestamp'] as int? ?? 0;
    final salt = decoded['salt'] as String? ?? '';

    final nowMs = (currentClock ?? DateTime.now()).millisecondsSinceEpoch;
    const maxFutureSkewMs = 2 * 60 * 60 * 1000;
    if (timestamp > nowMs + maxFutureSkewMs) {
      return const SecurityVerificationResult(
        status: SecurityValidationResult.clockRollbackDetected,
        errorMessage: 'Clock rollback or future timestamp tampering detected',
      );
    }

    final expectedSignature = _computeHmac(payloadStr, salt, timestamp);
    if (!_constantTimeEquals(signature, expectedSignature)) {
      return const SecurityVerificationResult(
        status: SecurityValidationResult.tampered,
        errorMessage: 'Cryptographic signature mismatch on entitlements list',
      );
    }

    try {
      final innerList = jsonDecode(payloadStr) as List<dynamic>;
      final list = innerList
          .map((item) => parser(item as Map<String, dynamic>))
          .toList();
      return SecurityVerificationResult(
        status: SecurityValidationResult.valid,
        data: list,
      );
    } catch (e) {
      return SecurityVerificationResult(
        status: SecurityValidationResult.corrupted,
        errorMessage: 'Verified list payload deserialization failed: $e',
      );
    }
  }

  /// Computes HMAC-SHA256 signature for given inputs
  String _computeHmac(String payload, String salt, int timestamp) {
    final keyBytes = utf8.encode('$_baseSecret:$salt');
    final messageBytes = utf8.encode('$payload:$timestamp');
    final hmac = Hmac(sha256, keyBytes);
    return hmac.convert(messageBytes).toString();
  }

  /// Generates a pseudo-random deterministic salt based on timestamp and secret
  String _generateSalt(int timestamp) {
    final raw = '$_baseSecret:$timestamp';
    return sha256.convert(utf8.encode(raw)).toString().substring(0, 16);
  }

  /// Constant-time string comparison to prevent timing side-channel attacks
  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}
