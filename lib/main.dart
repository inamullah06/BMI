import 'package:bmi/data/repositories/plan_repository.dart';
import 'package:bmi/domain/use_cases/calculate_bmi.dart';
import 'package:bmi/ui/core/app_theme.dart';
import 'package:bmi/ui/features/bmi/view_models/bmi_view_model.dart';
import 'package:bmi/ui/features/bmi/views/bmi_view.dart';
import 'package:flutter/material.dart';

// BMI Calculator — MediClean UI (Design 2, approved by inam 2026-11-11),
// refactored to the Flutter team's layered architecture (UI / Logic /
// Data) following the flutter-apply-architecture-best-practices skill:
// Views are lean, the ViewModel holds UI state, the Use Case holds the
// BMI maths, and the Repository holds the per-category plan content.
// Same behaviour, same English text, same colours as the original
// single-file app. English only; Light/Dark toggle defaults to Light.

void main() {
  // Manual constructor dependency injection (no DI package added):
  // Repository -> Use Case -> ViewModel -> View.
  const PlanRepository planRepository = PlanRepository();
  const CalculateBmi calculateBmi = CalculateBmi(planRepository: planRepository);
  final BmiViewModel viewModel = BmiViewModel(calculateBmi: calculateBmi);
  runApp(BmiApp(viewModel: viewModel));
}

class BmiApp extends StatelessWidget {
  const BmiApp({super.key, required this.viewModel});

  final BmiViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: BmiView(viewModel: viewModel),
    );
  }
}
