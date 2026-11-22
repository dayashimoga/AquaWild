import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Validation status outcomes for in-app purchase receipts
enum ReceiptValidationStatus {
  verified,
  invalidSignature,
  alreadyRedeemed,
  bundleMismatch,
  expired,
  unsupportedStore,
}

/// Normalized in-app purchase receipt model across Apple, Google, and Sandbox
class PurchaseReceipt {
  final String transactionId;
  final String productId;
  final DateTime purchaseDate;
  final String store;
  final String bundleId;
  final String signature;
  final String? rawReceiptData;

  const PurchaseReceipt({
    required this.transactionId,
    required this.productId,
    required this.purchaseDate,
    required this.store,
    this.bundleId = 'com.aquawild.app',
    required this.signature,
    this.rawReceiptData,
  });

  Map<String, dynamic> toJson() => {
        'transaction_id': transactionId,
        'product_id': productId,
        'purchase_date': purchaseDate.toIso8601String(),
        'store': store,
        'bundle_id': bundleId,
        'signature': signature,
        'raw_receipt_data': rawReceiptData,
      };

  factory PurchaseReceipt.fromJson(Map<String, dynamic> json) {
    return PurchaseReceipt(
      transactionId: json['transaction_id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      purchaseDate: json['purchase_date'] != null
          ? DateTime.parse(json['purchase_date'] as String)
          : DateTime.now(),
      store: json['store'] as String? ?? 'sandbox',
      bundleId: json['bundle_id'] as String? ?? 'com.aquawild.app',
      signature: json['signature'] as String? ?? '',
      rawReceiptData: json['raw_receipt_data'] as String?,
    );
  }
}

/// Outcome of a receipt validation check
class ReceiptValidationResult {
  final bool isValid;
  final ReceiptValidationStatus status;
  final String message;
  final PurchaseReceipt? verifiedReceipt;

  const ReceiptValidationResult({
    required this.isValid,
    required this.status,
    required this.message,
    this.verifiedReceipt,
  });

  factory ReceiptValidationResult.success(PurchaseReceipt receipt) {
    return ReceiptValidationResult(
      isValid: true,
      status: ReceiptValidationStatus.verified,
      message: 'Receipt cryptographically verified',
      verifiedReceipt: receipt,
    );
  }

  factory ReceiptValidationResult.failed(
    ReceiptValidationStatus status,
    String message,
  ) {
    return ReceiptValidationResult(
      isValid: false,
      status: status,
      message: message,
    );
  }
}

/// Service providing store receipt verification, signature checks,
/// and replay attack prevention for in-app purchases and subscriptions
class ReceiptVerificationService {
  final SharedPreferences? _prefs;
  final String _signingSecret;

  static const String _defaultSecret = 'aquawild_receipt_sec_0x99e2a';
  static const String _redeemedTxKey = 'aquawild_redeemed_transactions';

  final Set<String> _redeemedTransactions = {};

  ReceiptVerificationService({
    SharedPreferences? prefs,
    String? signingSecret,
  })  : _prefs = prefs,
        _signingSecret = signingSecret ?? _defaultSecret {
    _loadRedeemedTransactions();
  }

  void _loadRedeemedTransactions() {
    if (_prefs != null) {
      final list = _prefs.getStringList(_redeemedTxKey);
      if (list != null) {
        _redeemedTransactions.addAll(list);
      }
    }
  }

  Future<void> _saveRedeemedTransactions() async {
    if (_prefs != null) {
      await _prefs.setStringList(
        _redeemedTxKey,
        _redeemedTransactions.toList(),
      );
    }
  }

  /// Verifies an incoming purchase receipt
  ReceiptValidationResult verifyReceipt(
    PurchaseReceipt receipt, {
    bool allowReplayForSubscriptions = false,
  }) {
    // 1. Bundle ID validation
    const validBundles = ['com.aquawild.app', 'com.aquawild.web'];
    if (!validBundles.contains(receipt.bundleId)) {
      return ReceiptValidationResult.failed(
        ReceiptValidationStatus.bundleMismatch,
        'Invalid bundle ID: expected one of $validBundles, got ${receipt.bundleId}',
      );
    }

    // 2. Replay attack check for one-time purchases
    if (!allowReplayForSubscriptions &&
        _redeemedTransactions.contains(receipt.transactionId)) {
      return ReceiptValidationResult.failed(
        ReceiptValidationStatus.alreadyRedeemed,
        'Transaction ${receipt.transactionId} has already been redeemed',
      );
    }

    // 3. Supported store check
    const supportedStores = [
      'apple_app_store',
      'google_play',
      'stripe',
      'sandbox',
      'web_sandbox',
      'desktop_sandbox',
      'iap',
      'admin_override',
      'admin_god_mode',
    ];
    if (!supportedStores.contains(receipt.store)) {
      return ReceiptValidationResult.failed(
        ReceiptValidationStatus.unsupportedStore,
        'Unsupported store provider: ${receipt.store}',
      );
    }

    // 4. Cryptographic signature check
    final expectedSignature = generateSignature(
      bundleId: receipt.bundleId,
      productId: receipt.productId,
      transactionId: receipt.transactionId,
      purchaseDate: receipt.purchaseDate,
    );

    if (receipt.signature != expectedSignature) {
      return ReceiptValidationResult.failed(
        ReceiptValidationStatus.invalidSignature,
        'Receipt signature verification failed: signature does not match payload',
      );
    }

    // 5. Mark transaction as redeemed
    _redeemedTransactions.add(receipt.transactionId);
    _saveRedeemedTransactions();

    return ReceiptValidationResult.success(receipt);
  }

  /// Computes expected signature for a receipt payload
  String generateSignature({
    required String bundleId,
    required String productId,
    required String transactionId,
    required DateTime purchaseDate,
  }) {
    final payload = '$bundleId:$productId:$transactionId:${purchaseDate.millisecondsSinceEpoch}';
    final hmac = Hmac(sha256, utf8.encode(_signingSecret));
    return hmac.convert(utf8.encode(payload)).toString();
  }

  /// Helper generating a cryptographically valid sandbox receipt for tests/simulations
  PurchaseReceipt createSandboxReceipt({
    required String productId,
    required String transactionId,
    String store = 'sandbox',
    String bundleId = 'com.aquawild.app',
    DateTime? purchaseDate,
  }) {
    final date = purchaseDate ?? DateTime.now();
    final signature = generateSignature(
      bundleId: bundleId,
      productId: productId,
      transactionId: transactionId,
      purchaseDate: date,
    );

    return PurchaseReceipt(
      transactionId: transactionId,
      productId: productId,
      purchaseDate: date,
      store: store,
      bundleId: bundleId,
      signature: signature,
      rawReceiptData: 'sandbox_verified_token_$transactionId',
    );
  }

  /// Checks if a transaction ID has already been redeemed
  bool isTransactionRedeemed(String transactionId) {
    return _redeemedTransactions.contains(transactionId);
  }

  /// Clears in-memory and persisted redeemed transaction cache (for testing)
  Future<void> clearRedeemedCache() async {
    _redeemedTransactions.clear();
    if (_prefs != null) {
      await _prefs.remove(_redeemedTxKey);
    }
  }
}
