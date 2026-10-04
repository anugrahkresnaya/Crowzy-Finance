import 'package:crowzy_finance/data/models/account_model.dart';
import 'package:crowzy_finance/data/models/account_type.dart';
import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/data/models/transfer_model.dart';
import 'package:crowzy_finance/features/accounts/providers/account_provider.dart';
import 'package:crowzy_finance/features/accounts/providers/balance_provider.dart';
import 'package:crowzy_finance/features/accounts/providers/transfer_provider.dart';
import 'package:crowzy_finance/features/transactions/providers/transaction_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _at = DateTime(2026, 10, 1);

AccountModel _account(String id, double opening) => AccountModel(
      id: id,
      userId: 'u',
      name: id,
      type: AccountType.bank,
      openingBalance: opening,
      createdAt: _at,
      updatedAt: _at,
    );

TransactionModel _tx(String id, double amount, TransactionType type, {String? accountId}) =>
    TransactionModel(
      id: id,
      userId: 'u',
      amount: amount,
      type: type,
      categoryId: 'c',
      accountId: accountId,
      date: DateTime(2026, 10, 3),
      createdAt: _at,
      updatedAt: _at,
    );

late List<AccountModel> _accounts;
late List<TransactionModel> _transactions;
late List<TransferModel> _transfers;

class _Accounts extends AccountList {
  @override
  Future<List<AccountModel>> build() async => _accounts;
}

class _Transactions extends TransactionList {
  @override
  Future<List<TransactionModel>> build() async => _transactions;
}

class _Transfers extends TransferList {
  @override
  Future<List<TransferModel>> build() async => _transfers;
}

void main() {
  Future<ProviderContainer> container() async {
    final c = ProviderContainer(overrides: [
      accountListProvider.overrideWith(_Accounts.new),
      transactionListProvider.overrideWith(_Transactions.new),
      transferListProvider.overrideWith(_Transfers.new),
      defaultAccountIdProvider.overrideWithValue('cash'),
    ]);
    addTearDown(c.dispose);
    await c.read(accountListProvider.future);
    await c.read(transactionListProvider.future);
    await c.read(transferListProvider.future);
    return c;
  }

  setUp(() {
    _accounts = [_account('bca', 1000), _account('cash', 0)];
    _transactions = [
      _tx('a', 500, TransactionType.income, accountId: 'bca'),
      _tx('b', 120, TransactionType.expense),
    ];
    _transfers = [
      TransferModel(
        id: 't',
        userId: 'u',
        fromAccountId: 'bca',
        toAccountId: 'cash',
        amount: 300,
        date: _at,
        createdAt: _at,
        updatedAt: _at,
      ),
    ];
  });

  test('the home balance is the opening balances plus every transaction', () async {
    final c = await container();

    expect(c.read(allTimeBalanceProvider), 1000 + 500 - 120);
  });

  test('a transfer does not change the home balance', () async {
    final c = await container();
    final before = c.read(allTimeBalanceProvider);

    _transfers = [];
    c.invalidate(transferListProvider);
    await c.read(transferListProvider.future);

    expect(c.read(allTimeBalanceProvider), before);
  });

  test('the home balance equals the sum of the account balances', () async {
    final c = await container();

    final balances = c.read(accountBalanceMapProvider);
    expect(balances, {'bca': 1000 + 500 - 300, 'cash': 300 - 120});
    expect(balances.values.reduce((a, b) => a + b), c.read(allTimeBalanceProvider));
  });

  test('the month summary measures change against the opening balances too', () async {
    _accounts = [_account('bca', 1000)];
    _transactions = [
      TransactionModel(
        id: 'now',
        userId: 'u',
        amount: 100,
        type: TransactionType.income,
        categoryId: 'c',
        accountId: 'bca',
        date: DateTime.now(),
        createdAt: _at,
        updatedAt: _at,
      ),
    ];
    final c = await container();

    // 100 earned on a starting balance of 1000; with no transactions before
    // this month, only the opening balance can supply that starting balance.
    expect(c.read(thisMonthSummaryProvider).changePercent, closeTo(10, 0.0001));
  });
}
