import 'dart:math' as math;

/// Represents ambient weather conditions impacting human perspiration and hydration needs.
class WeatherCondition {
  final double temperatureCelsius;
  final double humidityPercentage;
  final double uvIndex;
  final double altitudeMeters;
  final String description;
  final String cityName;

  const WeatherCondition({
    required this.temperatureCelsius,
    required this.humidityPercentage,
    this.uvIndex = 5.0,
    this.altitudeMeters = 0.0,
    this.description = 'Pleasant & Clear',
    this.cityName = 'Habitat Base',
  });

  /// Standard baseline default condition (21°C, 45% humidity, sea level).
  static const WeatherCondition standard = WeatherCondition(
    temperatureCelsius: 21.0,
    humidityPercentage: 45.0,
    uvIndex: 4.0,
    altitudeMeters: 50.0,
    description: 'Mild & Temperate',
    cityName: 'Emerald Meadow',
  );

  /// Approximate Steadman Heat Index calculation.
  double get heatIndexCelsius {
    if (temperatureCelsius < 20.0) return temperatureCelsius;
    final t = temperatureCelsius;
    final r = humidityPercentage;
    // Simplified Rothfusz regression equation approximation
    final hi = -8.78469475556 +
        1.61139411 * t +
        2.33854883889 * r -
        0.14611605 * t * r -
        0.012308094 * t * t -
        0.0164248277778 * r * r +
        0.002211732 * t * t * r +
        0.00072546 * t * r * r -
        0.000003582 * t * t * r * r;
    return math.max(t, hi);
  }

  /// Additional water volume recommended strictly due to ambient heat, humidity, and altitude (in ml).
  int get weatherHydrationOffsetMl {
    int offset = 0;
    // Heat offset: +25ml per °C above 22°C
    if (temperatureCelsius > 22.0) {
      offset += ((temperatureCelsius - 22.0) * 25).round();
    }
    // High heat index / muggy humidity offset
    if (heatIndexCelsius > 28.0) {
      offset += ((heatIndexCelsius - 28.0) * 20).round();
    }
    // Altitude offset (increased respiration and insensible water loss above 1500m):
    // +150ml per 500m above 1500m
    if (altitudeMeters > 1500.0) {
      offset += (((altitudeMeters - 1500.0) / 500.0) * 150).round();
    }
    // UV index offset (high sun exposure adds +100ml for UV >= 8)
    if (uvIndex >= 8.0) {
      offset += 150;
    }
    return offset;
  }

  WeatherCondition copyWith({
    double? temperatureCelsius,
    double? humidityPercentage,
    double? uvIndex,
    double? altitudeMeters,
    String? description,
    String? cityName,
  }) {
    return WeatherCondition(
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
      humidityPercentage: humidityPercentage ?? this.humidityPercentage,
      uvIndex: uvIndex ?? this.uvIndex,
      altitudeMeters: altitudeMeters ?? this.altitudeMeters,
      description: description ?? this.description,
      cityName: cityName ?? this.cityName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperatureCelsius': temperatureCelsius,
      'humidityPercentage': humidityPercentage,
      'uvIndex': uvIndex,
      'altitudeMeters': altitudeMeters,
      'description': description,
      'cityName': cityName,
    };
  }

  factory WeatherCondition.fromJson(Map<String, dynamic> json) {
    return WeatherCondition(
      temperatureCelsius: (json['temperatureCelsius'] as num).toDouble(),
      humidityPercentage: (json['humidityPercentage'] as num).toDouble(),
      uvIndex: (json['uvIndex'] as num?)?.toDouble() ?? 5.0,
      altitudeMeters: (json['altitudeMeters'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? 'Pleasant & Clear',
      cityName: json['cityName'] as String? ?? 'Habitat Base',
    );
  }
}
