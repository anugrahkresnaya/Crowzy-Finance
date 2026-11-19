import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Text styles shared by several widgets that the Material text theme does not
/// cover directly. Both build on the theme so fonts stay in one place.
class AppText {
  AppText._();

  /// Serif figures for money. Lining figures keep digits the same height.
  static TextStyle amount(BuildContext context, {double size = 19, Color? color}) {
    return Theme.of(context).textTheme.titleMedium!.copyWith(
      fontSize: size,
      color: color,
      fontFeatures: const [FontFeature.liningFigures()],
    );
  }

  /// Small letter-spaced label. Callers pass the text already upper-cased.
  static TextStyle eyebrow(BuildContext context, {Color color = AppColors.textLabel}) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 11 * 0.16,
      color: color,
    );
  }
}
