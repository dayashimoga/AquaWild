import '../../domain/models/beverage_type.dart';

/// Result of parsing natural language voice command
class VoiceParseResult {
  final BeverageType beverage;
  final double volumeMl;
  final double confidence;
  final String originalTranscript;
  final String confirmationMessage;

  const VoiceParseResult({
    required this.beverage,
    required this.volumeMl,
    required this.confidence,
    required this.originalTranscript,
    required this.confirmationMessage,
  });
}

/// Service parsing natural language speech transcriptions into structured hydration logs
class VoiceCommandService {
  const VoiceCommandService();

  static const VoiceCommandService instance = VoiceCommandService();

  /// Parses an arbitrary spoken utterance such as "Drank 350ml green tea" or "Had 12 oz cold water"
  VoiceParseResult parseUtterance(String utterance) {
    final lower = utterance.trim().toLowerCase();

    // 1. Identify Beverage
    final beverageMatch = _detectBeverage(lower);
    final beverage = beverageMatch.$1;
    final beverageConfidence = beverageMatch.$2;

    // 2. Identify Volume
    final volumeMatch = _detectVolume(lower);
    final double volumeMl;
    final double volumeConfidence;

    if (volumeMatch != null) {
      volumeMl = volumeMatch;
      volumeConfidence = 1.0;
    } else {
      // Default to beverage's first preset volume if volume not stated
      volumeMl = beverage.presetVolumesMl.first.toDouble();
      volumeConfidence = 0.7;
    }

    final overallConfidence = (beverageConfidence * 0.6) + (volumeConfidence * 0.4);

    return VoiceParseResult(
      beverage: beverage,
      volumeMl: volumeMl,
      confidence: overallConfidence,
      originalTranscript: utterance,
      confirmationMessage:
          'Logged ${volumeMl.toStringAsFixed(0)}ml of ${beverage.name} (+${(volumeMl * beverage.hydrationCoefficient).toStringAsFixed(0)}ml net)',
    );
  }

  (BeverageType, double) _detectBeverage(String input) {
    if (input.contains('matcha') || input.contains('green tea') || input.contains('sencha')) {
      return (BeverageType.greenTea, 0.95);
    }
    if (input.contains('herbal') || input.contains('chamomile') || input.contains('peppermint') || input.contains('hibiscus')) {
      return (BeverageType.herbalTea, 0.95);
    }
    if (input.contains('tea')) {
      return (BeverageType.greenTea, 0.85);
    }
    if (input.contains('espresso') || input.contains('latte') || input.contains('cappuccino') || input.contains('americano') || input.contains('coffee')) {
      return (BeverageType.espresso, 0.95);
    }
    if (input.contains('electrolyte') || input.contains('sports drink') || input.contains('hydration powder') || input.contains('gatorade')) {
      return (BeverageType.electrolyte, 0.95);
    }
    if (input.contains('coconut')) {
      return (BeverageType.coconutWater, 0.95);
    }
    if (input.contains('sparkling') || input.contains('seltzer') || input.contains('carbonated water')) {
      return (BeverageType.sparklingWater, 0.95);
    }
    if (input.contains('juice') || input.contains('orange') || input.contains('lemonade')) {
      return (BeverageType.citrusJuice, 0.9);
    }
    if (input.contains('milk') || input.contains('oat milk') || input.contains('almond milk')) {
      return (BeverageType.milk, 0.9);
    }
    if (input.contains('kombucha')) {
      return (BeverageType.kombucha, 0.95);
    }
    if (input.contains('smoothie')) {
      return (BeverageType.smoothie, 0.95);
    }
    if (input.contains('protein') || input.contains('shake') || input.contains('whey')) {
      return (BeverageType.proteinShake, 0.95);
    }
    if (input.contains('broth') || input.contains('soup')) {
      return (BeverageType.boneBroth, 0.95);
    }
    if (input.contains('water') || input.contains('aqua') || input.contains('h2o')) {
      return (BeverageType.pureWater, 0.95);
    }

    // Heuristic scan against allBeverages display names
    for (final bev in BeverageType.allBeverages) {
      if (input.contains(bev.name.toLowerCase())) {
        return (bev, 0.9);
      }
    }

    // Default fallback
    return (BeverageType.pureWater, 0.6);
  }

  double? _detectVolume(String input) {
    // Check ml / milliliters / mls
    final mlRegex = RegExp(r'(\d+(?:\.\d+)?)\s*(?:ml|milliliters?|millilitres?)');
    final mlMatch = mlRegex.firstMatch(input);
    if (mlMatch != null) {
      return double.tryParse(mlMatch.group(1)!);
    }

    // Check oz / ounces
    final ozRegex = RegExp(r'(\d+(?:\.\d+)?)\s*(?:oz|ounces?)');
    final ozMatch = ozRegex.firstMatch(input);
    if (ozMatch != null) {
      final oz = double.tryParse(ozMatch.group(1)!);
      if (oz != null) {
        return (oz * 29.5735).roundToDouble();
      }
    }

    // Check liters / l
    final literRegex = RegExp(r'(\d+(?:\.\d+)?)\s*(?:l|liters?|litres?)');
    final literMatch = literRegex.firstMatch(input);
    if (literMatch != null) {
      final liters = double.tryParse(literMatch.group(1)!);
      if (liters != null) {
        return (liters * 1000).roundToDouble();
      }
    }

    // Check standalone number near drink keywords
    final standaloneRegex = RegExp(r'\b(\d{2,4})\b');
    final standaloneMatch = standaloneRegex.firstMatch(input);
    if (standaloneMatch != null) {
      final val = double.tryParse(standaloneMatch.group(1)!);
      if (val != null && val >= 30 && val <= 3000) {
        return val;
      }
    }

    return null;
  }
}
