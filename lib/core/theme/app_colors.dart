import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand seed — violet, modern fintech feel
  static const Color seed = Color(0xFF8B5CF6);
  static const Color seedLight = Color(0xFFA78BFA);

  // Dark mode surfaces — black with a purple tint
  static const Color darkBackground = Color(0xFF0C0812);
  static const Color darkSurface = Color(0xFF17111F);
  static const Color darkSurfaceHigh = Color(0xFF1F1729);

  // Light mode surfaces — soft violet tint
  static const Color lightBackground = Color(0xFFF7F5FB);
  static const Color lightSurface = Color(0xFFFFFFFF);

  // Balance card gradient — black → deep purple → violet
  static const Color gradientStart = Color(0xFF0C0812);
  static const Color gradientMid = Color(0xFF2E1065);
  static const Color gradientEnd = Color(0xFF7C3AED);

  // Semantic
  static const Color error = Color(0xFFEF4444);
  static const Color income = Color(0xFF34D399);
  static const Color expense = Color(0xFFFB7185);
}
