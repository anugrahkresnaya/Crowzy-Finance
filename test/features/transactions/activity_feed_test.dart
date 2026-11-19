import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/features/transactions/utils/activity_feed.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';

import '../../support/transfers.dart';

void main() {
  TransactionEntry tx(
    String id,
    DateTime date, {
    double amount = 100,
    TransactionType type = TransactionType.expense,
    String category = 'food',
    String? note,
    String? transferGroupId,
  }) =>
      TransactionEntry(
        TransactionModel(
          id: id,
          userId: 'u1',
          amount: amount,
          type: type,
          categoryId: category,
          note: note,
          transferGroupId: transferGroupId,
          date: date,
          createdAt: date,
          updatedAt: date,
        ),
      );

  TransferEntry transfer(
    String id,
    DateTime date, {
    double amount = 500000,
    String from = 'bca',
    String to = 'dana',
    String? note,
  }) =>
      TransferEntry(fakeTransfer(id, from: from, to: to, amount: amount, note: note, date: date));

  List<String> ids(Iterable<ActivityEntry> list) => list.map((t) => t.id).toList();

  final october = DateTime(2026, 10);
  final all = <ActivityEntry>[
    tx('oct1', DateTime(2026, 10, 1), note: 'Rent', category: 'housing'),
    tx('oct3', DateTime(2026, 10, 3), note: 'Groceries'),
    tx('oct3in', DateTime(2026, 10, 3), type: TransactionType.income, category: 'salary'),
    tx('sep30', DateTime(2026, 9, 30), note: 'Coffee beans'),
  ];
  const names = {'food': 'Food', 'housing': 'Housing', 'salary': 'Salary'};
  const accounts = {'bca': 'BCA', 'dana': 'DANA', 'cash': 'Cash'};

  group('filterActivity', () {
    test('keeps only the chosen month', () {
      expect(ids(filterActivity(all, month: october)), ['oct1', 'oct3', 'oct3in']);
    });

    test('with no month it keeps everything', () {
      expect(filterActivity(all), hasLength(4));
    });

    test('filters by type', () {
      expect(
        ids(filterActivity(all, month: october, filter: ActivityFilter.income)),
        ['oct3in'],
      );
      expect(
        ids(filterActivity(all, month: october, filter: ActivityFilter.expense)),
        ['oct1', 'oct3'],
      );
    });

    test('filters by category', () {
      expect(ids(filterActivity(all, month: october, categoryId: 'housing')), ['oct1']);
    });

    test('a date range overrides the month', () {
      final range = DateTimeRange(start: DateTime(2026, 9, 29), end: DateTime(2026, 10, 1));
      expect(ids(filterActivity(all, month: october, dateRange: range)), ['oct1', 'sep30']);
    });

    test('a date range includes the whole of its last day, but not the next one', () {
      final range = DateTimeRange(start: DateTime(2026, 10, 1), end: DateTime(2026, 10, 3));
      final withLate = [
        ...all,
        tx('late', DateTime(2026, 10, 3, 23, 30)),
        tx('next', DateTime(2026, 10, 4)),
      ];
      final result = ids(filterActivity(withLate, dateRange: range));
      expect(result, containsAll(['oct1', 'oct3', 'late']));
      expect(result, isNot(contains('next')));
    });

    test('search matches the note or the category name, ignoring case', () {
      expect(ids(filterActivity(all, query: 'GROCER', categoryNames: names)), ['oct3']);
      expect(ids(filterActivity(all, query: 'housing', categoryNames: names)), ['oct1']);
    });

    test('search looks across every month even when one is selected', () {
      expect(
        ids(filterActivity(all, month: october, query: 'coffee', categoryNames: names)),
        ['sep30'],
      );
    });

    test('a blank search does not widen the month', () {
      expect(filterActivity(all, month: october, query: '   '), hasLength(3));
    });

    test('search still respects an explicit date range', () {
      final range = DateTimeRange(start: DateTime(2026, 10, 1), end: DateTime(2026, 10, 31));
      expect(
        filterActivity(all, dateRange: range, query: 'coffee', categoryNames: names),
        isEmpty,
      );
    });

    test('filters combine', () {
      expect(
        ids(filterActivity(
          all,
          month: october,
          filter: ActivityFilter.expense,
          categoryId: 'food',
        )),
        ['oct3'],
      );
    });

    test('handles transactions without a note', () {
      expect(filterActivity(all, query: 'zzz', categoryNames: names), isEmpty);
    });

    group('with transfers', () {
      final mixed = <ActivityEntry>[
        ...all,
        transfer('top', DateTime(2026, 10, 2), note: 'Top up DANA'),
        transfer('cash', DateTime(2026, 10, 4), from: 'dana', to: 'cash'),
        transfer('old', DateTime(2026, 9, 1)),
      ];

      test('All shows transfers beside transactions in the month', () {
        expect(
          ids(filterActivity(mixed, month: october)),
          ['oct1', 'oct3', 'oct3in', 'top', 'cash'],
        );
      });

      test('Transfers shows only transfers', () {
        expect(
          ids(filterActivity(mixed, month: october, filter: ActivityFilter.transfers)),
          ['top', 'cash'],
        );
      });

      test('Expenses and Income leave transfers out, and Transfers leaves transactions out', () {
        expect(
          ids(filterActivity(mixed, month: october, filter: ActivityFilter.expense)),
          ['oct1', 'oct3'],
        );
        expect(
          ids(filterActivity(mixed, month: october, filter: ActivityFilter.income)),
          ['oct3in'],
        );
      });

      test('choosing a category leaves transfers out, since they have none', () {
        expect(ids(filterActivity(mixed, month: october, categoryId: 'food')), ['oct3']);
      });

      test('a transfer is found by its note or by either account name', () {
        expect(ids(filterActivity(mixed, query: 'top up', accountNames: accounts)), ['top']);
        expect(
          ids(filterActivity(mixed, query: 'cash', accountNames: accounts)),
          ['cash'],
        );
        expect(
          ids(filterActivity(mixed, query: 'dana', accountNames: accounts)),
          ['top', 'cash', 'old'],
        );
      });

      test('the word transfer finds transfers', () {
        expect(
          ids(filterActivity(mixed, query: 'transfer', accountNames: accounts)),
          ['top', 'cash', 'old'],
        );
      });

      test('a date range applies to transfers too', () {
        final range = DateTimeRange(start: DateTime(2026, 10, 4), end: DateTime(2026, 10, 4));
        expect(ids(filterActivity(mixed, dateRange: range)), ['cash']);
      });
    });
  });

  group('mergeActivity', () {
    test('puts transactions and transfers in one list, newest first', () {
      final merged = mergeActivity(
        [(tx('a', DateTime(2026, 10, 1))).transaction, (tx('c', DateTime(2026, 10, 5))).transaction],
        [(transfer('b', DateTime(2026, 10, 3))).transfer],
      );

      expect(ids(merged), ['c', 'b', 'a']);
      expect(merged[1], isA<TransferEntry>());
    });

    test('an empty feed is empty', () {
      expect(mergeActivity(const [], const []), isEmpty);
    });

    test('a transfer sits above a transaction from the same moment, such as its own fee', () {
      final moment = DateTime(2026, 10, 2, 12);
      final merged = mergeActivity(
        [tx('fee', moment).transaction, tx('lunch', moment).transaction],
        [transfer('t', moment).transfer],
      );

      expect(merged.first.id, 't');
    });
  });

  group('groupActivityByDay', () {
    test('groups consecutive entries that share a day, in order', () {
      final days = groupActivityByDay([
        tx('a', DateTime(2026, 10, 3, 18)),
        transfer('t', DateTime(2026, 10, 3, 12)),
        tx('b', DateTime(2026, 10, 3, 9)),
        tx('c', DateTime(2026, 10, 1)),
      ]);

      expect(days.map((g) => g.day), [DateTime(2026, 10, 3), DateTime(2026, 10, 1)]);
      expect(days.map((g) => ids(g.entries)), [
        ['a', 't', 'b'],
        ['c'],
      ]);
    });

    test('the net is income minus expenses', () {
      final days = groupActivityByDay([
        tx('a', DateTime(2026, 10, 1), amount: 18200000, type: TransactionType.income),
        tx('b', DateTime(2026, 10, 1), amount: 3500000),
      ]);

      expect(days.single.net, 14700000);
    });

    test('an expense-only day is negative', () {
      final days = groupActivityByDay([
        tx('a', DateTime(2026, 10, 3), amount: 184500),
        tx('b', DateTime(2026, 10, 3), amount: 52000),
      ]);

      expect(days.single.net, -236500);
    });

    test('a transfer never counts towards the day, but its fee expense does', () {
      final days = groupActivityByDay([
        transfer('t', DateTime(2026, 10, 2), amount: 500000),
        tx('fee', DateTime(2026, 10, 2), amount: 2500),
        tx('lunch', DateTime(2026, 10, 2), amount: 68000),
      ]);

      expect(days.single.net, -70500);
      expect(days.single.hasTotal, isTrue);
    });

    test('a day with only transfers has a zero net and no total to show', () {
      final days = groupActivityByDay([transfer('t', DateTime(2026, 10, 2))]);

      expect(days.single.net, 0);
      expect(days.single.hasTotal, isFalse);
    });

    test('works for oldest-first lists too', () {
      final days = groupActivityByDay([
        tx('a', DateTime(2026, 10, 1)),
        tx('b', DateTime(2026, 10, 3)),
      ]);

      expect(days.map((g) => g.day), [DateTime(2026, 10, 1), DateTime(2026, 10, 3)]);
    });

    test('an empty list has no groups', () {
      expect(groupActivityByDay(const []), isEmpty);
    });

    test('the same day separated by another day stays as separate groups', () {
      final days = groupActivityByDay([
        tx('a', DateTime(2026, 10, 3)),
        tx('b', DateTime(2026, 10, 1)),
        tx('c', DateTime(2026, 10, 3)),
      ]);

      expect(days, hasLength(3));
    });
  });
}
