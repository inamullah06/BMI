import 'package:flutter/foundation.dart';

/// BMI categories, with the exact display names used in the original app.
///
/// The original single-file app stored the category as a plain string
/// ('Underweight', 'Healthy weight', 'Overweight', 'Obesity'). The enum
/// keeps those exact strings as [label] so the UI, colours and avatar
/// mapping are unchanged.
enum BmiCategory {
  underweight,
  healthyWeight,
  overweight,
  obesity;

  String get label {
    switch (this) {
      case BmiCategory.underweight:
        return 'Underweight';
      case BmiCategory.healthyWeight:
        return 'Healthy weight';
      case BmiCategory.overweight:
        return 'Overweight';
      case BmiCategory.obesity:
        return 'Obesity';
    }
  }
}

/// Per-category guidance content: plan steps, what to eat, what to avoid,
/// and a sample 1-day menu. Pure data, supplied by [PlanRepository].
///
/// Immutable plain-Dart model — no code generation, no new dependencies.
@immutable
class BmiPlan {
  const BmiPlan({
    required this.title,
    required this.steps,
    required this.eat,
    required this.avoid,
    required this.sampleMenu,
  });

  final String title;
  final List<String> steps;
  final List<String> eat;
  final List<String> avoid;
  final String sampleMenu;

  @override
  bool operator ==(Object other) {
    return other is BmiPlan &&
        other.title == title &&
        listEquals(other.steps, steps) &&
        listEquals(other.eat, eat) &&
        listEquals(other.avoid, avoid) &&
        other.sampleMenu == sampleMenu;
  }

  @override
  int get hashCode => Object.hash(
        title,
        Object.hashAll(steps),
        Object.hashAll(eat),
        Object.hashAll(avoid),
        sampleMenu,
      );
}

/// The complete result of one BMI calculation.
///
/// Immutable plain-Dart model — no code generation, no new dependencies.
/// Holds the BMI value, the category, the healthy-weight range for the
/// user's height, how many kilograms to gain or lose, and the plan data
/// for the category.
@immutable
class BmiResult {
  const BmiResult({
    required this.bmi,
    required this.category,
    required this.weightKg,
    required this.heightMetres,
    required this.healthyLowKg,
    required this.healthyHighKg,
    required this.kilogramsToGain,
    required this.kilogramsToLose,
    required this.plan,
  });

  /// The BMI value, e.g. 22.84.
  final double bmi;

  /// Category from the standard thresholds (< 18.5, < 25, < 30, else).
  final BmiCategory category;

  /// The weight that was entered, in kilograms.
  final double weightKg;

  /// The height that was entered, converted to metres.
  final double heightMetres;

  /// Lower end of the healthy-weight range: 18.5 x height^2.
  final double healthyLowKg;

  /// Upper end of the healthy-weight range: 24.9 x height^2.
  final double healthyHighKg;

  /// Kilograms to gain to reach the healthy range, or null if the
  /// weight is already at or above the healthy range.
  final double? kilogramsToGain;

  /// Kilograms to lose to reach the healthy range, or null if the
  /// weight is already at or below the healthy range.
  final double? kilogramsToLose;

  /// Plan content (steps, eat/avoid lists, sample menu) for [category].
  final BmiPlan plan;

  /// True when the weight is inside the healthy-weight range.
  bool get isInHealthyRange => kilogramsToGain == null && kilogramsToLose == null;

  /// The result line shown under the Calculate button, exactly as in
  /// the original app: 'Your BMI is 22.84'.
  String get resultText => 'Your BMI is ${bmi.toStringAsFixed(2)}';

  /// The healthy-range line shown under the ring gauge, exactly as in
  /// the original app, e.g.:
  /// 'Healthy weight: 54.0 – 72.6 kg  •  You need to gain 9.0 kg'.
  String get healthyRangeText {
    final double? gain = kilogramsToGain;
    final double? lose = kilogramsToLose;
    final String diff;
    if (gain != null) {
      diff = 'You need to gain ${gain.toStringAsFixed(1)} kg';
    } else if (lose != null) {
      diff = 'You need to lose ${lose.toStringAsFixed(1)} kg';
    } else {
      diff = 'You are in the healthy range — get stronger!';
    }
    return 'Healthy weight: ${healthyLowKg.toStringAsFixed(1)} – '
        '${healthyHighKg.toStringAsFixed(1)} kg  •  $diff';
  }

  @override
  bool operator ==(Object other) {
    return other is BmiResult &&
        other.bmi == bmi &&
        other.category == category &&
        other.weightKg == weightKg &&
        other.heightMetres == heightMetres &&
        other.healthyLowKg == healthyLowKg &&
        other.healthyHighKg == healthyHighKg &&
        other.kilogramsToGain == kilogramsToGain &&
        other.kilogramsToLose == kilogramsToLose &&
        other.plan == plan;
  }

  @override
  int get hashCode => Object.hash(
        bmi,
        category,
        weightKg,
        heightMetres,
        healthyLowKg,
        healthyHighKg,
        kilogramsToGain,
        kilogramsToLose,
        plan,
      );
}
