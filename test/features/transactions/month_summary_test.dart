import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/features/transactions/utils/month_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var counter = 0;
  TransactionModel tx(DateTime date, double amount, TransactionType type) {
    counter++;
    return TransactionModel(
      id: 't$counter',
      userId: 'u1',
      amount: amount,
      type: type,
      categoryId: 'c1',
      date: date,
      createdAt: date,
      updatedAt: date,
    );
  }

  final october = DateTime(2026, 10, 15);

  test('splits the month into income and expenses', () {
    final summary = summarizeMonth([
      tx(DateTime(2026, 10, 1), 500, TransactionType.income),
      tx(DateTime(2026, 10, 3), 100, TransactionType.expense),
      tx(DateTime(2026, 10, 9), 50, TransactionType.expense),
    ], october);

    expect(summary.income, 500);
    expect(summary.expense, 150);
    expect(summary.net, 350);
  });

  test('ignores transactions from other months', () {
    final summary = summarizeMonth([
      tx(DateTime(2026, 9, 30), 900, TransactionType.income),
      tx(DateTime(2026, 10, 2), 10, TransactionType.expense),
      tx(DateTime(2026, 11, 1), 700, TransactionType.expense),
    ], october);

    expect(summary.income, 0);
    expect(summary.expense, 10);
  });

  test('change is the net result relative to the balance the month started with', () {
    final summary = summarizeMonth([
      tx(DateTime(2026, 9, 5), 1000, TransactionType.income),
      tx(DateTime(2026, 9, 20), 200, TransactionType.expense), // starts at 800
      tx(DateTime(2026, 10, 1), 500, TransactionType.income),
      tx(DateTime(2026, 10, 3), 100, TransactionType.expense), // net +400
    ], october);

    expect(summary.changePercent, closeTo(50, 1e-9));
  });

  test('change is negative when the month lost money', () {
    final summary = summarizeMonth([
      tx(DateTime(2026, 9, 5), 1000, TransactionType.income),
      tx(DateTime(2026, 10, 3), 250, TransactionType.expense),
    ], october);

    expect(summary.changePercent, closeTo(-25, 1e-9));
  });

  test('change is null when the month started with no positive balance', () {
    expect(summarizeMonth(const [], october).changePercent, isNull);
    expect(
      summarizeMonth([tx(DateTime(2026, 10, 1), 500, TransactionType.income)], october)
          .changePercent,
      isNull,
    );
    expect(
      summarizeMonth([
        tx(DateTime(2026, 9, 5), 300, TransactionType.expense),
        tx(DateTime(2026, 10, 1), 500, TransactionType.income),
      ], october)
          .changePercent,
      isNull,
    );
  });

  test('an opening balance counts towards the balance the month started with', () {
    final transactions = [tx(DateTime(2026, 10, 3), 100, TransactionType.income)];

    expect(summarizeMonth(transactions, october).changePercent, isNull);

    final withOpening = summarizeMonth(transactions, october, openingBalance: 1000);
    expect(withOpening.changePercent, closeTo(10, 0.0001));
    expect(withOpening.income, 100);
  });
}
