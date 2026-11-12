import 'dart:math' as math;

import 'package:bmi/domain/models/bmi_result.dart';
import 'package:bmi/ui/core/app_theme.dart';
import 'package:flutter/material.dart';

/// The MediClean ring gauge: a circular progress ring with the BMI
/// number in the centre and the category chip underneath.
///
/// BMI 14..40 is mapped onto the ring (14 = empty, 40 = full).
/// Before the first calculation the ring shows '--' in teal.
class RingGauge extends StatelessWidget {
  const RingGauge({
    super.key,
    required this.colors,
    required this.result,
  });

  final MediCleanColors colors;
  final BmiResult? result;

  @override
  Widget build(BuildContext context) {
    final BmiResult? result = this.result;
    final double bmi = result?.bmi ?? 0;
    // Map BMI 14..40 onto the ring.
    final double progress = ((bmi - 14) / 26).clamp(0.0, 1.0).toDouble();
    final BmiCategory? category = result?.category;
    final Color color =
        category == null ? MediCleanColors.teal : colors.categoryColor(category);
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CustomPaint(
            size: const Size(180, 180),
            painter: RingPainter(
              progress: progress,
              color: color,
              trackColor: colors.ringTrack,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                result == null ? '--' : bmi.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: colors.inkColor,
                ),
              ),
              Text(
                'BMI',
                style: TextStyle(fontSize: 13, color: colors.mutedColor),
              ),
              if (category != null)
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Paints the ring gauge: a round-capped track circle plus the
/// coloured arc for [progress] (0.0–1.0), starting at the top.
class RingPainter extends CustomPainter {
  const RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  final double progress;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2 - 10;
    final Paint track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);
    if (progress > 0) {
      final Paint foreground = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        progress * 2 * math.pi,
        false,
        foreground,
      );
    }
  }

  @override
  bool shouldRepaint(RingPainter old) =>
      old.progress != progress || old.color != color || old.trackColor != trackColor;
}
