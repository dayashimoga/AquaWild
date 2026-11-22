import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Highly detailed handcrafted vector painter rendering:
/// - Inflatable striped swim tube (Coral Red `#FF5252` and Mint Teal `#26A69A`) with 3D tubular gradient & highlights
/// - Ruby the Red Panda reclining comfortably with auburn fur, white ear tufts & face markings
/// - S-curved ringed tail dipping into the water behind the float tube
/// - Cool aviator sunglasses with reflective glass sheen & animated specular shine
/// - Glass tumbler with citrus drink, straw, and lemon slice held in paw
/// - Parallax depth shadow projected on the pool floor
class FloatingRedPandaPainter extends CustomPainter {
  final double bobOffset; // Vertical displacement in px from buoyancy spring
  final double tiltAngle; // Angular rocking rotation in radians
  final double glintPhase; // 0.0 to 1.0 for sunglasses glint sweep

  FloatingRedPandaPainter({
    required this.bobOffset,
    required this.tiltAngle,
    required this.glintPhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    // 1. Projected Underwater Parallax Shadow
    // Offsets by solar angle and scales with buoyancy height
    _drawUnderwaterShadow(canvas, centerX, centerY);

    // Apply buoyancy displacement & rocking tilt to the floating mascot assembly
    canvas.save();
    canvas.translate(centerX, centerY + bobOffset);
    canvas.rotate(tiltAngle);

    // 2. Ringed Fluffy Tail (dipping under the swim tube into the pool water)
    _drawRingedTail(canvas);

    // 3. Inflatable Candy-Striped Swim Tube (Background half)
    _drawSwimTubeBack(canvas);

    // 4. Red Panda Body & Reclining Paws
    _drawRedPandaBody(canvas);

    // 5. Inflatable Swim Tube (Foreground half)
    _drawSwimTubeFront(canvas);

    // 6. Red Panda Head, Ears & Facial Markings
    _drawRedPandaHead(canvas);

    // 7. Aviator Sunglasses with Animated Glint
    _drawAviatorSunglasses(canvas);

    // 8. Refreshing Tropical Citrus Drink Held in Paw
    _drawCitrusDrink(canvas);

    canvas.restore();
  }

  void _drawUnderwaterShadow(Canvas canvas, double cx, double cy) {
    final double shadowDistance = 32.0 + (bobOffset * 0.4);
    final double shadowScale = 1.0 - (bobOffset * 0.003);

    final Paint shadowPaint = Paint()
      ..color = const Color(0x44001E3D)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18.0);

    canvas.save();
    canvas.translate(cx + 16.0, cy + shadowDistance);
    canvas.scale(shadowScale, shadowScale * 0.85);

    // Composite oval representing tube and body shadow on pool tiles
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 170, height: 140),
      shadowPaint,
    );
    canvas.restore();
  }

  void _drawRingedTail(Canvas canvas) {
    final Path tailPath = Path();
    tailPath.moveTo(40, 20);
    tailPath.cubicTo(80, 50, 95, -10, 115, 30);
    tailPath.cubicTo(125, 55, 90, 85, 55, 60);
    tailPath.close();

    final Paint tailPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.redPandaAuburn, Color(0xFFBF360C)],
      ).createShader(tailPath.getBounds());

    canvas.drawPath(tailPath, tailPaint);

    // Alternating dark auburn tail stripes
    final Paint stripePaint = Paint()
      ..color = const Color(0xFF3E2723).withValues(alpha: 0.8)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(const Offset(65, 32), const Offset(75, 48), stripePaint);
    canvas.drawLine(const Offset(85, 24), const Offset(95, 42), stripePaint);
    canvas.drawLine(const Offset(105, 26), const Offset(112, 40), stripePaint);

    // Fluffy tail tip
    final Paint tipPaint = Paint()..color = AppColors.redPandaWhite;
    canvas.drawCircle(const Offset(115, 34), 9.0, tipPaint);
  }

  void _drawSwimTubeBack(Canvas canvas) {
    final Rect tubeRect = Rect.fromCenter(
      center: const Offset(0, 12),
      width: 170,
      height: 140,
    );

    final Paint tubeBasePaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFFF8A80),
          AppColors.tubeCoral,
          Color(0xFFC62828),
        ],
      ).createShader(tubeRect);

    canvas.drawOval(tubeRect, tubeBasePaint);
  }

  void _drawRedPandaBody(Canvas canvas) {
    // Reclining torso resting inside the tube
    final Rect bodyRect = Rect.fromCenter(
      center: const Offset(0, 8),
      width: 95,
      height: 85,
    );

    final Paint bodyPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.0, -0.2),
        radius: 0.9,
        colors: [
          AppColors.redPandaAuburn,
          Color(0xFFBF360C),
          Color(0xFF3E2723),
        ],
      ).createShader(bodyRect);

    canvas.drawOval(bodyRect, bodyPaint);

    // Cream belly patch
    final Rect chestRect = Rect.fromCenter(
      center: const Offset(0, 16),
      width: 50,
      height: 44,
    );
    final Paint chestPaint = Paint()..color = AppColors.redPandaWhite;
    canvas.drawOval(chestRect, chestPaint);
  }

  void _drawSwimTubeFront(Canvas canvas) {
    // Toroidal tube front rim with alternating teal/coral stripes
    final Path frontRim = Path();
    frontRim.addArc(
      Rect.fromCenter(center: const Offset(0, 12), width: 170, height: 140),
      0,
      math.pi,
    );

    final Paint tubeStripePaint = Paint()
      ..color = AppColors.tubeTeal
      ..strokeWidth = 28.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(frontRim, tubeStripePaint);

    // Accent segments on the inflatable ring
    final Paint coralSegmentPaint = Paint()
      ..color = AppColors.tubeCoral
      ..strokeWidth = 28.0
      ..style = PaintingStyle.stroke;

    // Segment 1 (Left flank)
    final Path seg1 = Path()
      ..addArc(
        Rect.fromCenter(center: const Offset(0, 12), width: 170, height: 140),
        math.pi * 0.15,
        math.pi * 0.22,
      );
    canvas.drawPath(seg1, coralSegmentPaint);

    // Segment 2 (Right flank)
    final Path seg2 = Path()
      ..addArc(
        Rect.fromCenter(center: const Offset(0, 12), width: 170, height: 140),
        math.pi * 0.63,
        math.pi * 0.22,
      );
    canvas.drawPath(seg2, coralSegmentPaint);

    // Specular wet tubular highlight along top curve
    final Path highlightPath = Path()
      ..addArc(
        Rect.fromCenter(center: const Offset(0, 4), width: 154, height: 122),
        math.pi * 0.1,
        math.pi * 0.8,
      );
    final Paint highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(highlightPath, highlightPaint);
  }

  void _drawRedPandaHead(Canvas canvas) {
    const Offset headCenter = Offset(0, -32);

    // Ears (Triangular rounded with white fur interior)
    final Paint earOuterPaint = Paint()..color = AppColors.redPandaAuburn;
    final Paint earInnerPaint = Paint()..color = AppColors.redPandaWhite;

    // Left Ear
    final Path leftEar = Path()
      ..moveTo(-34, -48)
      ..lineTo(-54, -72)
      ..lineTo(-20, -64)
      ..close();
    canvas.drawPath(leftEar, earOuterPaint);

    final Path leftEarInner = Path()
      ..moveTo(-32, -50)
      ..lineTo(-46, -67)
      ..lineTo(-24, -60)
      ..close();
    canvas.drawPath(leftEarInner, earInnerPaint);

    // Right Ear
    final Path rightEar = Path()
      ..moveTo(34, -48)
      ..lineTo(54, -72)
      ..lineTo(20, -64)
      ..close();
    canvas.drawPath(rightEar, earOuterPaint);

    final Path rightEarInner = Path()
      ..moveTo(32, -50)
      ..lineTo(46, -67)
      ..lineTo(24, -60)
      ..close();
    canvas.drawPath(rightEarInner, earInnerPaint);

    // Head base circle
    final Paint headPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.0, -0.3),
        colors: [
          Color(0xFFFF7043),
          AppColors.redPandaAuburn,
          Color(0xFFBF360C),
        ],
      ).createShader(Rect.fromCircle(center: headCenter, radius: 40));

    canvas.drawCircle(headCenter, 38, headPaint);

    // White cheek patches
    final Paint whiteCheekPaint = Paint()..color = AppColors.redPandaWhite;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-26, -24), width: 22, height: 16),
      whiteCheekPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(26, -24), width: 22, height: 16),
      whiteCheekPaint,
    );

    // White muzzle & smile
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, -22), width: 28, height: 20),
      whiteCheekPaint,
    );

    // Dark button nose
    final Paint nosePaint = Paint()..color = const Color(0xFF212121);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, -26), width: 10, height: 7),
        const Radius.circular(3),
      ),
      nosePaint,
    );

    // Content smiling mouth
    final Path mouthPath = Path()
      ..moveTo(-6, -20)
      ..quadraticBezierTo(0, -15, 6, -20);
    final Paint mouthPaint = Paint()
      ..color = const Color(0xFF212121)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    canvas.drawPath(mouthPath, mouthPaint);
  }

  void _drawAviatorSunglasses(Canvas canvas) {
    final Paint goldFrame = Paint()
      ..color = const Color(0xFFFFD54F)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    final Paint darkLens = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF212121), Color(0xFF37474F)],
      ).createShader(
        Rect.fromCenter(center: const Offset(0, -36), width: 64, height: 24),
      );

    // Left teardrop lens
    final RRect leftLens = RRect.fromRectAndCorners(
      Rect.fromCenter(center: const Offset(-16, -35), width: 26, height: 20),
      topLeft: const Radius.circular(10),
      topRight: const Radius.circular(10),
      bottomLeft: const Radius.circular(14),
      bottomRight: const Radius.circular(12),
    );
    canvas.drawRRect(leftLens, darkLens);
    canvas.drawRRect(leftLens, goldFrame);

    // Right teardrop lens
    final RRect rightLens = RRect.fromRectAndCorners(
      Rect.fromCenter(center: const Offset(16, -35), width: 26, height: 20),
      topLeft: const Radius.circular(10),
      topRight: const Radius.circular(10),
      bottomLeft: const Radius.circular(12),
      bottomRight: const Radius.circular(14),
    );
    canvas.drawRRect(rightLens, darkLens);
    canvas.drawRRect(rightLens, goldFrame);

    // Bridge wire between lenses
    canvas.drawLine(const Offset(-3, -39), const Offset(3, -39), goldFrame);
    canvas.drawLine(const Offset(-3, -35), const Offset(3, -35), goldFrame);

    // Animated Specular Glint sweeping across sunglasses
    final double sweepX = -32.0 + (glintPhase * 64.0);
    final Paint glintPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 2.0;

    canvas.save();
    canvas.clipRRect(leftLens);
    canvas.drawLine(
      Offset(sweepX, -46),
      Offset(sweepX + 12, -24),
      glintPaint,
    );
    canvas.restore();

    canvas.save();
    canvas.clipRRect(rightLens);
    canvas.drawLine(
      Offset(sweepX, -46),
      Offset(sweepX + 12, -24),
      glintPaint,
    );
    canvas.restore();
  }

  void _drawCitrusDrink(Canvas canvas) {
    // Paw resting on right tube holding the glass
    final Paint pawPaint = Paint()..color = const Color(0xFF3E2723);
    canvas.drawCircle(const Offset(46, 0), 10.0, pawPaint);

    // Tumbler glass
    final Rect glassRect = Rect.fromCenter(
      center: const Offset(56, -6),
      width: 20,
      height: 30,
    );

    // Golden citrus juice fill
    final Paint juicePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [Color(0xFFFF9800), Color(0xFFFFD54F)],
      ).createShader(glassRect);

    final RRect juiceRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(56, -4), width: 17, height: 22),
      const Radius.circular(3),
    );
    canvas.drawRRect(juiceRRect, juicePaint);

    // Glass outline & specular rim
    final Paint glassOutline = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(glassRect, const Radius.circular(4)),
      glassOutline,
    );

    // Diagonal Striped Straw
    final Paint strawPaint = Paint()
      ..color = const Color(0xFFFF1744)
      ..strokeWidth = 2.4;
    canvas.drawLine(const Offset(54, -4), const Offset(62, -26), strawPaint);

    // Fresh citrus lime wheel garnish
    final Paint limeWheel = Paint()..color = const Color(0xFF76FF03);
    canvas.drawCircle(const Offset(48, -18), 7.0, limeWheel);
    final Paint limePith = Paint()..color = const Color(0xFFCCFF90);
    canvas.drawCircle(const Offset(48, -18), 5.0, limePith);
  }

  @override
  bool shouldRepaint(covariant FloatingRedPandaPainter oldDelegate) {
    return oldDelegate.bobOffset != bobOffset ||
        oldDelegate.tiltAngle != tiltAngle ||
        oldDelegate.glintPhase != glintPhase;
  }
}
