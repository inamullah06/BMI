import 'dart:math' as math;
import 'package:flutter/material.dart';

// MediClean UI — Design 2, approved by inam (2026-11-11).
// White + teal health-app look: soft white cards, teal accent,
// ring gauge for the BMI result, sliders/steppers for inputs,
// full-body avatar image, and plan split into 3 cards.
// Same BMI logic as before: weight kg, height ft+in,
// BMI = kg / m^2, decimal inputs via double.tryParse.
//
// Language option (added 2026-11-11): English / Roman Urdu toggle
// in the AppBar. Default is Roman Urdu. The toggle switches every
// visible text in the app — labels, button, messages, categories,
// plans, menus and the disclaimer. The BMI calculation, category
// keys, colours, avatar images and layout are unchanged.
//
// Theme option (added 2026-11-11): Light / Dark toggle in the AppBar
// (moon/sun button). Default is Light, keeping the approved MediClean
// light look. Dark mode re-colours every surface and text through the
// getters below; the teal accent stays the same in both modes.

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF0D9488);
    return MaterialApp(
      title: 'BMI Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: teal,
          primary: teal,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6FAF9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F172A),
          elevation: 0,
          centerTitle: false,
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: teal,
          inactiveTrackColor: Color(0xFFD6E8E5),
          thumbColor: teal,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const teal = Color(0xFF0D9488);

  // ---- Theme: Light / Dark (default Light) ----
  bool _isDark = false;

  // Light colours are the approved MediClean look; dark colours are
  // slate surfaces with light text so nothing is unreadable.
  Color get bg => _isDark ? const Color(0xFF0F172A) : const Color(0xFFF6FAF9);
  Color get cardColor => _isDark ? const Color(0xFF1E293B) : Colors.white;
  Color get inkColor => _isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
  Color get mutedColor => _isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  Color get borderColor => _isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  Color get fieldFill => _isDark ? const Color(0xFF1E293B) : Colors.white;
  Color get stepperBg => _isDark ? const Color(0xFF134E4A) : const Color(0xFFE6F4F2);
  Color get avatarBg => _isDark ? const Color(0xFF134E4A) : const Color(0xFFE6F4F2);
  Color get sliderInactive => _isDark ? const Color(0xFF334155) : const Color(0xFFD6E8E5);
  Color get appBarBg => _isDark ? const Color(0xFF1E293B) : Colors.white;
  Color get ringTrack => _isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

  /// Dark variant of a light plan-card tint, so tinted cards stay
  /// readable in dark mode (light tint = light mode, dark tint = dark).
  Color _darkTint(Color lightTint) {
    if (!_isDark) return lightTint;
    if (lightTint == const Color(0xFFE6F4F2)) return const Color(0xFF134E4A);
    if (lightTint == const Color(0xFFECFDF5)) return const Color(0xFF14532D);
    if (lightTint == const Color(0xFFFEF2F2)) return const Color(0xFF7F1D1D);
    if (lightTint == const Color(0xFFFFFBEB)) return const Color(0xFF78350F);
    return lightTint;
  }

  /// Brighter variant of a plan-card accent colour for dark mode.
  Color _darkAccent(Color light) {
    if (!_isDark) return light;
    if (light == const Color(0xFF059669)) return const Color(0xFF34D399);
    if (light == const Color(0xFFDC2626)) return const Color(0xFFF87171);
    return light;
  }

  final wtController = TextEditingController();
  final ftController = TextEditingController();
  final inController = TextEditingController();

  double weightSlider = 70;
  double heightFtSlider = 5;
  double heightInSlider = 7;

  // Language: true = Roman Urdu (default), false = English.
  bool _isUrdu = true;

  String result = '';
  String category = '';
  String planTitle = '';
  List<String> planSteps = [];
  List<String> eatList = [];
  List<String> avoidList = [];
  String sampleMenu = '';
  double? bmiValue;
  double? heightM;
  double? weightKg;

  @override
  void initState() {
    super.initState();
    wtController.text = '70';
    ftController.text = '5';
    inController.text = '7';
  }

  @override
  void dispose() {
    wtController.dispose();
    ftController.dispose();
    inController.dispose();
    super.dispose();
  }

  // ---- Language helpers ----

  /// Returns the Roman Urdu text when _isUrdu is true, else English.
  String tr(String en, String ur) => _isUrdu ? ur : en;

  /// Display name for a category key. In Roman Urdu mode the English
  /// term stays in brackets so the user learns both names.
  String categoryLabel(String key) {
    switch (key) {
      case 'Underweight':
        return tr('Underweight', 'Kam Wazan (Underweight)');
      case 'Healthy weight':
        return tr('Healthy weight', 'Sehatmand (Healthy)');
      case 'Overweight':
        return tr('Overweight', 'Zyada Wazan (Overweight)');
      case 'Obesity':
        return tr('Obesity', 'Motapa (Obesity)');
      default:
        return key;
    }
  }

  /// Switch language and re-translate the current result/plan, if any.
  void _setLanguage(bool urdu) {
    setState(() {
      _isUrdu = urdu;
      if (bmiValue != null) {
        result = tr(
          'Your BMI is ${bmiValue!.toStringAsFixed(2)}',
          'Aapka BMI ${bmiValue!.toStringAsFixed(2)} hai',
        );
        setPlan(bmiValue!);
      }
    });
  }

  // ---- BMI logic (unchanged) ----

  /// Internal category key — never shown directly; use categoryLabel().
  String getCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Healthy weight';
    if (bmi < 30) return 'Overweight';
    return 'Obesity';
  }

  Color getCategoryColor(String cat) {
    if (_isDark) {
      switch (cat) {
        case 'Underweight':
          return const Color(0xFF60A5FA);
        case 'Healthy weight':
          return const Color(0xFF34D399);
        case 'Overweight':
          return const Color(0xFFFBBF24);
        case 'Obesity':
          return const Color(0xFFF87171);
        default:
          return const Color(0xFF2DD4BF);
      }
    }
    switch (cat) {
      case 'Underweight':
        return const Color(0xFF2563EB);
      case 'Healthy weight':
        return const Color(0xFF059669);
      case 'Overweight':
        return const Color(0xFFD97706);
      case 'Obesity':
        return const Color(0xFFDC2626);
      default:
        return teal;
    }
  }

  // Real full-body avatar image for the category.
  // Underweight has no separate image (its generation failed), so the
  // healthy image is shown squeezed thin (scaleX 0.62) as a fallback.
  String getAvatarAsset() {
    switch (category) {
      case 'Overweight':
        return 'assets/images/overweight.webp';
      case 'Obesity':
        return 'assets/images/obesity.webp';
      default:
        return 'assets/images/healthy.webp';
    }
  }

  double getAvatarScaleX() {
    return category == 'Underweight' ? 0.62 : 1.0;
  }

  void setPlan(double bmi) {
    if (bmi < 18.5) {
      planTitle = tr(
        'How to go from Underweight to Healthy',
        'Underweight → Healthy kaise bane',
      );
      planSteps = [
        tr(
          'Eat 300–500 extra calories every day (increase slowly).',
          'Roz 300–500 extra calories khayein (slowly badhayein).',
        ),
        tr(
          'Include protein in every meal: eggs, lentils, milk, yogurt, meat.',
          'Har meal mein protein: ande, daal, doodh, dahi, gosht.',
        ),
        tr(
          'Do strength exercise 3 days a week: push-ups, squats.',
          'Hafte mein 3 din strength exercise: push-ups, squats.',
        ),
        tr(
          'Sleep 7–8 hours and drink plenty of water.',
          'Neend 7–8 ghante, paani zyada piyen.',
        ),
      ];
      eatList = [
        tr('Milk, yogurt, eggs', 'Doodh, dahi, ande'),
        tr('Lentils, chickpeas, meat', 'Daal, chane, gosht'),
        tr('Dry fruits: almonds, walnuts', 'Dry fruits: badam, akhrot'),
        tr('Bread, rice, potatoes', 'Roti, chawal, aloo'),
      ];
      avoidList = [
        tr('Skipping meals', 'Khana skip karna'),
        tr('Living only on tea / snacks', 'Sirf chai / snacks par guzara'),
        tr(
          'Too much fast food (empty calories)',
          'Zyada fast food (empty calories)',
        ),
      ];
      sampleMenu = tr(
        'Breakfast: milk + eggs + paratha. Lunch: lentils + rice + yogurt. Evening: dry fruits + milk. Dinner: meat/vegetables + bread.',
        'Nashta: doodh + ande + paratha. Lunch: daal + chawal + dahi. Shaam: dry fruits + doodh. Dinner: gosht/sabzi + roti.',
      );
    } else if (bmi < 25) {
      planTitle = tr(
        'How to go from Healthy to Stronger',
        'Healthy → Stronger kaise bane',
      );
      planSteps = [
        tr(
          'Keep protein in every meal (eggs, lentils, milk, yogurt, meat).',
          'Protein har meal mein rakhein (ande, daal, doodh, gosht).',
        ),
        tr(
          'Do strength training 4 days a week + walk 30 minutes every day.',
          'Hafte mein 4 din strength training + roz 30 min walk.',
        ),
        tr(
          'Cut down on sweets and cold drinks.',
          'Meetha aur cold drink kam kar dein.',
        ),
        tr(
          'Sleep 7–8 hours — muscles are built during sleep.',
          'Neend 7–8 ghante — muscle neend mein banta hai.',
        ),
      ];
      eatList = [
        tr('Eggs, milk, yogurt', 'Ande, doodh, dahi'),
        tr('Lentils, chickpeas, meat', 'Daal, chane, gosht'),
        tr('Vegetables, fruit, dry fruits', 'Sabzi, fruit, dry fruits'),
      ];
      avoidList = [
        tr('Cold drink / sweets every day', 'Roz cold drink / meetha'),
        tr('Too much oily fast food', 'Zyada oily fast food'),
        tr('Heavy food late at night', 'Late night heavy khana'),
      ];
      sampleMenu = tr(
        'Breakfast: eggs + milk. Lunch: lentils + bread + salad. Evening: fruit + yogurt. Dinner: meat/vegetables + bread.',
        'Nashta: ande + doodh. Lunch: daal + roti + salad. Shaam: fruit + dahi. Dinner: gosht/sabzi + roti.',
      );
    } else if (bmi < 30) {
      planTitle = tr(
        'How to go from Overweight to Healthy',
        'Overweight → Healthy kaise bane',
      );
      planSteps = [
        tr(
          'Eat 300–500 fewer calories every day — slowly, no crash diet.',
          'Roz 300–500 calories kam khayein — aahista, crash diet nahi.',
        ),
        tr(
          'Walk briskly for 30–45 minutes, 5 days a week.',
          'Roz 30–45 min tez walk, hafte mein 5 din.',
        ),
        tr(
          'Eat a little less bread/rice and more vegetables/salad.',
          'Roti/chawal thora kam, sabzi/salad zyada.',
        ),
        tr(
          'Check your weight every week, target 0.5 kg/week.',
          'Har hafte weight check karein, target 0.5 kg/week.',
        ),
      ];
      eatList = [
        tr('Vegetables, salad, fruit', 'Sabzi, salad, fruit'),
        tr('Lentils, yogurt (low fat)', 'Daal, dahi (low fat)'),
        tr('Plenty of water, green tea', 'Paani zyada, green tea'),
      ];
      avoidList = [
        tr('Cold drink / sweets / mithai', 'Cold drink / meetha / mithai'),
        tr('Fast food: burger, fries, pizza', 'Fast food: burger, fries, pizza'),
        tr('Too much oily / ghee food', 'Zyada tel / ghee wala khana'),
        tr('Snacking late at night', 'Late night snacking'),
      ];
      sampleMenu = tr(
        'Breakfast: eggs + milk (low fat). Lunch: lentils + 1 bread + salad. Evening: fruit. Dinner: vegetables + 1 bread + yogurt.',
        'Nashta: ande + doodh (low fat). Lunch: daal + 1 roti + salad. Shaam: fruit. Dinner: sabzi + 1 roti + dahi.',
      );
    } else {
      planTitle = tr(
        'How to go from Obesity to Healthy',
        'Obesity → Healthy kaise bane',
      );
      planSteps = [
        tr(
          'First consult a doctor / dietitian, then start the plan.',
          'Doctor / dietitian se mashwara zaroor lein, phir plan shuru karein.',
        ),
        tr(
          'Start with a 30-minute walk every day, then slowly increase it.',
          'Roz 30 min walk se shuru karein, aahista badhayein.',
        ),
        tr(
          'Stop sweets, cold drinks and fast food.',
          'Meetha, cold drink aur fast food band kar dein.',
        ),
        tr(
          'Keep a small target: lose 5% of your weight first.',
          'Chhota target rakhein: pehle 5% weight kam karna.',
        ),
      ];
      eatList = [
        tr('Vegetables, salad, fruit', 'Sabzi, salad, fruit'),
        tr('Lentils, yogurt (low fat)', 'Daal, dahi (low fat)'),
        tr('Plenty of water', 'Paani zyada'),
      ];
      avoidList = [
        tr('Cold drink / sweets / mithai', 'Cold drink / meetha / mithai'),
        tr('Fast food and bakery items', 'Fast food aur bakery items'),
        tr('Too much oily / ghee food', 'Zyada tel / ghee wala khana'),
        tr('Snacking late at night', 'Late night snacking'),
      ];
      sampleMenu = tr(
        'Breakfast: eggs + milk (low fat). Lunch: lentils + salad + 1 bread. Evening: fruit. Dinner: vegetables + yogurt.',
        'Nashta: ande + doodh (low fat). Lunch: daal + salad + 1 roti. Shaam: fruit. Dinner: sabzi + dahi.',
      );
    }
  }

  void _syncSlidersFromFields() {
    final w = double.tryParse(wtController.text.trim());
    final f = double.tryParse(ftController.text.trim());
    final i = double.tryParse(inController.text.trim());
    if (w != null) weightSlider = w.clamp(30, 150);
    if (f != null) heightFtSlider = f.clamp(3, 7);
    if (i != null) heightInSlider = i.clamp(0, 11);
  }

  void calculate() {
    final wt = wtController.text.trim();
    final ft = ftController.text.trim();
    final inch = inController.text.trim();
    if (wt.isEmpty || ft.isEmpty || inch.isEmpty) {
      setState(() {
        result = tr(
          'Please fill all the required blanks',
          'Saare khaali boxes bhar dein',
        );
        category = '';
        bmiValue = null;
        planSteps = [];
        eatList = [];
        avoidList = [];
        sampleMenu = '';
      });
      return;
    }
    // double.tryParse so 70.5 also works (int.parse used to crash).
    final dWt = double.tryParse(wt);
    final dFt = double.tryParse(ft);
    final dInch = double.tryParse(inch);
    if (dWt == null || dFt == null || dInch == null ||
        dWt <= 0 || dFt <= 0 || dInch < 0) {
      setState(() {
        result = tr(
          'Please enter valid numbers',
          'Sahi numbers daalein',
        );
        category = '';
        bmiValue = null;
        planSteps = [];
        eatList = [];
        avoidList = [];
        sampleMenu = '';
      });
      return;
    }
    final tInch = (dFt * 12) + dInch;
    final tCm = tInch * 2.54;
    final tM = tCm / 100;
    final bmi = dWt / (tM * tM);
    setState(() {
      weightKg = dWt;
      heightM = tM;
      bmiValue = bmi;
      result = tr(
        'Your BMI is ${bmi.toStringAsFixed(2)}',
        'Aapka BMI ${bmi.toStringAsFixed(2)} hai',
      );
      category = getCategory(bmi);
      _syncSlidersFromFields();
      setPlan(bmi);
    });
  }

  String healthyRangeText() {
    if (heightM == null) return '';
    final low = 18.5 * heightM! * heightM!;
    final high = 24.9 * heightM! * heightM!;
    final diff = weightKg == null
        ? ''
        : weightKg! < low
            ? tr(
                'You need to gain ${(low - weightKg!).toStringAsFixed(1)} kg',
                '${(low - weightKg!).toStringAsFixed(1)} kg badhana hai',
              )
            : weightKg! > high
                ? tr(
                    'You need to lose ${(weightKg! - high).toStringAsFixed(1)} kg',
                    '${(weightKg! - high).toStringAsFixed(1)} kg kam karna hai',
                  )
                : tr(
                    'You are in the healthy range — get stronger!',
                    'Healthy range mein hain — strong banein!',
                  );
    return tr(
      'Healthy weight: ${low.toStringAsFixed(1)} – ${high.toStringAsFixed(1)} kg  •  $diff',
      'Healthy weight: ${low.toStringAsFixed(1)} – ${high.toStringAsFixed(1)} kg  •  $diff',
    );
  }

  // ---- MediClean widgets ----

  Widget _softCard({required Widget child, Color? tint}) {
    return Container(
      decoration: BoxDecoration(
        color: tint != null ? _darkTint(tint) : cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: child,
    );
  }

  /// One language chip in the AppBar: "English" or "Roman Urdu".
  Widget _langChip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? teal : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? teal : borderColor,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : inkColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepperRow({
    required String label,
    required String value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600, color: inkColor)),
        ),
        IconButton.filledTonal(
          onPressed: onMinus,
          icon: const Icon(Icons.remove),
          style: IconButton.styleFrom(backgroundColor: stepperBg, foregroundColor: inkColor),
        ),
        SizedBox(
          width: 72,
          child: Text(value,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: inkColor)),
        ),
        IconButton.filledTonal(
          onPressed: onPlus,
          icon: const Icon(Icons.add),
          style: IconButton.styleFrom(backgroundColor: stepperBg, foregroundColor: inkColor),
        ),
      ],
    );
  }

  Widget _planCard({
    required String title,
    required IconData icon,
    required Color color,
    required Color tint,
    required List<String> items,
  }) {
    final c = _darkAccent(color);
    return _softCard(
      tint: tint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: c),
            const SizedBox(width: 8),
            Text(title,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: c)),
          ]),
          const SizedBox(height: 10),
          ...items.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, size: 16, color: c),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Text(e,
                            style: TextStyle(fontSize: 14, color: inkColor))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _ringGauge() {
    final bmi = bmiValue ?? 0;
    // Map BMI 14..40 onto the ring.
    final progress = ((bmi - 14) / 26).clamp(0.0, 1.0);
    final color = bmiValue == null ? teal : getCategoryColor(category);
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(180, 180),
            painter: _RingPainter(
                progress: progress, color: color, trackColor: ringTrack),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                bmiValue == null ? '--' : bmi.toStringAsFixed(1),
                style: TextStyle(
                    fontSize: 38, fontWeight: FontWeight.w800, color: inkColor),
              ),
              Text('BMI',
                  style: TextStyle(fontSize: 13, color: mutedColor)),
              if (category.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(categoryLabel(category),
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: color)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatar() {
    final color =
        category.isEmpty ? teal : getCategoryColor(category);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: avatarBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Transform.scale(
              key: ValueKey(category),
              scaleX: getAvatarScaleX(),
              child: Image.asset(
                getAvatarAsset(),
                key: ValueKey(getAvatarAsset()),
                height: 220,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.person,
                  size: 120,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            category.isEmpty
                ? tr(
                    'Avatar — it will change with your BMI',
                    'Avatar — BMI ke hisaab se badle ga',
                  )
                : categoryLabel(category),
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: mutedColor),
      prefixIcon: Icon(icon, color: teal),
      filled: true,
      fillColor: fieldFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: teal, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 700;
    final contentWidth = isWide ? 860.0 : 520.0;
    final padding = isWide ? 24.0 : 16.0;

    final inputCard = _softCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(tr('Check your BMI', 'Apna BMI check karein'),
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: inkColor)),
          Text(
              tr(
                'Enter your weight and height — you can also change them with the slider.',
                'Weight aur height daalein — slider se bhi badal sakte hain.',
              ),
              style: TextStyle(fontSize: 13, color: mutedColor)),
          const SizedBox(height: 16),
          _stepperRow(
            label: tr('Weight', 'Wazan'),
            value: '${weightSlider.toStringAsFixed(0)} kg',
            onMinus: () => setState(() {
              weightSlider = (weightSlider - 1).clamp(30, 150);
              wtController.text = weightSlider.toStringAsFixed(0);
            }),
            onPlus: () => setState(() {
              weightSlider = (weightSlider + 1).clamp(30, 150);
              wtController.text = weightSlider.toStringAsFixed(0);
            }),
          ),
          Slider(
            value: weightSlider,
            min: 30,
            max: 150,
            divisions: 120,
            activeColor: teal,
            inactiveColor: sliderInactive,
            label: '${weightSlider.toStringAsFixed(0)} kg',
            onChanged: (v) => setState(() {
              weightSlider = v;
              wtController.text = v.toStringAsFixed(0);
            }),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: wtController,
            style: TextStyle(color: inkColor),
            decoration: _fieldDecoration(
                tr('Enter your weight (in Kgs)', 'Apna wazan daalein (Kgs mein)'),
                Icons.monitor_weight),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => _syncSlidersFromFields(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: ftController,
            style: TextStyle(color: inkColor),
            decoration: _fieldDecoration(
                tr('Enter your height (in Feet)',
                    'Apni height daalein (Feet mein)'),
                Icons.height),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: inController,
            style: TextStyle(color: inkColor),
            decoration: _fieldDecoration(
                tr('Enter your height (in Inches)',
                    'Apni height daalein (Inches mein)'),
                Icons.height),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: calculate,
            style: FilledButton.styleFrom(
              backgroundColor: teal,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(tr('Calculate BMI', 'BMI Calculate Karein'),
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ),
          if (result.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(result,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600, color: inkColor)),
          ],
        ],
      ),
    );

    final resultCard = _softCard(
      child: Column(
        children: [
          _ringGauge(),
          const SizedBox(height: 8),
          if (bmiValue != null)
            Text(healthyRangeText(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: mutedColor)),
          const SizedBox(height: 16),
          _avatar(),
          if (planSteps.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(planTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, color: inkColor)),
            const SizedBox(height: 12),
            _planCard(
              title: tr('Plan', 'Plan'),
              icon: Icons.checklist,
              color: teal,
              tint: const Color(0xFFE6F4F2),
              items: planSteps,
            ),
            const SizedBox(height: 12),
            _planCard(
              title: tr('What to eat', 'Kya khayein'),
              icon: Icons.restaurant,
              color: const Color(0xFF059669),
              tint: const Color(0xFFECFDF5),
              items: eatList,
            ),
            const SizedBox(height: 12),
            _planCard(
              title: tr('What NOT to eat', 'Kya NA khayein'),
              icon: Icons.block,
              color: const Color(0xFFDC2626),
              tint: const Color(0xFFFEF2F2),
              items: avoidList,
            ),
            const SizedBox(height: 12),
            _softCard(
              tint: const Color(0xFFFFFBEB),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr('Sample 1-day menu', 'Sample 1-day menu'),
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: inkColor)),
                  const SizedBox(height: 6),
                  Text(sampleMenu,
                      style: TextStyle(fontSize: 14, color: inkColor)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              tr(
                'BMI is a screening measure, not a diagnosis. '
                'For a personal diet/exercise plan, consult a doctor.',
                'BMI sirf ek screening measure hai, diagnosis nahi. '
                'Apne liye diet/exercise plan ke liye doctor se mashwara lein.',
              ),
              style: TextStyle(fontSize: 12, color: mutedColor),
              textAlign: TextAlign.center,
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                tr(
                  'Enter your weight and height and press Calculate — '
                  'your category, avatar and plan will appear here.',
                  'Weight aur height daal kar Calculate dabayein — '
                  'category, avatar aur plan yahan dikhe ga.',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(color: mutedColor),
              ),
            ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: appBarBg,
        foregroundColor: inkColor,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.monitor_weight, color: teal),
            SizedBox(width: 6),
            Text('BMI Calculator',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() => _isDark = !_isDark),
            icon: Icon(
              _isDark ? Icons.light_mode : Icons.dark_mode,
              color: inkColor,
            ),
            tooltip: _isDark
                ? tr('Switch to light mode', 'Light mode karein')
                : tr('Switch to dark mode', 'Dark mode karein'),
          ),
          _langChip('English', !_isUrdu, () => _setLanguage(false)),
          _langChip('Roman Urdu', _isUrdu, () => _setLanguage(true)),
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
                      children: [
                        Expanded(child: inputCard),
                        const SizedBox(width: 16),
                        Expanded(child: resultCard),
                      ],
                    )
                  : Column(
                      children: [
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
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  const _RingPainter(
      {required this.progress, required this.color, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final bg = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bg);
    if (progress > 0) {
      final fg = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        progress * 2 * math.pi,
        false,
        fg,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.trackColor != trackColor;
}
