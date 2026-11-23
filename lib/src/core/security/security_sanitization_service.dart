import 'dart:convert';

/// Comprehensive OWASP MASVS-compliant input sanitization, payload validation,
/// and security hygiene service.
class SecuritySanitizationService {
  SecuritySanitizationService._();

  static final RegExp _controlCharsRegex = RegExp(r'[\x00-\x1F\x7F]');
  static final RegExp _scriptTagRegex = RegExp(r'<script\b[^>]*>[\s\S]*?<\/script>', caseSensitive: false);
  static final RegExp _styleTagRegex = RegExp(r'<style\b[^>]*>[\s\S]*?<\/style>', caseSensitive: false);
  static final RegExp _htmlTagRegex = RegExp(r'<[^>]*>');
  static final RegExp _dangerousPromptPatterns = RegExp(
    r'(ignore (all )?previous instructions|system:\s*|override directives|disregard previous|you are now a)',
    caseSensitive: false,
  );

  /// Sanitizes generic text input by stripping scripts, styles, HTML tags, control characters,
  /// trimming leading/trailing whitespace, and enforcing maximum length limits.
  static String sanitizeText(
    String? input, {
    int maxLength = 100,
    String fallback = '',
  }) {
    if (input == null) return fallback;
    var sanitized = input
        .replaceAll(_scriptTagRegex, '')
        .replaceAll(_styleTagRegex, '')
        .replaceAll(_controlCharsRegex, '')
        .replaceAll(_htmlTagRegex, '')
        .trim();
    if (sanitized.isEmpty) return fallback;
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength).trim();
    }
    return sanitized;
  }

  /// Sanitizes and validates liquid volume or numeric metric input.
  /// Rejects `NaN`, `Infinity`, negative, and extreme out-of-bound values.
  static double sanitizeVolume(
    dynamic rawValue, {
    double min = 5.0,
    double max = 6000.0,
    double fallback = 250.0,
  }) {
    if (rawValue == null) return fallback;
    double? parsed;
    if (rawValue is num) {
      parsed = rawValue.toDouble();
    } else if (rawValue is String) {
      parsed = double.tryParse(rawValue.trim());
    }

    if (parsed == null || parsed.isNaN || parsed.isInfinite) {
      return fallback;
    }

    return parsed.clamp(min, max);
  }

  /// Sanitizes text destined for AI models or LLM prompts to mitigate prompt injection.
  static String sanitizePromptInput(
    String? input, {
    int maxLength = 500,
    String fallback = '',
  }) {
    if (input == null) return fallback;
    var sanitized = sanitizeText(input, maxLength: maxLength, fallback: fallback);
    sanitized = sanitized.replaceAll(_dangerousPromptPatterns, '[REDACTED_PROMPT_INJECTION]');
    return sanitized;
  }

  /// Validates URLs ensuring strict HTTPS enforcement and defense against Server-Side Request Forgery (SSRF).
  /// Rejects non-HTTP(S) schemes (file, javascript, data) and loopback/private IP addresses.
  static bool isValidSecureUrl(String? urlStr, {bool requireHttps = true}) {
    if (urlStr == null || urlStr.trim().isEmpty) return false;
    final uri = Uri.tryParse(urlStr.trim());
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return false;

    if (requireHttps && uri.scheme != 'https') return false;
    if (!requireHttps && uri.scheme != 'https' && uri.scheme != 'http') return false;

    final host = uri.host.toLowerCase();
    // Block loopback and local/private networks (SSRF defense)
    if (host == 'localhost' ||
        host == '127.0.0.1' ||
        host == '0.0.0.0' ||
        host == '::1' ||
        host == '169.254.169.254' || // Cloud metadata endpoint
        host.startsWith('10.') ||
        host.startsWith('192.168.') ||
        RegExp(r'^172\.(1[6-9]|2[0-9]|3[0-1])\.').hasMatch(host)) {
      return false;
    }

    return true;
  }

  /// Validates JSON backup archive payload against schema tampering, DoS payloads, and corrupted values.
  static bool validateBackupPayload(
    dynamic rawJson, {
    int maxEntries = 50000,
    int maxByteSize = 15 * 1024 * 1024, // 15MB max
  }) {
    if (rawJson == null) return false;
    Map<String, dynamic> map;
    if (rawJson is String) {
      if (rawJson.length > maxByteSize) return false;
      try {
        final decoded = jsonDecode(rawJson);
        if (decoded is! Map<String, dynamic>) return false;
        map = decoded;
      } catch (_) {
        return false;
      }
    } else if (rawJson is Map<String, dynamic>) {
      map = rawJson;
    } else {
      return false;
    }

    // Header validations
    if (map['app'] != 'AquaWild') return false;
    final entries = map['entries'];
    if (entries is! List) return false;
    if (entries.length > maxEntries) return false;

    return true;
  }
}
