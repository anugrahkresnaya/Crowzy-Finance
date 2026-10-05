import 'package:crowzy_finance/data/models/account_model.dart';
import 'package:crowzy_finance/data/models/account_type.dart';
import 'package:crowzy_finance/features/accounts/providers/account_provider.dart';
import 'package:crowzy_finance/features/transactions/providers/transaction_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

AccountModel _account(String id, int order, {bool main = false, bool archived = false}) => AccountModel(
      id: id,
      userId: 'u',
      name: id,
      type: AccountType.bank,
      isMain: main,
      isArchived: archived,
      createdAt: DateTime(2026, 1, 1, 0, order),
      updatedAt: DateTime(2026),
    );

late List<AccountModel> _accounts;

class _Accounts extends AccountList {
  @override
  Future<List<AccountModel>> build() async => _accounts;
}

void main() {
  Future<String?> starting({String? lastUsed}) async {
    final c = ProviderContainer(overrides: [
      accountListProvider.overrideWith(_Accounts.new),
      lastUsedAccountIdProvider.overrideWithValue(lastUsed),
    ]);
    addTearDown(c.dispose);
    await c.read(accountListProvider.future);
    return c.read(startingAccountIdProvider);
  }

  test('is the main account when there is one', () async {
    _accounts = [_account('bca', 0), _account('dana', 1, main: true)];

    expect(await starting(lastUsed: 'bca'), 'dana');
  });

  test('is the account last used when there is no main one', () async {
    _accounts = [_account('bca', 0), _account('dana', 1)];

    expect(await starting(lastUsed: 'dana'), 'dana');
  });

  test('is the first account when there is neither', () async {
    _accounts = [_account('bca', 0), _account('dana', 1)];

    expect(await starting(), 'bca');
  });

  test('never offers an archived account, whether main, last used or first', () async {
    _accounts = [
      _account('old', 0, main: true, archived: true),
      _account('dana', 1),
    ];

    expect(await starting(lastUsed: 'old'), 'dana');
  });

  test('never offers an account that no longer exists, such as a stale last used one', () async {
    _accounts = [_account('bca', 0)];

    expect(await starting(lastUsed: 'deleted-long-ago'), 'bca');
  });

  test('is null when there are no accounts at all', () async {
    _accounts = [];

    expect(await starting(lastUsed: 'bca'), isNull);
  });
}
