import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
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
  final wtController = TextEditingController();
  final ftController = TextEditingController();
  final inController = TextEditingController();

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
        return Colors.blue;
      case 'Healthy weight':
        return Colors.green;
      case 'Overweight':
        return Colors.orange;
      case 'Obesity':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  // Body width of the full-body avatar, animated by category.
  double getAvatarWidth() {
    switch (category) {
      case 'Underweight':
        return 64;
      case 'Healthy weight':
        return 96;
      case 'Overweight':
        return 128;
      case 'Obesity':
        return 158;
      default:
        return 96;
    }
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

  Widget buildAvatar() {
    // Full-body avatar: head, flexing arms, green tank top, blue pants.
    // Width animates with the category — thin → athletic → heavy.
    final w = getAvatarWidth();
    final color = getCategoryColor(category);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Head
        const CircleAvatar(
          radius: 22,
          backgroundColor: Color(0xFFF2C89B),
          child: Icon(Icons.person, size: 30, color: Colors.brown),
        ),
        const SizedBox(height: 4),
        // Flexing arms + body
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.fitness_center,
                size: 28, color: Colors.orange),
            const SizedBox(width: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              width: w,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black26),
              ),
              child: const Center(
                child: Icon(Icons.sports_gymnastics,
                    size: 44, color: Colors.white),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.fitness_center,
                size: 28, color: Colors.orange),
          ],
        ),
        const SizedBox(height: 4),
        // Legs (blue pants)
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          width: w * 0.8,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.blue[800],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          category.isEmpty ? 'Avatar — BMI ke hisaab se badle ga' : category,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget buildList(String title, List<String> items, IconData icon,
      Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 4),
        ...items.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 6),
                  Expanded(child: Text(e)),
                ],
              ),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 700;
    final contentWidth = isWide ? 860.0 : 520.0;
    final padding = isWide ? 24.0 : 16.0;

    final calculatorCard = Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'BMI',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: wtController,
              decoration: const InputDecoration(
                labelText: 'Enter Your weight (in Kgs)',
                prefixIcon: Icon(Icons.line_weight),
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ftController,
              decoration: const InputDecoration(
                labelText: 'Enter Your Height (in Feet)',
                prefixIcon: Icon(Icons.height),
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: inController,
              decoration: const InputDecoration(
                labelText: 'Enter Your Height (in Inches)',
                prefixIcon: Icon(Icons.height),
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: calculate,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Calculate', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 16),
            if (result.isNotEmpty)
              Text(
                result,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w500),
              ),
            if (bmiValue != null) ...[
              const SizedBox(height: 8),
              Text(
                healthyRangeText(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );

    final resultCard = Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            buildAvatar(),
            if (planSteps.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                planTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              buildList('Plan', planSteps, Icons.check_circle,
                  Colors.green),
              const SizedBox(height: 12),
              buildList('Kya khayein', eatList, Icons.restaurant,
                  Colors.green),
              const SizedBox(height: 12),
              buildList('Kya NA khayein', avoidList, Icons.block,
                  Colors.red),
              const SizedBox(height: 12),
              const Text('Sample 1-day menu',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(sampleMenu),
              const SizedBox(height: 8),
              const Text(
                'BMI is a screening measure, not a diagnosis. '
                'For a personal diet/exercise plan, consult a doctor.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ] else
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'Weight aur height daal kar Calculate dabayein — '
                  'category, avatar aur plan yahan dikhe ga.',
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('BMI Calculator')),
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
                        Expanded(child: calculatorCard),
                        const SizedBox(width: 16),
                        Expanded(child: resultCard),
                      ],
                    )
                  : Column(
                      children: [
                        calculatorCard,
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
