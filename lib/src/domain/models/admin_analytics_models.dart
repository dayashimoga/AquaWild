import 'package:flutter/foundation.dart';

/// Breakdown of revenue and subscriber volume for a specific SKU.
@immutable
class SkuSalesPerformance {
  final String sku;
  final String productName;
  final int totalUnitsSold;
  final double grossRevenueUsd;
  final int activeSubscriberCount;
  final double conversionRatePercent;

  const SkuSalesPerformance({
    required this.sku,
    required this.productName,
    required this.totalUnitsSold,
    required this.grossRevenueUsd,
    required this.activeSubscriberCount,
    required this.conversionRatePercent,
  });

  SkuSalesPerformance copyWith({
    String? sku,
    String? productName,
    int? totalUnitsSold,
    double? grossRevenueUsd,
    int? activeSubscriberCount,
    double? conversionRatePercent,
  }) {
    return SkuSalesPerformance(
      sku: sku ?? this.sku,
      productName: productName ?? this.productName,
      totalUnitsSold: totalUnitsSold ?? this.totalUnitsSold,
      grossRevenueUsd: grossRevenueUsd ?? this.grossRevenueUsd,
      activeSubscriberCount:
          activeSubscriberCount ?? this.activeSubscriberCount,
      conversionRatePercent:
          conversionRatePercent ?? this.conversionRatePercent,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sku': sku,
      'productName': productName,
      'totalUnitsSold': totalUnitsSold,
      'grossRevenueUsd': grossRevenueUsd,
      'activeSubscriberCount': activeSubscriberCount,
      'conversionRatePercent': conversionRatePercent,
    };
  }

