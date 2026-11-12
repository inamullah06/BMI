import 'package:bmi/data/repositories/plan_repository.dart';
import 'package:bmi/domain/models/bmi_result.dart';

/// Pure BMI calculation logic, extracted verbatim from the original
/// single-file app.
///
/// Inputs are the values the user typed: weight in kilograms, height in
/// feet and inches. The conversion and formula are unchanged:
/// total inches = feet x 12 + inches; centimetres = inches x 2.54;
/// metres = centimetres / 100; BMI = kg / m^2.
///
/// Category thresholds are unchanged: BMI < 18.5 Underweight,
/// < 25 Healthy weight, < 30 Overweight, otherwise Obesity.
///
/// The healthy-weight range is unchanged: 18.5 x height^2 to
/// 24.9 x height^2 (kilograms).
///
/// The plan content for the resulting category comes from
/// [PlanRepository], which this use case sits in front of — the
/// architecture skill's Use Case position between ViewModel and
/// Repository.
class CalculateBmi {
  const CalculateBmi({required PlanRepository planRepository})
      : _planRepository = planRepository;

  final PlanRepository _planRepository;

  BmiResult call({
    required double weightKg,
    required double heightFeet,
    required double heightInches,
  }) {
    if (weightKg <= 0 || heightFeet <= 0 || heightInches < 0) {
      throw ArgumentError(
        'Weight and height must be positive (weight: $weightKg, '
        'feet: $heightFeet, inches: $heightInches).',
      );
    }

    final double totalInches = (heightFeet * 12) + heightInches;
    final double totalCm = totalInches * 2.54;
    final double heightMetres = totalCm / 100;
    final double bmi = weightKg / (heightMetres * heightMetres);

    final BmiCategory category = _categoryFor(bmi);

    final double healthyLowKg = 18.5 * heightMetres * heightMetres;
    final double healthyHighKg = 24.9 * heightMetres * heightMetres;
    final double? kilogramsToGain =
        weightKg < healthyLowKg ? healthyLowKg - weightKg : null;
    final double? kilogramsToLose =
        weightKg > healthyHighKg ? weightKg - healthyHighKg : null;

    return BmiResult(
      bmi: bmi,
      category: category,
      weightKg: weightKg,
      heightMetres: heightMetres,
      healthyLowKg: healthyLowKg,
      healthyHighKg: healthyHighKg,
      kilogramsToGain: kilogramsToGain,
      kilogramsToLose: kilogramsToLose,
      plan: _planRepository.planFor(category),
    );
  }

  static BmiCategory _categoryFor(double bmi) {
    if (bmi < 18.5) {
      return BmiCategory.underweight;
    }
    if (bmi < 25) {
      return BmiCategory.healthyWeight;
    }
    if (bmi < 30) {
      return BmiCategory.overweight;
    }
    return BmiCategory.obesity;
  }
}
