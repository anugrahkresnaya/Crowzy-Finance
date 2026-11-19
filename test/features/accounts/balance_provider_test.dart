import 'package:crowzy_finance/data/models/account_model.dart';
import 'package:crowzy_finance/data/models/account_type.dart';
import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/features/accounts/providers/account_provider.dart';
import 'package:crowzy_finance/features/accounts/providers/balance_provider.dart';
import 'package:crowzy_finance/features/accounts/utils/account_balance.dart';
import 'package:crowzy_finance/features/transactions/providers/transaction_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/transfers.dart';

final _at = DateTime(2026, 10, 1);

AccountModel _account(String id, double initial, {bool main = false, bool archived = false}) =>
    AccountModel(
      id: id,
      userId: 'u',
      name: id,
      type: AccountType.bank,
      initialBalance: initial,
      isMain: main,
      isArchived: archived,
      createdAt: _at,
      updatedAt: _at,
    );

TransactionModel _tx(
  String id,
  double amount,
  TransactionType type, {
  String? accountId,
  DateTime? date,
}) =>
    TransactionModel(
      id: id,
      userId: 'u',
      amount: amount,
      type: type,
      categoryId: 'c',
      accountId: accountId,
      date: date ?? _at,
      createdAt: _at,
      updatedAt: _at,
    );

late List<AccountModel> _accounts;
late List<TransactionModel> _transactions;

class _Accounts extends AccountList {
  @override
  Future<List<AccountModel>> build() async => _accounts;
}

class _Transactions extends TransactionList {
  @override
  Future<List<TransactionModel>> build() async => _transactions;
}

void main() {
  Future<ProviderContainer> container() async {
    final c = ProviderContainer(overrides: [
      accountListProvider.overrideWith(_Accounts.new),
      transactionListProvider.overrideWith(_Transactions.new),
    ]);
    addTearDown(c.dispose);
    await c.read(accountListProvider.future);
    await c.read(transactionListProvider.future);
    return c;
  }

  setUp(() {
    _accounts = [_account('bca', 1000), _account('cash', 0)];
    _transactions = [
      _tx('a', 500, TransactionType.income, accountId: 'bca'),
      _tx('b', 120, TransactionType.expense),
      ...legsOf(fakeTransfer('t', from: 'bca', to: 'cash', amount: 300)),
    ];
  });

  test('the home balance is the initial balances plus every transaction', () async {
    final c = await container();

    expect(c.read(allTimeBalanceProvider), 1000 + 500 - 120);
  });

  test('a transfer does not change the home balance', () async {
    final c = await container();
    final withTransfer = c.read(allTimeBalanceProvider);

    _transactions = _transactions.where((t) => t.transferGroupId == null).toList();
    c.invalidate(transactionListProvider);
    await c.read(transactionListProvider.future);

    expect(c.read(allTimeBalanceProvider), withTransfer);
  });

  test('the home balance equals the sum of every account balance, unassigned included', () async {
    final c = await container();

    final balances = c.read(accountBalanceMapProvider);
    expect(balances, {'bca': 1000 + 500 - 300, 'cash': 300, unassignedAccountId: -120});
    expect(balances.values.reduce((a, b) => a + b), c.read(allTimeBalanceProvider));
  });

  test('spending leaves out the two legs of a transfer', () async {
    final c = await container();

    expect(c.read(spendingTransactionsProvider).map((t) => t.id), ['a', 'b']);
  });

  test('the month summary counts only real income and spending, not a transfer', () async {
    _transactions = [
      _tx('salary', 1000, TransactionType.income, accountId: 'bca', date: DateTime.now()),
      _tx('lunch', 100, TransactionType.expense, accountId: 'bca', date: DateTime.now()),
      ...legsOf(fakeTransfer('t', amount: 5000, date: DateTime.now())),
    ];
    final c = await container();

    final month = c.read(thisMonthSummaryProvider);
    expect(month.income, 1000);
    expect(month.expense, 100);
  });

  test('the month summary measures change against the initial balances too', () async {
    _accounts = [_account('bca', 1000)];
    _transactions = [_tx('now', 100, TransactionType.income, accountId: 'bca', date: DateTime.now())];
    final c = await container();

    // 100 earned on a starting balance of 1000; with nothing before this month,
    // only the initial balance can supply that starting balance.
    expect(c.read(thisMonthSummaryProvider).changePercent, closeTo(10, 0.0001));
  });

  group('the main account', () {
    test('is the one marked main', () async {
      _accounts = [_account('bca', 0), _account('dana', 0, main: true)];
      final c = await container();

      expect(c.read(mainAccountIdProvider), 'dana');
    });

    test('is null when none is marked, or the main one is archived', () async {
      _accounts = [_account('bca', 0)];
      expect(await container().then((c) => c.read(mainAccountIdProvider)), isNull);

      _accounts = [_account('bca', 0, main: true, archived: true)];
      expect(await container().then((c) => c.read(mainAccountIdProvider)), isNull);
    });
  });
}
