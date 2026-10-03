import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';

/// A month as a grid of days (weeks start on Monday). Each day with spending
/// carries a dot whose strength shows how much, relative to the month's
/// biggest day.
class ReportCalendarGrid extends StatelessWidget {
  const ReportCalendarGrid({
    super.key,
    required this.month,
    required this.amounts,
    required this.selectedDay,
    required this.onSelect,
  });

  final DateTime month;
  final List<double> amounts;
  final int? selectedDay;
  final ValueChanged<int> onSelect;

  static const _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  /// Empty cells before the 1st so it lands under the right weekday.
  static int leadingBlanks(DateTime month) => DateTime(month.year, month.month, 1).weekday - 1;

  static Color levelColor(double amount, double peak) {
    if (peak <= 0) return AppColors.brassDim;
    final share = amount / peak;
    if (share > 0.5) return AppColors.brass;
    if (share > 0.2) return AppColors.brassMid;
    return AppColors.brassDim;
  }

  @override
  Widget build(BuildContext context) {
    final peak = amounts.fold(0.0, math.max);
    final blanks = leadingBlanks(month);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Row(
          children: [
            for (final label in _weekdays)
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textFaint,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        GridView.count(
          crossAxisCount: 7,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          childAspectRatio: 0.9,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (var i = 0; i < blanks; i++) const SizedBox.shrink(),
            for (var day = 1; day <= amounts.length; day++)
              _DayCell(
                day: day,
                date: DateTime(month.year, month.month, day),
                amount: amounts[day - 1],
                dotColor: amounts[day - 1] > 0 ? levelColor(amounts[day - 1], peak) : null,
                selected: selectedDay == day,
                onTap: () => onSelect(day),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text('Less', style: textTheme.bodySmall?.copyWith(color: AppColors.textFaint)),
            const SizedBox(width: 8),
            for (final color in [AppColors.brassDim, AppColors.brassMid, AppColors.brass]) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
            ],
            Text('More', style: textTheme.bodySmall?.copyWith(color: AppColors.textFaint)),
          ],
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.date,
    required this.amount,
    required this.dotColor,
    required this.selected,
    required this.onTap,
  });

  final int day;
  final DateTime date;
  final double amount;
  final Color? dotColor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '${DateFormatter.dayShort(date)}, ${CurrencyFormatter.format(amount)}',
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: selected ? AppColors.hero : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: selected ? AppColors.brass : Colors.transparent),
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$day', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 4),
              SizedBox(
                height: 6,
                child: dotColor == null
                    ? null
                    : DecoratedBox(
                        decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                        child: const SizedBox(width: 6, height: 6),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
