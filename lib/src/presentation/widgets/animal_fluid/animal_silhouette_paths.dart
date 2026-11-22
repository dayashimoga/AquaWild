import 'package:flutter/material.dart';

/// Precision vector silhouette paths for exotic animal hydration companions.
/// Scales proportionally to any bounding box while preserving anatomically accurate
/// proportions and smooth continuous bezier contours.
class AnimalSilhouettePaths {
  AnimalSilhouettePaths._();

  /// Generates the outer vessel clipping path for the given animal [id]
  static Path getSilhouettePath(String id, Size size) {
    switch (id) {
      case 'red_panda':
        return _buildRedPandaPath(size);
      case 'capybara':
        return _buildCapybaraPath(size);
      case 'axolotl':
        return _buildAxolotlPath(size);
      case 'sea_otter':
        return _buildSeaOtterPath(size);
      case 'andean_llama':
        return _buildLlamaPath(size);
      default:
        return _buildRedPandaPath(size);
    }
  }

  /// Ruby the Red Panda silhouette (Perched upright with rounded ears and fluffy tail)
  static Path _buildRedPandaPath(Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    path.moveTo(w * 0.25, h * 0.95); // Left rear paw
    path.lineTo(w * 0.20, h * 0.82); // Left flank
    path.cubicTo(w * 0.05, h * 0.88, w * 0.02, h * 0.60, w * 0.12, h * 0.45); // Sweeping tail
    path.cubicTo(w * 0.16, h * 0.38, w * 0.25, h * 0.48, w * 0.26, h * 0.60); // Tail arch
    path.lineTo(w * 0.30, h * 0.48); // Left shoulder
    path.lineTo(w * 0.28, h * 0.28); // Left cheek
    path.lineTo(w * 0.22, h * 0.12); // Left ear tip
    path.lineTo(w * 0.38, h * 0.18); // Left ear base
    path.quadraticBezierTo(w * 0.50, h * 0.14, w * 0.62, h * 0.18); // Crown between ears
    path.lineTo(w * 0.78, h * 0.12); // Right ear tip
    path.lineTo(w * 0.72, h * 0.28); // Right ear base
    path.lineTo(w * 0.70, h * 0.48); // Right cheek & shoulder
    path.cubicTo(w * 0.84, h * 0.58, w * 0.86, h * 0.75, w * 0.82, h * 0.88); // Right torso & flank
    path.lineTo(w * 0.75, h * 0.95); // Right rear paw
    path.quadraticBezierTo(w * 0.50, h * 0.92, w * 0.25, h * 0.95); // Base curve
    path.close();

    return path;
  }

  /// Cappy the Capybara silhouette (Chunky, zen profile with flat snout and rounded rump)
  static Path _buildCapybaraPath(Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    path.moveTo(w * 0.22, h * 0.95); // Left front foot
    path.lineTo(w * 0.18, h * 0.65); // Front chest
    path.lineTo(w * 0.12, h * 0.45); // Lower snout
    path.lineTo(w * 0.10, h * 0.32); // Snout tip
    path.lineTo(w * 0.25, h * 0.28); // Snout bridge
    path.lineTo(w * 0.32, h * 0.20); // Small ear
    path.lineTo(w * 0.38, h * 0.25); // Behind ear
    path.cubicTo(w * 0.55, h * 0.22, w * 0.78, h * 0.26, w * 0.90, h * 0.45); // Broad barrel back
    path.cubicTo(w * 0.95, h * 0.60, w * 0.92, h * 0.82, w * 0.84, h * 0.95); // Rump
    path.lineTo(w * 0.72, h * 0.95); // Hind leg
    path.lineTo(w * 0.68, h * 0.75); // Belly
    path.lineTo(w * 0.35, h * 0.75); // Underbelly
    path.lineTo(w * 0.32, h * 0.95); // Right front foot
    path.close();

    return path;
  }

