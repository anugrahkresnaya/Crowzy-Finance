import 'package:crowzy_finance/data/models/category_model.dart';
import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/features/reports/repository/report_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final repository = const ReportRepository();

  TransactionModel tx({
    required double amount,
    required TransactionType type,
    required DateTime date,
    String categoryId = 'food',
  }) {
    return TransactionModel(
      id: '${date.millisecondsSinceEpoch}-$categoryId-$amount',
      userId: 'u1',
      amount: amount,
      type: type,
      categoryId: categoryId,
      date: date,
      createdAt: date,
      updatedAt: date,
    );
  }

  test('transactionsForMonth filters by year and month', () {
    final transactions = [
      tx(amount: 100, type: TransactionType.expense, date: DateTime(2026, 1, 5)),
      tx(amount: 200, type: TransactionType.expense, date: DateTime(2026, 2, 1)),
    ];

    final result = repository.transactionsForMonth(transactions, DateTime(2026, 1, 1));
    expect(result, hasLength(1));
    expect(result.first.amount, 100);
  });

  test('summarize totals income and expense separately', () {
    final transactions = [
      tx(amount: 1000, type: TransactionType.income, date: DateTime(2026, 1, 5)),
      tx(amount: 300, type: TransactionType.expense, date: DateTime(2026, 1, 6)),
      tx(amount: 200, type: TransactionType.expense, date: DateTime(2026, 1, 7)),
    ];

    final summary = repository.summarize(transactions);
    expect(summary.totalIncome, 1000);
    expect(summary.totalExpense, 500);
    expect(summary.net, 500);
  });

  test('breakdownByCategory groups and computes percentages', () {
    final categories = [
      CategoryModel(
        id: 'food',
        name: 'Food',
        icon: 'restaurant',
        type: TransactionType.expense,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
      CategoryModel(
        id: 'transport',
        name: 'Transport',
        icon: 'directions_car',
        type: TransactionType.expense,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    ];
    final transactions = [
      tx(amount: 300, type: TransactionType.expense, date: DateTime(2026, 1, 1), categoryId: 'food'),
      tx(amount: 100, type: TransactionType.expense, date: DateTime(2026, 1, 2), categoryId: 'transport'),
    ];

    final breakdown =
        repository.breakdownByCategory(transactions, categories, TransactionType.expense);

    expect(breakdown, hasLength(2));
    expect(breakdown.first.category?.name, 'Food');
    expect(breakdown.first.percentage, 75.0);
    expect(breakdown.last.percentage, 25.0);
  });

  test('percentChange handles zero-previous edge cases', () {
    expect(repository.percentChange(0, 0), 0);
    expect(repository.percentChange(0, 100), 100);
    expect(repository.percentChange(100, 150), 50);
    expect(repository.percentChange(100, 50), -50);
  });
}
