import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/features/accounts/utils/account_balance.dart';
import 'package:crowzy_finance/features/accounts/utils/account_feed.dart';
import 'package:crowzy_finance/features/transactions/utils/activity_feed.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/transfers.dart';

void main() {
  final at = DateTime(2026, 10, 2);

  ActivityEntry tx(String id, {String? accountId}) => TransactionEntry(
        TransactionModel(
          id: id,
          userId: 'u',
          amount: 10,
          type: TransactionType.expense,
          categoryId: 'c',
          accountId: accountId,
          date: at,
          createdAt: at,
          updatedAt: at,
        ),
      );

  ActivityEntry transfer(String id, String from, String to) =>
      TransferEntry(fakeTransfer(id, from: from, to: to));

  List<String> ids(String account, List<ActivityEntry> all) =>
      entriesForAccount(all, accountId: account).map((e) => e.id).toList();

  final all = [
    tx('on-bca', accountId: 'bca'),
    tx('on-dana', accountId: 'dana'),
    tx('no-account'),
    tx('fee', accountId: 'bca'),
    transfer('t1', 'bca', 'dana'),
    transfer('t2', 'dana', 'cash'),
  ];

  test('an account gets its own transactions, including the fee of a transfer that left it', () {
    expect(ids('bca', all), ['on-bca', 'fee', 't1']);
  });

  test('a transfer shows on both the account it left and the one it reached', () {
    expect(ids('dana', all), ['on-dana', 't1', 't2']);
    expect(ids('cash', all), ['t2']);
  });

  test('a transaction with no account is on no account page but the unassigned one', () {
    expect(ids('bca', all), isNot(contains('no-account')));
    expect(ids(unassignedAccountId, all), ['no-account']);
  });

  test('the unassigned page never lists a transfer', () {
    expect(ids(unassignedAccountId, [transfer('t', 'bca', 'dana')]), isEmpty);
  });

  test('an account with nothing on it has an empty list', () {
    expect(ids('jago', all), isEmpty);
  });
}
