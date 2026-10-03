import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../utils/report_stats.dart';

/// How this month's spending compares with the previous month's.
class ExpenseComparisonCard extends StatelessWidget {
  const ExpenseComparisonCard({
    super.key,
    required this.previousMonthName,
    required this.changePercent,
  });

  /// e.g. "September".
  final String previousMonthName;

  /// Change in expenses versus the previous month; negative means less spending.
  final double changePercent;

  @override
  Widget build(BuildContext context) {
    final lessSpent = changePercent <= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.hero,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.heroBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('VERSUS ${previousMonthName.toUpperCase()}', style: AppText.eyebrow(context)),
                const SizedBox(height: 3),
                Text(
                  lessSpent ? 'You spent less overall' : 'You spent more overall',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Text(
            wholePercent(changePercent),
            style: AppText.amount(
              context,
              size: 26,
              color: lessSpent ? AppColors.income : AppColors.expense,
            ),
          ),
        ],
      ),
    );
  }
}
