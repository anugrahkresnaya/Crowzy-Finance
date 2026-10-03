import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/features/budgets/utils/category_spend.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TransactionModel tx(
    DateTime date,
    double amount,
    String category, {
    TransactionType type = TransactionType.expense,
  }) =>
      TransactionModel(
        id: '${date.millisecondsSinceEpoch}$category$amount',
        userId: 'u1',
        amount: amount,
        type: type,
        categoryId: category,
        date: date,
        createdAt: date,
        updatedAt: date,
      );

  final october = DateTime(2026, 10, 15);

  group('totalsByCategory', () {
    test('adds up this month\'s expenses per category', () {
      final totals = totalsByCategory([
        tx(DateTime(2026, 10, 1), 100, 'food'),
        tx(DateTime(2026, 10, 20), 50, 'food'),
        tx(DateTime(2026, 10, 3), 30, 'dining'),
      ], october);

      expect(totals, {'food': 150, 'dining': 30});
    });

    test('ignores other months and income by default', () {
      final totals = totalsByCategory([
        tx(DateTime(2026, 9, 30), 999, 'food'),
        tx(DateTime(2026, 11, 1), 999, 'food'),
        tx(DateTime(2026, 10, 2), 500, 'salary', type: TransactionType.income),
        tx(DateTime(2026, 10, 2), 10, 'food'),
      ], october);

      expect(totals, {'food': 10});
    });

    test('can total income instead', () {
      final totals = totalsByCategory([
        tx(DateTime(2026, 10, 2), 500, 'salary', type: TransactionType.income),
        tx(DateTime(2026, 10, 2), 10, 'food'),
      ], october, type: TransactionType.income);

      expect(totals, {'salary': 500});
    });

    test('is empty when there is nothing', () {
      expect(totalsByCategory(const [], october), isEmpty);
    });
  });

  group('limitUsed', () {
    test('is the share of the limit spent', () {
      expect(limitUsed(500, 1000), 0.5);
      expect(limitUsed(850, 1000), closeTo(0.85, 1e-9));
    });

    test('goes above 1 when over the limit', () {
      expect(limitUsed(1500, 1000), 1.5);
    });

    test('is null without a usable limit', () {
      expect(limitUsed(500, null), isNull);
      expect(limitUsed(500, 0), isNull);
      expect(limitUsed(500, -10), isNull);
    });

    test('is zero when nothing was spent', () {
      expect(limitUsed(0, 1000), 0);
    });
  });
}
