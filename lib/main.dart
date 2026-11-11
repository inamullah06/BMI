import 'dart:math' as math;
import 'package:flutter/material.dart';

// MediClean UI — Design 2, approved by inam (2026-11-11).
// White + teal health-app look: soft white cards, teal accent,
// ring gauge for the BMI result, sliders/steppers for inputs,
// full-body avatar image, and plan split into 3 cards.
// Same BMI logic as before: weight kg, height ft+in,
// BMI = kg / m^2, decimal inputs via double.tryParse.

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
          centerTitle: true,
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
  static const ink = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const cardBorder = Color(0xFFE2E8F0);

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

  String getCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Healthy weight';
    if (bmi < 30) return 'Overweight';
    return 'Obesity';
  }

  Color getCategoryColor(String cat) {
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
      planTitle = 'Underweight → Healthy kaise bane';
      planSteps = [
        'Roz 300–500 extra calories khayein (slowly badhayein).',
        'Har meal mein protein: ande, daal, doodh, dahi, gosht.',
        'Hafte mein 3 din strength exercise: push-ups, squats.',
        'Neend 7–8 ghante, paani zyada piyen.',
      ];
      eatList = [
        'Doodh, dahi, ande',
        'Daal, chane, gosht',
        'Dry fruits: badam, akhrot',
        'Roti, chawal, aloo',
      ];
      avoidList = [
        'Khana skip karna',
        'Sirf chai / snacks par guzara',
        'Zyada fast food (empty calories)',
      ];
      sampleMenu =
          'Nashta: doodh + ande + paratha. Lunch: daal + chawal + dahi. Shaam: dry fruits + doodh. Dinner: gosht/sabzi + roti.';
    } else if (bmi < 25) {
      planTitle = 'Healthy → Stronger kaise bane';
      planSteps = [
        'Protein har meal mein rakhein (ande, daal, doodh, gosht).',
        'Hafte mein 4 din strength training + roz 30 min walk.',
        'Meetha aur cold drink kam kar dein.',
        'Neend 7–8 ghante — muscle neend mein banta hai.',
      ];
      eatList = [
        'Ande, doodh, dahi',
        'Daal, chane, gosht',
        'Sabzi, fruit, dry fruits',
      ];
      avoidList = [
        'Roz cold drink / meetha',
        'Zyada oily fast food',
        'Late night heavy khana',
      ];
      sampleMenu =
          'Nashta: ande + doodh. Lunch: daal + roti + salad. Shaam: fruit + dahi. Dinner: gosht/sabzi + roti.';
    } else if (bmi < 30) {
      planTitle = 'Overweight → Healthy kaise bane';
      planSteps = [
        'Roz 300–500 calories kam khayein — aahista, crash diet nahi.',
        'Roz 30–45 min tez walk, hafte mein 5 din.',
        'Roti/chawal thora kam, sabzi/salad zyada.',
        'Har hafte weight check karein, target 0.5 kg/week.',
      ];
      eatList = [
        'Sabzi, salad, fruit',
        'Daal, dahi (low fat)',
        'Paani zyada, green tea',
      ];
      avoidList = [
        'Cold drink / meetha / mithai',
        'Fast food: burger, fries, pizza',
        'Zyada tel / ghee wala khana',
        'Late night snacking',
      ];
      sampleMenu =
          'Nashta: ande + doodh (low fat). Lunch: daal + 1 roti + salad. Shaam: fruit. Dinner: sabzi + 1 roti + dahi.';
    } else {
      planTitle = 'Obesity → Healthy kaise bane';
      planSteps = [
        'Doctor / dietitian se mashwara zaroor lein, phir plan shuru karein.',
        'Roz 30 min walk se shuru karein, aahista badhayein.',
        'Meetha, cold drink aur fast food band kar dein.',
        'Chhota target rakhein: pehle 5% weight kam karna.',
      ];
      eatList = [
        'Sabzi, salad, fruit',
        'Daal, dahi (low fat)',
        'Paani zyada',
      ];
      avoidList = [
        'Cold drink / meetha / mithai',
        'Fast food aur bakery items',
        'Zyada tel / ghee wala khana',
        'Late night snacking',
      ];
      sampleMenu =
          'Nashta: ande + doodh (low fat). Lunch: daal + salad + 1 roti. Shaam: fruit. Dinner: sabzi + dahi.';
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
            ? '${(low - weightKg!).toStringAsFixed(1)} kg badhana hai'
            : weightKg! > high
                ? '${(weightKg! - high).toStringAsFixed(1)} kg kam karna hai'
                : 'Healthy range mein hain — strong banein!';
    return 'Healthy weight: ${low.toStringAsFixed(1)} – ${high.toStringAsFixed(1)} kg  •  $diff';
  }

  // ---- MediClean widgets ----

  Widget _softCard({required Widget child, Color? tint}) {
    return Container(
      decoration: BoxDecoration(
        color: tint ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder),
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
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600, color: ink)),
        ),
        IconButton.filledTonal(
          onPressed: onMinus,
          icon: const Icon(Icons.remove),
          style: IconButton.styleFrom(backgroundColor: const Color(0xFFE6F4F2)),
        ),
        SizedBox(
          width: 72,
          child: Text(value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: ink)),
        ),
        IconButton.filledTonal(
          onPressed: onPlus,
          icon: const Icon(Icons.add),
          style: IconButton.styleFrom(backgroundColor: const Color(0xFFE6F4F2)),
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
    return _softCard(
      tint: tint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(title,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: color)),
          ]),
          const SizedBox(height: 10),
          ...items.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, size: 16, color: color),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Text(e,
                            style: const TextStyle(fontSize: 14, color: ink))),
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
            painter: _RingPainter(progress: progress, color: color),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                bmiValue == null ? '--' : bmi.toStringAsFixed(1),
                style: const TextStyle(
                    fontSize: 38, fontWeight: FontWeight.w800, color: ink),
              ),
              const Text('BMI',
                  style: TextStyle(fontSize: 13, color: muted)),
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
        color: const Color(0xFFE6F4F2),
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
                ? 'Avatar — BMI ke hisaab se badle ga'
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
      prefixIcon: Icon(icon, color: teal),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: cardBorder),
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
          const Text('Apna BMI check karein',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: ink)),
          const Text('Weight aur height daalein — slider se bhi badal sakte hain.',
              style: TextStyle(fontSize: 13, color: muted)),
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
            label: '${weightSlider.toStringAsFixed(0)} kg',
            onChanged: (v) => setState(() {
              weightSlider = v;
              wtController.text = v.toStringAsFixed(0);
            }),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: wtController,
            decoration: _fieldDecoration(
                'Enter Your weight (in Kgs)', Icons.monitor_weight),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => _syncSlidersFromFields(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: ftController,
            decoration:
                _fieldDecoration('Enter Your Height (in Feet)', Icons.height),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: inController,
            decoration: _fieldDecoration(
                'Enter Your Height (in Inches)', Icons.height),
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
            child: const Text('Calculate BMI',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ),
          if (result.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(result,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600, color: ink)),
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
                style: const TextStyle(fontSize: 13, color: muted)),
          const SizedBox(height: 16),
          _avatar(),
          if (planSteps.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(planTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, color: ink)),
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
              title: 'Kya khayein',
              icon: Icons.restaurant,
              color: const Color(0xFF059669),
              tint: const Color(0xFFECFDF5),
              items: eatList,
            ),
            const SizedBox(height: 12),
            _planCard(
              title: 'Kya NA khayein',
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
                  const Text('Sample 1-day menu',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: ink)),
                  const SizedBox(height: 6),
                  Text(sampleMenu,
                      style: const TextStyle(fontSize: 14, color: ink)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'BMI is a screening measure, not a diagnosis. '
              'For a personal diet/exercise plan, consult a doctor.',
              style: TextStyle(fontSize: 12, color: muted),
              textAlign: TextAlign.center,
            ),
          ] else
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Weight aur height daal kar Calculate dabayein — '
                'category, avatar aur plan yahan dikhe ga.',
                textAlign: TextAlign.center,
                style: TextStyle(color: muted),
              ),
            ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.monitor_weight, color: teal),
            SizedBox(width: 8),
            Text('BMI Calculator',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
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
  const _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final bg = Paint()
      ..color = const Color(0xFFE2E8F0)
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
      old.progress != progress || old.color != color;
}
