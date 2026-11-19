import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/icon_mapper.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../../../data/models/category_model.dart';
import '../../../budgets/utils/category_spend.dart';

/// A category with this month's total. For expense categories the row also
/// shows the optional monthly limit and how much of it has been used; the bar
/// turns terracotta once 85% is reached.
class CategoryRow extends StatelessWidget {
  const CategoryRow({
    super.key,
    required this.category,
    required this.amount,
    required this.onTap,
    this.limit,
    this.showLimit = true,
    this.trailing,
  });

  /// At this share of the limit the row starts to warn.
  static const warnAt = 0.85;

  final CategoryModel category;

  /// This month's total for the category.
  final double amount;

  /// The monthly limit, when one is set.
  final double? limit;

  /// Whether to show limit information at all (income categories do not).
  final bool showLimit;
  final VoidCallback onTap;

  /// Extra control at the end of the row, e.g. an edit/delete menu.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final used = showLimit ? limitUsed(amount, limit) : null;
    final warning = used != null && used >= warnAt;
    final isIncome = !showLimit;

    final amountColor = isIncome
        ? AppColors.income
        : warning
            ? AppColors.expense
            : AppColors.ivory;
    final caption = !showLimit
        ? 'this month'
        : limit == null
            ? 'no limit set'
            : 'of ${CurrencyFormatter.number(limit!)}';

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(2, 14, 2, 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.divider)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.hairline),
                    ),
                    child: Icon(IconMapper.iconFor(category.icon), size: 19, color: AppColors.brass),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.number(amount),
                        style: AppText.amount(context, color: amountColor),
                      ),
                      Text(caption, style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                  ?trailing,
                ],
              ),
              if (used != null)
                Padding(
                  padding: const EdgeInsets.only(left: 56, top: 10),
                  child: AppProgressBar(
                    value: math.min(used, 1),
                    color: warning ? AppColors.expense : AppColors.brass,
                    semanticLabel: '${category.name} limit used',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
