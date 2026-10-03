import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/features/reports/utils/report_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TransactionModel tx(DateTime date, double amount, {TransactionType type = TransactionType.expense}) =>
      TransactionModel(
        id: '${date.millisecondsSinceEpoch}-$amount',
        userId: 'u1',
        amount: amount,
        type: type,
        categoryId: 'c1',
        date: date,
        createdAt: date,
        updatedAt: date,
      );

  final october = DateTime(2026, 10);

  group('dailyExpenses', () {
    test('has one entry per day of the month', () {
      expect(dailyExpenses(const [], DateTime(2026, 10)), hasLength(31));
      expect(dailyExpenses(const [], DateTime(2026, 9)), hasLength(30));
      expect(dailyExpenses(const [], DateTime(2026, 2)), hasLength(28));
      expect(dailyExpenses(const [], DateTime(2028, 2)), hasLength(29));
    });

    test('adds up expenses on the same day', () {
      final amounts = dailyExpenses([
        tx(DateTime(2026, 10, 3, 9), 184500),
        tx(DateTime(2026, 10, 3, 18), 52000),
        tx(DateTime(2026, 10, 1), 100),
      ], october);

      expect(amounts[2], 236500);
      expect(amounts[0], 100);
      expect(amounts[1], 0);
    });

    test('ignores income and other months', () {
      final amounts = dailyExpenses([
        tx(DateTime(2026, 10, 2), 500, type: TransactionType.income),
        tx(DateTime(2026, 9, 2), 700),
        tx(DateTime(2026, 11, 2), 900),
      ], october);

      expect(amounts.every((a) => a == 0), isTrue);
    });

    test('counts the last day of the month', () {
      expect(dailyExpenses([tx(DateTime(2026, 10, 31, 23, 59), 40)], october)[30], 40);
    });
  });

  group('peakDay', () {
    test('is the highest day, 1-based', () {
      expect(peakDay([0, 50, 300, 20]), 3);
    });

    test('ties go to the earliest day', () {
      expect(peakDay([0, 300, 300]), 2);
    });

    test('is null when nothing was spent', () {
      expect(peakDay([0, 0, 0]), isNull);
      expect(peakDay(const []), isNull);
    });
  });

  group('dailyAverage', () {
    final amounts = [100.0, 200.0, 300.0, 0.0, 0.0]; // pretend month of 5 days

    test('a finished month averages over all its days', () {
      expect(
        dailyAverage(amounts, month: DateTime(2026, 9), now: DateTime(2026, 10, 3)),
        120,
      );
    });

    test('the month in progress only counts the days so far', () {
      // On day 3: (100 + 200 + 300) / 3, not / 5.
      expect(
        dailyAverage(amounts, month: DateTime(2026, 10), now: DateTime(2026, 10, 3)),
        200,
      );
    });

    test('an empty month averages zero', () {
      expect(dailyAverage(const [], month: DateTime(2026, 9), now: DateTime(2026, 10, 3)), 0);
    });
  });

  group('topSpendingDays', () {
    test('ranks days by spending and leaves out days with none', () {
      expect(topSpendingDays([0, 50, 300, 20, 0]), [3, 2, 4]);
    });

    test('ties go to the earlier day', () {
      expect(topSpendingDays([100, 100, 100]), [1, 2, 3]);
    });

    test('respects the limit', () {
      expect(topSpendingDays([1, 2, 3, 4, 5, 6, 7, 8], limit: 3), [8, 7, 6]);
    });

    test('is empty when nothing was spent', () {
      expect(topSpendingDays([0, 0]), isEmpty);
    });
  });

  group('wholePercent', () {
    test('uses a true minus and a plus', () {
      expect(wholePercent(-12.4), '−12%');
      expect(wholePercent(7.6), '+8%');
      expect(wholePercent(0), '+0%');
    });

    test('does not show a minus for a change that rounds to zero', () {
      expect(wholePercent(-0.3), '+0%');
    });
  });
}
