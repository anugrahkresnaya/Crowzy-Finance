import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction_type.dart';

/// Expenses for each day of [month], index 0 being the 1st. Days with no
/// spending are 0.
List<double> dailyExpenses(Iterable<TransactionModel> transactions, DateTime month) {
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  final amounts = List<double>.filled(daysInMonth, 0);

  for (final t in transactions) {
    if (t.type != TransactionType.expense || !DateFormatter.isSameMonth(t.date, month)) continue;
    amounts[t.date.day - 1] += t.amount;
  }
  return amounts;
}

/// The day (1-based) with the highest spending, or null when nothing was spent.
/// Ties go to the earliest day.
int? peakDay(List<double> amounts) {
  var best = 0.0;
  int? day;
  for (var i = 0; i < amounts.length; i++) {
    if (amounts[i] > best) {
      best = amounts[i];
      day = i + 1;
    }
  }
  return day;
}

/// Average spending per day. For the month in progress only the days so far
/// count, so a young month is not dragged down by days that have not happened.
double dailyAverage(List<double> amounts, {required DateTime month, DateTime? now}) {
  final today = now ?? DateTime.now();
  final elapsed = DateFormatter.isSameMonth(month, today)
      ? today.day.clamp(1, amounts.length)
      : amounts.length;
  if (elapsed == 0) return 0;

  final total = amounts.take(elapsed).fold(0.0, (a, b) => a + b);
  return total / elapsed;
}

/// Day numbers (1-based) ranked by spending, highest first, leaving out days
/// with none. Ties go to the earlier day.
List<int> topSpendingDays(List<double> amounts, {int limit = 6}) {
  final days = [
    for (var i = 0; i < amounts.length; i++)
      if (amounts[i] > 0) i + 1,
  ]..sort((a, b) {
      final byAmount = amounts[b - 1].compareTo(amounts[a - 1]);
      return byAmount != 0 ? byAmount : a.compareTo(b);
    });
  return days.take(limit).toList();
}

/// "-12%" / "+7%": a whole-number percentage with a true minus sign.
String wholePercent(double percent) {
  final rounded = percent.round();
  return '${rounded < 0 ? '−' : '+'}${rounded.abs()}%';
}
