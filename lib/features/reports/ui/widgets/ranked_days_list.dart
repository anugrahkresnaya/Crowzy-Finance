import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../utils/report_stats.dart';

/// The month's biggest spending days. Tap one to look at it.
class RankedDaysList extends StatelessWidget {
  const RankedDaysList({
    super.key,
    required this.month,
    required this.amounts,
    required this.onSelect,
  });

  final DateTime month;
  final List<double> amounts;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final days = topSpendingDays(amounts);
    if (days.isEmpty) {
      return const EmptyState(icon: Icons.bar_chart_rounded, message: 'No spending this month');
    }

    final peak = amounts[days.first - 1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('BIGGEST SPENDING DAYS', style: AppText.eyebrow(context)),
        const SizedBox(height: 6),
        for (final day in days)
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () => onSelect(day),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.divider)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          DateFormatter.dayShort(DateTime(month.year, month.month, day)),
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          CurrencyFormatter.signed(amounts[day - 1], income: false),
                          style: AppText.amount(context, color: AppColors.expense),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AppProgressBar(
                      value: amounts[day - 1] / peak,
                      color: AppColors.expense,
                      semanticLabel: DateFormatter.dayShort(DateTime(month.year, month.month, day)),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
