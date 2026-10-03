import 'package:flutter/material.dart';

/// Dark-elegance palette: bottle-green near-black, ivory text, brass accents,
/// with burgundy reserved for the add action and notices.
class AppColors {
  AppColors._();

  // Surfaces
  static const Color background = Color(0xFF0B100E);
  static const Color surface = Color(0xFF121A16);
  static const Color surfaceHigh = Color(0xFF172620);
  static const Color hero = Color(0xFF13241B);
  static const Color heroBorder = Color(0xFF2F4A3B);

  // Lines
  static const Color hairline = Color(0xFF2A3A31);
  static const Color hairlineSoft = Color(0xFF243228);
  static const Color divider = Color(0xFF1F2B24);
  static const Color track = Color(0xFF25332B);

  // Text
  static const Color ivory = Color(0xFFEFE8D8);
  static const Color textLabel = Color(0xFFB4BBA9);
  static const Color textMuted = Color(0xFFA3AA9C);
  static const Color textFaint = Color(0xFF8A9187);

  // Brass accent
  static const Color brass = Color(0xFFD8C08A);
  static const Color brassOutline = Color(0xFF8C7A4F);
  static const Color brassDim = Color(0xFF5F5640);

  // Burgundy (add action, notices)
  static const Color burgundy = Color(0xFF4A1C26);
  static const Color burgundyBorder = Color(0xFF6A2D3A);
  static const Color noticeBackground = Color(0xFF1A1113);
  static const Color noticeBorder = Color(0xFF4A2A30);

  // Semantic
  static const Color income = Color(0xFF9DBF9A);
  static const Color expense = Color(0xFFE0A08B);
  static const Color error = Color(0xFFE58B75);

  // Receipt slip
  static const Color paper = Color(0xFFEFE8D8);
  static const Color ink = Color(0xFF1B1F1C);
  static const Color inkMuted = Color(0xFF5B5F55);
  static const Color inkRule = Color(0xFF8C8672);
  static const Color oxblood = Color(0xFF7A2E1F);

  // Legacy names kept so existing widgets compile until they are restyled in
  // later phases; each maps to the closest new token.
  static const Color seed = brass;
  static const Color seedLight = brass;
  static const Color darkBackground = background;
  static const Color darkSurface = surface;
  static const Color darkSurfaceHigh = hero;
  static const Color gradientStart = background;
  static const Color gradientMid = hero;
  static const Color gradientEnd = heroBorder;
  static const Color blobAccent = brassOutline;
}
