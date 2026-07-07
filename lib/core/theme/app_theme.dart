import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: brightness,
    ).copyWith(
      surface: isDark ? AppColors.darkSurface : AppColors.lightSurface,
    );

    final baseTextTheme = isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(baseTextTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      textTheme: textTheme,
      inputDecorationTheme: _inputDecorationTheme(colorScheme),
      filledButtonTheme: _filledButtonTheme(colorScheme, textTheme),
      textButtonTheme: _textButtonTheme(colorScheme),
      outlinedButtonTheme: _outlinedButtonTheme(colorScheme),
      appBarTheme: _appBarTheme(colorScheme, textTheme),
      snackBarTheme: _snackBarTheme(colorScheme),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(ColorScheme scheme) {
    final radius = BorderRadius.circular(16);
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecorationTheme(
      filled: true,
      fillColor: Color.alphaBlend(scheme.primary.withValues(alpha: 0.06), scheme.surface),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: border(Colors.transparent, 0),
      enabledBorder: border(Colors.transparent, 0),
      disabledBorder: border(Colors.transparent, 0),
      focusedBorder: border(scheme.primary, 1.6),
      errorBorder: border(scheme.error, 1.4),
      focusedErrorBorder: border(scheme.error, 1.6),
      labelStyle: TextStyle(color: scheme.onSurfaceVariant),
      floatingLabelStyle: TextStyle(color: scheme.primary),
      hintStyle: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.6)),
      suffixIconColor: scheme.onSurfaceVariant,
      prefixIconColor: scheme.onSurfaceVariant,
    );
  }

  static FilledButtonThemeData _filledButtonTheme(ColorScheme scheme, TextTheme textTheme) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme(ColorScheme scheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: scheme.primary),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(ColorScheme scheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        side: BorderSide(color: scheme.primary.withValues(alpha: 0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static AppBarTheme _appBarTheme(ColorScheme scheme, TextTheme textTheme) {
    return AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  static SnackBarThemeData _snackBarTheme(ColorScheme scheme) {
    return SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
