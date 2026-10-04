import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/data/models/transfer_model.dart';
import 'package:crowzy_finance/features/accounts/utils/account_activity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final october = DateTime(2026, 10, 15);

  TransactionModel tx(String id, DateTime date, {String? accountId, String? transferId}) =>
      TransactionModel(
        id: id,
        userId: 'u',
        amount: 10,
        type: TransactionType.expense,
        categoryId: 'c',
        accountId: accountId,
        transferId: transferId,
        date: date,
        createdAt: date,
        updatedAt: date,
      );

  TransferModel transfer(String id, DateTime date, String from, String to) => TransferModel(
        id: id,
        userId: 'u',
        fromAccountId: from,
        toAccountId: to,
        amount: 10,
        date: date,
        createdAt: date,
        updatedAt: date,
      );

  Map<String, int> counts(List<TransactionModel> txs, List<TransferModel> transfers) =>
      entriesInMonth(
        transactions: txs,
        transfers: transfers,
        month: october,
        defaultAccountId: 'cash',
      );

  group('entriesInMonth', () {
    test('counts transactions per account and gives account-less ones to the default', () {
      final result = counts([
        tx('a', DateTime(2026, 10, 1), accountId: 'bca'),
        tx('b', DateTime(2026, 10, 2), accountId: 'bca'),
        tx('c', DateTime(2026, 10, 3)),
      ], []);

      expect(result, {'bca': 2, 'cash': 1});
    });

    test('a transfer counts once for each account it touches', () {
      final result = counts([], [transfer('t', DateTime(2026, 10, 4), 'bca', 'dana')]);

      expect(result, {'bca': 1, 'dana': 1});
    });

    test('a transfer fee is part of its transfer and is not counted again', () {
      final result = counts(
        [tx('fee', DateTime(2026, 10, 4), accountId: 'bca', transferId: 't')],
        [transfer('t', DateTime(2026, 10, 4), 'bca', 'dana')],
      );

      expect(result['bca'], 1);
    });

    test('other months are left out', () {
      final result = counts(
        [tx('old', DateTime(2026, 9, 30), accountId: 'bca')],
        [transfer('t', DateTime(2026, 11, 1), 'bca', 'dana')],
      );

      expect(result, isEmpty);
    });
  });

  group('accountSubtitle', () {
    test('the default account says so whatever its activity', () {
      expect(accountSubtitle(isDefault: true, entriesThisMonth: 9), 'Default account');
    });

    test('other accounts describe this month', () {
      expect(accountSubtitle(isDefault: false, entriesThisMonth: 0), 'No activity this month');
      expect(accountSubtitle(isDefault: false, entriesThisMonth: 1), '1 entry this month');
      expect(accountSubtitle(isDefault: false, entriesThisMonth: 12), '12 entries this month');
    });
  });
}