  /// Lottie the Axolotl silhouette (Cute aquatic salamander with branching feathery gills)
  static Path _buildAxolotlPath(Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    path.moveTo(w * 0.35, h * 0.95); // Tail tip
    path.cubicTo(w * 0.20, h * 0.75, w * 0.22, h * 0.50, w * 0.28, h * 0.42); // Left body
    // Left external branching gills
    path.lineTo(w * 0.10, h * 0.38);
    path.lineTo(w * 0.24, h * 0.32);
    path.lineTo(w * 0.08, h * 0.25);
    path.lineTo(w * 0.26, h * 0.22);
    path.lineTo(w * 0.15, h * 0.14);
    path.lineTo(w * 0.34, h * 0.18);
    // Head crown
    path.quadraticBezierTo(w * 0.50, h * 0.12, w * 0.66, h * 0.18);
    // Right external branching gills
    path.lineTo(w * 0.85, h * 0.14);
    path.lineTo(w * 0.74, h * 0.22);
    path.lineTo(w * 0.92, h * 0.25);
    path.lineTo(w * 0.76, h * 0.32);
    path.lineTo(w * 0.90, h * 0.38);
    path.lineTo(w * 0.72, h * 0.42); // Right body
    path.cubicTo(w * 0.78, h * 0.50, w * 0.80, h * 0.75, w * 0.65, h * 0.95);
    path.close();

    return path;
  }

  /// Ollie the Sea Otter silhouette (Floating on back with folded paws and paddle tail)
  static Path _buildSeaOtterPath(Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    path.moveTo(w * 0.38, h * 0.95);
    path.cubicTo(w * 0.22, h * 0.85, w * 0.18, h * 0.55, w * 0.26, h * 0.35);
    path.lineTo(w * 0.28, h * 0.20); // Round head
    path.quadraticBezierTo(w * 0.50, h * 0.12, w * 0.72, h * 0.20);
    path.lineTo(w * 0.74, h * 0.35);
    path.cubicTo(w * 0.82, h * 0.55, w * 0.78, h * 0.85, w * 0.62, h * 0.95);
    path.close();

    return path;
  }

  /// Luna the Andean Llama silhouette (Inspired by Waterllama reference image with long neck and fluffy coat)
  static Path _buildLlamaPath(Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    path.moveTo(w * 0.24, h * 0.95); // Front left leg
    path.lineTo(w * 0.26, h * 0.70); // Front knee
    path.lineTo(w * 0.28, h * 0.52); // Chest
    path.lineTo(w * 0.32, h * 0.32); // Base of long neck
    path.lineTo(w * 0.34, h * 0.18); // Chin
    path.lineTo(w * 0.28, h * 0.14); // Muzzle
    path.lineTo(w * 0.38, h * 0.10); // Forehead
    path.lineTo(w * 0.40, h * 0.04); // Left tall ear
    path.lineTo(w * 0.44, h * 0.09); // Ear notch
    path.lineTo(w * 0.48, h * 0.04); // Right tall ear
    path.lineTo(w * 0.52, h * 0.12); // Neck nape
    path.lineTo(w * 0.50, h * 0.38); // Fluffy back of neck
    path.cubicTo(w * 0.60, h * 0.40, w * 0.75, h * 0.42, w * 0.84, h * 0.50); // Fluffy back
    path.lineTo(w * 0.90, h * 0.48); // Small fluffy tail
    path.lineTo(w * 0.88, h * 0.58);
    path.lineTo(w * 0.82, h * 0.70); // Rump
    path.lineTo(w * 0.80, h * 0.95); // Rear leg
    path.lineTo(w * 0.72, h * 0.95);
    path.lineTo(w * 0.70, h * 0.68); // Underbelly
    path.lineTo(w * 0.38, h * 0.68);
    path.lineTo(w * 0.32, h * 0.95); // Front right leg
    path.close();

    return path;
  }
}
