import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../repository/report_repository.dart';

class MomComparisonCard extends StatelessWidget {
  const MomComparisonCard({
    super.key,
    required this.current,
    required this.incomeChangePercent,
    required this.expenseChangePercent,
    required this.netChangePercent,
  });

  final MonthlySummary current;
  final double incomeChangePercent;
  final double expenseChangePercent;
  final double netChangePercent;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('vs Last Month', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 12),
            _ComparisonRow(
              label: 'Income',
              amount: current.totalIncome,
              changePercent: incomeChangePercent,
              color: AppColors.income,
            ),
            const SizedBox(height: 8),
            _ComparisonRow(
              label: 'Expense',
              amount: current.totalExpense,
              changePercent: expenseChangePercent,
              color: AppColors.expense,
            ),
            const SizedBox(height: 8),
            _ComparisonRow(
              label: 'Net',
              amount: current.net,
              changePercent: netChangePercent,
              color: current.net >= 0 ? AppColors.income : AppColors.expense,
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    required this.label,
    required this.amount,
    required this.changePercent,
    required this.color,
  });

  final String label;
  final double amount;
  final double changePercent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isUp = changePercent >= 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              CurrencyFormatter.format(amount),
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Icon(
              isUp ? Icons.arrow_upward : Icons.arrow_downward,
              size: 14,
              color: isUp ? AppColors.income : AppColors.expense,
            ),
            Text(
              '${changePercent.abs().toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}
