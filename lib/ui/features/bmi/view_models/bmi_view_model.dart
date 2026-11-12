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
///
/// Age and gender (added later) are required inputs too: age
/// defaults to 28 and must be a whole number from 5 to 120, kept in
/// sync across its stepper, slider and text field exactly like the
/// weight input; gender defaults to Male. Neither changes the BMI
/// formula — they are shown with the result only, via [profileLine].
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
    ageController.text = '28';
  }

  final CalculateBmi _calculateBmi;

  final TextEditingController weightController = TextEditingController();
  final TextEditingController feetController = TextEditingController();
  final TextEditingController inchesController = TextEditingController();

  /// Age field. Defaults to 28. Required, like the other fields;
  /// must be a whole number from 5 to 120.
  final TextEditingController ageController = TextEditingController();

  Gender _gender = Gender.male;

  /// Selected gender. Default Male. Display-only: it does not affect
  /// the BMI calculation.
  Gender get gender => _gender;

  /// Switch the selected gender.
  void setGender(Gender value) {
    if (_gender == value) {
      return;
    }
    _gender = value;
    notifyListeners();
  }

  double weightSlider = 70;
  double heightFeetSlider = 5;
  double heightInchesSlider = 7;

  /// Age slider position, kept in sync with the age stepper and the
  /// age field. Range 5–120, default 28.
  double ageSlider = 28;

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

  /// Age and gender captured when the latest result was calculated,
  /// so the result line keeps showing the inputs that produced it
  /// even if the user edits the fields afterwards. Cleared on error.
  int? _resultAge;
  Gender? _resultGender;

  /// The age/gender line shown under the BMI number in the result
  /// area, e.g. 'Age: 25  •  Female'. Empty when there is no result.
  String get profileLine {
    final int? age = _resultAge;
    final Gender? gender = _resultGender;
    if (age == null || gender == null) {
      return '';
    }
    return 'Age: $age  •  ${gender.label}';
  }

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
  /// the slider ranges (weight 30–150, feet 3–7, inches 0–11, age
  /// 5–120). Unparseable fields leave their slider untouched.
  ///
  /// The original called this from the weight field's `onChanged`
  /// without `setState`; here it notifies listeners, so the slider
  /// thumbs follow typing immediately. Same end state, fresher UI.
  void syncSlidersFromFields() {
    final double? weight = double.tryParse(weightController.text.trim());
    final double? feet = double.tryParse(feetController.text.trim());
    final double? inches = double.tryParse(inchesController.text.trim());
    final double? age = double.tryParse(ageController.text.trim());
    if (weight != null) {
      weightSlider = weight.clamp(30, 150).toDouble();
    }
    if (feet != null) {
      heightFeetSlider = feet.clamp(3, 7).toDouble();
    }
    if (inches != null) {
      heightInchesSlider = inches.clamp(0, 11).toDouble();
    }
    if (age != null) {
      ageSlider = age.clamp(5, 120).toDouble();
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

  /// Age stepper: move the age by [delta] years, clamped 5–120, and
  /// write the new value back into the age field.
  void stepAge(double delta) {
    ageSlider = (ageSlider + delta).clamp(5, 120).toDouble();
    ageController.text = ageSlider.toStringAsFixed(0);
    notifyListeners();
  }

  /// Age slider: adopt [value] and write it into the age field.
  void setAgeFromSlider(double value) {
    ageSlider = value;
    ageController.text = value.toStringAsFixed(0);
    notifyListeners();
  }

  /// Validate the inputs and run the calculation.
  void calculate() {
    final String weightText = weightController.text.trim();
    final String feetText = feetController.text.trim();
    final String inchesText = inchesController.text.trim();
    final String ageText = ageController.text.trim();
    if (weightText.isEmpty ||
        feetText.isEmpty ||
        inchesText.isEmpty ||
        ageText.isEmpty) {
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
    // Age must be a whole number from 5 to 120. Parsed with
    // double.tryParse so bad input never crashes; '25.0' counts as 25.
    final double? ageValue = double.tryParse(ageText);
    final int? age = ageValue != null && ageValue == ageValue.truncateToDouble()
        ? ageValue.toInt()
        : null;
    if (age == null || age < 5 || age > 120) {
      _fail('Please enter a valid age (5-120)');
      return;
    }
    _result = _calculateBmi(
      weightKg: weight,
      heightFeet: feet,
      heightInches: inches,
    );
    _resultAge = age;
    _resultGender = _gender;
    _resultMessage = _result!.resultText;
    _syncSlidersSilently();
    notifyListeners();
  }

  void _fail(String message) {
    _result = null;
    _resultAge = null;
    _resultGender = null;
    _resultMessage = message;
    notifyListeners();
  }

  /// Same sync as [syncSlidersFromFields], without its own
  /// notification — [calculate] notifies once at the end.
  void _syncSlidersSilently() {
    final double? weight = double.tryParse(weightController.text.trim());
    final double? feet = double.tryParse(feetController.text.trim());
    final double? inches = double.tryParse(inchesController.text.trim());
    final double? age = double.tryParse(ageController.text.trim());
    if (weight != null) {
      weightSlider = weight.clamp(30, 150).toDouble();
    }
    if (feet != null) {
      heightFeetSlider = feet.clamp(3, 7).toDouble();
    }
    if (inches != null) {
      heightInchesSlider = inches.clamp(0, 11).toDouble();
    }
    if (age != null) {
      ageSlider = age.clamp(5, 120).toDouble();
    }
  }

  @override
  void dispose() {
    weightController.dispose();
    feetController.dispose();
    inchesController.dispose();
    ageController.dispose();
    super.dispose();
  }
}
