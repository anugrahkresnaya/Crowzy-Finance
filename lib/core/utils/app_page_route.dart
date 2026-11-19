import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

/// Pushes [page] with a subtle fade + upward slide transition instead of the
/// platform default, for a more consistent "app-like" navigation feel.
Future<T?> pushSlide<T>(BuildContext context, Widget page) {
  return Navigator.of(context).push<T>(
    PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: AppMotion.scaled(context, AppMotion.pageIn),
      reverseTransitionDuration: AppMotion.scaled(context, AppMotion.pageOut),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: AppMotion.curveOut,
          reverseCurve: AppMotion.curveIn,
        );
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
