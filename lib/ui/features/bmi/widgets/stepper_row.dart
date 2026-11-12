import 'package:bmi/ui/core/app_theme.dart';
import 'package:flutter/material.dart';

/// Label + minus/plus stepper row, as used for the Weight input:
/// the label on the left, tonal round buttons around the value.
class StepperRow extends StatelessWidget {
  const StepperRow({
    super.key,
    required this.colors,
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final MediCleanColors colors;
  final String label;
  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colors.inkColor,
            ),
          ),
        ),
        IconButton.filledTonal(
          onPressed: onMinus,
          icon: const Icon(Icons.remove),
          style: IconButton.styleFrom(
            backgroundColor: colors.stepperBg,
            foregroundColor: colors.inkColor,
          ),
        ),
        SizedBox(
          width: 72,
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colors.inkColor,
            ),
          ),
        ),
        IconButton.filledTonal(
          onPressed: onPlus,
          icon: const Icon(Icons.add),
          style: IconButton.styleFrom(
            backgroundColor: colors.stepperBg,
            foregroundColor: colors.inkColor,
          ),
        ),
      ],
    );
  }
}
