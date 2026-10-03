import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../../../core/widgets/press_scale.dart';
import '../../../../data/models/wishlist_model.dart';

class WishlistTile extends StatelessWidget {
  const WishlistTile({
    super.key,
    required this.goal,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final WishlistModel goal;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isCompleted = goal.isCompleted;
    final isExpired = goal.isExpired;
    final deEmphasized = isCompleted || isExpired;
    final progress = goal.targetAmount > 0
        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final textTheme = Theme.of(context).textTheme;

    return Opacity(
      opacity: deEmphasized ? 0.65 : 1.0,
      child: PressScale(
        enabled: !isCompleted && onTap != null,
        child: Material(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColors.hairlineSoft),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: isCompleted ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          goal.name,
                          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                      if (isCompleted)
                        const _Badge(label: 'Goal reached', color: AppColors.income)
                      else if (isExpired)
                        const _Badge(label: 'Deadline passed', color: AppColors.textMuted),
                      if (onEdit != null)
                        IconButton(
                          tooltip: 'Edit',
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          color: AppColors.textFaint,
                          onPressed: onEdit,
                        ),
                      if (onDelete != null)
                        IconButton(
                          tooltip: 'Delete',
                          icon: const Icon(Icons.delete_outline, size: 20),
                          color: AppColors.textFaint,
                          onPressed: onDelete,
                        ),
                      const SizedBox(width: 6),
                      Text('${(progress * 100).round()}%', style: AppText.amount(context, size: 22)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${CurrencyFormatter.format(goal.currentAmount)} of '
                        '${CurrencyFormatter.format(goal.targetAmount)}',
                        style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                      ),
                      if (goal.deadline != null)
                        Text(
                          DateFormatter.day(goal.deadline!),
                          style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppProgressBar(
                    value: progress,
                    color: isCompleted ? AppColors.income : AppColors.brass,
                    semanticLabel: '${goal.name} progress',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
