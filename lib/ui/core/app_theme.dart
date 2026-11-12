import 'package:bmi/domain/models/bmi_result.dart';
import 'package:flutter/material.dart';

/// MediClean theme — Design 2, approved by inam (2026-11-11).
///
/// White + teal health-app look. Light colours are the approved
/// MediClean look; dark colours are slate surfaces with light text.
/// The teal accent stays the same in both modes.
class AppTheme {
  AppTheme._();

  /// The `ThemeData` used by the app, exactly as in the original
  /// `MyApp` widget (Material 3, teal seed, light scaffold colour,
  /// white AppBar, teal slider).
  static ThemeData get light {
    const Color teal = MediCleanColors.teal;
    return ThemeData(
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
    );
  }
}

/// Every colour the UI uses, resolved for the current theme mode.
///
/// Replaces the colour getters that lived on the original
/// `_MyHomePageState`. Construct with `isDark` from the ViewModel;
/// the View rebuilds through `ListenableBuilder` when the mode flips.
@immutable
class MediCleanColors {
  const MediCleanColors({required this.isDark});

  static const Color teal = Color(0xFF0D9488);

  final bool isDark;

  Color get background => isDark ? const Color(0xFF0F172A) : const Color(0xFFF6FAF9);
  Color get cardColor => isDark ? const Color(0xFF1E293B) : Colors.white;
  Color get inkColor => isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
  Color get mutedColor => isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  Color get borderColor => isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  Color get fieldFill => isDark ? const Color(0xFF1E293B) : Colors.white;
  Color get stepperBg => isDark ? const Color(0xFF134E4A) : const Color(0xFFE6F4F2);
  Color get avatarBg => isDark ? const Color(0xFF134E4A) : const Color(0xFFE6F4F2);
  Color get sliderInactive => isDark ? const Color(0xFF334155) : const Color(0xFFD6E8E5);
  Color get appBarBg => isDark ? const Color(0xFF1E293B) : Colors.white;
  Color get ringTrack => isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

  /// Dark variant of a light plan-card tint, so tinted cards stay
  /// readable in dark mode (light tint = light mode, dark tint = dark).
  Color tint(Color lightTint) {
    if (!isDark) {
      return lightTint;
    }
    if (lightTint == const Color(0xFFE6F4F2)) {
      return const Color(0xFF134E4A);
    }
    if (lightTint == const Color(0xFFECFDF5)) {
      return const Color(0xFF14532D);
    }
    if (lightTint == const Color(0xFFFEF2F2)) {
      return const Color(0xFF7F1D1D);
    }
    if (lightTint == const Color(0xFFFFFBEB)) {
      return const Color(0xFF78350F);
    }
    return lightTint;
  }

  /// Brighter variant of a plan-card accent colour for dark mode.
  Color accent(Color light) {
    if (!isDark) {
      return light;
    }
    if (light == const Color(0xFF059669)) {
      return const Color(0xFF34D399);
    }
    if (light == const Color(0xFFDC2626)) {
      return const Color(0xFFF87171);
    }
    return light;
  }

  /// The colour for a BMI category in the current mode.
  ///
  /// Light: Underweight blue, Healthy weight green, Overweight amber,
  /// Obesity red. Dark: the brighter variants of the same colours.
  /// (The original code's unreachable `default` branch — for an empty
  /// category — is gone: call sites pass [teal] when there is no
  /// result yet, exactly as the original widgets did.)
  Color categoryColor(BmiCategory category) {
    if (isDark) {
      switch (category) {
        case BmiCategory.underweight:
          return const Color(0xFF60A5FA);
        case BmiCategory.healthyWeight:
          return const Color(0xFF34D399);
        case BmiCategory.overweight:
          return const Color(0xFFFBBF24);
        case BmiCategory.obesity:
          return const Color(0xFFF87171);
      }
    }
    switch (category) {
      case BmiCategory.underweight:
        return const Color(0xFF2563EB);
      case BmiCategory.healthyWeight:
        return const Color(0xFF059669);
      case BmiCategory.overweight:
        return const Color(0xFFD97706);
      case BmiCategory.obesity:
        return const Color(0xFFDC2626);
    }
  }
}
