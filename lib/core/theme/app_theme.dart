import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// The app ships a single dark theme ("dark elegance"): Cormorant Garamond for
/// titles and amounts, Hanken Grotesk for everything else.
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final textTheme = _textTheme();
    final colorScheme = _colorScheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      textTheme: textTheme,
      splashColor: AppColors.brass.withValues(alpha: 0.08),
      highlightColor: AppColors.brass.withValues(alpha: 0.04),
      dividerColor: AppColors.divider,
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1, space: 1),
      inputDecorationTheme: _inputDecorationTheme(colorScheme, textTheme),
      filledButtonTheme: _filledButtonTheme(colorScheme, textTheme),
      textButtonTheme: _textButtonTheme(colorScheme, textTheme),
      outlinedButtonTheme: _outlinedButtonTheme(colorScheme, textTheme),
      segmentedButtonTheme: _segmentedButtonTheme(colorScheme, textTheme),
      floatingActionButtonTheme: _fabTheme(),
      appBarTheme: _appBarTheme(colorScheme, textTheme),
      snackBarTheme: _snackBarTheme(textTheme),
      cardTheme: _cardTheme(),
      bottomSheetTheme: _bottomSheetTheme(),
      dialogTheme: _dialogTheme(textTheme),
      navigationBarTheme: _navigationBarTheme(colorScheme, textTheme),
      chipTheme: _chipTheme(colorScheme, textTheme),
      tabBarTheme: _tabBarTheme(colorScheme, textTheme),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.brass,
        linearTrackColor: AppColors.track,
        circularTrackColor: AppColors.track,
      ),
      switchTheme: _switchTheme(),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.brass,
        selectionHandleColor: AppColors.brass,
      ),
    );
  }

  static ColorScheme _colorScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.brass,
      onPrimary: AppColors.background,
      primaryContainer: AppColors.hero,
      onPrimaryContainer: AppColors.brass,
      secondary: AppColors.brassOutline,
      onSecondary: AppColors.ivory,
      secondaryContainer: AppColors.burgundy,
      onSecondaryContainer: AppColors.brass,
      tertiary: AppColors.income,
      onTertiary: AppColors.background,
      error: AppColors.error,
      onError: AppColors.background,
      errorContainer: AppColors.noticeBackground,
      onErrorContainer: AppColors.expense,
      surface: AppColors.surface,
      onSurface: AppColors.ivory,
      onSurfaceVariant: AppColors.textLabel,
      outline: AppColors.hairline,
      outlineVariant: AppColors.hairlineSoft,
      shadow: Colors.black,
      scrim: Color(0xB8050806),
      inverseSurface: AppColors.ivory,
      onInverseSurface: AppColors.ink,
      inversePrimary: AppColors.brassOutline,
      surfaceTint: Colors.transparent,
      surfaceContainerLowest: AppColors.background,
      surfaceContainerLow: Color(0xFF0F1512),
      surfaceContainer: AppColors.surface,
      surfaceContainerHigh: Color(0xFF15201A),
      surfaceContainerHighest: AppColors.surfaceHigh,
    );
  }

  static TextTheme _textTheme() {
    final base = ThemeData(brightness: Brightness.dark).textTheme.apply(
          bodyColor: AppColors.ivory,
          displayColor: AppColors.ivory,
        );
    final sans = GoogleFonts.hankenGroteskTextTheme(base);

    TextStyle serif(TextStyle? style, double size) => GoogleFonts.cormorantGaramond(
          textStyle: style,
          fontSize: size,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.15,
        );

    return sans.copyWith(
      displayLarge: serif(sans.displayLarge, 57),
      displayMedium: serif(sans.displayMedium, 45),
      displaySmall: serif(sans.displaySmall, 36),
      headlineLarge: serif(sans.headlineLarge, 34),
      headlineMedium: serif(sans.headlineMedium, 30),
      headlineSmall: serif(sans.headlineSmall, 26),
      titleLarge: serif(sans.titleLarge, 28),
      titleMedium: serif(sans.titleMedium, 24),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(ColorScheme scheme, TextTheme textTheme) {
    final radius = BorderRadius.circular(16);
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: border(AppColors.hairline, 1),
      enabledBorder: border(AppColors.hairline, 1),
      disabledBorder: border(AppColors.hairlineSoft, 1),
      focusedBorder: border(AppColors.brassOutline, 1.2),
      errorBorder: border(scheme.error, 1),
      focusedErrorBorder: border(scheme.error, 1.2),
      labelStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textLabel),
      floatingLabelStyle: textTheme.bodySmall?.copyWith(color: AppColors.brass),
      hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textFaint),
      helperStyle: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
      errorStyle: textTheme.bodySmall?.copyWith(color: scheme.error),
      suffixIconColor: AppColors.textLabel,
      prefixIconColor: AppColors.textLabel,
    );
  }

  static TextStyle? _buttonText(TextTheme textTheme) =>
      textTheme.labelLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.2);

  static FilledButtonThemeData _filledButtonTheme(ColorScheme scheme, TextTheme textTheme) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.brass,
        foregroundColor: AppColors.background,
        disabledBackgroundColor: AppColors.brassDim,
        disabledForegroundColor: AppColors.textMuted,
        minimumSize: const Size.fromHeight(54),
        shape: const StadiumBorder(),
        textStyle: _buttonText(textTheme),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme(ColorScheme scheme, TextTheme textTheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.brass,
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(ColorScheme scheme, TextTheme textTheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.brass,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: AppColors.brass),
        shape: const StadiumBorder(),
        textStyle: _buttonText(textTheme),
      ),
    );
  }

  static SegmentedButtonThemeData _segmentedButtonTheme(ColorScheme scheme, TextTheme textTheme) {
    return SegmentedButtonThemeData(
      style: ButtonStyle(
        shape: const WidgetStatePropertyAll(StadiumBorder()),
        side: const WidgetStatePropertyAll(BorderSide(color: AppColors.hairline)),
        textStyle: WidgetStatePropertyAll(
          textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? AppColors.brass : AppColors.surface,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? AppColors.background : AppColors.textLabel,
        ),
      ),
    );
  }

  static FloatingActionButtonThemeData _fabTheme() {
    return const FloatingActionButtonThemeData(
      backgroundColor: AppColors.burgundy,
      foregroundColor: AppColors.brass,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      shape: CircleBorder(side: BorderSide(color: AppColors.brassOutline)),
    );
  }

  static AppBarTheme _appBarTheme(ColorScheme scheme, TextTheme textTheme) {
    return AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: AppColors.ivory,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge,
    );
  }

  static SnackBarThemeData _snackBarTheme(TextTheme textTheme) {
    return SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.surfaceHigh,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: AppColors.ivory),
      actionTextColor: AppColors.brass,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.hairline),
      ),
    );
  }

  static CardThemeData _cardTheme() {
    return CardThemeData(
      elevation: 0,
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.hairlineSoft),
      ),
    );
  }

  static BottomSheetThemeData _bottomSheetTheme() {
    return const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: AppColors.surface,
      modalBarrierColor: Color(0xB8050806),
      elevation: 0,
      modalElevation: 0,
      showDragHandle: true,
      dragHandleColor: Color(0xFF3A4A40),
      dragHandleSize: Size(40, 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        side: BorderSide(color: AppColors.hairline),
      ),
      clipBehavior: Clip.antiAlias,
    );
  }

  static DialogThemeData _dialogTheme(TextTheme textTheme) {
    return DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: textTheme.titleMedium,
      contentTextStyle: textTheme.bodyMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.hairline),
      ),
    );
  }

  // Replaced by the custom pill bar in a later phase; restyled meanwhile so the
  // app is coherent in the new palette.
  static NavigationBarThemeData _navigationBarTheme(ColorScheme scheme, TextTheme textTheme) {
    return NavigationBarThemeData(
      height: 68,
      elevation: 0,
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.brass,
      indicatorShape: const StadiumBorder(),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => textTheme.labelMedium?.copyWith(
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
          color: states.contains(WidgetState.selected) ? AppColors.brass : AppColors.textLabel,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? AppColors.background : AppColors.textLabel,
        ),
      ),
    );
  }

  static ChipThemeData _chipTheme(ColorScheme scheme, TextTheme textTheme) {
    return ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.brass,
      disabledColor: AppColors.surface,
      deleteIconColor: AppColors.brass,
      checkmarkColor: AppColors.background,
      labelStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textLabel),
      secondaryLabelStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.background,
        fontWeight: FontWeight.w600,
      ),
      side: const BorderSide(color: AppColors.hairline),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }

  static TabBarThemeData _tabBarTheme(ColorScheme scheme, TextTheme textTheme) {
    return TabBarThemeData(
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: AppColors.brass,
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
      labelColor: AppColors.background,
      unselectedLabelColor: AppColors.textLabel,
      labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      unselectedLabelStyle: textTheme.labelLarge,
    );
  }

  static SwitchThemeData _switchTheme() {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? AppColors.brass : AppColors.textMuted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? AppColors.brassDim : AppColors.track,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(AppColors.hairline),
    );
  }
}
