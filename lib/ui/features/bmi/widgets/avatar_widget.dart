import 'package:bmi/domain/models/bmi_result.dart';
import 'package:bmi/ui/core/app_theme.dart';
import 'package:bmi/ui/features/bmi/view_models/bmi_view_model.dart';
import 'package:flutter/material.dart';

/// The full-body avatar: the category's image on a pale teal tile,
/// with the category name underneath.
///
/// Male results use the strong-man images, Female results the
/// matching female images (selected by the ViewModel from the
/// result's gender). The image cross-fades/scales between categories
/// and genders via [AnimatedSwitcher] (600 ms). Underweight reuses
/// the healthy image squeezed thin (scaleX 0.62) — there is no
/// separate Underweight image for either gender. If an image asset
/// fails to load, a grey person icon is shown instead, so the app
/// never shows a broken-image box.
class BmiAvatar extends StatelessWidget {
  const BmiAvatar({
    super.key,
    required this.colors,
    required this.viewModel,
  });

  final MediCleanColors colors;
  final BmiViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final BmiCategory? category = viewModel.category;
    final Color color =
        category == null ? MediCleanColors.teal : colors.categoryColor(category);
    final String asset = viewModel.avatarAsset;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.avatarBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            transitionBuilder: (Widget child, Animation<double> animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Transform.scale(
              // Include the gender so switching Male -> Female (same
              // category) also animates the avatar change.
              key: ValueKey<String>(
                  '${viewModel.avatarGender.name}-${category?.name}'),
              scaleX: viewModel.avatarScaleX,
              child: Image.asset(
                asset,
                key: ValueKey<String>(asset),
                height: 220,
                fit: BoxFit.contain,
                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) =>
                    const Icon(
                  Icons.person,
                  size: 120,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            category == null ? 'Avatar — it will change with your BMI' : category.label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}
