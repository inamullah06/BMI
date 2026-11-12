import 'package:bmi/domain/models/bmi_result.dart';
import 'package:bmi/ui/core/app_theme.dart';
import 'package:bmi/ui/core/widgets/soft_card.dart';
import 'package:bmi/ui/features/bmi/view_models/bmi_view_model.dart';
import 'package:bmi/ui/features/bmi/widgets/avatar_widget.dart';
import 'package:bmi/ui/features/bmi/widgets/plan_card.dart';
import 'package:bmi/ui/features/bmi/widgets/ring_gauge.dart';
import 'package:flutter/material.dart';

/// The result card: ring gauge, healthy-range line, avatar, and —
/// once a calculation exists — the plan title, the Plan / What to
/// eat / What NOT to eat cards, the sample 1-day menu card, and the
/// screening disclaimer. Before the first calculation it shows the
/// hint text instead of the plan section.
class BmiResultCard extends StatelessWidget {
  const BmiResultCard({
    super.key,
    required this.colors,
    required this.viewModel,
  });

  final MediCleanColors colors;
  final BmiViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final BmiResult? result = viewModel.result;
    final BmiPlan? plan = result?.plan;
    return SoftCard(
      colors: colors,
      child: Column(
        children: <Widget>[
          RingGauge(colors: colors, result: result),
          const SizedBox(height: 8),
          if (result != null)
            Text(
              result.healthyRangeText,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: colors.mutedColor),
            ),
          const SizedBox(height: 16),
          BmiAvatar(colors: colors, viewModel: viewModel),
          if (plan != null) ...<Widget>[
            const SizedBox(height: 18),
            Text(
              plan.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colors.inkColor,
              ),
            ),
            const SizedBox(height: 12),
            PlanCard(
              colors: colors,
              title: 'Plan',
              icon: Icons.checklist,
              color: MediCleanColors.teal,
              tint: const Color(0xFFE6F4F2),
              items: plan.steps,
            ),
            const SizedBox(height: 12),
            PlanCard(
              colors: colors,
              title: 'What to eat',
              icon: Icons.restaurant,
              color: const Color(0xFF059669),
              tint: const Color(0xFFECFDF5),
              items: plan.eat,
            ),
            const SizedBox(height: 12),
            PlanCard(
              colors: colors,
              title: 'What NOT to eat',
              icon: Icons.block,
              color: const Color(0xFFDC2626),
              tint: const Color(0xFFFEF2F2),
              items: plan.avoid,
            ),
            const SizedBox(height: 12),
            SoftCard(
              colors: colors,
              tint: const Color(0xFFFFFBEB),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Sample 1-day menu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.inkColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    plan.sampleMenu,
                    style: TextStyle(fontSize: 14, color: colors.inkColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'BMI is a screening measure, not a diagnosis. '
              'For a personal diet/exercise plan, consult a doctor.',
              style: TextStyle(fontSize: 12, color: colors.mutedColor),
              textAlign: TextAlign.center,
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Enter your weight and height and press Calculate — '
                'your category, avatar and plan will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.mutedColor),
              ),
            ),
        ],
      ),
    );
  }
}
