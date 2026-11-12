import 'package:bmi/ui/core/app_theme.dart';
import 'package:bmi/ui/features/bmi/view_models/bmi_view_model.dart';
import 'package:bmi/ui/features/bmi/widgets/input_card.dart';
import 'package:bmi/ui/features/bmi/widgets/result_card.dart';
import 'package:flutter/material.dart';

/// The BMI screen (MVVM View): a lean widget that only lays out the
/// input and result cards and the Light/Dark AppBar button.
///
/// All state comes from [viewModel]; this widget holds no business
/// logic and no mutable state. It rebuilds through [ListenableBuilder]
/// whenever the ViewModel notifies.
///
/// Responsive layout, unchanged from the original: above 700 px the
/// two cards sit side by side (max width 860), otherwise stacked
/// (max width 520).
class BmiView extends StatelessWidget {
  const BmiView({super.key, required this.viewModel});

  final BmiViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (BuildContext context, Widget? _) {
        final MediCleanColors colors = MediCleanColors(isDark: viewModel.isDark);
        final double screenWidth = MediaQuery.of(context).size.width;
        final bool isWide = screenWidth > 700;
        final double contentWidth = isWide ? 860.0 : 520.0;
        final double padding = isWide ? 24.0 : 16.0;

        final Widget inputCard = BmiInputCard(colors: colors, viewModel: viewModel);
        final Widget resultCard = BmiResultCard(colors: colors, viewModel: viewModel);

        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            backgroundColor: colors.appBarBg,
            foregroundColor: colors.inkColor,
            title: const Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.monitor_weight, color: MediCleanColors.teal),
                SizedBox(width: 6),
                Text(
                  'BMI Calculator',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
              ],
            ),
            actions: <Widget>[
              IconButton(
                key: const Key('themeButton'),
                onPressed: viewModel.toggleTheme,
                icon: Icon(
                  viewModel.isDark ? Icons.light_mode : Icons.dark_mode,
                  color: colors.inkColor,
                ),
                tooltip: viewModel.isDark ? 'Switch to light mode' : 'Switch to dark mode',
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(child: inputCard),
                            const SizedBox(width: 16),
                            Expanded(child: resultCard),
                          ],
                        )
                      : Column(
                          children: <Widget>[
                            inputCard,
                            const SizedBox(height: 16),
                            resultCard,
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
