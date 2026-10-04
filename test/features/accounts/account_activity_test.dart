import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/features/accounts/utils/account_activity.dart';
import 'package:crowzy_finance/features/accounts/utils/account_balance.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/transfers.dart';

void main() {
  final october = DateTime(2026, 10, 15);

  TransactionModel tx(String id, DateTime date, {String? accountId}) => TransactionModel(
        id: id,
        userId: 'u',
        amount: 10,
        type: TransactionType.expense,
        categoryId: 'c',
        accountId: accountId,
        date: date,
        createdAt: date,
        updatedAt: date,
      );

  group('entriesInMonth', () {
    test('counts transactions per account and puts those on no account under unassigned', () {
      final result = entriesInMonth(
        transactions: [
          tx('a', DateTime(2026, 10, 1), accountId: 'bca'),
          tx('b', DateTime(2026, 10, 2), accountId: 'bca'),
          tx('c', DateTime(2026, 10, 3)),
        ],
        transfers: const [],
        month: october,
      );

      expect(result, {'bca': 2, unassignedAccountId: 1});
    });

    test('a transfer counts once for each account it touches', () {
      final result = entriesInMonth(
        transactions: const [],
        transfers: [fakeTransfer('t', from: 'bca', to: 'dana', date: DateTime(2026, 10, 4))],
        month: october,
      );

      expect(result, {'bca': 1, 'dana': 1});
    });

    test('a transfer fee is part of its transfer and is not counted again', () {
      final transfer = fakeTransfer('t', fee: 50, date: DateTime(2026, 10, 4));
      final result = entriesInMonth(
        transactions: [feeOf(transfer)],
        transfers: [transfer],
        month: october,
        feeIds: {transfer.feeId!},
      );

      expect(result['bca'], 1);
    });

    test('other months are left out', () {
      final result = entriesInMonth(
        transactions: [tx('old', DateTime(2026, 9, 30), accountId: 'bca')],
        transfers: [fakeTransfer('t', date: DateTime(2026, 11, 1))],
        month: october,
      );

      expect(result, isEmpty);
    });
  });

  group('accountSubtitle', () {
    test('the main account says so whatever its activity', () {
      expect(accountSubtitle(isMain: true, entriesThisMonth: 9), 'Main account');
    });

    test('other accounts describe this month', () {
      expect(accountSubtitle(isMain: false, entriesThisMonth: 0), 'No activity this month');
      expect(accountSubtitle(isMain: false, entriesThisMonth: 1), '1 entry this month');
      expect(accountSubtitle(isMain: false, entriesThisMonth: 12), '12 entries this month');
    });
  });
}
