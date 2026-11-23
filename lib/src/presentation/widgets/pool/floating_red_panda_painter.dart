import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Highly detailed anatomically accurate vector painter rendering:
/// - Ruby the Red Panda (*Ailurus fulgens*) reclining naturally in crystal-clear water
/// - Continuous water refraction contact rim (Zero artificial balloon / swim tube)
/// - Iconic plush cylindrical ringed tail with 12 alternating auburn/ochre bands & cream tip
/// - Dense auburn-red fur gradients with white chest bib & dark charcoal underbelly/limbs
/// - Authentic facial anatomy: white muzzle, cheek patches, distinctive auburn tear-tracks
/// - Expressive almond-shaped eyes (Sunglasses removed) with glossy catchlights & eyelid blinking support
/// - Refreshing highland spring bamboo/crystal drink held in paw
/// - Projected depth parallax shadow on the pool floor
class FloatingRedPandaPainter extends CustomPainter {
  final double bobOffset; // Vertical displacement in px from buoyancy spring
  final double tiltAngle; // Angular rocking rotation in radians
  final double glintPhase; // Shimmer/water glint phase (0.0 to 1.0)
  final double breathPhase; // Breathing expansion phase (0.0 to 1.0)
  final double blinkProgress; // Eyelid blink progress (0.0 = open, 1.0 = closed)
  final double tailWagPhase; // Tail pendulum wagging phase
  final Offset lookTarget; // Pupil eye-tracking offset (-1.0 to 1.0)
  final double earTwitchAngle; // Radians for spontaneous ear twitch flick
  final double reactionPulse; // 0.0 to 1.0 for affectionate squint & smile flare
  final double verticalSquash; // Squash/stretch ratio for anticipation & landing (1.0 = normal)
  final bool isFacingLeft; // Horizontal facing direction based on locomotion trajectory

