import 'package:bmi/data/repositories/plan_repository.dart';
import 'package:bmi/domain/models/bmi_result.dart';
import 'package:bmi/domain/use_cases/calculate_bmi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalculateBmi', () {
    late CalculateBmi calculateBmi;

    setUp(() {
      calculateBmi = const CalculateBmi(planRepository: PlanRepository());
    });

    group('BMI formula', () {
      test('105 kg / 5 ft 6 in -> BMI 37.36, Obesity', () {
        final BmiResult result = calculateBmi(
          weightKg: 105,
          heightFeet: 5,
          heightInches: 6,
        );
        expect(result.bmi, closeTo(37.36, 0.01));
        expect(result.resultText, equals('Your BMI is 37.36'));
        expect(result.category, equals(BmiCategory.obesity));
        expect(result.category.label, equals('Obesity'));
      });

      test('45 kg / 5 ft 7 in -> BMI 15.54, Underweight', () {
        final BmiResult result = calculateBmi(
          weightKg: 45,
          heightFeet: 5,
          heightInches: 7,
        );
        expect(result.bmi, closeTo(15.54, 0.01));
        expect(result.resultText, equals('Your BMI is 15.54'));
        expect(result.category, equals(BmiCategory.underweight));
        expect(result.category.label, equals('Underweight'));
      });

      test('decimal weight 70.5 kg is handled (double.tryParse parity)', () {
        final BmiResult result = calculateBmi(
          weightKg: 70.5,
          heightFeet: 5,
          heightInches: 7,
        );
        expect(result.bmi, closeTo(24.34, 0.01));
        expect(result.category, equals(BmiCategory.healthyWeight));
      });

      test('height conversion: feet x 12 + inches, x 2.54, / 100', () {
        final BmiResult result = calculateBmi(
          weightKg: 70,
          heightFeet: 5,
          heightInches: 7,
        );
        expect(result.heightMetres, closeTo(1.7018, 0.0001));
        expect(result.weightKg, equals(70));
      });
    });

    group('category thresholds', () {
      // At 5 ft 7 in (1.7018 m): BMI 18.5 <-> 53.58 kg,
      // BMI 25 <-> 72.40 kg, BMI 30 <-> 86.88 kg.
      test('below 18.5 is Underweight, at/above is Healthy weight', () {
        expect(
          calculateBmi(weightKg: 53, heightFeet: 5, heightInches: 7).category,
          equals(BmiCategory.underweight),
        );
        expect(
          calculateBmi(weightKg: 54, heightFeet: 5, heightInches: 7).category,
          equals(BmiCategory.healthyWeight),
        );
      });

      test('below 25 is Healthy weight, at/above is Overweight', () {
        expect(
          calculateBmi(weightKg: 72, heightFeet: 5, heightInches: 7).category,
          equals(BmiCategory.healthyWeight),
        );
        expect(
          calculateBmi(weightKg: 73, heightFeet: 5, heightInches: 7).category,
          equals(BmiCategory.overweight),
        );
      });

      test('below 30 is Overweight, at/above is Obesity', () {
        expect(
          calculateBmi(weightKg: 86, heightFeet: 5, heightInches: 7).category,
          equals(BmiCategory.overweight),
        );
        expect(
          calculateBmi(weightKg: 87, heightFeet: 5, heightInches: 7).category,
          equals(BmiCategory.obesity),
        );
      });
    });

    group('healthy-weight range', () {
      test('range is 18.5 x h^2 to 24.9 x h^2', () {
        final BmiResult result = calculateBmi(
          weightKg: 45,
          heightFeet: 5,
          heightInches: 7,
        );
        expect(result.healthyLowKg, closeTo(53.58, 0.01));
        expect(result.healthyHighKg, closeTo(72.11, 0.01));
      });

      test('underweight: kilograms to gain, exact range text', () {
        final BmiResult result = calculateBmi(
          weightKg: 45,
          heightFeet: 5,
          heightInches: 7,
        );
        expect(result.kilogramsToGain, closeTo(8.58, 0.01));
        expect(result.kilogramsToLose, isNull);
        expect(result.isInHealthyRange, isFalse);
        expect(
          result.healthyRangeText,
          equals('Healthy weight: 53.6 – 72.1 kg  •  You need to gain 8.6 kg'),
        );
      });

      test('in range: neither gain nor lose, exact range text', () {
        final BmiResult result = calculateBmi(
          weightKg: 70,
          heightFeet: 5,
          heightInches: 7,
        );
        expect(result.kilogramsToGain, isNull);
        expect(result.kilogramsToLose, isNull);
        expect(result.isInHealthyRange, isTrue);
        expect(
          result.healthyRangeText,
          equals(
            'Healthy weight: 53.6 – 72.1 kg  •  '
            'You are in the healthy range — get stronger!',
          ),
        );
      });

      test('obesity: kilograms to lose, exact range text', () {
        final BmiResult result = calculateBmi(
          weightKg: 105,
          heightFeet: 5,
          heightInches: 6,
        );
        expect(result.kilogramsToGain, isNull);
        expect(result.kilogramsToLose, closeTo(35.02, 0.01));
        expect(result.isInHealthyRange, isFalse);
        expect(
          result.healthyRangeText,
          equals('Healthy weight: 52.0 – 70.0 kg  •  You need to lose 35.0 kg'),
        );
      });
    });

    group('plan content', () {
      test('each category gets its own plan title and lists', () {
        final BmiResult underweight = calculateBmi(
          weightKg: 45,
          heightFeet: 5,
          heightInches: 7,
        );
        expect(underweight.plan.title, equals('How to go from Underweight to Healthy'));
        expect(underweight.plan.steps, hasLength(4));
        expect(underweight.plan.eat, hasLength(4));
        expect(underweight.plan.avoid, hasLength(3));

        final BmiResult obesity = calculateBmi(
          weightKg: 105,
          heightFeet: 5,
          heightInches: 6,
        );
        expect(obesity.plan.title, equals('How to go from Obesity to Healthy'));
        expect(obesity.plan.steps, hasLength(4));
        expect(
          obesity.plan.steps.first,
          equals('First consult a doctor / dietitian, then start the plan.'),
        );
      });
    });

    group('invalid input', () {
      test('zero or negative inputs throw ArgumentError', () {
        expect(
          () => calculateBmi(weightKg: 0, heightFeet: 5, heightInches: 7),
          throwsArgumentError,
        );
        expect(
          () => calculateBmi(weightKg: 70, heightFeet: 0, heightInches: 7),
          throwsArgumentError,
        );
        expect(
          () => calculateBmi(weightKg: 70, heightFeet: 5, heightInches: -1),
          throwsArgumentError,
        );
      });

      test('zero inches is allowed (5 ft 0 in)', () {
        final BmiResult result = calculateBmi(
          weightKg: 70,
          heightFeet: 5,
          heightInches: 0,
        );
        expect(result.bmi, closeTo(30.14, 0.01));
        expect(result.category, equals(BmiCategory.obesity));
      });
    });
  });
}
