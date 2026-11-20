import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction_type.dart';

/// Totals for [month] by category id, for transactions of [type].
Map<String, double> totalsByCategory(
  Iterable<TransactionModel> transactions,
  DateTime month, {
  TransactionType type = TransactionType.expense,
}) {
  final totals = <String, double>{};
  for (final t in transactions) {
    if (t.type != type || !DateFormatter.isSameMonth(t.date, month)) continue;
    totals[t.categoryId] = (totals[t.categoryId] ?? 0) + t.amount;
  }
  return totals;
}

/// How much of a limit has been used, as a fraction (1.0 is exactly on the
/// limit, above 1 is over it). Null when there is no usable limit.
double? limitUsed(double spent, double? limit) {
  if (limit == null || limit <= 0) return null;
  return spent / limit;
}
