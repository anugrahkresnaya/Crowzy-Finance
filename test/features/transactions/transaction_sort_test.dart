import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/features/transactions/utils/activity_feed.dart';
import 'package:crowzy_finance/features/transactions/utils/transaction_sort.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/transfers.dart';

void main() {
  ActivityEntry tx(String id, double amount, DateTime date) => TransactionEntry(TransactionModel(
        id: id,
        userId: 'u1',
        amount: amount,
        type: TransactionType.expense,
        categoryId: 'c1',
        date: date,
        createdAt: DateTime(2026, 7, 1),
        updatedAt: DateTime(2026, 7, 1),
      ));

  final a = tx('a', 50, DateTime(2026, 7, 3));
  final b = tx('b', 200, DateTime(2026, 7, 1));
  final c = tx('c', 10, DateTime(2026, 7, 5));
  final input = [a, b, c];

  List<String> ids(TransactionSort sort, [List<ActivityEntry>? list]) =>
      sortActivity(list ?? input, sort).map((t) => t.id).toList();

  test('sorts by date, newest and oldest first', () {
    expect(ids(TransactionSort.newest), ['c', 'a', 'b']);
    expect(ids(TransactionSort.oldest), ['b', 'a', 'c']);
  });

  test('sorts by amount, highest and lowest first', () {
    expect(ids(TransactionSort.highestAmount), ['b', 'a', 'c']);
    expect(ids(TransactionSort.lowestAmount), ['c', 'a', 'b']);
  });

  test('equal amounts fall back to newest first in both amount sorts', () {
    final tied = [
      tx('old', 100, DateTime(2026, 7, 1)),
      tx('new', 100, DateTime(2026, 7, 9)),
    ];
    expect(ids(TransactionSort.highestAmount, tied), ['new', 'old']);
    expect(ids(TransactionSort.lowestAmount, tied), ['new', 'old']);
  });

  test('does not mutate the input list', () {
    sortActivity(input, TransactionSort.highestAmount);
    expect(input.map((t) => t.id), ['a', 'b', 'c']);
  });

  test('transfers sort alongside transactions, by their amount', () {
    final transfer = TransferEntry(
      fakeTransfer('tr', amount: 120, fee: 9999, date: DateTime(2026, 7, 2)),
    );
    final mixed = [...input, transfer];

    expect(ids(TransactionSort.highestAmount, mixed), ['b', 'tr', 'a', 'c']);
    expect(ids(TransactionSort.newest, mixed), ['c', 'a', 'tr', 'b']);
  });

  test('a transfer ranks before a transaction from the same moment, in either date order', () {
    final moment = DateTime(2026, 7, 4);
    final transfer = TransferEntry(fakeTransfer('tr', amount: 1, date: moment));
    final same = [tx('same', 1, moment), transfer];

    expect(ids(TransactionSort.newest, same), ['tr', 'same']);
    expect(ids(TransactionSort.oldest, same), ['same', 'tr']);
  });
}
