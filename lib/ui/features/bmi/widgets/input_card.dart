import 'package:bmi/domain/models/bmi_result.dart';
import 'package:bmi/ui/core/app_theme.dart';
import 'package:bmi/ui/core/widgets/soft_card.dart';
import 'package:bmi/ui/features/bmi/view_models/bmi_view_model.dart';
import 'package:bmi/ui/features/bmi/widgets/stepper_row.dart';
import 'package:flutter/material.dart';

/// The input card: gender buttons, age stepper + slider + field,
/// weight stepper + slider synced with the weight field, height
/// feet/inches fields, the Calculate button, and the result/validation
/// message line.
///
/// Widget keys (`maleChip`, `femaleChip`, `ageField`, `weightField`,
/// `feetField`, `inchesField`, `calculateButton`) exist so widget
/// tests can find the inputs reliably; they change nothing on screen.
class BmiInputCard extends StatelessWidget {
  const BmiInputCard({
    super.key,
    required this.colors,
    required this.viewModel,
  });

  final MediCleanColors colors;
  final BmiViewModel viewModel;

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: colors.mutedColor),
      prefixIcon: Icon(icon, color: MediCleanColors.teal),
      filled: true,
      fillColor: colors.fieldFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: MediCleanColors.teal, width: 2),
      ),
    );
  }

  /// One large gender button: the gender symbol icon + label, teal
  /// filled with white text when selected, bordered outline with ink
  /// text when not — matching the MediClean theme in both Light and
  /// Dark modes.
  Widget _genderButton(Key key, Gender value) {
    final bool selected = viewModel.gender == value;
    final IconData icon = value == Gender.male ? Icons.male : Icons.female;
    final Color contentColor = selected ? Colors.white : colors.inkColor;
    return Expanded(
      child: InkWell(
        key: key,
        onTap: () => viewModel.setGender(value),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? MediCleanColors.teal : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: BorderSide(
              color: selected ? MediCleanColors.teal : colors.borderColor,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, color: contentColor),
              const SizedBox(width: 6),
              Text(
                value.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: contentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String resultMessage = viewModel.resultMessage;
    return SoftCard(
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Check your BMI',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: colors.inkColor,
            ),
          ),
          Text(
            'Enter your weight and height — you can also change them with the slider.',
            style: TextStyle(fontSize: 13, color: colors.mutedColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Gender',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colors.inkColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              _genderButton(const Key('maleChip'), Gender.male),
              const SizedBox(width: 12),
              _genderButton(const Key('femaleChip'), Gender.female),
            ],
          ),
          const SizedBox(height: 16),
          StepperRow(
            colors: colors,
            label: 'Age (Years)',
            value: '${viewModel.ageSlider.toStringAsFixed(0)} years',
            onMinus: () => viewModel.stepAge(-1),
            onPlus: () => viewModel.stepAge(1),
          ),
          Slider(
            value: viewModel.ageSlider,
            min: 5,
            max: 120,
            divisions: 115,
            activeColor: MediCleanColors.teal,
            inactiveColor: colors.sliderInactive,
            label: '${viewModel.ageSlider.toStringAsFixed(0)} years',
            onChanged: viewModel.setAgeFromSlider,
          ),
          const SizedBox(height: 8),
          TextField(
            key: const Key('ageField'),
            controller: viewModel.ageController,
            style: TextStyle(color: colors.inkColor),
            decoration: _fieldDecoration(
              'Enter your age (5 to 120 years)',
              Icons.cake,
            ),
            keyboardType: TextInputType.number,
            onChanged: (_) => viewModel.syncSlidersFromFields(),
          ),
          const SizedBox(height: 16),
          StepperRow(
            colors: colors,
            label: 'Weight',
            value: '${viewModel.weightSlider.toStringAsFixed(0)} kg',
            onMinus: () => viewModel.stepWeight(-1),
            onPlus: () => viewModel.stepWeight(1),
          ),
          Slider(
            value: viewModel.weightSlider,
            min: 30,
            max: 150,
            divisions: 120,
            activeColor: MediCleanColors.teal,
            inactiveColor: colors.sliderInactive,
            label: '${viewModel.weightSlider.toStringAsFixed(0)} kg',
            onChanged: viewModel.setWeightFromSlider,
          ),
          const SizedBox(height: 8),
          TextField(
            key: const Key('weightField'),
            controller: viewModel.weightController,
            style: TextStyle(color: colors.inkColor),
            decoration: _fieldDecoration('Enter your weight (in Kgs)', Icons.monitor_weight),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => viewModel.syncSlidersFromFields(),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('feetField'),
            controller: viewModel.feetController,
            style: TextStyle(color: colors.inkColor),
            decoration: _fieldDecoration('Enter your height (in Feet)', Icons.height),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('inchesField'),
            controller: viewModel.inchesController,
            style: TextStyle(color: colors.inkColor),
            decoration: _fieldDecoration('Enter your height (in Inches)', Icons.height),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('calculateButton'),
            onPressed: viewModel.calculate,
            style: FilledButton.styleFrom(
              backgroundColor: MediCleanColors.teal,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text(
              'Calculate BMI',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
          if (resultMessage.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              resultMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.inkColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
