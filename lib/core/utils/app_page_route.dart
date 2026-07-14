import 'package:flutter/material.dart';

/// Pushes [page] with a subtle fade + upward slide transition instead of the
/// platform default, for a more consistent "app-like" navigation feel.
Future<T?> pushSlide<T>(BuildContext context, Widget page) {
  return Navigator.of(context).push<T>(
    PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    ),
  );
}
