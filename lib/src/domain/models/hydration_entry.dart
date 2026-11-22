import 'beverage_type.dart';

/// Immutable domain record of an individual hydration event logged by the user
class HydrationEntry {
  final String id;
  final String beverageId;
  final double volumeMl;
  final double netHydrationMl;
  final double caffeineMg;
  final double electrolytesMg;
  final DateTime timestamp;
  final String? notes;

  HydrationEntry({
    required this.id,
    required this.beverageId,
    required this.volumeMl,
    required this.netHydrationMl,
    required this.caffeineMg,
    required this.electrolytesMg,
    required this.timestamp,
    this.notes,
  });

  /// Factory constructor to create an entry while computing net hydration and nutrients
  factory HydrationEntry.create({
    required String id,
    required BeverageType beverage,
    required double volumeMl,
    DateTime? timestamp,
    String? notes,
  }) {
    final net = beverage.calculateNetHydration(volumeMl);
    final caffeine = (volumeMl / 100.0) * beverage.caffeineMgPer100ml;
    final electrolytes = (volumeMl / 100.0) * beverage.electrolytesMgPer100ml;

    return HydrationEntry(
      id: id,
      beverageId: beverage.id,
      volumeMl: volumeMl,
      netHydrationMl: net,
      caffeineMg: caffeine,
      electrolytesMg: electrolytes,
      timestamp: timestamp ?? DateTime.now(),
      notes: notes,
    );
  }

  BeverageType get beverage => BeverageType.findById(beverageId);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'beverageId': beverageId,
      'volumeMl': volumeMl,
      'netHydrationMl': netHydrationMl,
      'caffeineMg': caffeineMg,
      'electrolytesMg': electrolytesMg,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }

  factory HydrationEntry.fromMap(Map<String, dynamic> map) {
    return HydrationEntry(
      id: map['id'] as String,
      beverageId: map['beverageId'] as String,
      volumeMl: (map['volumeMl'] as num).toDouble(),
      netHydrationMl: (map['netHydrationMl'] as num).toDouble(),
      caffeineMg: (map['caffeineMg'] as num).toDouble(),
      electrolytesMg: (map['electrolytesMg'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp'] as String),
      notes: map['notes'] as String?,
    );
  }

  HydrationEntry copyWith({
    String? id,
    String? beverageId,
    double? volumeMl,
    double? netHydrationMl,
    double? caffeineMg,
    double? electrolytesMg,
    DateTime? timestamp,
    String? notes,
  }) {
    return HydrationEntry(
      id: id ?? this.id,
      beverageId: beverageId ?? this.beverageId,
      volumeMl: volumeMl ?? this.volumeMl,
      netHydrationMl: netHydrationMl ?? this.netHydrationMl,
      caffeineMg: caffeineMg ?? this.caffeineMg,
      electrolytesMg: electrolytesMg ?? this.electrolytesMg,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
    );
  }
}
