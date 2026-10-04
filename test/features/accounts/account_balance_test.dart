import 'package:crowzy_finance/data/models/account_model.dart';
import 'package:crowzy_finance/data/models/account_type.dart';
import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/data/models/transfer_model.dart';
import 'package:crowzy_finance/features/accounts/utils/account_balance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final at = DateTime.utc(2026, 10, 1);

  AccountModel account(String id, double opening, {bool archived = false}) => AccountModel(
        id: id,
        userId: 'u',
        name: id,
        type: AccountType.bank,
        openingBalance: opening,
        isArchived: archived,
        createdAt: at,
        updatedAt: at,
      );

  TransactionModel tx(
    String id,
    double amount, {
    TransactionType type = TransactionType.expense,
    String? accountId,
    String? transferId,
  }) =>
      TransactionModel(
        id: id,
        userId: 'u',
        amount: amount,
        type: type,
        categoryId: 'c',
        accountId: accountId,
        transferId: transferId,
        date: at,
        createdAt: at,
        updatedAt: at,
      );

  TransferModel transfer(String id, String from, String to, double amount, {double fee = 0}) =>
      TransferModel(
        id: id,
        userId: 'u',
        fromAccountId: from,
        toAccountId: to,
        amount: amount,
        fee: fee,
        date: at,
        createdAt: at,
        updatedAt: at,
      );

  final accounts = [account('bca', 9000000), account('dana', 250000), account('cash', 0)];

  Map<String, double> balances({
    List<TransactionModel> transactions = const [],
    List<TransferModel> transfers = const [],
    String? excluding,
  }) =>
      accountBalances(
        accounts: accounts,
        transactions: transactions,
        transfers: transfers,
        defaultAccountId: 'cash',
        excludingTransferId: excluding,
      );

  group('accountBalances', () {
    test('starts from each opening balance', () {
      expect(balances(), {'bca': 9000000, 'dana': 250000, 'cash': 0});
    });

    test('income adds and expense subtracts on the account they belong to', () {
      final result = balances(transactions: [
        tx('a', 18200000, type: TransactionType.income, accountId: 'bca'),
        tx('b', 184500, accountId: 'bca'),
        tx('c', 68000, accountId: 'dana'),
      ]);

      expect(result['bca'], 9000000 + 18200000 - 184500);
      expect(result['dana'], 250000 - 68000);
      expect(result['cash'], 0);
    });

    test('a transaction with no account belongs to the default account', () {
      final result = balances(transactions: [
        tx('a', 50000, type: TransactionType.income),
        tx('b', 20000),
      ]);

      expect(result['cash'], 30000);
      expect(result['bca'], 9000000);
    });

    test('a transfer moves its amount from one account to the other', () {
      final result = balances(transfers: [transfer('t', 'bca', 'dana', 500000)]);

      expect(result['bca'], 8500000);
      expect(result['dana'], 750000);
    });

    test('the fee leaves the source once, through its linked expense', () {
      final result = balances(
        transactions: [tx('fee', 2500, accountId: 'bca', transferId: 't')],
        transfers: [transfer('t', 'bca', 'dana', 500000, fee: 2500)],
      );

      expect(result['bca'], 9000000 - 500000 - 2500);
      expect(result['dana'], 250000 + 500000);
    });

    test('excluding a transfer gives the balances from before it, fee included', () {
      final result = balances(
        transactions: [tx('fee', 2500, accountId: 'bca', transferId: 't')],
        transfers: [transfer('t', 'bca', 'dana', 500000, fee: 2500)],
        excluding: 't',
      );

      expect(result['bca'], 9000000);
      expect(result['dana'], 250000);
    });

    test('excluding one transfer keeps the others', () {
      final result = balances(
        transfers: [transfer('t1', 'bca', 'dana', 100), transfer('t2', 'bca', 'cash', 40)],
        excluding: 't1',
      );

      expect(result['bca'], 9000000 - 40);
      expect(result['cash'], 40);
      expect(result['dana'], 250000);
    });

    test('anything pointing at an unknown account is ignored', () {
      final result = balances(
        transactions: [tx('a', 10, accountId: 'ghost')],
        transfers: [transfer('t', 'ghost', 'dana', 100)],
      );

      expect(result.containsKey('ghost'), isFalse);
      expect(result['dana'], 250100);
    });

    test('with no default account known, an account-less transaction counts nowhere', () {
      final result = accountBalances(
        accounts: accounts,
        transactions: [tx('a', 10)],
        transfers: const [],
        defaultAccountId: null,
      );

      expect(result.values.reduce((a, b) => a + b), 9250000);
    });

    test('archived accounts keep their balance', () {
      final result = accountBalances(
        accounts: [account('old', 700, archived: true)],
        transactions: [tx('a', 200, accountId: 'old', type: TransactionType.income)],
        transfers: const [],
        defaultAccountId: null,
      );

      expect(result['old'], 900);
    });
  });

  group('totalBalance', () {
    test('is the opening balances plus income minus expense', () {
      final total = totalBalance(
        accounts: accounts,
        transactions: [
          tx('a', 1000, type: TransactionType.income, accountId: 'bca'),
          tx('b', 300, accountId: 'dana'),
        ],
      );

      expect(total, 9250000 + 1000 - 300);
    });

    test('a transfer leaves it unchanged, a transfer fee lowers it by the fee only', () {
      const feeOnly = 2500.0;
      final total = totalBalance(
        accounts: accounts,
        transactions: [tx('fee', feeOnly, accountId: 'bca', transferId: 't')],
      );

      expect(total, 9250000 - feeOnly);
    });

    test('archived accounts still count', () {
      expect(
        totalBalance(accounts: [account('a', 100), account('b', 50, archived: true)], transactions: const []),
        150,
      );
    });

    test('equals the sum of the individual balances when every transaction has a known account', () {
      final transactions = [
        tx('a', 18200000, type: TransactionType.income, accountId: 'bca'),
        tx('b', 184500, accountId: 'dana'),
        tx('c', 20000),
        tx('fee', 2500, accountId: 'bca', transferId: 't'),
      ];
      final transfers = [transfer('t', 'bca', 'dana', 500000, fee: 2500)];

      final sum = accountBalances(
        accounts: accounts,
        transactions: transactions,
        transfers: transfers,
        defaultAccountId: 'cash',
      ).values.reduce((a, b) => a + b);

      expect(totalBalance(accounts: accounts, transactions: transactions), sum);
    });
  });

  test('openingTotal adds every account, archived included', () {
    expect(openingTotal([account('a', 100), account('b', -40, archived: true)]), 60);
    expect(openingTotal(const []), 0);
  });
}
