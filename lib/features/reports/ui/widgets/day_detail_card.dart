import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';

/// What was spent on the selected day, and how that compares with an average
/// day this month.
class DayDetailCard extends StatelessWidget {
  const DayDetailCard({
    super.key,
    required this.date,
    required this.amount,
    required this.average,
    required this.isBiggestDay,
    this.onTap,
  });

  final DateTime date;
  final double amount;
  final double average;
  final bool isBiggestDay;

  /// Opens the day's receipt, when provided (shown as a chevron).
  final VoidCallback? onTap;

  /// "0,8× your daily average", with a decimal comma.
  static String multiplierText(double amount, double average) {
    if (amount <= 0) return 'No spending this day';
    if (average <= 0) return '';
    return '${(amount / average).toStringAsFixed(1).replaceAll('.', ',')}× your daily average';
  }

  @override
  Widget build(BuildContext context) {
    final note = [
      multiplierText(amount, average),
      if (isBiggestDay && amount > 0) 'biggest day',
    ].where((s) => s.isNotEmpty).join(' · ');

    return Material(
      color: AppColors.hero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.brassOutline),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormatter.dayLong(date).toUpperCase(),
                      style: AppText.eyebrow(context),
                    ),
                    if (note.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        note,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textSoft),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                amount > 0 ? CurrencyFormatter.signed(amount, income: false) : '0',
                style: AppText.amount(
                  context,
                  size: 26,
                  color: amount > 0 ? AppColors.expense : AppColors.textMuted,
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textLabel),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
