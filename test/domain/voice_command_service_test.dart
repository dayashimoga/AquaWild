import 'package:aquawild/src/core/services/voice_command_service.dart';
import 'package:aquawild/src/domain/models/beverage_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VoiceCommandService Tests', () {
    const service = VoiceCommandService.instance;

    test('parses explicit ml and beverage correctly', () {
      final res = service.parseUtterance('Drank 350ml green tea');
      expect(res.beverage, equals(BeverageType.greenTea));
      expect(res.volumeMl, equals(350.0));
      expect(res.confidence, greaterThanOrEqualTo(0.9));
      expect(res.confirmationMessage, contains('350ml'));
      expect(res.confirmationMessage, contains('Green Tea'));
    });

    test('parses espresso and small volume correctly', () {
      final res = service.parseUtterance('Had a 60 ml espresso');
      expect(res.beverage, equals(BeverageType.espresso));
      expect(res.volumeMl, equals(60.0));
      expect(res.confidence, greaterThanOrEqualTo(0.9));
    });

    test('converts ounces (oz) to milliliters correctly', () {
      final res = service.parseUtterance('Logged 16 oz cold water');
      expect(res.beverage, equals(BeverageType.pureWater));
      // 16 * 29.5735 ≈ 473.176 -> rounded to 473.0
      expect(res.volumeMl, equals(473.0));
    });

    test('converts liters (l) to milliliters correctly', () {
      final res = service.parseUtterance('Finished 1.5 l water bottle');
      expect(res.beverage, equals(BeverageType.pureWater));
      expect(res.volumeMl, equals(1500.0));
    });

    test('parses electrolytes and sports drinks', () {
      final res = service.parseUtterance('Drank 500ml electrolytes after gym');
      expect(res.beverage, equals(BeverageType.electrolyte));
      expect(res.volumeMl, equals(500.0));
    });

    test('parses coconut water', () {
      final res = service.parseUtterance('Had 330ml coconut water');
      expect(res.beverage, equals(BeverageType.coconutWater));
      expect(res.volumeMl, equals(330.0));
    });

    test('defaults to beverage preset volume when volume is missing', () {
      final res = service.parseUtterance('Just had green tea');
      expect(res.beverage, equals(BeverageType.greenTea));
      expect(res.volumeMl, equals(BeverageType.greenTea.presetVolumesMl.first.toDouble()));
    });

    test('defaults to pure water fallback on unknown text', () {
      final res = service.parseUtterance('Feeling thirsty today 400ml');
      expect(res.beverage, equals(BeverageType.pureWater));
      expect(res.volumeMl, equals(400.0));
    });
  });
}
