import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/data/models/transfer_model.dart';
import 'package:crowzy_finance/features/accounts/utils/account_feed.dart';
import 'package:crowzy_finance/features/transactions/utils/activity_feed.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final at = DateTime(2026, 10, 2);

  ActivityEntry tx(String id, {String? accountId, String? transferId}) => TransactionEntry(
        TransactionModel(
          id: id,
          userId: 'u',
          amount: 10,
          type: TransactionType.expense,
          categoryId: 'c',
          accountId: accountId,
          transferId: transferId,
          date: at,
          createdAt: at,
          updatedAt: at,
        ),
      );

  ActivityEntry transfer(String id, String from, String to) => TransferEntry(
        TransferModel(
          id: id,
          userId: 'u',
          fromAccountId: from,
          toAccountId: to,
          amount: 10,
          date: at,
          createdAt: at,
          updatedAt: at,
        ),
      );

  List<String> ids(String account, List<ActivityEntry> all) => entriesForAccount(
        all,
        accountId: account,
        defaultAccountId: 'cash',
      ).map((e) => e.id).toList();

  final all = [
    tx('on-bca', accountId: 'bca'),
    tx('on-dana', accountId: 'dana'),
    tx('no-account'),
    tx('fee', accountId: 'bca', transferId: 't1'),
    transfer('t1', 'bca', 'dana'),
    transfer('t2', 'dana', 'cash'),
  ];

  test('an account gets its own transactions, including the fee of a transfer that left it', () {
    expect(ids('bca', all), ['on-bca', 'fee', 't1']);
  });

  test('a transfer shows on both the account it left and the one it reached', () {
    expect(ids('dana', all), ['on-dana', 't1', 't2']);
    expect(ids('cash', all), ['no-account', 't2']);
  });

  test('a transaction with no account belongs to the default account only', () {
    expect(ids('bca', all), isNot(contains('no-account')));
    expect(ids('cash', all), contains('no-account'));
  });

  test('with no default account known, account-less transactions belong to nobody', () {
    final result = entriesForAccount(all, accountId: 'cash', defaultAccountId: null);

    expect(result.map((e) => e.id), ['t2']);
  });

  test('an account with nothing on it has an empty list', () {
    expect(ids('jago', all), isEmpty);
  });
}
