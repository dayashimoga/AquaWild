import 'package:aquawild/src/presentation/widgets/animal_fluid/animal_silhouette_paths.dart';
import 'package:aquawild/src/presentation/widgets/animal_fluid/wave_column_solver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Wave Column Solver & Animal Silhouette Path Tests', () {
    test('WaveColumnSolver initializes with 64 columns at equilibrium', () {
      final solver = WaveColumnSolver(columnCount: 64);
      expect(solver.columns.length, equals(64));
      expect(solver.totalKineticEnergy, equals(0.0));

      solver.setTargetHeight(100.0);
      for (final col in solver.columns) {
        expect(col.targetHeight, equals(100.0));
      }
    });

    test('Splashing a column applies velocity impulse and spreads to neighbors', () {
      final solver = WaveColumnSolver(columnCount: 64);
      solver.splash(32, 20.0);

      expect(solver.columns[32].velocity, equals(20.0));
      expect(solver.columns[31].velocity, equals(10.0));
      expect(solver.columns[33].velocity, equals(10.0));

      // Step physics
      solver.step(dt: 1.0);
      expect(solver.columns[32].height, greaterThan(0.0));
      expect(solver.totalKineticEnergy, greaterThan(0.0));
    });

    test('AnimalSilhouettePaths generates non-empty paths for all animals', () {
      const size = Size(300, 350);
      final animals = [
        'red_panda',
        'capybara',
        'axolotl',
        'sea_otter',
        'andean_llama',
      ];

      for (final id in animals) {
        final path = AnimalSilhouettePaths.getSilhouettePath(id, size);
        final bounds = path.getBounds();
        expect(bounds.width, greaterThan(100.0));
        expect(bounds.height, greaterThan(100.0));
      }
    });
  });
}
