import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestDoColors {
  QuestDoColors._();

  static const Color primary = Color(0xFF725477);
  static const Color primaryContainer = Color(0xFFE0BBE4);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF66496B);
  static const Color primaryFixedDim = Color(0xFFDFBBE4);
  static const Color onPrimaryFixed = Color(0xFF2A1131);

  static const Color secondary = Color(0xFF326940);
  static const Color secondaryContainer = Color(0xFFB2EEB9);
  static const Color secondaryFixedDim = Color(0xFF99D4A1);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF376E44);

  static const Color tertiary = Color(0xFF705D00);
  static const Color tertiaryContainer = Color(0xFFE9C400);
  static const Color onTertiary = Color(0xFFFFFFFF);

  static const Color background = Color(0xFFFCF9F8);
  static const Color surface = Color(0xFFFCF9F8);
  static const Color surfaceDim = Color(0xFFDCD9D9);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF6F3F2);
  static const Color surfaceContainer = Color(0xFFF0EDED);
  static const Color surfaceContainerHigh = Color(0xFFEAE7E7);
  static const Color surfaceContainerHighest = Color(0xFFE4E2E1);
  static const Color surfaceVariant = Color(0xFFE4E2E1);

  static const Color onSurface = Color(0xFF1B1C1C);
  static const Color onSurfaceVariant = Color(0xFF4C444C);
  static const Color outline = Color(0xFF7D747C);
  static const Color outlineVariant = Color(0xFFCFC3CC);
  static const Color error = Color(0xFFBA1A1A);

  static const Color darkBackground = Color(0xFF1B1C1C);
  static const Color darkSurface = Color(0xFF1B1C1C);
  static const Color darkSurfaceContainer = Color(0xFF303030);
  static const Color darkOnSurface = Color(0xFFF3F0F0);
}

class QuestDoTheme {
  QuestDoTheme._();

  static TextTheme _textTheme = GoogleFonts.interTextTheme();

  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: QuestDoColors.primary,
      onPrimary: QuestDoColors.onPrimary,
      primaryContainer: QuestDoColors.primaryContainer,
      onPrimaryContainer: QuestDoColors.onPrimaryContainer,
      secondary: QuestDoColors.secondary,
      onSecondary: QuestDoColors.onSecondary,
      secondaryContainer: QuestDoColors.secondaryContainer,
      onSecondaryContainer: QuestDoColors.onSecondaryContainer,
      tertiary: QuestDoColors.tertiary,
      onTertiary: QuestDoColors.onTertiary,
      tertiaryContainer: QuestDoColors.tertiaryContainer,
      surface: QuestDoColors.surface,
      onSurface: QuestDoColors.onSurface,
      onSurfaceVariant: QuestDoColors.onSurfaceVariant,
      outline: QuestDoColors.outline,
      outlineVariant: QuestDoColors.outlineVariant,
      surfaceContainerLowest: QuestDoColors.surfaceContainerLowest,
      surfaceContainerLow: QuestDoColors.surfaceContainerLow,
      surfaceContainer: QuestDoColors.surfaceContainer,
      surfaceContainerHigh: QuestDoColors.surfaceContainerHigh,
      surfaceContainerHighest: QuestDoColors.surfaceContainerHighest,
      surfaceDim: QuestDoColors.surfaceDim,
    ),
    scaffoldBackgroundColor: QuestDoColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: QuestDoColors.primaryFixedDim,
      onPrimary: QuestDoColors.onPrimaryFixed,
      primaryContainer: QuestDoColors.primaryContainer,
      onPrimaryContainer: QuestDoColors.onPrimaryContainer,
      secondary: QuestDoColors.secondaryFixedDim,
      onSecondary: QuestDoColors.onSecondary,
      secondaryContainer: QuestDoColors.secondaryContainer,
      onSecondaryContainer: QuestDoColors.onSecondaryContainer,
      tertiary: QuestDoColors.tertiaryContainer,
      onTertiary: QuestDoColors.onTertiary,
      tertiaryContainer: QuestDoColors.tertiaryContainer,
      surface: QuestDoColors.darkSurface,
      onSurface: QuestDoColors.darkOnSurface,
      onSurfaceVariant: QuestDoColors.onSurfaceVariant,
      outline: QuestDoColors.outline,
      outlineVariant: QuestDoColors.outlineVariant,
      surfaceContainerLowest: Color(0xFF141414),
      surfaceContainerLow: Color(0xFF232323),
      surfaceContainer: QuestDoColors.darkSurfaceContainer,
      surfaceContainerHigh: Color(0xFF3A3A3A),
      surfaceContainerHighest: Color(0xFF444444),
      surfaceDim: Color(0xFF141414),
    ),
    scaffoldBackgroundColor: QuestDoColors.darkBackground,
  );
}

final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

void toggleTheme() {
  themeModeNotifier.value =
      themeModeNotifier.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
}
