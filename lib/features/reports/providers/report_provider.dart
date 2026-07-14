import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction_type.dart';
import '../../categories/providers/category_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../repository/report_repository.dart';

part 'report_provider.g.dart';

@riverpod
ReportRepository reportRepository(Ref ref) => const ReportRepository();

@riverpod
class SelectedReportMonth extends _$SelectedReportMonth {
  @override
  DateTime build() => DateFormatter.startOfMonth(DateTime.now());

  void next() => state = DateFormatter.nextMonth(state);
  void previous() => state = DateFormatter.previousMonth(state);
}

@riverpod
List<TransactionModel> monthTransactions(Ref ref) {
  final month = ref.watch(selectedReportMonthProvider);
  final all = ref.watch(transactionListProvider).value ?? const [];
  return ref.watch(reportRepositoryProvider).transactionsForMonth(all, month);
}

@riverpod
MonthlySummary monthSummary(Ref ref) {
  final transactions = ref.watch(monthTransactionsProvider);
  return ref.watch(reportRepositoryProvider).summarize(transactions);
}

@riverpod
MonthlySummary previousMonthSummary(Ref ref) {
  final month = ref.watch(selectedReportMonthProvider);
  final previousMonth = DateFormatter.previousMonth(month);
  final all = ref.watch(transactionListProvider).value ?? const [];
  final repository = ref.watch(reportRepositoryProvider);
  return repository.summarize(repository.transactionsForMonth(all, previousMonth));
}

@riverpod
List<CategoryBreakdownEntry> incomeBreakdown(Ref ref) {
  final transactions = ref.watch(monthTransactionsProvider);
  final categories = ref.watch(categoryListProvider).value ?? const [];
  return ref
      .watch(reportRepositoryProvider)
      .breakdownByCategory(transactions, categories, TransactionType.income);
}

@riverpod
List<CategoryBreakdownEntry> expenseBreakdown(Ref ref) {
  final transactions = ref.watch(monthTransactionsProvider);
  final categories = ref.watch(categoryListProvider).value ?? const [];
  return ref
      .watch(reportRepositoryProvider)
      .breakdownByCategory(transactions, categories, TransactionType.expense);
}

@riverpod
Map<DateTime, DayActivity> reportCalendarMarkers(Ref ref) {
  final transactions = ref.watch(monthTransactionsProvider);
  return ref.watch(reportRepositoryProvider).calendarMarkers(transactions);
}
