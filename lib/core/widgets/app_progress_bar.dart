import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';

/// Thin progress line that fills in from empty the first time it is shown and
/// eases to any later value. [value] is a fraction from 0 to 1.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    this.color = AppColors.brass,
    this.height = 3,
    this.semanticLabel,
  });

  final double value;
  final Color color;
  final double height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final target = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);

    return Semantics(
      label: semanticLabel,
      value: '${(target * 100).round()}%',
      child: ExcludeSemantics(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: ColoredBox(
              color: AppColors.track,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: target),
                duration: AppMotion.scaled(context, AppMotion.fill),
                curve: AppMotion.curveOut,
                builder: (context, fraction, _) => Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: fraction,
                    child: ColoredBox(color: color, child: SizedBox(height: height)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
