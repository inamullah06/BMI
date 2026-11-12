import 'package:bmi/domain/models/bmi_result.dart';

/// Single source of truth for the per-category guidance content.
///
/// All text is copied verbatim from the original app's `setPlan`
/// (English-only version, commit d118112). The app has no network,
/// database or platform data source, so there is no Service layer:
/// this repository returns constant local data. See README.md in the
/// project root for the note on the missing Service layer.
class PlanRepository {
  const PlanRepository();

  BmiPlan planFor(BmiCategory category) {
    switch (category) {
      case BmiCategory.underweight:
        return const BmiPlan(
          title: 'How to go from Underweight to Healthy',
          steps: [
            'Eat 300–500 extra calories every day (increase slowly).',
            'Include protein in every meal: eggs, lentils, milk, yogurt, meat.',
            'Do strength exercise 3 days a week: push-ups, squats.',
            'Sleep 7–8 hours and drink plenty of water.',
          ],
          eat: [
            'Milk, yogurt, eggs',
            'Lentils, chickpeas, meat',
            'Dry fruits: almonds, walnuts',
            'Bread, rice, potatoes',
          ],
          avoid: [
            'Skipping meals',
            'Living only on tea / snacks',
            'Too much fast food (empty calories)',
          ],
          sampleMenu:
              'Breakfast: milk + eggs + paratha. Lunch: lentils + rice + yogurt. '
              'Evening: dry fruits + milk. Dinner: meat/vegetables + bread.',
        );
      case BmiCategory.healthyWeight:
        return const BmiPlan(
          title: 'How to go from Healthy to Stronger',
          steps: [
            'Keep protein in every meal (eggs, lentils, milk, yogurt, meat).',
            'Do strength training 4 days a week + walk 30 minutes every day.',
            'Cut down on sweets and cold drinks.',
            'Sleep 7–8 hours — muscles are built during sleep.',
          ],
          eat: [
            'Eggs, milk, yogurt',
            'Lentils, chickpeas, meat',
            'Vegetables, fruit, dry fruits',
          ],
          avoid: [
            'Cold drink / sweets every day',
            'Too much oily fast food',
            'Heavy food late at night',
          ],
          sampleMenu:
              'Breakfast: eggs + milk. Lunch: lentils + bread + salad. '
              'Evening: fruit + yogurt. Dinner: meat/vegetables + bread.',
        );
      case BmiCategory.overweight:
        return const BmiPlan(
          title: 'How to go from Overweight to Healthy',
          steps: [
            'Eat 300–500 fewer calories every day — slowly, no crash diet.',
            'Walk briskly for 30–45 minutes, 5 days a week.',
            'Eat a little less bread/rice and more vegetables/salad.',
            'Check your weight every week, target 0.5 kg/week.',
          ],
          eat: [
            'Vegetables, salad, fruit',
            'Lentils, yogurt (low fat)',
            'Plenty of water, green tea',
          ],
          avoid: [
            'Cold drink / sweets / mithai',
            'Fast food: burger, fries, pizza',
            'Too much oily / ghee food',
            'Snacking late at night',
          ],
          sampleMenu:
              'Breakfast: eggs + milk (low fat). Lunch: lentils + 1 bread + salad. '
              'Evening: fruit. Dinner: vegetables + 1 bread + yogurt.',
        );
      case BmiCategory.obesity:
        return const BmiPlan(
          title: 'How to go from Obesity to Healthy',
          steps: [
            'First consult a doctor / dietitian, then start the plan.',
            'Start with a 30-minute walk every day, then slowly increase it.',
            'Stop sweets, cold drinks and fast food.',
            'Keep a small target: lose 5% of your weight first.',
          ],
          eat: [
            'Vegetables, salad, fruit',
            'Lentils, yogurt (low fat)',
            'Plenty of water',
          ],
          avoid: [
            'Cold drink / sweets / mithai',
            'Fast food and bakery items',
            'Too much oily / ghee food',
            'Snacking late at night',
          ],
          sampleMenu:
              'Breakfast: eggs + milk (low fat). Lunch: lentils + salad + 1 bread. '
              'Evening: fruit. Dinner: vegetables + yogurt.',
        );
    }
  }
}
