import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../../../data/models/wishlist_model.dart';

/// The goal in focus, in the same framed card as the balance: how far along it
/// is, the amounts, and a button to add to it.
class FeaturedGoalCard extends StatelessWidget {
  const FeaturedGoalCard({
    super.key,
    required this.goal,
    required this.onAddContribution,
    this.onEdit,
    this.onDelete,
  });

  final WishlistModel goal;
  final VoidCallback onAddContribution;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final progress = goal.targetAmount > 0
        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.hero,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.brassOutline),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 12, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: AppColors.heroBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag_outlined, size: 20, color: AppColors.brass),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    goal.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium,
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    tooltip: 'Edit',
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    color: AppColors.textLabel,
                    onPressed: onEdit,
                  ),
                if (onDelete != null)
                  IconButton(
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: AppColors.textLabel,
                    onPressed: onDelete,
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (goal.deadline != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'BY ${DateFormatter.monthYearShort(goal.deadline!).toUpperCase()}',
                        style: AppText.eyebrow(context),
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('${(progress * 100).round()}%', style: AppText.amount(context, size: 44)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${CurrencyFormatter.format(goal.currentAmount)} of '
                          '${CurrencyFormatter.format(goal.targetAmount)}',
                          style: textTheme.bodySmall?.copyWith(color: AppColors.textLabel),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AppProgressBar(
                    value: progress,
                    height: 4,
                    semanticLabel: '${goal.name} progress',
                  ),
                  const SizedBox(height: 18),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(46)),
                    onPressed: onAddContribution,
                    child: const Text('Add contribution'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
