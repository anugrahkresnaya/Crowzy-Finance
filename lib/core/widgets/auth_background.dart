import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Wraps auth screens with a soft violet glow in the top corner, matching
/// the balance card gradient, so the auth flow feels part of the same app.
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: -120,
          right: -80,
          child: _glow(280, AppColors.gradientEnd.withValues(alpha: isDark ? 0.28 : 0.14)),
        ),
        Positioned(
          bottom: -140,
          left: -100,
          child: _glow(260, AppColors.gradientMid.withValues(alpha: isDark ? 0.24 : 0.1)),
        ),
        child,
      ],
    );
  }

  Widget _glow(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
