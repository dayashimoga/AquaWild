import 'beverage_type.dart';

/// Represents a single stacked liquid layer inside an animal silhouette vessel.
/// Stratified by relative density with realistic color boundaries.
class FluidLayer {
  final BeverageType beverage;
  final double volumeMl;
  final double fractionOfTotal; // 0.0 to 1.0 (relative height fraction of current fill)
  final double relativeDensity;

  const FluidLayer({
    required this.beverage,
    required this.volumeMl,
    required this.fractionOfTotal,
    required this.relativeDensity,
  });

  FluidLayer copyWith({
    BeverageType? beverage,
    double? volumeMl,
    double? fractionOfTotal,
    double? relativeDensity,
  }) {
    return FluidLayer(
      beverage: beverage ?? this.beverage,
      volumeMl: volumeMl ?? this.volumeMl,
      fractionOfTotal: fractionOfTotal ?? this.fractionOfTotal,
      relativeDensity: relativeDensity ?? this.relativeDensity,
    );
  }
}
