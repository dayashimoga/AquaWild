import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// App Theme Engine supporting Hydro-Glass, Dark, Light, and High-Contrast modes
class AppTheme {
  AppTheme._();

  /// Futuristic Bioluminescent Hydro-Glass theme (Default flagship experience)
  static ThemeData get hydroGlassTheme {
    final baseTextTheme = Typography.material2021().white;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.surfaceAbyssal,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.cyanPrimary,
        secondary: AppColors.cyanVibrant,
        surface: AppColors.surfaceDark,
        error: Colors.redAccent,
        onPrimary: AppColors.surfaceAbyssal,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      textTheme: GoogleFonts.outfitTextTheme(baseTextTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: const Color(0x1A00E5FF),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0x3300E5FF), width: 1.2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0x1F00E5FF),
        labelStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0x3300E5FF)),
        ),
      ),
    );
  }

  /// Abyssal OLED Dark theme
  static ThemeData get darkTheme {
    final baseTextTheme = Typography.material2021().white;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0D1117),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.cyanPrimary,
        secondary: AppColors.cyanVibrant,
        surface: Color(0xFF161B22),
        error: Colors.redAccent,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      textTheme: GoogleFonts.outfitTextTheme(baseTextTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF21262D),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF30363D), width: 1),
        ),
      ),
    );
  }

  /// Crisp Day Light theme
  static ThemeData get lightTheme {
    final baseTextTheme = Typography.material2021().black;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.surfaceLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.cyanDeep,
        secondary: AppColors.cyanVibrant,
        surface: Colors.white,
        error: Colors.redAccent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.surfaceDark,
      ),
      textTheme: GoogleFonts.outfitTextTheme(baseTextTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0x1F00B0FF), width: 1),
        ),
      ),
    );
  }

  /// High Contrast WCAG 2.2 AAA compliant theme for low-vision users
  static ThemeData get highContrastTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.highContrastBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.highContrastAccent,
        secondary: AppColors.highContrastAccent,
        surface: AppColors.highContrastBackground,
        error: Colors.red,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: AppColors.highContrastForeground,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.highContrastForeground, width: 2),
        ),
      ),
    );
  }

  /// Neon Bioluminescence Premium Theme (PRO / IAP Pack)
  /// Features deep electric midnight base, high-voltage cyan & magenta neon accents,
  /// and radiant glowing hydro-glass surfaces.
  static ThemeData get neonBioluminescenceTheme {
    final baseTextTheme = Typography.material2021().white;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF050814),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00F0FF),
        secondary: Color(0xFFFF007F),
        tertiary: Color(0xFF39FF14),
        surface: Color(0xFF0A1026),
        error: Color(0xFFFF2A6D),
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: Color(0xFFE0FFFF),
      ),
      textTheme: GoogleFonts.outfitTextTheme(baseTextTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: const Color(0x2600F0FF),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0x6600F0FF), width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0x2BFF007F),
        labelStyle: const TextStyle(color: Color(0xFFE0FFFF)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0x66FF007F), width: 1.2),
        ),
      ),
    );
  }

  /// Minimal Zen Premium Theme (PRO / IAP Pack)
  /// Features warm Japanese washi paper aesthetics, natural moss green,
  /// bamboo cedar accents, and calming earthy harmony.
  static ThemeData get minimalZenTheme {
    final baseTextTheme = Typography.material2021().black;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF9F7F1),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF4A6B53),
        secondary: Color(0xFFC48B54),
        tertiary: Color(0xFF8C7355),
        surface: Colors.white,
        error: Color(0xFFB33939),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF2C3531),
      ),
      textTheme: GoogleFonts.outfitTextTheme(baseTextTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0x334A6B53), width: 1.0),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFEDE8DD),
        labelStyle: const TextStyle(color: Color(0xFF2C3531)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0x444A6B53), width: 1.0),
        ),
      ),
    );
  }

  /// Cyber Ocean Synthwave Premium Theme (PRO / IAP Pack)
  /// Features deep oceanic trench midnight, synthetic ultraviolet glows,
  /// electric cyan highlights, and sunset coral accents.
  static ThemeData get cyberOceanTheme {
    final baseTextTheme = Typography.material2021().white;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF040B1A),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00E5FF),
        secondary: Color(0xFF9D4EDD),
        tertiary: Color(0xFFFF5E3A),
        surface: Color(0xFF0D1B2A),
        error: Color(0xFFFF4D6D),
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: Color(0xFFF0F4F8),
      ),
      textTheme: GoogleFonts.outfitTextTheme(baseTextTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: const Color(0x2B0D1B2A),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0x559D4EDD), width: 1.4),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0x2B9D4EDD),
        labelStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0x4400E5FF), width: 1.0),
        ),
      ),
    );
  }
}
