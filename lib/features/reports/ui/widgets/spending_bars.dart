import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';

/// One bar per day of the month. Tap a bar to select that day. Bars grow in on
/// first show (give the widget a key per month to replay that on a month
/// change); selecting a day does not replay it.
class SpendingBars extends StatelessWidget {
  const SpendingBars({
    super.key,
    required this.amounts,
    required this.month,
    required this.selectedDay,
    required this.onSelect,
  });

  /// Spending for each day, index 0 being the 1st.
  final List<double> amounts;
  final DateTime month;

  /// The selected day, 1-based.
  final int? selectedDay;
  final ValueChanged<int> onSelect;

  static const _height = 90.0;
  static const _minBar = 3.0;

  @override
  Widget build(BuildContext context) {
    final peak = amounts.fold(0.0, math.max);
    final reduced = AppMotion.reduced(context);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('SPENDING BY DAY', style: AppText.eyebrow(context, color: AppColors.textMuted)),
            Text('Tap a bar', style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: _height,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.hairline)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < amounts.length; i++)
                Expanded(
                  child: _Bar(
                    day: i + 1,
                    amount: amounts[i],
                    month: month,
                    height: peak == 0 ? _minBar : math.max(_minBar, amounts[i] / peak * (_height - 4)),
                    selected: selectedDay == i + 1,
                    animateIn: !reduced,
                    delay: AppMotion.barStep * i,
                    onTap: () => onSelect(i + 1),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('1', style: textTheme.bodySmall?.copyWith(color: AppColors.textFaint)),
            Text(
              '${(amounts.length / 2).round()}',
              style: textTheme.bodySmall?.copyWith(color: AppColors.textFaint),
            ),
            Text(
              '${amounts.length}',
              style: textTheme.bodySmall?.copyWith(color: AppColors.textFaint),
            ),
          ],
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.day,
    required this.amount,
    required this.month,
    required this.height,
    required this.selected,
    required this.animateIn,
    required this.delay,
    required this.onTap,
  });

  final int day;
  final double amount;
  final DateTime month;
  final double height;
  final bool selected;
  final bool animateIn;
  final Duration delay;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = DateTime(month.year, month.month, day);
    Widget bar = Container(
      height: height,
      decoration: BoxDecoration(
        color: selected ? AppColors.brass : AppColors.brassDim,
        borderRadius: BorderRadius.circular(3),
      ),
    );

    if (animateIn) {
      bar = bar.animate(delay: delay).scaleY(
            begin: 0,
            end: 1,
            alignment: Alignment.bottomCenter,
            duration: AppMotion.barGrow,
            curve: AppMotion.curveOut,
          );
    }

    return Semantics(
      button: true,
      selected: selected,
      label: '${DateFormatter.dayShort(date)}, ${CurrencyFormatter.format(amount)}',
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Align(alignment: Alignment.bottomCenter, child: bar),
        ),
      ),
    );
  }
}
