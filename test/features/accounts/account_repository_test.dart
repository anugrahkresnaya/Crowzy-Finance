import 'dart:io';

import 'package:crowzy_finance/data/models/account_model.dart';
import 'package:crowzy_finance/data/models/account_type.dart';
import 'package:crowzy_finance/features/accounts/repository/account_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Box<Map> box;
  late AccountRepository repository;

  setUp(() async {
    Hive.init(Directory.systemTemp.createTempSync().path);
    box = await Hive.openBox<Map>('test_accounts');
    repository = AccountRepository(box);
  });

  tearDown(() => box.deleteFromDisk());

  AccountModel account(String id, {DateTime? createdAt, bool isDeleted = false}) => AccountModel(
        id: id,
        userId: 'u1',
        name: id,
        type: AccountType.bank,
        isDeleted: isDeleted,
        createdAt: createdAt ?? DateTime.utc(2026, 7, 1),
        updatedAt: DateTime.utc(2026, 7, 1),
      );

  test('there is no account until one is added', () {
    expect(repository.getAll(), isEmpty);
  });

  group('getAll', () {
    test('lists accounts oldest first and leaves out deleted ones', () async {
      await repository.save(account('b', createdAt: DateTime.utc(2026, 7, 3)));
      await repository.save(account('a', createdAt: DateTime.utc(2026, 7, 2)));
      await repository.save(account('gone', isDeleted: true));

      expect(repository.getAll().map((a) => a.id), ['a', 'b']);
    });

    test('keeps archived accounts, since they still hold money', () async {
      await repository.save(account('a').copyWith(isArchived: true));

      expect(repository.getAll().single.isArchived, isTrue);
    });

    test('keeps the main flag, the initial balance and the e-wallet type as saved', () async {
      await repository.save(
        account('a').copyWith(isMain: true, initialBalance: 1850000, type: AccountType.ewallet),
      );

      final stored = repository.getAll().single;
      expect(stored.isMain, isTrue);
      expect(stored.initialBalance, 1850000);
      expect(stored.type, AccountType.ewallet);
    });
  });

  test('getById finds an account and ignores deleted or missing ones', () async {
    await repository.save(account('a'));
    await repository.save(account('gone', isDeleted: true));

    expect(repository.getById('a')?.id, 'a');
    expect(repository.getById('gone'), isNull);
    expect(repository.getById('missing'), isNull);
  });
}
