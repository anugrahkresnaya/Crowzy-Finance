import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Motion language: calm and deliberate, no bounce or overshoot, nothing loops
/// except loading states. Every duration and curve in the app comes from here.
class AppMotion {
  AppMotion._();

  // Curves: exits are quicker than entrances.
  static const Curve curveOut = Curves.easeOutCubic;
  static const Curve curveIn = Curves.easeInCubic;

  // Core durations.
  static const Duration fast = Duration(milliseconds: 150); // press, color
  static const Duration base = Duration(milliseconds: 250); // expand, list row
  static const Duration slow = Duration(milliseconds: 400); // screen entrances
  static const Duration signature = Duration(milliseconds: 1000); // receipt print

  // Navigation and sheets.
  static const Duration pageIn = Duration(milliseconds: 400);
  static const Duration pageOut = Duration(milliseconds: 300);
  static const Duration sheetIn = Duration(milliseconds: 400);
  static const Duration sheetOut = Duration(milliseconds: 300);
  static const Duration scrimIn = Duration(milliseconds: 250);
  static const Duration navGlide = Duration(milliseconds: 480);
  static const Duration panelSlide = Duration(milliseconds: 520);
  static const Duration iconColor = Duration(milliseconds: 320);

  // Data visuals.
  static const Duration barGrow = Duration(milliseconds: 500);
  static const Duration barStep = Duration(milliseconds: 25);
  static const Duration fill = Duration(milliseconds: 700);
  static const Duration countUp = Duration(milliseconds: 900);

  // Receipt slip.
  static const Duration slipReveal = Duration(milliseconds: 700);
  static const Duration slipRevealDelay = Duration(milliseconds: 380);
  static const Duration slipLineStep = Duration(milliseconds: 80);
  static const Duration slipFeed = signature;
  static const Duration stampIn = Duration(milliseconds: 260);

  // Staggered lists: 40 ms per row, capped so deep rows never wait.
  static const Duration staggerStep = Duration(milliseconds: 40);
  static const int maxStaggered = 8;

  /// Entrance delay for the row at [index], capped at [maxStaggered] rows.
  static Duration stagger(int index) =>
      staggerStep * math.min(math.max(index, 0), maxStaggered);

  /// How bottom sheets open and close: up over [sheetIn], down over the quicker
  /// [sheetOut] with an ease-in. Instant when motion is reduced.
  static AnimationStyle sheetAnimation(BuildContext context) {
    if (reduced(context)) return AnimationStyle.noAnimation;
    return const AnimationStyle(
      duration: sheetIn,
      reverseDuration: sheetOut,
      curve: curveOut,
      reverseCurve: curveIn,
    );
  }

  /// Whether the user asked the system to reduce motion.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// [duration], or [Duration.zero] when motion is reduced.
  static Duration scaled(BuildContext context, Duration duration) =>
      reduced(context) ? Duration.zero : duration;
}
