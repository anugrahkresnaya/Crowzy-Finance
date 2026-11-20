import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';

/// Three softly pulsing dots in an assistant bubble: the assistant is working
/// on an answer. This is a loading state, so it is the one place a motion
/// loops; with reduced motion the dots simply sit still.
class ThinkingDots extends StatelessWidget {
  const ThinkingDots({super.key});

  static const _pulse = Duration(milliseconds: 600);
  static const _offset = Duration(milliseconds: 160);

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Semantics(
        label: 'The assistant is thinking',
        liveRegion: true,
        child: ExcludeSemantics(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.hairlineSoft),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(6),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  _dot(reduced, i),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dot(bool reduced, int index) {
    final dot = Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(color: AppColors.textLabel, shape: BoxShape.circle),
    );
    if (reduced) return Opacity(opacity: 0.6, child: dot);

    return dot
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
          delay: _offset * index,
        )
        .fade(begin: 0.25, end: 1, duration: _pulse, curve: Curves.easeInOut);
  }
}
