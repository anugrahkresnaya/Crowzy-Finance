import '../../../data/models/category_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/wishlist_model.dart';
import '../../reports/repository/report_repository.dart';

/// Builds the aggregated payload sent to the `chat-qa` Edge Function. Only
/// summaries/aggregates ever leave the device — never raw transaction rows.
Map<String, dynamic> buildChatContext({
  required List<TransactionModel> transactions,
  required List<CategoryModel> categories,
  required List<WishlistModel> wishlists,
  required double allTimeBalance,
  DateTime? now,
}) {
  const repo = ReportRepository();
  final weekly = repo.weeklyBuckets(transactions, categories, now: now);
  final monthly = repo.monthlyBuckets(transactions, categories, now: now);

  return {
    'current_balance': allTimeBalance,
    'weekly': [
      for (final b in weekly)
        {
          'week_start': b.weekStart.toIso8601String().split('T').first,
          'income': b.totalIncome,
          'expense': b.totalExpense,
          'expense_by_category': b.expenseByCategory,
        },
    ],
    'monthly': [
      for (final b in monthly)
        {
          'month': '${b.month.year}-${b.month.month.toString().padLeft(2, '0')}',
          'income': b.totalIncome,
          'expense': b.totalExpense,
          'expense_by_category': b.expenseByCategory,
        },
    ],
    'wishlist_goals': [
      for (final w in wishlists.where((w) => !w.isDeleted))
        {
          'name': w.name,
          'target_amount': w.targetAmount,
          'current_amount': w.currentAmount,
          'deadline': w.deadline?.toIso8601String().split('T').first,
          'is_completed': w.isCompleted,
        },
    ],
  };
}
