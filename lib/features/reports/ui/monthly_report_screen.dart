import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../providers/report_provider.dart';
import 'widgets/mom_comparison_card.dart';
import 'widgets/report_calendar_view.dart';
import 'widgets/report_list_view.dart';

class MonthlyReportScreen extends ConsumerStatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  ConsumerState<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends ConsumerState<MonthlyReportScreen> {
  bool _showCalendar = false;

  @override
  Widget build(BuildContext context) {
    final month = ref.watch(selectedReportMonthProvider);
    final summary = ref.watch(monthSummaryProvider);
    final previousSummary = ref.watch(previousMonthSummaryProvider);
    final reportRepository = ref.watch(reportRepositoryProvider);
    final incomeBreakdown = ref.watch(incomeBreakdownProvider);
    final expenseBreakdown = ref.watch(expenseBreakdownProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Report')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () =>
                      ref.read(selectedReportMonthProvider.notifier).previous(),
                ),
                Text(
                  DateFormatter.monthYear(month),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: month.year == DateTime.now().year &&
                          month.month == DateTime.now().month
                      ? null
                      : () => ref.read(selectedReportMonthProvider.notifier).next(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            MomComparisonCard(
              current: summary,
              incomeChangePercent: reportRepository.percentChange(
                previousSummary.totalIncome,
                summary.totalIncome,
              ),
              expenseChangePercent: reportRepository.percentChange(
                previousSummary.totalExpense,
                summary.totalExpense,
              ),
              netChangePercent:
                  reportRepository.percentChange(previousSummary.net, summary.net),
            ),
            const SizedBox(height: 16),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('List'), icon: Icon(Icons.list)),
                ButtonSegment(
                    value: true,
                    label: Text('Calendar'),
                    icon: Icon(Icons.calendar_month)),
              ],
              selected: {_showCalendar},
              onSelectionChanged: (selection) =>
                  setState(() => _showCalendar = selection.first),
            ),
            const SizedBox(height: 12),
            if (_showCalendar)
              const ReportCalendarView()
            else
              SizedBox(
                height: 400,
                child: const ReportListView(),
              ),
            const SizedBox(height: 24),
            if (incomeBreakdown.isNotEmpty) ...[
              Text('Income by Category', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: incomeBreakdown
                        .map(
                          (entry) => ListTile(
                            title: Text(entry.category?.name ?? 'Uncategorized'),
                            trailing: Text(
                              '${CurrencyFormatter.format(entry.total)} (${entry.percentage.toStringAsFixed(0)}%)',
                              style: const TextStyle(
                                color: AppColors.income,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (expenseBreakdown.isNotEmpty) ...[
              Text('Expense by Category', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: expenseBreakdown
                        .map(
                          (entry) => ListTile(
                            title: Text(entry.category?.name ?? 'Uncategorized'),
                            trailing: Text(
                              '${CurrencyFormatter.format(entry.total)} (${entry.percentage.toStringAsFixed(0)}%)',
                              style: const TextStyle(
                                color: AppColors.expense,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
