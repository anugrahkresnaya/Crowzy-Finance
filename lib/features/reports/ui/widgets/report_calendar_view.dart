import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../categories/providers/category_provider.dart';
import '../../../transactions/ui/widgets/transaction_tile.dart';
import '../../providers/report_provider.dart';

class ReportCalendarView extends ConsumerStatefulWidget {
  const ReportCalendarView({super.key});

  @override
  ConsumerState<ReportCalendarView> createState() => _ReportCalendarViewState();
}

class _ReportCalendarViewState extends ConsumerState<ReportCalendarView> {
  DateTime? _selectedDay;

  void _showDayTransactions(DateTime day) {
    final transactions = ref
        .read(monthTransactionsProvider)
        .where((t) =>
            t.date.year == day.year && t.date.month == day.month && t.date.day == day.day)
        .toList();
    final categories = ref.read(categoryListProvider).value ?? const [];
    final categoryById = {for (final c in categories) c.id: c};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        expand: false,
        builder: (context, controller) => transactions.isEmpty
            ? const Center(child: Text('No transactions on this day'))
            : ListView.builder(
                controller: controller,
                itemCount: transactions.length,
                itemBuilder: (context, index) => TransactionTile(
                  transaction: transactions[index],
                  category: categoryById[transactions[index].categoryId],
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final month = ref.watch(selectedReportMonthProvider);
    final markers = ref.watch(reportCalendarMarkersProvider);
    final focusedDay = DateTime(month.year, month.month, 1);

    return TableCalendar(
      key: ValueKey(month),
      firstDay: DateTime(month.year, month.month, 1),
      lastDay: DateTime(month.year, month.month + 1, 0),
      focusedDay: focusedDay,
      headerVisible: false,
      availableGestures: AvailableGestures.none,
      selectedDayPredicate: (day) => _selectedDay != null && isSameDay(_selectedDay, day),
      onDaySelected: (selected, focused) {
        setState(() => _selectedDay = selected);
        _showDayTransactions(selected);
      },
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          final activity = markers[DateTime(day.year, day.month, day.day)];
          if (activity == null) return null;
          return Positioned(
            bottom: 4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (activity.hasIncome) _dot(AppColors.income),
                if (activity.hasIncome && activity.hasExpense) const SizedBox(width: 2),
                if (activity.hasExpense) _dot(AppColors.expense),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
