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

  /// Cappy the Capybara silhouette (Chunky, peaceful zen profile with flat blunt snout,
  /// small rounded ear, barrel torso, and relaxed paws)
  static Path _buildCapybaraPath(Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    // Front left paw base
    path.moveTo(w * 0.24, h * 0.95);

    // Front chest ascending to broad chin
    path.cubicTo(w * 0.20, h * 0.82, w * 0.16, h * 0.65, w * 0.16, h * 0.50);

    // Characteristic blunt, flat snout
    path.cubicTo(w * 0.14, h * 0.42, w * 0.08, h * 0.38, w * 0.08, h * 0.30);
    path.cubicTo(w * 0.08, h * 0.24, w * 0.18, h * 0.22, w * 0.26, h * 0.22);

    // Small rounded ear perched high on head
    path.cubicTo(w * 0.28, h * 0.18, w * 0.30, h * 0.15, w * 0.34, h * 0.15);
    path.cubicTo(w * 0.38, h * 0.15, w * 0.40, h * 0.18, w * 0.42, h * 0.22);

    // Broad, muscular barrel back
    path.cubicTo(w * 0.55, h * 0.22, w * 0.72, h * 0.26, w * 0.85, h * 0.40);

    // Rounded rump contour
    path.cubicTo(w * 0.95, h * 0.52, w * 0.95, h * 0.76, w * 0.88, h * 0.90);

    // Rear hind paw
    path.cubicTo(w * 0.85, h * 0.95, w * 0.78, h * 0.96, w * 0.74, h * 0.95);

    // Chunky relaxed underbelly
    path.cubicTo(w * 0.66, h * 0.84, w * 0.45, h * 0.84, w * 0.38, h * 0.92);

    // Front right paw meeting base
    path.cubicTo(w * 0.34, h * 0.96, w * 0.28, h * 0.96, w * 0.24, h * 0.95);
    path.close();

    return path;
  }

  /// Lottie the Axolotl silhouette (Cute aquatic salamander with 6 organic branching feathery gill plumes)
  static Path _buildAxolotlPath(Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    // Paddle tail tip at base
    path.moveTo(w * 0.42, h * 0.95);

    // Left body and fin ascending to gills
    path.cubicTo(w * 0.28, h * 0.82, w * 0.22, h * 0.62, w * 0.28, h * 0.46);

    // Left external branching gills (3 soft plume arches)
    // Lower left plume
    path.cubicTo(w * 0.18, h * 0.44, w * 0.08, h * 0.42, w * 0.08, h * 0.38);
    path.cubicTo(w * 0.08, h * 0.34, w * 0.16, h * 0.33, w * 0.24, h * 0.33);

    // Middle left plume
    path.cubicTo(w * 0.14, h * 0.31, w * 0.05, h * 0.29, w * 0.05, h * 0.25);
    path.cubicTo(w * 0.05, h * 0.21, w * 0.15, h * 0.22, w * 0.25, h * 0.22);

    // Upper left plume
    path.cubicTo(w * 0.18, h * 0.19, w * 0.10, h * 0.14, w * 0.12, h * 0.11);
    path.cubicTo(w * 0.15, h * 0.09, w * 0.25, h * 0.12, w * 0.32, h * 0.16);

    // Wide smiling head crown
    path.quadraticBezierTo(w * 0.50, h * 0.11, w * 0.68, h * 0.16);

    // Right external branching gills (3 soft plume arches)
    // Upper right plume
    path.cubicTo(w * 0.75, h * 0.12, w * 0.85, h * 0.09, w * 0.88, h * 0.11);
    path.cubicTo(w * 0.90, h * 0.14, w * 0.82, h * 0.19, w * 0.75, h * 0.22);

    // Middle right plume
    path.cubicTo(w * 0.85, h * 0.22, w * 0.95, h * 0.21, w * 0.95, h * 0.25);
    path.cubicTo(w * 0.95, h * 0.29, w * 0.86, h * 0.31, w * 0.76, h * 0.33);

    // Lower right plume
    path.cubicTo(w * 0.84, h * 0.33, w * 0.92, h * 0.34, w * 0.92, h * 0.38);
    path.cubicTo(w * 0.92, h * 0.42, w * 0.82, h * 0.44, w * 0.72, h * 0.46);

    // Right body and tail fin descending
    path.cubicTo(w * 0.78, h * 0.62, w * 0.72, h * 0.82, w * 0.58, h * 0.95);
    path.quadraticBezierTo(w * 0.50, h * 0.92, w * 0.42, h * 0.95);
    path.close();

    return path;
  }

  /// Ollie the Sea Otter silhouette (Floating on back with folded paws, rounded ears,
  /// flippers and broad paddle tail)
  static Path _buildSeaOtterPath(Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    // Paddle tail base
    path.moveTo(w * 0.40, h * 0.95);

    // Left flipper and hindquarters
    path.cubicTo(w * 0.26, h * 0.90, w * 0.20, h * 0.78, w * 0.22, h * 0.68);

    // Left buoyant barrel flank and folded paw
    path.cubicTo(w * 0.20, h * 0.52, w * 0.22, h * 0.38, w * 0.28, h * 0.28);

    // Left rounded ear
    path.cubicTo(w * 0.26, h * 0.24, w * 0.25, h * 0.18, w * 0.30, h * 0.16);
    path.cubicTo(w * 0.33, h * 0.15, w * 0.36, h * 0.18, w * 0.38, h * 0.20);

    // Round head dome
    path.quadraticBezierTo(w * 0.50, h * 0.11, w * 0.62, h * 0.20);

    // Right rounded ear
    path.cubicTo(w * 0.64, h * 0.18, w * 0.67, h * 0.15, w * 0.70, h * 0.16);
    path.cubicTo(w * 0.75, h * 0.18, w * 0.74, h * 0.24, w * 0.72, h * 0.28);

    // Right folded paw and buoyant flank
    path.cubicTo(w * 0.78, h * 0.38, w * 0.80, h * 0.52, w * 0.78, h * 0.68);

    // Right flipper paw
    path.cubicTo(w * 0.80, h * 0.78, w * 0.74, h * 0.90, w * 0.60, h * 0.95);

    // Broad flat paddle tail
    path.quadraticBezierTo(w * 0.50, h * 0.92, w * 0.40, h * 0.95);
    path.close();

    return path;
  }

  /// Luna the Andean Llama silhouette (Graceful high-altitude camelid with long neck,
  /// fluffy woolly scallops, curved banana ears, and proud tail)
  static Path _buildLlamaPath(Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    // Front left leg / hoof base
    path.moveTo(w * 0.26, h * 0.95);

    // Foreleg rising to fluffy chest wool
    path.cubicTo(w * 0.26, h * 0.84, w * 0.27, h * 0.68, w * 0.29, h * 0.54);

    // Chest woolly tufts
    path.cubicTo(w * 0.25, h * 0.48, w * 0.28, h * 0.40, w * 0.33, h * 0.34);

    // Slender neck rising to chin
    path.cubicTo(w * 0.33, h * 0.26, w * 0.32, h * 0.18, w * 0.35, h * 0.15);

    // Muzzle and sweet chin
    path.cubicTo(w * 0.30, h * 0.15, w * 0.26, h * 0.12, w * 0.28, h * 0.09);
    path.cubicTo(w * 0.32, h * 0.08, w * 0.36, h * 0.08, w * 0.40, h * 0.09);

    // Curved banana ears
    // Left ear
    path.cubicTo(w * 0.38, h * 0.05, w * 0.39, h * 0.02, w * 0.43, h * 0.02);
    path.cubicTo(w * 0.45, h * 0.04, w * 0.44, h * 0.08, w * 0.46, h * 0.09);

    // Right ear
    path.cubicTo(w * 0.48, h * 0.05, w * 0.50, h * 0.02, w * 0.53, h * 0.02);
    path.cubicTo(w * 0.55, h * 0.05, w * 0.54, h * 0.09, w * 0.54, h * 0.14);

    // Fluffy scalloped wool along back of neck
    path.cubicTo(w * 0.57, h * 0.18, w * 0.58, h * 0.24, w * 0.54, h * 0.28);
    path.cubicTo(w * 0.57, h * 0.32, w * 0.58, h * 0.38, w * 0.55, h * 0.42);

    // Fluffy woolly back
    path.cubicTo(w * 0.65, h * 0.42, w * 0.76, h * 0.44, w * 0.82, h * 0.50);

    // Fluffy upturned tail
    path.cubicTo(w * 0.90, h * 0.48, w * 0.92, h * 0.55, w * 0.86, h * 0.60);

    // Rounded rump descending to rear leg
    path.cubicTo(w * 0.84, h * 0.68, w * 0.82, h * 0.80, w * 0.80, h * 0.95);

    // Rear hoof
    path.cubicTo(w * 0.76, h * 0.96, w * 0.70, h * 0.96, w * 0.68, h * 0.95);

    // Fluffy wool underbelly
    path.cubicTo(w * 0.68, h * 0.76, w * 0.42, h * 0.76, w * 0.38, h * 0.95);

    // Front hooves meeting base
    path.cubicTo(w * 0.34, h * 0.96, w * 0.28, h * 0.96, w * 0.26, h * 0.95);
    path.close();

    return path;
  }

  /// Freya the Arctic Fox silhouette (Alert seated posture with tall pointed ears,
  /// sleek arched back, and giant fluffy curled tail)
  static Path _buildArcticFoxPath(Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    // Front paws at base
    path.moveTo(w * 0.30, h * 0.95);

    // Front leg rising to chest
    path.cubicTo(w * 0.30, h * 0.82, w * 0.28, h * 0.65, w * 0.26, h * 0.50);

    // Throat ascending to sharp fox snout tip
    path.cubicTo(w * 0.24, h * 0.38, w * 0.20, h * 0.28, w * 0.12, h * 0.24);

    // Snout bridge to forehead
    path.cubicTo(w * 0.18, h * 0.21, w * 0.24, h * 0.18, w * 0.26, h * 0.15);

    // Left tall pointed ear
    path.cubicTo(w * 0.25, h * 0.10, w * 0.26, h * 0.05, w * 0.28, h * 0.04);
    path.cubicTo(w * 0.34, h * 0.07, w * 0.38, h * 0.11, w * 0.40, h * 0.14);

    // Crown between ears
    path.quadraticBezierTo(w * 0.44, h * 0.11, w * 0.48, h * 0.04);

    // Right pointed ear
    path.cubicTo(w * 0.50, h * 0.07, w * 0.52, h * 0.12, w * 0.54, h * 0.16);

    // Sleek arched canine back
    path.cubicTo(w * 0.62, h * 0.30, w * 0.70, h * 0.46, w * 0.72, h * 0.64);

    // Big fluffy curled tail sweeping outward and up
    path.cubicTo(w * 0.88, h * 0.60, w * 0.98, h * 0.74, w * 0.90, h * 0.90);
    path.cubicTo(w * 0.82, h * 0.96, w * 0.70, h * 0.96, w * 0.62, h * 0.95);

    // Underbelly
    path.quadraticBezierTo(w * 0.45, h * 0.92, w * 0.30, h * 0.95);
    path.close();

    return path;
  }

  /// Percy the Emperor Penguin silhouette (Hydrodynamic torpedo standing posture with
  /// flipper wings, slender pointed beak, and webbed feet)
  static Path _buildPenguinPath(Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    // Left webbed foot
    path.moveTo(w * 0.35, h * 0.96);

    // Left flipper wing contour
    path.cubicTo(w * 0.26, h * 0.85, w * 0.14, h * 0.68, w * 0.18, h * 0.44);

    // Left shoulder to throat
    path.cubicTo(w * 0.22, h * 0.32, w * 0.28, h * 0.24, w * 0.34, h * 0.18);

    // Slender pointed beak tip
    path.cubicTo(w * 0.28, h * 0.18, w * 0.20, h * 0.19, w * 0.16, h * 0.19);
    path.cubicTo(w * 0.24, h * 0.15, w * 0.30, h * 0.13, w * 0.36, h * 0.12);

    // Rounded crown
    path.quadraticBezierTo(w * 0.50, h * 0.07, w * 0.64, h * 0.12);

    // Nape to right flipper wing
    path.cubicTo(w * 0.72, h * 0.25, w * 0.86, h * 0.50, w * 0.82, h * 0.75);

    // Right webbed foot
    path.cubicTo(w * 0.78, h * 0.86, w * 0.72, h * 0.94, w * 0.65, h * 0.96);

    // Base between feet
    path.quadraticBezierTo(w * 0.50, h * 0.94, w * 0.35, h * 0.96);
    path.close();

    return path;
  }

  /// Echo the Dolphin silhouette (Hydrodynamic leaping curve with rostrum, melon forehead,
  /// falcate dorsal fin, and caudal flukes)
  static Path _buildDolphinPath(Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    // Left fluke tip
    path.moveTo(w * 0.15, h * 0.92);

    // Fluke center notch and right fluke tip
    path.cubicTo(w * 0.18, h * 0.88, w * 0.22, h * 0.86, w * 0.24, h * 0.85);
    path.cubicTo(w * 0.26, h * 0.88, w * 0.28, h * 0.90, w * 0.30, h * 0.92);

    // Caudal peduncle to underbelly
    path.cubicTo(w * 0.26, h * 0.78, w * 0.22, h * 0.60, w * 0.30, h * 0.42);

    // Pectoral fin
    path.cubicTo(w * 0.22, h * 0.44, w * 0.18, h * 0.42, w * 0.22, h * 0.38);

    // Throat to rostrum snout tip
    path.cubicTo(w * 0.28, h * 0.28, w * 0.34, h * 0.18, w * 0.42, h * 0.12);

    // Rounded melon forehead
    path.quadraticBezierTo(w * 0.52, h * 0.09, w * 0.60, h * 0.14);

    // Back to falcate dorsal fin
    path.cubicTo(w * 0.64, h * 0.20, w * 0.70, h * 0.20, w * 0.78, h * 0.16);
    path.cubicTo(w * 0.76, h * 0.26, w * 0.72, h * 0.36, w * 0.70, h * 0.44);

    // Back curve down to caudal peduncle
    path.cubicTo(w * 0.65, h * 0.60, w * 0.45, h * 0.75, w * 0.26, h * 0.78);
    path.close();

    return path;
  }

  /// Octavia the Octopus silhouette (Bulbous cephalopod mantle with 8 undulating coiled tentacles)
  static Path _buildOctopusPath(Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    // Center base
    path.moveTo(w * 0.50, h * 0.95);

    // Left undulating coiled tentacles
    path.cubicTo(w * 0.36, h * 0.96, w * 0.20, h * 0.90, w * 0.12, h * 0.80);
    path.cubicTo(w * 0.04, h * 0.74, w * 0.04, h * 0.64, w * 0.12, h * 0.58);
    path.cubicTo(w * 0.18, h * 0.54, w * 0.24, h * 0.48, w * 0.26, h * 0.44);

    // Left mantle dome
    path.cubicTo(w * 0.20, h * 0.32, w * 0.28, h * 0.16, w * 0.38, h * 0.12);

    // Mantle crown
    path.quadraticBezierTo(w * 0.50, h * 0.07, w * 0.62, h * 0.12);

    // Right mantle dome
    path.cubicTo(w * 0.72, h * 0.16, w * 0.80, h * 0.32, w * 0.74, h * 0.44);

    // Right undulating coiled tentacles
    path.cubicTo(w * 0.76, h * 0.48, w * 0.82, h * 0.54, w * 0.88, h * 0.58);
    path.cubicTo(w * 0.96, h * 0.64, w * 0.96, h * 0.74, w * 0.88, h * 0.80);
    path.cubicTo(w * 0.80, h * 0.90, w * 0.64, h * 0.96, w * 0.50, h * 0.95);
    path.close();

    return path;
  }

  /// Kira the Snow Leopard silhouette (Muscular stalking alpine feline with rounded ears
  /// and iconic thick counterbalancing tail)
  static Path _buildSnowLeopardPath(Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    // Front paw
    path.moveTo(w * 0.26, h * 0.95);

    // Muscular foreleg to broad chest
    path.cubicTo(w * 0.25, h * 0.82, w * 0.22, h * 0.64, w * 0.20, h * 0.48);

    // Chin to muzzle
    path.cubicTo(w * 0.18, h * 0.38, w * 0.16, h * 0.28, w * 0.22, h * 0.22);

    // Forehead to left rounded ear
    path.cubicTo(w * 0.24, h * 0.16, w * 0.26, h * 0.10, w * 0.30, h * 0.10);

    // Crown dome between ears
    path.quadraticBezierTo(w * 0.40, h * 0.13, w * 0.50, h * 0.10);

    // Right rounded ear
    path.cubicTo(w * 0.54, h * 0.10, w * 0.56, h * 0.16, w * 0.58, h * 0.22);

    // Muscular alpine back
    path.cubicTo(w * 0.66, h * 0.30, w * 0.76, h * 0.42, w * 0.78, h * 0.56);

    // Thick curling tail
    path.cubicTo(w * 0.90, h * 0.58, w * 0.98, h * 0.70, w * 0.94, h * 0.86);
    path.cubicTo(w * 0.90, h * 0.96, w * 0.82, h * 0.96, w * 0.76, h * 0.95);

    // Underbelly
    path.cubicTo(w * 0.66, h * 0.82, w * 0.44, h * 0.82, w * 0.38, h * 0.95);

    // Front paws meeting base
    path.quadraticBezierTo(w * 0.32, h * 0.96, w * 0.26, h * 0.95);
    path.close();

    return path;
  }
}
