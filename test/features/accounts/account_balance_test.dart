import 'package:crowzy_finance/data/models/account_model.dart';
import 'package:crowzy_finance/data/models/account_type.dart';
import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/features/accounts/utils/account_balance.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/transfers.dart';

void main() {
  final at = DateTime.utc(2026, 10, 1);

  AccountModel account(String id, double initial, {bool archived = false}) => AccountModel(
        id: id,
        userId: 'u',
        name: id,
        type: AccountType.bank,
        initialBalance: initial,
        isArchived: archived,
        createdAt: at,
        updatedAt: at,
      );

  TransactionModel tx(
    String id,
    double amount, {
    TransactionType type = TransactionType.expense,
    String? accountId,
  }) =>
      TransactionModel(
        id: id,
        userId: 'u',
        amount: amount,
        type: type,
        categoryId: 'c',
        accountId: accountId,
        date: at,
        createdAt: at,
        updatedAt: at,
      );

  final accounts = [account('bca', 9000000), account('dana', 250000), account('cash', 0)];

  Map<String, double> balances(List<TransactionModel> transactions, {Set<String> excluding = const {}}) =>
      accountBalances(
        accounts: accounts,
        transactions: transactions,
        excludingTransactionIds: excluding,
      );

  group('accountBalances', () {
    test('starts from each initial balance', () {
      expect(balances(const []), {'bca': 9000000, 'dana': 250000, 'cash': 0});
    });

    test('income adds and expense subtracts on the account they belong to', () {
      final result = balances([
        tx('a', 18200000, type: TransactionType.income, accountId: 'bca'),
        tx('b', 184500, accountId: 'bca'),
        tx('c', 68000, accountId: 'dana'),
      ]);

      expect(result['bca'], 9000000 + 18200000 - 184500);
      expect(result['dana'], 250000 - 68000);
      expect(result['cash'], 0);
    });

    test('a transfer moves money through its two legs, with no special case', () {
      final result = balances(legsOf(fakeTransfer('t', from: 'bca', to: 'dana', amount: 500000)));

      expect(result['bca'], 8500000);
      expect(result['dana'], 750000);
    });

    test('the fee is an ordinary expense on the source account', () {
      final transfer = fakeTransfer('t', from: 'bca', to: 'dana', amount: 500000, fee: 2500);
      final result = balances([...legsOf(transfer), feeOf(transfer)]);

      expect(result['bca'], 9000000 - 500000 - 2500);
      expect(result['dana'], 250000 + 500000);
    });

    test('transactions on no account are totalled apart, under the unassigned key', () {
      final result = balances([
        tx('a', 50000, type: TransactionType.income),
        tx('b', 20000),
        tx('c', 1000, accountId: 'bca'),
      ]);

      expect(result[unassignedAccountId], 30000);
      expect(result['bca'], 9000000 - 1000);
      expect(result['cash'], 0);
    });

    test('there is no unassigned entry when nothing is unassigned', () {
      expect(balances([tx('a', 1, accountId: 'bca')]).containsKey(unassignedAccountId), isFalse);
    });

    test('a transaction on an account that no longer exists counts as unassigned', () {
      final result = balances([tx('a', 10, accountId: 'ghost')]);

      expect(result.containsKey('ghost'), isFalse);
      expect(result[unassignedAccountId], -10);
    });

    test('excluding transactions gives the balances from before them, fee included', () {
      final transfer = fakeTransfer('t', from: 'bca', to: 'dana', amount: 500000, fee: 2500);
      final all = [...legsOf(transfer), feeOf(transfer)];

      final result = balances(all, excluding: {transfer.outLegId, transfer.inLegId, transfer.feeId!});

      expect(result['bca'], 9000000);
      expect(result['dana'], 250000);
    });

    test('excluding some transactions keeps the others', () {
      final result = balances(
        [tx('a', 100, accountId: 'bca'), tx('b', 40, accountId: 'bca')],
        excluding: {'a'},
      );

      expect(result['bca'], 9000000 - 40);
    });

    test('archived accounts keep their balance', () {
      final result = accountBalances(
        accounts: [account('old', 700, archived: true)],
        transactions: [tx('a', 200, accountId: 'old', type: TransactionType.income)],
      );

      expect(result['old'], 900);
    });
  });

  group('totalBalance', () {
    test('is the initial balances plus income minus expense, wherever it is', () {
      final total = totalBalance(
        accounts: accounts,
        transactions: [
          tx('a', 1000, type: TransactionType.income, accountId: 'bca'),
          tx('b', 300, accountId: 'dana'),
          tx('c', 50),
        ],
      );

      expect(total, 9250000 + 1000 - 300 - 50);
    });

    test('a transfer leaves it unchanged, a transfer fee lowers it by the fee only', () {
      final transfer = fakeTransfer('t', amount: 500000, fee: 2500);

      expect(totalBalance(accounts: accounts, transactions: legsOf(transfer)), 9250000);
      expect(
        totalBalance(accounts: accounts, transactions: [...legsOf(transfer), feeOf(transfer)]),
        9250000 - 2500,
      );
    });

    test('archived accounts still count', () {
      expect(
        totalBalance(accounts: [account('a', 100), account('b', 50, archived: true)], transactions: const []),
        150,
      );
    });

    test('equals the sum of every row on the Accounts screen, unassigned money included', () {
      final transfer = fakeTransfer('t', from: 'bca', to: 'dana', amount: 500000, fee: 2500);
      final transactions = [
        tx('a', 18200000, type: TransactionType.income, accountId: 'bca'),
        tx('b', 184500, accountId: 'dana'),
        tx('c', 20000),
        ...legsOf(transfer),
        feeOf(transfer),
      ];

      final sum = accountBalances(accounts: accounts, transactions: transactions)
          .values
          .reduce((a, b) => a + b);

      expect(totalBalance(accounts: accounts, transactions: transactions), sum);
    });
  });

  test('initialTotal adds every account, archived included', () {
    expect(initialTotal([account('a', 100), account('b', -40, archived: true)]), 60);
    expect(initialTotal(const []), 0);
  });
}
