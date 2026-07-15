import '../../../core/utils/date_formatter.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction_type.dart';

class MonthlySummary {
  const MonthlySummary({this.totalIncome = 0, this.totalExpense = 0});

  final double totalIncome;
  final double totalExpense;

  double get net => totalIncome - totalExpense;
}

class CategoryBreakdownEntry {
  const CategoryBreakdownEntry({
    required this.category,
    required this.total,
    required this.percentage,
  });

  final CategoryModel? category;
  final double total;
  final double percentage;
}

class DayActivity {
  const DayActivity({this.hasIncome = false, this.hasExpense = false});

  final bool hasIncome;
  final bool hasExpense;
}

class WeeklyBucket {
  const WeeklyBucket({
    required this.weekStart,
    required this.totalIncome,
    required this.totalExpense,
    required this.expenseByCategory,
  });

  final DateTime weekStart;
  final double totalIncome;
  final double totalExpense;
  final Map<String, double> expenseByCategory;
}

class MonthlyBucket {
  const MonthlyBucket({
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.expenseByCategory,
  });

  final DateTime month;
  final double totalIncome;
  final double totalExpense;
  final Map<String, double> expenseByCategory;
}

class ReportRepository {
  const ReportRepository();

  List<TransactionModel> transactionsForMonth(List<TransactionModel> all, DateTime month) {
    return all
        .where((t) => t.date.year == month.year && t.date.month == month.month)
        .toList();
  }

  MonthlySummary summarize(List<TransactionModel> transactions) {
    var income = 0.0;
    var expense = 0.0;
    for (final t in transactions) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }
    return MonthlySummary(totalIncome: income, totalExpense: expense);
  }

  List<CategoryBreakdownEntry> breakdownByCategory(
    List<TransactionModel> transactions,
    List<CategoryModel> categories,
    TransactionType type,
  ) {
    final categoryById = {for (final c in categories) c.id: c};
    final totals = <String, double>{};
    for (final t in transactions.where((t) => t.type == type)) {
      totals[t.categoryId] = (totals[t.categoryId] ?? 0) + t.amount;
    }
    final grandTotal = totals.values.fold(0.0, (a, b) => a + b);

    final entries = totals.entries
        .map(
          (e) => CategoryBreakdownEntry(
            category: categoryById[e.key],
            total: e.value,
            percentage: grandTotal == 0 ? 0 : (e.value / grandTotal) * 100,
          ),
        )
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));
    return entries;
  }

  Map<DateTime, DayActivity> calendarMarkers(List<TransactionModel> transactions) {
    final markers = <DateTime, DayActivity>{};
    for (final t in transactions) {
      final day = DateTime(t.date.year, t.date.month, t.date.day);
      final existing = markers[day] ?? const DayActivity();
      markers[day] = DayActivity(
        hasIncome: existing.hasIncome || t.type == TransactionType.income,
        hasExpense: existing.hasExpense || t.type == TransactionType.expense,
      );
    }
    return markers;
  }

  double percentChange(double previous, double current) {
    if (previous == 0) return current == 0 ? 0 : 100;
    return ((current - previous) / previous.abs()) * 100;
  }

  /// Last [weeks] Mon-Sun buckets ending with the current week, oldest first.
  /// Every week in range is included (zero-filled) so callers get a complete,
  /// evenly-spaced series regardless of transaction gaps.
  List<WeeklyBucket> weeklyBuckets(
    List<TransactionModel> all,
    List<CategoryModel> categories, {
    int weeks = 8,
    DateTime? now,
  }) {
    final categoryById = {for (final c in categories) c.id: c};
    final currentWeekStart = _startOfWeek(now ?? DateTime.now());
    final oldestWeekStart = currentWeekStart.subtract(Duration(days: 7 * (weeks - 1)));

    final byWeek = <DateTime, List<TransactionModel>>{};
    for (final t in all) {
      final weekStart = _startOfWeek(t.date);
      if (weekStart.isBefore(oldestWeekStart) || weekStart.isAfter(currentWeekStart)) continue;
      (byWeek[weekStart] ??= []).add(t);
    }

    return [
      for (var i = 0; i < weeks; i++)
        _bucketFor(
          oldestWeekStart.add(Duration(days: 7 * i)),
          byWeek,
          categoryById,
          (weekStart, income, expense, byCategory) =>
              WeeklyBucket(weekStart: weekStart, totalIncome: income, totalExpense: expense, expenseByCategory: byCategory),
        ),
    ];
  }

  /// Last [months] calendar-month buckets ending with the current month,
  /// oldest first. Every month in range is included (zero-filled).
  List<MonthlyBucket> monthlyBuckets(
    List<TransactionModel> all,
    List<CategoryModel> categories, {
    int months = 12,
    DateTime? now,
  }) {
    final categoryById = {for (final c in categories) c.id: c};
    final currentMonth = DateFormatter.startOfMonth(now ?? DateTime.now());
    final oldestMonth = DateTime(currentMonth.year, currentMonth.month - (months - 1));

    final byMonth = <DateTime, List<TransactionModel>>{};
    for (final t in all) {
      final month = DateFormatter.startOfMonth(t.date);
      if (month.isBefore(oldestMonth) || month.isAfter(currentMonth)) continue;
      (byMonth[month] ??= []).add(t);
    }

    return [
      for (var i = 0; i < months; i++)
        _bucketFor(
          DateTime(oldestMonth.year, oldestMonth.month + i),
          byMonth,
          categoryById,
          (month, income, expense, byCategory) =>
              MonthlyBucket(month: month, totalIncome: income, totalExpense: expense, expenseByCategory: byCategory),
        ),
    ];
  }

  T _bucketFor<T>(
    DateTime bucketStart,
    Map<DateTime, List<TransactionModel>> grouped,
    Map<String, CategoryModel> categoryById,
    T Function(DateTime bucketStart, double income, double expense, Map<String, double> expenseByCategory) build,
  ) {
    final transactions = grouped[bucketStart] ?? const [];
    var income = 0.0;
    var expense = 0.0;
    final expenseByCategory = <String, double>{};
    for (final t in transactions) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        expense += t.amount;
        final name = categoryById[t.categoryId]?.name ?? 'Uncategorized';
        expenseByCategory[name] = (expenseByCategory[name] ?? 0) + t.amount;
      }
    }
    return build(bucketStart, income, expense, expenseByCategory);
  }

  DateTime _startOfWeek(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.subtract(Duration(days: day.weekday - 1));
  }
}
