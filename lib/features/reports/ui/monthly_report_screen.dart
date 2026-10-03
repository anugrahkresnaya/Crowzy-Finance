import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/month_switcher.dart';
import '../providers/report_provider.dart';
import '../utils/report_stats.dart';
import 'widgets/category_breakdown_list.dart';
import 'widgets/day_detail_card.dart';
import 'widgets/expense_comparison_card.dart';
import 'widgets/ranked_days_list.dart';
import 'widgets/report_calendar_grid.dart';
import 'widgets/spending_bars.dart';

enum _ReportView { overview, calendar, days }

class MonthlyReportScreen extends ConsumerStatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  ConsumerState<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends ConsumerState<MonthlyReportScreen> {
  _ReportView _view = _ReportView.overview;

  /// The day picked by the user (1-based); null means "the biggest day".
  int? _day;

  @override
  Widget build(BuildContext context) {
    // A different month starts again from its biggest day.
    ref.listen<DateTime>(selectedReportMonthProvider, (_, _) => setState(() => _day = null));

    final month = ref.watch(selectedReportMonthProvider);
    final summary = ref.watch(monthSummaryProvider);
    final transactions = ref.watch(monthTransactionsProvider);
    final amounts = ref.watch(dailySpendingProvider);
    final notifier = ref.read(selectedReportMonthProvider.notifier);
    final now = DateTime.now();
    final isCurrentMonth = DateFormatter.isSameMonth(month, now);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
          children: [
            Text('Reports', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 32)),
            MonthSwitcher(
              label: DateFormatter.monthYear(month),
              onPrevious: notifier.previous,
              onNext: isCurrentMonth ? null : notifier.next,
            ),
            SegmentedButton<_ReportView>(
              showSelectedIcon: false,
              expandedInsets: EdgeInsets.zero,
              segments: const [
                ButtonSegment(value: _ReportView.overview, label: Text('Overview')),
                ButtonSegment(value: _ReportView.calendar, label: Text('Calendar')),
                ButtonSegment(value: _ReportView.days, label: Text('Days')),
              ],
              selected: {_view},
              onSelectionChanged: (selection) => setState(() => _view = selection.first),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _SummaryTile(
                    label: 'INCOME',
                    amount: summary.totalIncome,
                    color: AppColors.income,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryTile(
                    label: 'EXPENSES',
                    amount: summary.totalExpense,
                    color: AppColors.expense,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (transactions.isEmpty)
              EmptyState(
                icon: Icons.bar_chart_rounded,
                message: 'No transactions in ${DateFormatter.monthYear(month)}',
              )
            else
              AnimatedSwitcher(
                duration: AppMotion.scaled(context, AppMotion.base),
                switchInCurve: AppMotion.curveOut,
                switchOutCurve: AppMotion.curveIn,
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.topCenter,
                  children: [...previous, ?current],
                ),
                child: KeyedSubtree(
                  key: ValueKey(_view),
                  child: _content(context, month: month, amounts: amounts),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, {required DateTime month, required List<double> amounts}) {
    final peak = peakDay(amounts);
    final selected = _day ?? peak;
    final average = dailyAverage(amounts, month: month);

    Widget? dayCard() => selected == null
        ? null
        : DayDetailCard(
            date: DateTime(month.year, month.month, selected),
            amount: amounts[selected - 1],
            average: average,
            isBiggestDay: selected == peak,
          );

    void select(int day) => setState(() => _day = day);

    switch (_view) {
      case _ReportView.overview:
        return _overview(context, month, amounts, selected, dayCard(), select);
      case _ReportView.calendar:
        return Column(
          children: [
            _Panel(
              child: ReportCalendarGrid(
                month: month,
                amounts: amounts,
                selectedDay: selected,
                onSelect: select,
              ),
            ),
            if (dayCard() case final card?) ...[const SizedBox(height: 12), card],
          ],
        );
      case _ReportView.days:
        return RankedDaysList(
          month: month,
          amounts: amounts,
          onSelect: (day) => setState(() {
            _day = day;
            _view = _ReportView.overview;
          }),
        );
    }
  }

  Widget _overview(
    BuildContext context,
    DateTime month,
    List<double> amounts,
    int? selected,
    Widget? dayCard,
    ValueChanged<int> select,
  ) {
    final expenseBreakdown = ref.watch(expenseBreakdownProvider);
    final incomeBreakdown = ref.watch(incomeBreakdownProvider);
    final summary = ref.watch(monthSummaryProvider);
    final previous = ref.watch(previousMonthSummaryProvider);
    final repository = ref.watch(reportRepositoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Panel(
          child: SpendingBars(
            key: ValueKey(month),
            amounts: amounts,
            month: month,
            selectedDay: selected,
            onSelect: select,
          ),
        ),
        if (dayCard != null) ...[const SizedBox(height: 12), dayCard],
        if (expenseBreakdown.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('BY CATEGORY', style: AppText.eyebrow(context)),
          const SizedBox(height: 4),
          CategoryBreakdownList(entries: expenseBreakdown),
        ],
        if (incomeBreakdown.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('INCOME BY CATEGORY', style: AppText.eyebrow(context)),
          const SizedBox(height: 4),
          CategoryBreakdownList(entries: incomeBreakdown),
        ],
        if (previous.totalExpense > 0) ...[
          const SizedBox(height: 16),
          ExpenseComparisonCard(
            previousMonthName: DateFormatter.monthName(DateFormatter.previousMonth(month)),
            changePercent: repository.percentChange(previous.totalExpense, summary.totalExpense),
          ),
        ],
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.amount, required this.color});

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.eyebrow(context, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.number(amount),
              style: AppText.amount(context, size: 24, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.hairlineSoft),
      ),
      child: child,
    );
  }
}
