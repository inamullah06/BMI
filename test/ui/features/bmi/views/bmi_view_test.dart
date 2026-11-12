import 'package:bmi/data/repositories/plan_repository.dart';
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
      await tester.pump();

      await tester.ensureVisible(find.byKey(const Key('calculateButton')));
      await tester.tap(find.byKey(const Key('calculateButton')));
      // AnimatedSwitcher runs a 600 ms scale transition; settle it.
      await tester.pumpAndSettle();

      expect(find.text('Your BMI is 37.36'), findsOneWidget);
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
      await tester.pump();

      await tester.ensureVisible(find.byKey(const Key('calculateButton')));
      await tester.tap(find.byKey(const Key('calculateButton')));
      await tester.pump();

      expect(find.text('Please enter valid numbers'), findsOneWidget);
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
