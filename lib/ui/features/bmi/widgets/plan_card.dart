import 'package:bmi/ui/core/app_theme.dart';
import 'package:bmi/ui/core/widgets/soft_card.dart';
import 'package:flutter/material.dart';

/// A tinted plan card: an icon + title header, then one check-marked
/// row per item. Used for the Plan, What to eat and What NOT to eat
/// sections. The accent colour is brightened in dark mode by the theme.
class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.colors,
    required this.title,
    required this.icon,
    required this.color,
    required this.tint,
    required this.items,
  });

  final MediCleanColors colors;
  final String title;
  final IconData icon;
  final Color color;
  final Color tint;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final Color accent = colors.accent(color);
    return SoftCard(
      colors: colors,
      tint: tint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, color: accent),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (String item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.check_circle, size: 16, color: accent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(fontSize: 14, color: colors.inkColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
