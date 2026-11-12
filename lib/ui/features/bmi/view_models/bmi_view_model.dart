import 'package:bmi/domain/models/bmi_result.dart';
import 'package:bmi/domain/use_cases/calculate_bmi.dart';
import 'package:flutter/material.dart';

/// UI state and user interactions for the BMI screen (MVVM ViewModel).
///
/// Holds all state the View displays: the input fields, the slider
/// positions, the Light/Dark mode, the latest result, and the message
/// line under the Calculate button. The calculation itself lives in
/// [CalculateBmi], injected via the constructor; this class only
/// parses input (with `double.tryParse`, so 70.5 works), validates it
/// with the original messages, and exposes the outcome.
///
/// Behaviour preserved from the original `_MyHomePageState`:
/// - Default inputs 70 kg / 5 ft / 7 in, default theme Light.
/// - Empty fields -> 'Please fill all the required blanks'.
/// - Unparseable or out-of-range numbers ->
///   'Please enter valid numbers'.
/// - On an error the previous result and plan are cleared.
/// - The weight slider/stepper and the weight field stay in sync;
///   the feet/inches fields only sync the sliders on Calculate,
///   exactly as before (the height slider values are kept for parity
///   with the original state, although the View never displayed them).
class BmiViewModel extends ChangeNotifier {
  BmiViewModel({required CalculateBmi calculateBmi})
      : _calculateBmi = calculateBmi {
    weightController.text = '70';
    feetController.text = '5';
    inchesController.text = '7';
  }

  final CalculateBmi _calculateBmi;

  final TextEditingController weightController = TextEditingController();
  final TextEditingController feetController = TextEditingController();
  final TextEditingController inchesController = TextEditingController();

  double weightSlider = 70;
  double heightFeetSlider = 5;
  double heightInchesSlider = 7;

  bool _isDark = false;

  /// Light/Dark mode. Default Light, keeping the approved MediClean look.
  bool get isDark => _isDark;

  String _resultMessage = '';

  /// Message under the Calculate button: the result line on success,
  /// a validation message on failure, empty before the first tap.
  String get resultMessage => _resultMessage;

  BmiResult? _result;

  /// The latest successful calculation, or null before the first
  /// successful tap / after a validation failure.
  BmiResult? get result => _result;

  /// Category of the latest result, or null when there is no result.
  BmiCategory? get category => _result?.category;

  /// Full-body avatar image for the current category.
  ///
  /// Underweight has no separate image (its generation failed), so the
  /// healthy image is used and squeezed thin (see [avatarScaleX]).
  String get avatarAsset {
    switch (category) {
      case BmiCategory.overweight:
        return 'assets/images/overweight.webp';
      case BmiCategory.obesity:
        return 'assets/images/obesity.webp';
      case BmiCategory.underweight:
      case BmiCategory.healthyWeight:
      case null:
        return 'assets/images/healthy.webp';
    }
  }

  /// Horizontal squeeze for the avatar: 0.62 for Underweight (the
  /// healthy image shown thin), 1.0 for everything else.
  double get avatarScaleX => category == BmiCategory.underweight ? 0.62 : 1.0;

  /// Flip Light/Dark mode.
  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  /// Copy the text-field values into the slider positions, clamped to
  /// the slider ranges (weight 30–150, feet 3–7, inches 0–11).
  /// Unparseable fields leave their slider untouched.
  ///
  /// The original called this from the weight field's `onChanged`
  /// without `setState`; here it notifies listeners, so the slider
  /// thumb follows typing immediately. Same end state, fresher UI.
  void syncSlidersFromFields() {
    final double? weight = double.tryParse(weightController.text.trim());
    final double? feet = double.tryParse(feetController.text.trim());
    final double? inches = double.tryParse(inchesController.text.trim());
    if (weight != null) {
      weightSlider = weight.clamp(30, 150).toDouble();
    }
    if (feet != null) {
      heightFeetSlider = feet.clamp(3, 7).toDouble();
    }
    if (inches != null) {
      heightInchesSlider = inches.clamp(0, 11).toDouble();
    }
    notifyListeners();
  }

  /// Weight stepper: move the weight by [delta] kg, clamped 30–150,
  /// and write the new value back into the weight field.
  void stepWeight(double delta) {
    weightSlider = (weightSlider + delta).clamp(30, 150).toDouble();
    weightController.text = weightSlider.toStringAsFixed(0);
    notifyListeners();
  }

  /// Weight slider: adopt [value] and write it into the weight field.
  void setWeightFromSlider(double value) {
    weightSlider = value;
    weightController.text = value.toStringAsFixed(0);
    notifyListeners();
  }

  /// Validate the inputs and run the calculation.
  void calculate() {
    final String weightText = weightController.text.trim();
    final String feetText = feetController.text.trim();
    final String inchesText = inchesController.text.trim();
    if (weightText.isEmpty || feetText.isEmpty || inchesText.isEmpty) {
      _fail('Please fill all the required blanks');
      return;
    }
    // double.tryParse so 70.5 also works (int.parse used to crash).
    final double? weight = double.tryParse(weightText);
    final double? feet = double.tryParse(feetText);
    final double? inches = double.tryParse(inchesText);
    if (weight == null ||
        feet == null ||
        inches == null ||
        weight <= 0 ||
        feet <= 0 ||
        inches < 0) {
      _fail('Please enter valid numbers');
      return;
    }
    _result = _calculateBmi(
      weightKg: weight,
      heightFeet: feet,
      heightInches: inches,
    );
    _resultMessage = _result!.resultText;
    _syncSlidersSilently();
    notifyListeners();
  }

  void _fail(String message) {
    _result = null;
    _resultMessage = message;
    notifyListeners();
  }

  /// Same sync as [syncSlidersFromFields], without its own
  /// notification — [calculate] notifies once at the end.
  void _syncSlidersSilently() {
    final double? weight = double.tryParse(weightController.text.trim());
    final double? feet = double.tryParse(feetController.text.trim());
    final double? inches = double.tryParse(inchesController.text.trim());
    if (weight != null) {
      weightSlider = weight.clamp(30, 150).toDouble();
    }
    if (feet != null) {
      heightFeetSlider = feet.clamp(3, 7).toDouble();
    }
    if (inches != null) {
      heightInchesSlider = inches.clamp(0, 11).toDouble();
    }
  }

  @override
  void dispose() {
    weightController.dispose();
    feetController.dispose();
    inchesController.dispose();
    super.dispose();
  }
}