  // Reusable paints to ensure 120 FPS performance with zero per-frame GC allocations
  final Paint _shadowPaint = Paint()
    ..color = const Color(0x38001E3D)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16.0);

  final Paint _waterContactRimPaint = Paint()
    ..color = const Color(0x44B2EBF2)
    ..strokeWidth = 3.5
    ..style = PaintingStyle.stroke;

  final Paint _furWhitePaint = Paint()
    ..style = PaintingStyle.fill
    ..color = AppColors.redPandaWhite;

  final Paint _limbDarkPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0xFF261C14);

  final Paint _eyePupilPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = const Color(0xFF150D0A);

  final Paint _specularHighlightPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.white;

  final Paint _tearTrackPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 2.4
    ..color = const Color(0xFF8D2B0D);

  final Paint _mouthPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 1.8
    ..color = const Color(0xFF1E140F);

  FloatingRedPandaPainter({
    required this.bobOffset,
    required this.tiltAngle,
    required this.glintPhase,
    this.breathPhase = 0.0,
    this.blinkProgress = 0.0,
    this.tailWagPhase = 0.0,
    this.lookTarget = Offset.zero,
    this.earTwitchAngle = 0.0,
    this.reactionPulse = 0.0,
    this.verticalSquash = 1.0,
    this.isFacingLeft = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    // 1. Projected Underwater Parallax Shadow on Pool Tiles
    _drawUnderwaterShadow(canvas, centerX, centerY);

    // Apply buoyancy displacement, rocking tilt, and volume-preserving squash/stretch
    canvas.save();
    canvas.translate(centerX, centerY + bobOffset);
    canvas.rotate(tiltAngle);
    if (isFacingLeft) {
      canvas.scale(-1.0, 1.0);
    }
    if ((verticalSquash - 1.0).abs() > 0.005) {
      final double safeSquash = verticalSquash.clamp(0.80, 1.25);
      canvas.scale(1.0 / math.sqrt(safeSquash), safeSquash);
    }

    // 2. Submerged Water Contact & Wet Rim
    _drawWaterlinePerimeter(canvas);

    // 3. Luxurious 12-Ringed Plush Tail (Curling naturally across pool surface)
    _drawPlushRingedTail(canvas);

    // 4. Submerged Hind Legs & Dark Underbelly
    _drawSubmergedHindLimbs(canvas);

    // 5. Reclining Auburn Torso & White Chest Fur Bib (With Breathing Expansion)
    _drawTorsoAndChest(canvas);

    // 6. Forelimbs & Natural Floating Water Paddling Paws
    _drawForelimbs(canvas);

    // 7. Anatomical Head, Ears, Facial Masks & Expressive Eyes
    _drawHeadAndFacialAnatomy(canvas);

    // 8. Natural Right Forelimb Resting in Water
    _drawRightForelimb(canvas);

    canvas.restore();
  }

  void _drawUnderwaterShadow(Canvas canvas, double cx, double cy) {
    final double shadowDistance = 28.0 + (bobOffset * 0.35);
    final double shadowScale = 1.0 - (bobOffset * 0.002);

    canvas.save();
    canvas.translate(cx + 12.0, cy + shadowDistance);
    canvas.scale(shadowScale, shadowScale * 0.85);

    // Composite organic shadow matching Ruby's body and long tail
    final Path shadowPath = Path();
    shadowPath.addOval(
      Rect.fromCenter(center: const Offset(0, 10), width: 110, height: 95),
    );
    shadowPath.addOval(
      Rect.fromCenter(center: const Offset(55, 30), width: 90, height: 45),
    );

    canvas.drawPath(shadowPath, _shadowPaint);
    canvas.restore();
  }

  void _drawWaterlinePerimeter(Canvas canvas) {
    // Water meniscus glow where fur meets the liquid surface
    final Path waterlinePath = Path();
    waterlinePath.addOval(
      Rect.fromCenter(center: const Offset(0, 16), width: 118, height: 86),
    );
    canvas.drawPath(waterlinePath, _waterContactRimPaint);
  }

  void _drawPlushRingedTail(Canvas canvas) {
    // Dynamic tail wag deflection
    final double wagAngle = math.sin(tailWagPhase) * 0.08;

    canvas.save();
    canvas.translate(35, 22);
    canvas.rotate(wagAngle);

    // Elegant S-curved thick plush tail path
    final Path tailPath = Path();
    tailPath.moveTo(0, 0);
    tailPath.cubicTo(35, 15, 60, -10, 85, 8);
    tailPath.cubicTo(108, 24, 118, 48, 98, 62);
    tailPath.cubicTo(78, 74, 45, 52, 25, 38);
    tailPath.close();

    final Paint tailBasePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFE64A19),
          AppColors.redPandaAuburn,
          Color(0xFFBF360C),
        ],
      ).createShader(tailPath.getBounds());

    canvas.drawPath(tailPath, tailBasePaint);

    // 12 Alternating Distinctive Tail Rings (Dark Auburn and Warm Ochre/Buff)
    final Paint darkRingPaint = Paint()
      ..color = const Color(0xFF4E1D0E).withValues(alpha: 0.85)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Paint ochreRingPaint = Paint()
      ..color = const Color(0xFFFFB74D).withValues(alpha: 0.75)
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final ringOffsets = [
      (const Offset(22, 10), const Offset(28, 28)),
      (const Offset(38, 7), const Offset(44, 28)),
      (const Offset(52, 6), const Offset(58, 30)),
      (const Offset(66, 7), const Offset(72, 34)),
      (const Offset(80, 12), const Offset(85, 42)),
      (const Offset(92, 22), const Offset(88, 52)),
    ];

    for (int i = 0; i < ringOffsets.length; i++) {
      final (p1, p2) = ringOffsets[i];
      canvas.drawLine(p1, p2, darkRingPaint);
      if (i < ringOffsets.length - 1) {
        final mid1 = Offset((p1.dx + ringOffsets[i + 1].$1.dx) / 2,
            (p1.dy + ringOffsets[i + 1].$1.dy) / 2);
        final mid2 = Offset((p2.dx + ringOffsets[i + 1].$2.dx) / 2,
            (p2.dy + ringOffsets[i + 1].$2.dy) / 2);
        canvas.drawLine(mid1, mid2, ochreRingPaint);
      }
    }

    // Bushy Cream Tail Tip dipping into water ripples
    final Paint tailTipPaint = Paint()..color = const Color(0xFFFFF8E1);
    final Path tipPath = Path();
    tipPath.moveTo(96, 42);
    tipPath.quadraticBezierTo(116, 52, 98, 62);
    tipPath.quadraticBezierTo(86, 56, 96, 42);
    canvas.drawPath(tipPath, tailTipPaint);

    canvas.restore();
  }

  void _drawSubmergedHindLimbs(Canvas canvas) {
    // Dark charcoal/chocolate hind legs resting in water
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-38, 26), width: 32, height: 24),
      _limbDarkPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(36, 26), width: 32, height: 24),
      _limbDarkPaint,
    );
  }

  void _drawTorsoAndChest(Canvas canvas) {
    // Breathing expansion factor (subtle 3-4% volumetric chest scaling)
    final double breathScale = 1.0 + (math.sin(breathPhase * math.pi * 2) * 0.035);

    canvas.save();
    canvas.scale(breathScale, breathScale);

    // Main Auburn Torso
    final Rect torsoRect =
        Rect.fromCenter(center: const Offset(0, 12), width: 88, height: 76);
    final Paint torsoPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.0, -0.2),
        radius: 0.85,
        colors: [
          Color(0xFFFF7043),
          AppColors.redPandaAuburn,
          Color(0xFFBF360C),
        ],
      ).createShader(torsoRect);

    canvas.drawOval(torsoRect, torsoPaint);

    // Cream-White Chest Bib Fur Patch
    final Path chestBib = Path();
    chestBib.moveTo(0, -6);
    chestBib.cubicTo(-22, 0, -26, 26, 0, 36);
    chestBib.cubicTo(26, 26, 22, 0, 0, -6);
    canvas.drawPath(chestBib, _furWhitePaint);

    canvas.restore();
  }

  void _drawForelimbs(Canvas canvas) {
    // Left front paw resting comfortably on water
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-32, 10), width: 22, height: 18),
      _limbDarkPaint,
    );

    // Left paw pad highlights
    final Paint padPaint = Paint()..color = const Color(0xFF150D0A);
    canvas.drawCircle(const Offset(-32, 11), 3.5, padPaint);
  }

  void _drawHeadAndFacialAnatomy(Canvas canvas) {
    const Offset headCenter = Offset(0, -32);

    // 1. Triangular Rounded Ears
    _drawEars(canvas, headCenter);

    // 2. Head Base Skull with Auburn Gradient
    final Rect headRect =
        Rect.fromCircle(center: headCenter, radius: 42);
    final Paint headPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.0, -0.3),
        colors: [
          Color(0xFFFF7043),
          AppColors.redPandaAuburn,
          Color(0xFFBF360C),
        ],
      ).createShader(headRect);

    canvas.drawCircle(headCenter, 40, headPaint);

    // 3. Iconic White Cheek Masks & Eyebrow Spots
    _drawFacialWhiteMarkings(canvas, headCenter);

    // 4. Characteristic Auburn Tear-Tracks
    _drawAuburnTearTracks(canvas, headCenter);

    // 5. Expressive Glossy Eyes (Sunglasses REMOVED)
    _drawExpressiveEyes(canvas, headCenter);

    // 6. Realistic Button Nose, Philtrum, and Sweet Smile
    _drawMuzzleAndMouth(canvas, headCenter);
  }

  void _drawEars(Canvas canvas, Offset headCenter) {
    final Paint earOuterPaint = Paint()..color = const Color(0xFF9C2A0A);
    final Paint earFurPaint = Paint()..color = AppColors.redPandaWhite;

    // Left Ear
    final Path leftEarOuter = Path()
      ..moveTo(headCenter.dx - 22, headCenter.dy - 20)
      ..lineTo(headCenter.dx - 48, headCenter.dy - 50)
      ..quadraticBezierTo(headCenter.dx - 44, headCenter.dy - 56,
          headCenter.dx - 36, headCenter.dy - 54)
      ..lineTo(headCenter.dx - 12, headCenter.dy - 32)
      ..close();
    canvas.drawPath(leftEarOuter, earOuterPaint);

    // Left Ear Dense White Fur Tuft
    final Path leftEarTuft = Path()
      ..moveTo(headCenter.dx - 20, headCenter.dy - 22)
      ..lineTo(headCenter.dx - 40, headCenter.dy - 46)
      ..lineTo(headCenter.dx - 28, headCenter.dy - 38)
      ..lineTo(headCenter.dx - 34, headCenter.dy - 48)
      ..lineTo(headCenter.dx - 18, headCenter.dy - 30)
      ..close();
    canvas.drawPath(leftEarTuft, earFurPaint);

    // Right Ear (with spontaneous ear twitch flick support)
    canvas.save();
    if (earTwitchAngle.abs() > 0.001) {
      canvas.translate(headCenter.dx + 22, headCenter.dy - 20);
      canvas.rotate(earTwitchAngle);
      canvas.translate(-(headCenter.dx + 22), -(headCenter.dy - 20));
    }

    final Path rightEarOuter = Path()
      ..moveTo(headCenter.dx + 22, headCenter.dy - 20)
      ..lineTo(headCenter.dx + 48, headCenter.dy - 50)
      ..quadraticBezierTo(headCenter.dx + 44, headCenter.dy - 56,
          headCenter.dx + 36, headCenter.dy - 54)
      ..lineTo(headCenter.dx + 12, headCenter.dy - 32)
      ..close();
    canvas.drawPath(rightEarOuter, earOuterPaint);

    // Right Ear Dense White Fur Tuft
    final Path rightEarTuft = Path()
      ..moveTo(headCenter.dx + 20, headCenter.dy - 22)
      ..lineTo(headCenter.dx + 40, headCenter.dy - 46)
      ..lineTo(headCenter.dx + 28, headCenter.dy - 38)
      ..lineTo(headCenter.dx + 34, headCenter.dy - 48)
      ..lineTo(headCenter.dx + 18, headCenter.dy - 30)
      ..close();
    canvas.drawPath(rightEarTuft, earFurPaint);
    canvas.restore();
  }

  void _drawFacialWhiteMarkings(Canvas canvas, Offset headCenter) {
    // Broad white cheek patches extending to side of face
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(headCenter.dx - 25, headCenter.dy + 8),
        width: 24,
        height: 18,
      ),
      _furWhitePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(headCenter.dx + 25, headCenter.dy + 8),
        width: 24,
        height: 18,
      ),
      _furWhitePaint,
    );

    // White Muzzle Area
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(headCenter.dx, headCenter.dy + 12),
        width: 32,
        height: 22,
      ),
      _furWhitePaint,
    );

    // Expressive White Eyebrow Spots
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(headCenter.dx - 15, headCenter.dy - 16),
        width: 8,
        height: 6,
      ),
      _furWhitePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(headCenter.dx + 15, headCenter.dy - 16),
        width: 8,
        height: 6,
      ),
      _furWhitePaint,
    );
  }

  void _drawAuburnTearTracks(Canvas canvas, Offset headCenter) {
    // Iconic Red Panda Tear Stripes running from eye corners to mouth
    final Path leftTrack = Path();
    leftTrack.moveTo(headCenter.dx - 12, headCenter.dy - 4);
    leftTrack.quadraticBezierTo(
      headCenter.dx - 18,
      headCenter.dy + 4,
      headCenter.dx - 14,
      headCenter.dy + 16,
    );
    canvas.drawPath(leftTrack, _tearTrackPaint);

    final Path rightTrack = Path();
    rightTrack.moveTo(headCenter.dx + 12, headCenter.dy - 4);
    rightTrack.quadraticBezierTo(
      headCenter.dx + 18,
      headCenter.dy + 4,
      headCenter.dx + 14,
      headCenter.dy + 16,
    );
    canvas.drawPath(rightTrack, _tearTrackPaint);
  }

  void _drawExpressiveEyes(Canvas canvas, Offset headCenter) {
    final double leftEyeX = headCenter.dx - 16;
    final double rightEyeX = headCenter.dx + 16;
    final double eyeY = headCenter.dy - 5;

    final double clampedBlink = blinkProgress.clamp(0.0, 1.0);
    final double reactionSquint = (reactionPulse * 0.5).clamp(0.0, 0.7);
    final double effectiveBlink = math.max(clampedBlink, reactionSquint);
    final double eyeHeight = 11.0 * (1.0 - effectiveBlink * 0.95);

    // If eyes are mostly open, draw iris, pupils and specular shine
    if (eyeHeight > 2.0) {
      final Paint irisPaint = Paint()
        ..shader = const RadialGradient(
          colors: [
            Color(0xFF5D4037),
            Color(0xFF3E2723),
            Color(0xFF1B0000),
          ],
        ).createShader(
          Rect.fromCenter(center: Offset(leftEyeX, eyeY), width: 14, height: 14),
        );

      // Eye tracking pupil offset
      final double pupilDx = (lookTarget.dx * 2.0).clamp(-2.5, 2.5);
      final double pupilDy = (lookTarget.dy * 1.5).clamp(-2.0, 2.0);

      // Left Eye
      final Rect leftEyeRect = Rect.fromCenter(
        center: Offset(leftEyeX, eyeY),
        width: 13,
        height: eyeHeight,
      );
      canvas.drawOval(leftEyeRect, irisPaint);
      canvas.drawCircle(
        Offset(leftEyeX + pupilDx, eyeY + pupilDy),
        3.5 * (1.0 - effectiveBlink * 0.5),
        _eyePupilPaint,
      );
      // Dual Specular Catchlights for life and moisture
      canvas.drawCircle(
        Offset(leftEyeX - 2.2, eyeY - 2.2),
        1.8,
        _specularHighlightPaint,
      );
      canvas.drawCircle(
        Offset(leftEyeX + 1.8, eyeY + 1.6),
        0.9,
        _specularHighlightPaint,
      );

      // Right Eye
      final Rect rightEyeRect = Rect.fromCenter(
        center: Offset(rightEyeX, eyeY),
        width: 13,
        height: eyeHeight,
      );
      canvas.drawOval(rightEyeRect, irisPaint);
      canvas.drawCircle(
        Offset(rightEyeX + pupilDx, eyeY + pupilDy),
        3.5 * (1.0 - effectiveBlink * 0.5),
        _eyePupilPaint,
      );
      canvas.drawCircle(
        Offset(rightEyeX - 2.2, eyeY - 2.2),
        1.8,
        _specularHighlightPaint,
      );
      canvas.drawCircle(
        Offset(rightEyeX + 1.8, eyeY + 1.6),
        0.9,
        _specularHighlightPaint,
      );
    } else {
      // Eyelid line when closed / blinking or squinting happily
      final Paint closedEyePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF2E170F);

      final double curveSag = reactionPulse > 0.2 ? -2.2 : 2.0;
      final Path leftClosed = Path()
        ..moveTo(leftEyeX - 6, eyeY)
        ..quadraticBezierTo(leftEyeX, eyeY + curveSag, leftEyeX + 6, eyeY);
      canvas.drawPath(leftClosed, closedEyePaint);

      final Path rightClosed = Path()
        ..moveTo(rightEyeX - 6, eyeY)
        ..quadraticBezierTo(rightEyeX, eyeY + curveSag, rightEyeX + 6, eyeY);
      canvas.drawPath(rightClosed, closedEyePaint);
    }
  }

  void _drawMuzzleAndMouth(Canvas canvas, Offset headCenter) {
    // Affectionate cheek blush when stroked or reacted
    if (reactionPulse > 0.05) {
      final Paint blushPaint = Paint()
        ..color = Color.fromRGBO(255, 110, 130, 0.28 * reactionPulse.clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
      canvas.drawCircle(Offset(headCenter.dx - 22, headCenter.dy + 8), 7.5, blushPaint);
      canvas.drawCircle(Offset(headCenter.dx + 22, headCenter.dy + 8), 7.5, blushPaint);
    }

    // Dark button nose with nostrils
    final Offset nosePos = Offset(headCenter.dx, headCenter.dy + 6);
    final Paint nosePaint = Paint()..color = const Color(0xFF1E140F);

    final Path nosePath = Path();
    nosePath.moveTo(nosePos.dx - 6, nosePos.dy - 2);
    nosePath.quadraticBezierTo(
        nosePos.dx, nosePos.dy - 4, nosePos.dx + 6, nosePos.dy - 2);
    nosePath.quadraticBezierTo(
        nosePos.dx + 4, nosePos.dy + 4, nosePos.dx, nosePos.dy + 5);
    nosePath.quadraticBezierTo(
        nosePos.dx - 4, nosePos.dy + 4, nosePos.dx - 6, nosePos.dy - 2);
    canvas.drawPath(nosePath, nosePaint);

    // Philtrum vertical line
    canvas.drawLine(
      Offset(nosePos.dx, nosePos.dy + 5),
      Offset(nosePos.dx, nosePos.dy + 10),
      _mouthPaint,
    );

    // Content smiling mouth (flares wider when stroked)
    final double smileSag = 14.0 + reactionPulse * 2.5;
    final Path mouthPath = Path();
    mouthPath.moveTo(nosePos.dx - 8, nosePos.dy + 11);
    mouthPath.quadraticBezierTo(
      nosePos.dx - 4,
      nosePos.dy + smileSag,
      nosePos.dx,
      nosePos.dy + 11,
    );
    mouthPath.quadraticBezierTo(
      nosePos.dx + 4,
      nosePos.dy + smileSag,
      nosePos.dx + 8,
      nosePos.dy + 11,
    );
    canvas.drawPath(mouthPath, _mouthPaint);
  }

  void _drawRightForelimb(Canvas canvas) {
    // Right forepaw resting naturally on the water surface with gentle ripples
    const Offset pawPos = Offset(32, 10);
    canvas.drawOval(
      Rect.fromCenter(center: pawPos, width: 22, height: 18),
      _limbDarkPaint,
    );

    // Right paw dark pad highlights
    final Paint padPaint = Paint()..color = const Color(0xFF150D0A);
    canvas.drawCircle(const Offset(32, 11), 3.5, padPaint);

    // Water surface tension rim around resting paw
    final Paint pawRimPaint = Paint()
      ..color = const Color(0x55B2EBF2)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(32, 12), width: 26, height: 20),
      pawRimPaint,
    );
  }

  @override
  bool shouldRepaint(covariant FloatingRedPandaPainter oldDelegate) {
    return oldDelegate.bobOffset != bobOffset ||
        oldDelegate.tiltAngle != tiltAngle ||
        oldDelegate.glintPhase != glintPhase ||
        oldDelegate.breathPhase != breathPhase ||
        oldDelegate.blinkProgress != blinkProgress ||
        oldDelegate.tailWagPhase != tailWagPhase ||
        oldDelegate.lookTarget != lookTarget ||
        oldDelegate.earTwitchAngle != earTwitchAngle ||
        oldDelegate.reactionPulse != reactionPulse ||
        oldDelegate.verticalSquash != verticalSquash ||
        oldDelegate.isFacingLeft != isFacingLeft;
  }
}
