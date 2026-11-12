import 'package:bmi/data/repositories/plan_repository.dart';
import 'package:bmi/domain/models/bmi_result.dart';
import 'package:bmi/domain/use_cases/calculate_bmi.dart';
import 'package:bmi/ui/core/app_theme.dart';
import 'package:bmi/ui/features/bmi/view_models/bmi_view_model.dart';
import 'package:bmi/ui/features/bmi/views/bmi_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BmiView', () {
    late BmiViewModel viewModel;

    setUp(() {
      viewModel = BmiViewModel(
        calculateBmi: const CalculateBmi(planRepository: PlanRepository()),
      );
    });

    tearDown(() {
      viewModel.dispose();
    });

    Future<void> pumpView(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: BmiView(viewModel: viewModel),
        ),
      );
      await tester.pump();
    }

    testWidgets('shows the input card and empty result state initially',
        (WidgetTester tester) async {
      await pumpView(tester);

      expect(find.text('Check your BMI'), findsOneWidget);
      expect(find.text('Calculate BMI'), findsOneWidget);
      expect(find.text('--'), findsOneWidget);
      // Age field and gender buttons are present; Male and age 28
      // are the defaults.
      expect(find.byKey(const Key('ageField')), findsOneWidget);
      expect(find.text('Gender'), findsOneWidget);
      expect(find.byKey(const Key('maleChip')), findsOneWidget);
      expect(find.byKey(const Key('femaleChip')), findsOneWidget);
      expect(find.text('Male'), findsOneWidget);
      expect(find.text('Female'), findsOneWidget);
      expect(find.text('Age (Years)'), findsOneWidget);
      expect(find.text('28 years'), findsOneWidget);
      expect(viewModel.gender, equals(Gender.male));
      expect(viewModel.ageSlider, equals(28));
      expect(find.text('Avatar — it will change with your BMI'), findsOneWidget);
      expect(
        find.text(
          'Enter your weight and height and press Calculate — '
          'your category, avatar and plan will appear here.',
        ),
        findsOneWidget,
      );
      expect(find.text('Plan'), findsNothing);
    });

    testWidgets('calculating 105 kg / 5 ft 6 in shows BMI and Obesity plan',
        (WidgetTester tester) async {
      await pumpView(tester);

      await tester.enterText(find.byKey(const Key('weightField')), '105');
      await tester.enterText(find.byKey(const Key('feetField')), '5');
      await tester.enterText(find.byKey(const Key('inchesField')), '6');
      await tester.enterText(find.byKey(const Key('ageField')), '25');
      await tester.pump();

      await tester.ensureVisible(find.byKey(const Key('calculateButton')));
      await tester.tap(find.byKey(const Key('calculateButton')));
      // AnimatedSwitcher runs a 600 ms scale transition; settle it.
      await tester.pumpAndSettle();

      expect(find.text('Your BMI is 37.36'), findsOneWidget);
      // Age + default gender (Male) show under the BMI number.
      expect(find.text('Age: 25  •  Male'), findsOneWidget);
      // The category appears twice: the ring-gauge chip and the
      // avatar caption.
      expect(find.text('Obesity'), findsNWidgets(2));
      expect(
        find.text('Healthy weight: 52.0 – 70.0 kg  •  You need to lose 35.0 kg'),
        findsOneWidget,
      );
      await tester.ensureVisible(find.text('How to go from Obesity to Healthy'));
      expect(
        find.text('How to go from Obesity to Healthy'),
        findsOneWidget,
      );
      expect(find.text('What to eat'), findsOneWidget);
      expect(find.text('What NOT to eat'), findsOneWidget);
      expect(find.text('Sample 1-day menu'), findsOneWidget);
    });

    testWidgets('empty fields show the fill-in-blanks message',
        (WidgetTester tester) async {
      await pumpView(tester);

      await tester.enterText(find.byKey(const Key('weightField')), '');
      await tester.enterText(find.byKey(const Key('feetField')), '');
      await tester.enterText(find.byKey(const Key('inchesField')), '');
      await tester.enterText(find.byKey(const Key('ageField')), '');
      await tester.pump();

      await tester.ensureVisible(find.byKey(const Key('calculateButton')));
      await tester.tap(find.byKey(const Key('calculateButton')));
      await tester.pump();

      expect(
        find.text('Please fill all the required blanks'),
        findsOneWidget,
      );
      expect(find.text('Plan'), findsNothing);
    });

    testWidgets('invalid numbers show the valid-numbers message',
        (WidgetTester tester) async {
      await pumpView(tester);

      await tester.enterText(find.byKey(const Key('weightField')), 'abc');
      // Age must be filled so the numbers check is reached.
      await tester.enterText(find.byKey(const Key('ageField')), '25');
      await tester.pump();

      await tester.ensureVisible(find.byKey(const Key('calculateButton')));
      await tester.tap(find.byKey(const Key('calculateButton')));
      await tester.pump();

      expect(find.text('Please enter valid numbers'), findsOneWidget);
    });

    testWidgets('out-of-range age shows the valid-age message',
        (WidgetTester tester) async {
      await pumpView(tester);

      await tester.enterText(find.byKey(const Key('ageField')), '150');
      await tester.pump();

      await tester.ensureVisible(find.byKey(const Key('calculateButton')));
      await tester.tap(find.byKey(const Key('calculateButton')));
      await tester.pump();

      expect(find.text('Please enter a valid age (5-120)'), findsOneWidget);
      expect(find.text('Plan'), findsNothing);
    });

    testWidgets('typing an age syncs the age slider',
        (WidgetTester tester) async {
      await pumpView(tester);

      await tester.enterText(find.byKey(const Key('ageField')), '40');
      await tester.pump();

      expect(viewModel.ageSlider, equals(40));
      expect(find.text('40 years'), findsOneWidget);
    });

    testWidgets('switching gender to Female shows it in the result',
        (WidgetTester tester) async {
      await pumpView(tester);

      await tester.enterText(find.byKey(const Key('weightField')), '70');
      await tester.enterText(find.byKey(const Key('feetField')), '5');
      await tester.enterText(find.byKey(const Key('inchesField')), '7');
      await tester.enterText(find.byKey(const Key('ageField')), '30');
      await tester.pump();

      await tester.ensureVisible(find.byKey(const Key('femaleChip')));
      await tester.tap(find.byKey(const Key('femaleChip')));
      await tester.pump();
      expect(viewModel.gender, equals(Gender.female));

      await tester.ensureVisible(find.byKey(const Key('calculateButton')));
      await tester.tap(find.byKey(const Key('calculateButton')));
      await tester.pumpAndSettle();

      expect(find.text('Your BMI is 24.17'), findsOneWidget);
      expect(find.text('Age: 30  •  Female'), findsOneWidget);
      expect(find.text('Age: 30  •  Male'), findsNothing);
    });

    testWidgets('theme button toggles the moon/sun icon',
        (WidgetTester tester) async {
      await pumpView(tester);

      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
      await tester.tap(find.byKey(const Key('themeButton')));
      await tester.pump();
      expect(find.byIcon(Icons.light_mode), findsOneWidget);
      expect(find.byIcon(Icons.dark_mode), findsNothing);
    });
  });
}

// NOTE on avatar images in tests: the avatar uses Image.asset with the
// assets declared in pubspec.yaml (assets/images/*.webp). Under
// `flutter test` those declared assets are bundled for the test, so
// the image loads normally. If an asset is ever missing, the avatar's
// errorBuilder shows a grey person icon instead of failing the test —
// the assertions above do not depend on the image loading.
