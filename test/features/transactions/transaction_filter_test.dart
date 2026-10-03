import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/features/transactions/utils/transaction_filter.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';

void main() {
  TransactionModel tx(
    String id,
    DateTime date, {
    double amount = 100,
    TransactionType type = TransactionType.expense,
    String category = 'food',
    String? note,
  }) =>
      TransactionModel(
        id: id,
        userId: 'u1',
        amount: amount,
        type: type,
        categoryId: category,
        note: note,
        date: date,
        createdAt: date,
        updatedAt: date,
      );

  List<String> ids(List<TransactionModel> list) => list.map((t) => t.id).toList();

  final october = DateTime(2026, 10);
  final all = [
    tx('oct1', DateTime(2026, 10, 1), note: 'Rent', category: 'housing'),
    tx('oct3', DateTime(2026, 10, 3), note: 'Groceries'),
    tx('oct3in', DateTime(2026, 10, 3), type: TransactionType.income, category: 'salary'),
    tx('sep30', DateTime(2026, 9, 30), note: 'Coffee beans'),
  ];
  const names = {'food': 'Food', 'housing': 'Housing', 'salary': 'Salary'};

  group('filterTransactions', () {
    test('keeps only the chosen month', () {
      expect(ids(filterTransactions(all, month: october)), ['oct1', 'oct3', 'oct3in']);
    });

    test('with no month it keeps everything', () {
      expect(filterTransactions(all), hasLength(4));
    });

    test('filters by type', () {
      expect(
        ids(filterTransactions(all, month: october, type: TransactionType.income)),
        ['oct3in'],
      );
      expect(
        ids(filterTransactions(all, month: october, type: TransactionType.expense)),
        ['oct1', 'oct3'],
      );
    });

    test('filters by category', () {
      expect(ids(filterTransactions(all, month: october, categoryId: 'housing')), ['oct1']);
    });

    test('a date range overrides the month', () {
      final range = DateTimeRange(start: DateTime(2026, 9, 29), end: DateTime(2026, 10, 1));
      expect(ids(filterTransactions(all, month: october, dateRange: range)), ['oct1', 'sep30']);
    });

    test('a date range includes the whole of its last day, but not the next one', () {
      final range = DateTimeRange(start: DateTime(2026, 10, 1), end: DateTime(2026, 10, 3));
      final withLate = [
        ...all,
        tx('late', DateTime(2026, 10, 3, 23, 30)),
        tx('next', DateTime(2026, 10, 4)),
      ];
      final result = ids(filterTransactions(withLate, dateRange: range));
      expect(result, containsAll(['oct1', 'oct3', 'late']));
      expect(result, isNot(contains('next')));
    });

    test('search matches the note or the category name, ignoring case', () {
      expect(ids(filterTransactions(all, query: 'GROCER', categoryNames: names)), ['oct3']);
      expect(ids(filterTransactions(all, query: 'housing', categoryNames: names)), ['oct1']);
    });

    test('search looks across every month even when one is selected', () {
      expect(
        ids(filterTransactions(all, month: october, query: 'coffee', categoryNames: names)),
        ['sep30'],
      );
    });

    test('a blank search does not widen the month', () {
      expect(filterTransactions(all, month: october, query: '   '), hasLength(3));
    });

    test('search still respects an explicit date range', () {
      final range = DateTimeRange(start: DateTime(2026, 10, 1), end: DateTime(2026, 10, 31));
      expect(
        filterTransactions(all, dateRange: range, query: 'coffee', categoryNames: names),
        isEmpty,
      );
    });

    test('filters combine', () {
      expect(
        ids(filterTransactions(
          all,
          month: october,
          type: TransactionType.expense,
          categoryId: 'food',
        )),
        ['oct3'],
      );
    });

    test('handles transactions without a note', () {
      expect(filterTransactions(all, query: 'zzz', categoryNames: names), isEmpty);
    });
  });

  group('groupByDay', () {
    test('groups consecutive transactions that share a day, in order', () {
      final groups = groupByDay([
        tx('a', DateTime(2026, 10, 3, 18)),
        tx('b', DateTime(2026, 10, 3, 9)),
        tx('c', DateTime(2026, 10, 1)),
      ]);

      expect(groups.map((g) => g.day), [DateTime(2026, 10, 3), DateTime(2026, 10, 1)]);
      expect(groups.map((g) => ids(g.transactions)), [
        ['a', 'b'],
        ['c'],
      ]);
    });

    test('the net is income minus expenses', () {
      final groups = groupByDay([
        tx('a', DateTime(2026, 10, 1), amount: 18200000, type: TransactionType.income),
        tx('b', DateTime(2026, 10, 1), amount: 3500000),
      ]);

      expect(groups.single.net, 14700000);
    });

    test('an expense-only day is negative', () {
      final groups = groupByDay([
        tx('a', DateTime(2026, 10, 3), amount: 184500),
        tx('b', DateTime(2026, 10, 3), amount: 52000),
      ]);

      expect(groups.single.net, -236500);
    });

    test('works for oldest-first lists too', () {
      final groups = groupByDay([
        tx('a', DateTime(2026, 10, 1)),
        tx('b', DateTime(2026, 10, 3)),
      ]);

      expect(groups.map((g) => g.day), [DateTime(2026, 10, 1), DateTime(2026, 10, 3)]);
    });

    test('an empty list has no groups', () {
      expect(groupByDay(const []), isEmpty);
    });

    test('the same day separated by another day stays as separate groups', () {
      final groups = groupByDay([
        tx('a', DateTime(2026, 10, 3)),
        tx('b', DateTime(2026, 10, 1)),
        tx('c', DateTime(2026, 10, 3)),
      ]);

      expect(groups, hasLength(3));
    });
  });
}
