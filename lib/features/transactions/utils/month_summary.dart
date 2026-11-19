import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction_type.dart';

/// Income, expenses and net result of one calendar month.
class MonthSummary {
  const MonthSummary({
    required this.income,
    required this.expense,
    required this.changePercent,
  });

  final double income;
  final double expense;

  /// How much the balance grew (or shrank) this month relative to where it
  /// started, as a percentage. Null when the month started with no positive
  /// balance, since a percentage of zero or less would be meaningless.
  final double? changePercent;

  double get net => income - expense;
}

MonthSummary summarizeMonth(Iterable<TransactionModel> all, DateTime month) {
  final start = DateFormatter.startOfMonth(month);
  var income = 0.0;
  var expense = 0.0;
  var startingBalance = 0.0;

  for (final transaction in all) {
    final signed = transaction.type == TransactionType.income
        ? transaction.amount
        : -transaction.amount;

    if (transaction.date.isBefore(start)) {
      startingBalance += signed;
    } else if (DateFormatter.isSameMonth(transaction.date, month)) {
      if (signed >= 0) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }
  }

  final net = income - expense;
  return MonthSummary(
    income: income,
    expense: expense,
    changePercent: startingBalance > 0 ? net / startingBalance * 100 : null,
  );
}
