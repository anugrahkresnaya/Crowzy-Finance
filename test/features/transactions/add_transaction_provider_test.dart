import 'dart:io';

import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/features/accounts/providers/account_provider.dart';
import 'package:crowzy_finance/features/accounts/repository/account_repository.dart';
import 'package:crowzy_finance/features/auth/providers/auth_provider.dart';
import 'package:crowzy_finance/features/transactions/providers/transaction_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  late Box<Map> box;
  late Box meta;
  late Box<Map> accountsBox;
  late ProviderContainer container;

  setUp(() async {
    Hive.init(Directory.systemTemp.createTempSync().path);
    box = await Hive.openBox<Map>('test_add_transactions');
    meta = await Hive.openBox('test_add_meta');
    accountsBox = await Hive.openBox<Map>('test_add_accounts');
    container = ProviderContainer(overrides: [
      transactionBoxProvider.overrideWithValue(box),
      syncMetaBoxProvider.overrideWithValue(meta),
      accountsBoxProvider.overrideWithValue(accountsBox),
      currentUserProvider.overrideWithValue(
        const User(id: 'u1', appMetadata: {}, userMetadata: {}, aud: '', createdAt: ''),
      ),
      defaultAccountIdProvider.overrideWithValue(AccountRepository.defaultIdFor('u1')),
    ]);
    // The list is auto-disposed, so keep it alive while the test runs.
    container.listen(transactionListProvider, (_, _) {});
    await container.read(transactionListProvider.future);
  });

  tearDown(() async {
    container.dispose();
    await box.deleteFromDisk();
    await meta.deleteFromDisk();
    await accountsBox.deleteFromDisk();
  });

  Future<void> add({String? accountId}) => container.read(transactionListProvider.notifier).addTransaction(
        amount: 1000,
        type: TransactionType.expense,
        categoryId: 'food',
        date: DateTime(2026, 10, 2),
        accountId: accountId,
      );

  test('a transaction added to an account is saved on it, and that account is remembered', () async {
    await add(accountId: 'bca');

    final saved = container.read(transactionListProvider).value!.single;
    expect(saved.accountId, 'bca');
    expect(saved.isSynced, isFalse);
    expect(container.read(lastUsedAccountIdProvider), 'bca');
  });

  test('with no account given it goes to the default Cash account', () async {
    await add();

    expect(
      container.read(transactionListProvider).value!.single.accountId,
      AccountRepository.defaultIdFor('u1'),
    );
  });

  test('the default account is created locally so it can be pushed ahead of the transaction', () async {
    expect(accountsBox.isEmpty, isTrue);

    await add();

    expect(accountsBox.containsKey(AccountRepository.defaultIdFor('u1')), isTrue);
  });

  test('adding to another account leaves the default account alone', () async {
    await add(accountId: 'bca');

    expect(accountsBox.isEmpty, isTrue);
  });

  test('the last used account follows the latest transaction', () async {
    await add(accountId: 'bca');
    container.invalidate(lastUsedAccountIdProvider);
    await add(accountId: 'dana');
    container.invalidate(lastUsedAccountIdProvider);

    expect(container.read(lastUsedAccountIdProvider), 'dana');
  });
}
