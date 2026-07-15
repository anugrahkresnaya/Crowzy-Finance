import '../../../core/utils/date_formatter.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction_type.dart';
import '../../reports/repository/report_repository.dart';

/// The aggregated payload sent to the `passive-insights` Edge Function, plus
/// a client-only fingerprint used to decide whether a cached insight is
/// still valid. Only summaries ever leave the device — never raw rows.
class PassiveInsightContext {
  const PassiveInsightContext({required this.payload, required this.fingerprint});

  final Map<String, dynamic> payload;
  final String fingerprint;
}

PassiveInsightContext buildPassiveInsightContext({
  required List<TransactionModel> transactions,
  required List<CategoryModel> categories,
  DateTime? now,
}) {
  const repo = ReportRepository();
  final currentMonth = now ?? DateTime.now();
  final lastMonth = DateFormatter.previousMonth(currentMonth);

  final thisMonthTx = repo.transactionsForMonth(transactions, currentMonth);
  final lastMonthTx = repo.transactionsForMonth(transactions, lastMonth);

  final thisMonthSummary = repo.summarize(thisMonthTx);
  final lastMonthSummary = repo.summarize(lastMonthTx);

  final thisMonthByCategory = repo.breakdownByCategory(thisMonthTx, categories, TransactionType.expense);
  final lastMonthByCategory = repo.breakdownByCategory(lastMonthTx, categories, TransactionType.expense);

  Map<String, double> categoryTotals(List<CategoryBreakdownEntry> entries) => {
        for (final e in entries) (e.category?.name ?? 'Uncategorized'): e.total,
      };

  final payload = {
    'this_month': {
      'income': thisMonthSummary.totalIncome,
      'expense': thisMonthSummary.totalExpense,
      'expense_by_category': categoryTotals(thisMonthByCategory),
    },
    'last_month': {
      'income': lastMonthSummary.totalIncome,
      'expense': lastMonthSummary.totalExpense,
      'expense_by_category': categoryTotals(lastMonthByCategory),
    },
  };

  return PassiveInsightContext(
    payload: payload,
    fingerprint: _fingerprint(thisMonthTx, lastMonthTx),
  );
}

String _fingerprint(List<TransactionModel> thisMonthTx, List<TransactionModel> lastMonthTx) {
  final all = [...thisMonthTx, ...lastMonthTx];
  final count = all.length;
  final total = all.fold(0.0, (sum, t) => sum + t.amount);
  final latestUpdate = all.isEmpty
      ? 0
      : all.map((t) => t.updatedAt.millisecondsSinceEpoch).reduce((a, b) => a > b ? a : b);
  return '$count:$total:$latestUpdate';
}
