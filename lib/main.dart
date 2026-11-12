import 'dart:math' as math;
import 'package:flutter/material.dart';

// MediClean UI — Design 2, approved by inam (2026-11-11).
// White + teal health-app look: soft white cards, teal accent,
// ring gauge for the BMI result, sliders/steppers for inputs,
// full-body avatar image, and plan split into 3 cards.
// Same BMI logic as before: weight kg, height ft+in,
// BMI = kg / m^2, decimal inputs via double.tryParse.
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

  // ---- BMI logic (unchanged) ----


  /// Category key for the given BMI (shown directly).
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
      planTitle = 'How to go from Underweight to Healthy';
      planSteps = [
        'Eat 300–500 extra calories every day (increase slowly).',
        'Include protein in every meal: eggs, lentils, milk, yogurt, meat.',
        'Do strength exercise 3 days a week: push-ups, squats.',
        'Sleep 7–8 hours and drink plenty of water.',
      ];
      eatList = [
        'Milk, yogurt, eggs',
        'Lentils, chickpeas, meat',
        'Dry fruits: almonds, walnuts',
        'Bread, rice, potatoes',
      ];
      avoidList = [
        'Skipping meals',
        'Living only on tea / snacks',
        'Too much fast food (empty calories)',
      ];
      sampleMenu = 'Breakfast: milk + eggs + paratha. Lunch: lentils + rice + yogurt. Evening: dry fruits + milk. Dinner: meat/vegetables + bread.';
    } else if (bmi < 25) {
      planTitle = 'How to go from Healthy to Stronger';
      planSteps = [
        'Keep protein in every meal (eggs, lentils, milk, yogurt, meat).',
        'Do strength training 4 days a week + walk 30 minutes every day.',
        'Cut down on sweets and cold drinks.',
        'Sleep 7–8 hours — muscles are built during sleep.',
      ];
      eatList = [
        'Eggs, milk, yogurt',
        'Lentils, chickpeas, meat',
        'Vegetables, fruit, dry fruits',
      ];
      avoidList = [
        'Cold drink / sweets every day',
        'Too much oily fast food',
        'Heavy food late at night',
      ];
      sampleMenu = 'Breakfast: eggs + milk. Lunch: lentils + bread + salad. Evening: fruit + yogurt. Dinner: meat/vegetables + bread.';
    } else if (bmi < 30) {
      planTitle = 'How to go from Overweight to Healthy';
      planSteps = [
        'Eat 300–500 fewer calories every day — slowly, no crash diet.',
        'Walk briskly for 30–45 minutes, 5 days a week.',
        'Eat a little less bread/rice and more vegetables/salad.',
        'Check your weight every week, target 0.5 kg/week.',
      ];
      eatList = [
        'Vegetables, salad, fruit',
        'Lentils, yogurt (low fat)',
        'Plenty of water, green tea',
      ];
      avoidList = [
        'Cold drink / sweets / mithai',
        'Fast food: burger, fries, pizza',
        'Too much oily / ghee food',
        'Snacking late at night',
      ];
      sampleMenu = 'Breakfast: eggs + milk (low fat). Lunch: lentils + 1 bread + salad. Evening: fruit. Dinner: vegetables + 1 bread + yogurt.';
    } else {
      planTitle = 'How to go from Obesity to Healthy';
      planSteps = [
        'First consult a doctor / dietitian, then start the plan.',
        'Start with a 30-minute walk every day, then slowly increase it.',
        'Stop sweets, cold drinks and fast food.',
        'Keep a small target: lose 5% of your weight first.',
      ];
      eatList = [
        'Vegetables, salad, fruit',
        'Lentils, yogurt (low fat)',
        'Plenty of water',
      ];
      avoidList = [
        'Cold drink / sweets / mithai',
        'Fast food and bakery items',
        'Too much oily / ghee food',
        'Snacking late at night',
      ];
      sampleMenu = 'Breakfast: eggs + milk (low fat). Lunch: lentils + salad + 1 bread. Evening: fruit. Dinner: vegetables + yogurt.';
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
        result = 'Please fill all the required blanks';
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
        result = 'Please enter valid numbers';
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
      result = 'Your BMI is ${bmi.toStringAsFixed(2)}';
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
            ? 'You need to gain ${(low - weightKg!).toStringAsFixed(1)} kg'
            : weightKg! > high
                ? 'You need to lose ${(weightKg! - high).toStringAsFixed(1)} kg'
                : 'You are in the healthy range — get stronger!';
    return 'Healthy weight: ${low.toStringAsFixed(1)} – ${high.toStringAsFixed(1)} kg  •  $diff';
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
                  child: Text(category,
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
                ? 'Avatar — it will change with your BMI'
                : category,
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
          Text('Check your BMI',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: inkColor)),
          Text(
              'Enter your weight and height — you can also change them with the slider.',
              style: TextStyle(fontSize: 13, color: mutedColor)),
          const SizedBox(height: 16),
          _stepperRow(
            label: 'Weight',
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
                'Enter your weight (in Kgs)',
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
                'Enter your height (in Feet)',
                Icons.height),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: inController,
            style: TextStyle(color: inkColor),
            decoration: _fieldDecoration(
                'Enter your height (in Inches)',
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
            child: Text('Calculate BMI',
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
              title: 'Plan',
              icon: Icons.checklist,
              color: teal,
              tint: const Color(0xFFE6F4F2),
              items: planSteps,
            ),
            const SizedBox(height: 12),
            _planCard(
              title: 'What to eat',
              icon: Icons.restaurant,
              color: const Color(0xFF059669),
              tint: const Color(0xFFECFDF5),
              items: eatList,
            ),
            const SizedBox(height: 12),
            _planCard(
              title: 'What NOT to eat',
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
                  Text('Sample 1-day menu',
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
              'BMI is a screening measure, not a diagnosis. '
                'For a personal diet/exercise plan, consult a doctor.',
              style: TextStyle(fontSize: 12, color: mutedColor),
              textAlign: TextAlign.center,
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Enter your weight and height and press Calculate — '
                  'your category, avatar and plan will appear here.',
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
                ? 'Switch to light mode'
                : 'Switch to dark mode',
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
