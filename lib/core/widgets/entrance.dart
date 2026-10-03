import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_motion.dart';

extension Entrance on Widget {
  /// Fades and slides this widget in once, using the shared motion tokens.
  ///
  /// Rows in a list pass their [index] so entrances stagger (capped, see
  /// [AppMotion.stagger]); [delay] offsets the whole sequence. Returns the
  /// widget unchanged when the system asks to reduce motion.
  Widget entrance(
    BuildContext context, {
    int index = 0,
    Duration delay = Duration.zero,
    Duration duration = AppMotion.base,
    Axis axis = Axis.vertical,
  }) {
    if (AppMotion.reduced(context)) return this;

    final begin = axis == Axis.vertical ? const Offset(0, 0.04) : const Offset(0.03, 0);
    return animate(delay: delay + AppMotion.stagger(index))
        .fadeIn(duration: duration, curve: AppMotion.curveOut)
        .slide(begin: begin, end: Offset.zero, duration: duration, curve: AppMotion.curveOut);
  }
}
