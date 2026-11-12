import 'package:bmi/ui/core/app_theme.dart';
import 'package:flutter/material.dart';

/// The soft rounded MediClean card used by every section of the BMI
/// screen: white (or slate in dark mode) with a thin border and a
/// soft shadow. An optional [tint] re-colours the card (plan cards
/// and the sample-menu card use tints, dark-adjusted by the theme).
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.colors,
    required this.child,
    this.tint,
  });

  final MediCleanColors colors;
  final Widget child;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final Color? tint = this.tint;
    return Container(
      decoration: BoxDecoration(
        color: tint != null ? colors.tint(tint) : colors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.borderColor),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: child,
    );
  }
}
