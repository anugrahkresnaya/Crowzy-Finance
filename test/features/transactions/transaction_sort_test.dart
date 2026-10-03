import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/features/transactions/utils/transaction_sort.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TransactionModel tx(String id, double amount, DateTime date) => TransactionModel(
        id: id,
        userId: 'u1',
        amount: amount,
        type: TransactionType.expense,
        categoryId: 'c1',
        date: date,
        createdAt: DateTime(2026, 7, 1),
        updatedAt: DateTime(2026, 7, 1),
      );

  final a = tx('a', 50, DateTime(2026, 7, 3));
  final b = tx('b', 200, DateTime(2026, 7, 1));
  final c = tx('c', 10, DateTime(2026, 7, 5));
  final input = [a, b, c];

  List<String> ids(TransactionSort sort, [List<TransactionModel>? list]) =>
      sortTransactions(list ?? input, sort).map((t) => t.id).toList();

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
    sortTransactions(input, TransactionSort.highestAmount);
    expect(input.map((t) => t.id), ['a', 'b', 'c']);
  });
}
