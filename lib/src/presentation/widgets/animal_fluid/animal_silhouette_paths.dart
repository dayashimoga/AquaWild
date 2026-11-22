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
      case 'arctic_fox':
        return _buildArcticFoxPath(size);
      case 'emperor_penguin':
        return _buildPenguinPath(size);
      case 'bottlenose_dolphin':
        return _buildDolphinPath(size);
      case 'blue_ringed_octopus':
        return _buildOctopusPath(size);
      case 'snow_leopard':
        return _buildSnowLeopardPath(size);
      default:
        return _buildRedPandaPath(size);
    }
  }

  /// Ruby the Red Panda silhouette (Anatomically accurate Ailurus fulgens contour:
  /// rounded ears, cheek fur ruffs, sweeping bushy tail, and paws)
  static Path _buildRedPandaPath(Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    // Start at left rear paw
    path.moveTo(w * 0.28, h * 0.95);

    // Left flank ascending to bushy tail base
    path.cubicTo(w * 0.22, h * 0.92, w * 0.17, h * 0.86, w * 0.16, h * 0.76);

    // Outer sweeping bushy tail arc
    path.cubicTo(w * 0.06, h * 0.82, w * 0.02, h * 0.66, w * 0.04, h * 0.52);

    // Rounded bushy tail apex
    path.cubicTo(w * 0.06, h * 0.40, w * 0.14, h * 0.36, w * 0.20, h * 0.42);

    // Inner tail contour meeting torso
    path.cubicTo(w * 0.25, h * 0.46, w * 0.26, h * 0.56, w * 0.28, h * 0.64);

    // Left shoulder rising to head
    path.cubicTo(w * 0.28, h * 0.54, w * 0.27, h * 0.45, w * 0.28, h * 0.38);

    // Left cheek fur ruffs (double tuft flare)
    path.cubicTo(w * 0.23, h * 0.35, w * 0.21, h * 0.30, w * 0.24, h * 0.26);
    path.cubicTo(w * 0.22, h * 0.23, w * 0.24, h * 0.20, w * 0.27, h * 0.18);

    // Left ear (rounded triangular contour with wide base)
    path.cubicTo(w * 0.24, h * 0.14, w * 0.23, h * 0.09, w * 0.26, h * 0.07);
    path.cubicTo(w * 0.30, h * 0.07, w * 0.35, h * 0.11, w * 0.38, h * 0.15);

    // Crown dome between ears
    path.quadraticBezierTo(w * 0.50, h * 0.12, w * 0.62, h * 0.15);

    // Right ear (rounded triangular contour with wide base)
    path.cubicTo(w * 0.65, h * 0.11, w * 0.70, h * 0.07, w * 0.74, h * 0.07);
    path.cubicTo(w * 0.77, h * 0.09, w * 0.76, h * 0.14, w * 0.73, h * 0.18);

    // Right cheek fur ruffs (double tuft flare)
    path.cubicTo(w * 0.76, h * 0.20, w * 0.78, h * 0.23, w * 0.76, h * 0.26);
    path.cubicTo(w * 0.79, h * 0.30, w * 0.77, h * 0.35, w * 0.72, h * 0.38);

    // Right shoulder and barrel torso
    path.cubicTo(w * 0.73, h * 0.45, w * 0.74, h * 0.54, w * 0.74, h * 0.62);
    path.cubicTo(w * 0.81, h * 0.68, w * 0.84, h * 0.78, w * 0.80, h * 0.88);

    // Right rear paw
    path.cubicTo(w * 0.78, h * 0.93, w * 0.75, h * 0.96, w * 0.72, h * 0.95);

    // Underbelly base curve arching back to left paw
    path.quadraticBezierTo(w * 0.50, h * 0.92, w * 0.28, h * 0.95);
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

  /// Freya the Arctic Fox silhouette (Alert seated posture with tall pointed ears and bushy curled tail)
  static Path _buildArcticFoxPath(Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    path.moveTo(w * 0.30, h * 0.95); // Front paws
    path.lineTo(w * 0.28, h * 0.72); // Front legs
    path.lineTo(w * 0.24, h * 0.50); // Chest
    path.lineTo(w * 0.22, h * 0.34); // Throat
    path.lineTo(w * 0.12, h * 0.24); // Sharp fox snout tip
    path.lineTo(w * 0.26, h * 0.18); // Forehead
    path.lineTo(w * 0.28, h * 0.05); // Left tall pointed ear tip
    path.lineTo(w * 0.40, h * 0.14); // Ear notch
    path.lineTo(w * 0.48, h * 0.05); // Right pointed ear tip
    path.lineTo(w * 0.54, h * 0.18); // Neck nape
    path.cubicTo(w * 0.62, h * 0.32, w * 0.70, h * 0.48, w * 0.72, h * 0.65); // Sleek arched back
    // Big fluffy curled tail sweeping outward and up
    path.cubicTo(w * 0.88, h * 0.62, w * 0.98, h * 0.75, w * 0.90, h * 0.92); // Outer tail curve
    path.lineTo(w * 0.75, h * 0.95); // Tail tip at ground
    path.lineTo(w * 0.62, h * 0.95); // Rear hind paw
    path.quadraticBezierTo(w * 0.45, h * 0.92, w * 0.30, h * 0.95);
    path.close();

    return path;
  }

  /// Percy the Emperor Penguin silhouette (Regal standing posture with flipper wings and hydrodynamic belly)
  static Path _buildPenguinPath(Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    path.moveTo(w * 0.35, h * 0.96); // Left webbed foot
    path.lineTo(w * 0.28, h * 0.85); // Lower body
    path.cubicTo(w * 0.15, h * 0.75, w * 0.12, h * 0.55, w * 0.20, h * 0.42); // Left wing flipper
    path.lineTo(w * 0.30, h * 0.30); // Left shoulder
    path.lineTo(w * 0.34, h * 0.18); // Throat
    path.lineTo(w * 0.18, h * 0.19); // Slender pointed beak tip
    path.lineTo(w * 0.36, h * 0.12); // Beak top & crown
    path.quadraticBezierTo(w * 0.50, h * 0.07, w * 0.64, h * 0.12); // Rounded head crown
    path.lineTo(w * 0.68, h * 0.24); // Nape
    path.cubicTo(w * 0.78, h * 0.40, w * 0.88, h * 0.58, w * 0.82, h * 0.75); // Right wing flipper
    path.cubicTo(w * 0.78, h * 0.85, w * 0.72, h * 0.92, w * 0.65, h * 0.96); // Right webbed foot
    path.quadraticBezierTo(w * 0.50, h * 0.94, w * 0.35, h * 0.96);
    path.close();

    return path;
  }

  /// Echo the Dolphin silhouette (Dynamic leaping arch with dorsal fin, rostrum snout, and tail flukes)
  static Path _buildDolphinPath(Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    path.moveTo(w * 0.15, h * 0.92); // Left fluke tip
    path.lineTo(w * 0.22, h * 0.84); // Fluke center notch
    path.lineTo(w * 0.30, h * 0.92); // Right fluke tip
    path.lineTo(w * 0.26, h * 0.78); // Caudal peduncle
    path.cubicTo(w * 0.22, h * 0.62, w * 0.25, h * 0.48, w * 0.32, h * 0.35); // Underbelly
    path.lineTo(w * 0.22, h * 0.40); // Pectoral fin
    path.lineTo(w * 0.35, h * 0.28); // Throat
    path.lineTo(w * 0.42, h * 0.12); // Rostrum snout tip
    path.quadraticBezierTo(w * 0.52, h * 0.10, w * 0.60, h * 0.16); // Rounded melon forehead
    path.lineTo(w * 0.64, h * 0.28); // Back leading to dorsal fin
    path.lineTo(w * 0.82, h * 0.20); // Dorsal fin tip
    path.lineTo(w * 0.72, h * 0.42); // Dorsal fin trailing edge
    path.cubicTo(w * 0.65, h * 0.60, w * 0.45, h * 0.75, w * 0.26, h * 0.78); // Muscular tail stock
    path.close();

    return path;
  }

  /// Octavia the Octopus silhouette (Bulbous mantle with 8 undulating coiled tentacles)
  static Path _buildOctopusPath(Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    // Center base
    path.moveTo(w * 0.50, h * 0.95);
    // Left undulating coiled tentacles
    path.cubicTo(w * 0.35, h * 0.96, w * 0.20, h * 0.90, w * 0.12, h * 0.80);
    path.lineTo(w * 0.05, h * 0.68); // Far left tentacle curl
    path.lineTo(w * 0.14, h * 0.62);
    path.lineTo(w * 0.22, h * 0.50); // Left tentacle base
    // Left mantle dome
    path.cubicTo(w * 0.18, h * 0.35, w * 0.26, h * 0.18, w * 0.38, h * 0.12);
    path.quadraticBezierTo(w * 0.50, h * 0.07, w * 0.62, h * 0.12); // Mantle crown
    // Right mantle dome
    path.cubicTo(w * 0.74, h * 0.18, w * 0.82, h * 0.35, w * 0.78, h * 0.50);
    // Right undulating coiled tentacles
    path.lineTo(w * 0.86, h * 0.62);
    path.lineTo(w * 0.95, h * 0.68); // Far right tentacle curl
    path.lineTo(w * 0.88, h * 0.80);
    path.cubicTo(w * 0.80, h * 0.90, w * 0.65, h * 0.96, w * 0.50, h * 0.95);
    path.close();

    return path;
  }

  /// Kira the Snow Leopard silhouette (Muscular stalking alpine feline with iconic long thick tail)
  static Path _buildSnowLeopardPath(Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    path.moveTo(w * 0.25, h * 0.95); // Front paw
    path.lineTo(w * 0.24, h * 0.68); // Muscular front leg
    path.lineTo(w * 0.20, h * 0.48); // Broad chest
    path.lineTo(w * 0.18, h * 0.32); // Chin & muzzle
    path.lineTo(w * 0.24, h * 0.22); // Forehead
    path.lineTo(w * 0.28, h * 0.12); // Left rounded ear tip
    path.lineTo(w * 0.38, h * 0.18); // Ear notch
    path.lineTo(w * 0.48, h * 0.12); // Right rounded ear tip
    path.lineTo(w * 0.54, h * 0.20); // Nape
    path.cubicTo(w * 0.65, h * 0.28, w * 0.75, h * 0.38, w * 0.78, h * 0.55); // Muscular back
    // Iconic thick counterbalancing tail arching out and curling
    path.cubicTo(w * 0.92, h * 0.58, w * 0.98, h * 0.72, w * 0.94, h * 0.88); // Outer tail
    path.lineTo(w * 0.82, h * 0.95); // Rear hind paw
    path.lineTo(w * 0.65, h * 0.78); // Underbelly
    path.quadraticBezierTo(w * 0.45, h * 0.82, w * 0.25, h * 0.95);
    path.close();

    return path;
  }
}
