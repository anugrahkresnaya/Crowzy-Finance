import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
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

    return Opacity(
      opacity: deEmphasized ? 0.6 : 1.0,
      child: Card(
        child: InkWell(
          onTap: isCompleted ? null : onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        goal.name,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (isCompleted)
                      _Badge(label: 'Goal reached', color: AppColors.income)
                    else if (isExpired)
                      _Badge(
                        label: 'Deadline passed',
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    if (onEdit != null)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: onEdit,
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: onDelete,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.seed.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(
                      isCompleted ? AppColors.income : AppColors.seed,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${CurrencyFormatter.format(goal.currentAmount)} / '
                      '${CurrencyFormatter.format(goal.targetAmount)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (goal.deadline != null)
                      Text(
                        DateFormatter.day(goal.deadline!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                  ],
                ),
              ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
