import 'dart:io';

import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/features/accounts/providers/account_provider.dart';
import 'package:crowzy_finance/features/auth/providers/auth_provider.dart';
import 'package:crowzy_finance/features/transactions/providers/transaction_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  late Box<Map> box;
  late Box meta;

  setUp(() async {
    Hive.init(Directory.systemTemp.createTempSync().path);
    box = await Hive.openBox<Map>('test_add_transactions');
    meta = await Hive.openBox('test_add_meta');
  });

  tearDown(() async {
    await box.deleteFromDisk();
    await meta.deleteFromDisk();
  });

  Future<ProviderContainer> container({String? main}) async {
    final c = ProviderContainer(overrides: [
      transactionBoxProvider.overrideWithValue(box),
      syncMetaBoxProvider.overrideWithValue(meta),
      mainAccountIdProvider.overrideWithValue(main),
      currentUserProvider.overrideWithValue(
        const User(id: 'u1', appMetadata: {}, userMetadata: {}, aud: '', createdAt: ''),
      ),
    ]);
    addTearDown(c.dispose);
    // The list is auto-disposed, so keep it alive while the test runs.
    c.listen(transactionListProvider, (_, _) {});
    await c.read(transactionListProvider.future);
    return c;
  }

  Future<void> add(ProviderContainer c, {String? accountId}) =>
      c.read(transactionListProvider.notifier).addTransaction(
            amount: 1000,
            type: TransactionType.expense,
            categoryId: 'food',
            date: DateTime(2026, 10, 2),
            accountId: accountId,
          );

  test('a transaction added to an account is saved on it, and that account is remembered', () async {
    final c = await container();

    await add(c, accountId: 'bca');

    final saved = c.read(transactionListProvider).value!.single;
    expect(saved.accountId, 'bca');
    expect(saved.isSynced, isFalse);
    expect(c.read(lastUsedAccountIdProvider), 'bca');
  });

  test('with no account given it starts on the main account', () async {
    final c = await container(main: 'dana');
    await meta.put('last_used_account', 'bca');

    await add(c);

    expect(c.read(transactionListProvider).value!.single.accountId, 'dana');
  });

  test('with no main account it uses the account last used', () async {
    final c = await container();
    await meta.put('last_used_account', 'bca');

    await add(c);

    expect(c.read(transactionListProvider).value!.single.accountId, 'bca');
  });

  test('with neither it is left on no account, not given an invented one', () async {
    final c = await container();

    await add(c);

    expect(c.read(transactionListProvider).value!.single.accountId, isNull);
    expect(meta.get('last_used_account'), isNull);
  });

  test('the last used account follows the latest transaction', () async {
    final c = await container();

    await add(c, accountId: 'bca');
    c.invalidate(lastUsedAccountIdProvider);
    await add(c, accountId: 'dana');
    c.invalidate(lastUsedAccountIdProvider);

    expect(c.read(lastUsedAccountIdProvider), 'dana');
  });
}
