import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../../../core/widgets/press_scale.dart';
import '../../../../data/models/wishlist_model.dart';

/// Compact goal summary for Home: the goal's name, how far along it is, and a
/// thin progress line. Tapping opens the wishlist.
class GoalHighlightTile extends StatelessWidget {
  const GoalHighlightTile({super.key, required this.goal, required this.onTap});

  final WishlistModel goal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = goal.targetAmount > 0
        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;

    return PressScale(
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.hairlineSoft),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.name.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.eyebrow(context, color: AppColors.textMuted),
                ),
                const SizedBox(height: 2),
                Text('${(progress * 100).round()}%', style: AppText.amount(context, size: 28)),
                const SizedBox(height: 8),
                AppProgressBar(value: progress, semanticLabel: '${goal.name} progress'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
