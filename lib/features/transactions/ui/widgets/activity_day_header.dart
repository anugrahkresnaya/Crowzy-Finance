import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../utils/activity_feed.dart';

/// The line above a day's entries: the day, and what it came to. A day with
/// only transfers has nothing to total.
class ActivityDayHeader extends StatelessWidget {
  const ActivityDayHeader({super.key, required this.day});

  final ActivityDay day;

  @override
  Widget build(BuildContext context) {
    final net = day.net;
    final color = net > 0
        ? AppColors.income
        : net < 0
            ? AppColors.expense
            : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.fromLTRB(2, 18, 2, 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.hairline)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            DateFormatter.relativeDayLong(day.day).toUpperCase(),
            style: AppText.eyebrow(context, color: AppColors.textMuted),
          ),
          if (day.hasTotal)
            Text(
              CurrencyFormatter.signed(net.abs(), income: net >= 0),
              style: AppText.amount(context, size: 16, color: color),
            ),
        ],
      ),
    );
  }
}
