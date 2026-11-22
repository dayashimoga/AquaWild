/// Single wave column in the 1D coupled shallow-water simulation
class WaveColumn {
  double height; // Current surface elevation displacement
  double targetHeight; // Equilibrium surface height
  double velocity; // Vertical velocity

  WaveColumn({
    this.height = 0.0,
    this.targetHeight = 0.0,
    this.velocity = 0.0,
  });
}

/// Real-time coupled 1D/2D spring-damper shallow-water wave solver.
/// Models surface tension, viscosity damping, and neighbor velocity wave propagation.
class WaveColumnSolver {
  final int columnCount;
  final double tension; // Spring constant k
  final double damping; // Viscosity damping c
  final double spread; // Neighbor coupling spread s

  late final List<WaveColumn> columns;

  WaveColumnSolver({
    this.columnCount = 64,
    this.tension = 0.025,
    this.damping = 0.04,
    this.spread = 0.25,
  }) {
    columns = List.generate(
      columnCount,
      (_) => WaveColumn(height: 0.0, targetHeight: 0.0, velocity: 0.0),
    );
  }

  /// Sets the baseline liquid fill level (in pixels from bottom, or normalized 0.0 to 1.0)
  void setTargetHeight(double target) {
    for (int i = 0; i < columnCount; i++) {
      columns[i].targetHeight = target;
    }
  }

  /// Applies a localized liquid splash impulse (e.g. from pouring a beverage)
  void splash(int columnIndex, double impulseSpeed) {
    if (columnIndex < 0 || columnIndex >= columnCount) return;
    columns[columnIndex].velocity += impulseSpeed;

    // Splash adjacent neighbor columns with diminishing impulse
    if (columnIndex > 0) columns[columnIndex - 1].velocity += impulseSpeed * 0.5;
    if (columnIndex < columnCount - 1) {
      columns[columnIndex + 1].velocity += impulseSpeed * 0.5;
    }
  }

  /// Steps the shallow-water wave physics forward by time step [dt]
  void step({double dt = 1.0}) {
    // 1. Hooke's Law + viscous damping per column
    for (int i = 0; i < columnCount; i++) {
      final col = columns[i];
      final double delta = col.height - col.targetHeight;
      final double acceleration = (-tension * delta) - (damping * col.velocity);
      col.velocity += acceleration * dt;
      col.height += col.velocity * dt;
    }

    // 2. Neighbor coupling wave propagation passes (spread)
    final List<double> leftDeltas = List.filled(columnCount, 0.0);
    final List<double> rightDeltas = List.filled(columnCount, 0.0);

    for (int pass = 0; pass < 8; pass++) {
      for (int i = 0; i < columnCount; i++) {
        if (i > 0) {
          leftDeltas[i] = spread * (columns[i].height - columns[i - 1].height);
          columns[i - 1].velocity += leftDeltas[i];
        }
        if (i < columnCount - 1) {
          rightDeltas[i] = spread * (columns[i].height - columns[i + 1].height);
          columns[i + 1].velocity += rightDeltas[i];
        }
      }

      for (int i = 0; i < columnCount; i++) {
        if (i > 0) columns[i - 1].height += leftDeltas[i];
        if (i < columnCount - 1) columns[i + 1].height += rightDeltas[i];
      }
    }
  }

  /// Resets all columns to equilibrium smoothly
  void reset(double target) {
    for (int i = 0; i < columnCount; i++) {
      columns[i].height = target;
      columns[i].targetHeight = target;
      columns[i].velocity = 0.0;
    }
  }

  /// Computes the total kinetic energy of the water surface (useful for audio/haptics threshold)
  double get totalKineticEnergy {
    double energy = 0.0;
    for (final col in columns) {
      energy += col.velocity * col.velocity;
    }
    return energy;
  }
}
