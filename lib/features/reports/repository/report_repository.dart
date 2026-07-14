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
}