  factory SkuSalesPerformance.fromMap(Map<String, dynamic> map) {
    return SkuSalesPerformance(
      sku: map['sku'] as String? ?? '',
      productName: map['productName'] as String? ?? 'SKU Product',
      totalUnitsSold: (map['totalUnitsSold'] as num?)?.toInt() ?? 0,
      grossRevenueUsd: (map['grossRevenueUsd'] as num?)?.toDouble() ?? 0.0,
      activeSubscriberCount:
          (map['activeSubscriberCount'] as num?)?.toInt() ?? 0,
      conversionRatePercent:
          (map['conversionRatePercent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Real-time financial, subscriber volume, and engagement KPI summary.
@immutable
class MonetizationKpiSummary {
  final int totalUsersCount;
  final int activeProUsersCount;
  final int freeUsersCount;
  final double monthlyRecurringRevenueUsd; // MRR
  final double annualRecurringRevenueUsd; // ARR
  final double lifetimeGrossRevenueUsd;
  final double averageRevenuePerUserUsd; // ARPU
  final int trialActiveCount;
  final double trialToPaidConversionRate; // Percentage e.g. 68.5%
  final double churnRatePercent; // Percentage e.g. 2.1%
  final List<SkuSalesPerformance> skuBreakdown;
  final DateTime calculatedAt;

  const MonetizationKpiSummary({
    required this.totalUsersCount,
    required this.activeProUsersCount,
    required this.freeUsersCount,
    required this.monthlyRecurringRevenueUsd,
    required this.annualRecurringRevenueUsd,
    required this.lifetimeGrossRevenueUsd,
    required this.averageRevenuePerUserUsd,
    required this.trialActiveCount,
    required this.trialToPaidConversionRate,
    required this.churnRatePercent,
    required this.skuBreakdown,
    required this.calculatedAt,
  });

  /// Formatted MRR in USD (e.g. $14,250.00).
  String get formattedMrr =>
      '\$${monthlyRecurringRevenueUsd.toStringAsFixed(2)}';

  /// Formatted ARR in USD (e.g. $171,000.00).
  String get formattedArr =>
      '\$${annualRecurringRevenueUsd.toStringAsFixed(2)}';

  /// Formatted Lifetime Gross Revenue in USD.
  String get formattedGross =>
      '\$${lifetimeGrossRevenueUsd.toStringAsFixed(2)}';

  /// Formatted ARPU in USD (e.g. $4.85).
  String get formattedArpu =>
      '\$${averageRevenuePerUserUsd.toStringAsFixed(2)}';

  /// Pro subscriber penetration rate (e.g. 24.5%).
  double get proPenetrationPercent {
    if (totalUsersCount <= 0) return 0.0;
    return (activeProUsersCount / totalUsersCount) * 100.0;
  }

  MonetizationKpiSummary copyWith({
    int? totalUsersCount,
    int? activeProUsersCount,
    int? freeUsersCount,
    double? monthlyRecurringRevenueUsd,
    double? annualRecurringRevenueUsd,
    double? lifetimeGrossRevenueUsd,
    double? averageRevenuePerUserUsd,
    int? trialActiveCount,
    double? trialToPaidConversionRate,
    double? churnRatePercent,
    List<SkuSalesPerformance>? skuBreakdown,
    DateTime? calculatedAt,
  }) {
    return MonetizationKpiSummary(
      totalUsersCount: totalUsersCount ?? this.totalUsersCount,
      activeProUsersCount: activeProUsersCount ?? this.activeProUsersCount,
      freeUsersCount: freeUsersCount ?? this.freeUsersCount,
      monthlyRecurringRevenueUsd:
          monthlyRecurringRevenueUsd ?? this.monthlyRecurringRevenueUsd,
      annualRecurringRevenueUsd:
          annualRecurringRevenueUsd ?? this.annualRecurringRevenueUsd,
      lifetimeGrossRevenueUsd:
          lifetimeGrossRevenueUsd ?? this.lifetimeGrossRevenueUsd,
      averageRevenuePerUserUsd:
          averageRevenuePerUserUsd ?? this.averageRevenuePerUserUsd,
      trialActiveCount: trialActiveCount ?? this.trialActiveCount,
      trialToPaidConversionRate:
          trialToPaidConversionRate ?? this.trialToPaidConversionRate,
      churnRatePercent: churnRatePercent ?? this.churnRatePercent,
      skuBreakdown: skuBreakdown ?? this.skuBreakdown,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalUsersCount': totalUsersCount,
      'activeProUsersCount': activeProUsersCount,
      'freeUsersCount': freeUsersCount,
      'monthlyRecurringRevenueUsd': monthlyRecurringRevenueUsd,
      'annualRecurringRevenueUsd': annualRecurringRevenueUsd,
      'lifetimeGrossRevenueUsd': lifetimeGrossRevenueUsd,
      'averageRevenuePerUserUsd': averageRevenuePerUserUsd,
      'trialActiveCount': trialActiveCount,
      'trialToPaidConversionRate': trialToPaidConversionRate,
      'churnRatePercent': churnRatePercent,
      'skuBreakdown': skuBreakdown.map((s) => s.toMap()).toList(),
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }

  factory MonetizationKpiSummary.fromMap(Map<String, dynamic> map) {
    return MonetizationKpiSummary(
      totalUsersCount: (map['totalUsersCount'] as num?)?.toInt() ?? 0,
      activeProUsersCount: (map['activeProUsersCount'] as num?)?.toInt() ?? 0,
      freeUsersCount: (map['freeUsersCount'] as num?)?.toInt() ?? 0,
      monthlyRecurringRevenueUsd:
          (map['monthlyRecurringRevenueUsd'] as num?)?.toDouble() ?? 0.0,
      annualRecurringRevenueUsd:
          (map['annualRecurringRevenueUsd'] as num?)?.toDouble() ?? 0.0,
      lifetimeGrossRevenueUsd:
          (map['lifetimeGrossRevenueUsd'] as num?)?.toDouble() ?? 0.0,
      averageRevenuePerUserUsd:
          (map['averageRevenuePerUserUsd'] as num?)?.toDouble() ?? 0.0,
      trialActiveCount: (map['trialActiveCount'] as num?)?.toInt() ?? 0,
      trialToPaidConversionRate:
          (map['trialToPaidConversionRate'] as num?)?.toDouble() ?? 0.0,
      churnRatePercent: (map['churnRatePercent'] as num?)?.toDouble() ?? 0.0,
      skuBreakdown: (map['skuBreakdown'] as List<dynamic>?)
              ?.map((e) =>
                  SkuSalesPerformance.fromMap(e as Map<String, dynamic>))
              .toList() ??
          const [],
      calculatedAt: map['calculatedAt'] != null
          ? DateTime.tryParse(map['calculatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Default baseline telemetry summary for operational display.
  static MonetizationKpiSummary get defaultBaseline {
    return MonetizationKpiSummary(
      totalUsersCount: 12450,
      activeProUsersCount: 3820,
      freeUsersCount: 8630,
      monthlyRecurringRevenueUsd: 14890.0,
      annualRecurringRevenueUsd: 178680.0,
      lifetimeGrossRevenueUsd: 94520.0,
      averageRevenuePerUserUsd: 7.59,
      trialActiveCount: 412,
      trialToPaidConversionRate: 64.2,
      churnRatePercent: 1.8,
      skuBreakdown: const [
        SkuSalesPerformance(
          sku: 'aquawild_pro_annual',
          productName: 'AquaWild Pro (Annual + Trial)',
          totalUnitsSold: 2150,
          grossRevenueUsd: 64478.50,
          activeSubscriberCount: 2150,
          conversionRatePercent: 71.4,
        ),
        SkuSalesPerformance(
          sku: 'aquawild_pro_monthly',
          productName: 'AquaWild Pro (Monthly)',
          totalUnitsSold: 1420,
          grossRevenueUsd: 22663.20,
          activeSubscriberCount: 1420,
          conversionRatePercent: 58.2,
        ),
        SkuSalesPerformance(
          sku: 'aquawild_pro_lifetime',
          productName: 'AquaWild Pro (Lifetime VIP)',
          totalUnitsSold: 250,
          grossRevenueUsd: 17497.50,
          activeSubscriberCount: 250,
          conversionRatePercent: 100.0,
        ),
        SkuSalesPerformance(
          sku: 'deep_sea_legends_pack',
          productName: 'Deep Sea Legends Pack',
          totalUnitsSold: 890,
          grossRevenueUsd: 4441.10,
          activeSubscriberCount: 0,
          conversionRatePercent: 32.1,
        ),
        SkuSalesPerformance(
          sku: 'alpine_legends_pack',
          productName: 'Alpine Legends Pack',
          totalUnitsSold: 640,
          grossRevenueUsd: 3193.60,
          activeSubscriberCount: 0,
          conversionRatePercent: 28.4,
        ),
      ],
      calculatedAt: DateTime.now(),
    );
  }
}
