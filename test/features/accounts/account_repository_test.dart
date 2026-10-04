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

  group('defaultIdFor', () {
    test('is stable for a user and differs between users', () {
      expect(AccountRepository.defaultIdFor('u1'), AccountRepository.defaultIdFor('u1'));
      expect(AccountRepository.defaultIdFor('u1'), isNot(AccountRepository.defaultIdFor('u2')));
    });

    test('is a version 5 uuid', () {
      expect(
        AccountRepository.defaultIdFor('u1'),
        matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-5[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')),
      );
    });
  });

  group('ensureDefault', () {
    test('creates one unsynced Cash account for the user', () async {
      final created = await repository.ensureDefault('u1', now: DateTime.utc(2026, 7, 2));

      expect(created.id, AccountRepository.defaultIdFor('u1'));
      expect(created.name, 'Cash');
      expect(created.type, AccountType.cash);
      expect(created.openingBalance, 0);
      expect(created.isSynced, isFalse);
      expect(repository.getAll(), hasLength(1));
    });

    test('does not replace an existing default, even after it was renamed', () async {
      final first = await repository.ensureDefault('u1');
      await repository.save(first.copyWith(name: 'Wallet', openingBalance: 900000));

      final again = await repository.ensureDefault('u1');

      expect(again.name, 'Wallet');
      expect(again.openingBalance, 900000);
      expect(repository.getAll(), hasLength(1));
    });
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
  });

  test('getById finds an account and ignores deleted or missing ones', () async {
    await repository.save(account('a'));
    await repository.save(account('gone', isDeleted: true));

    expect(repository.getById('a')?.id, 'a');
    expect(repository.getById('gone'), isNull);
    expect(repository.getById('missing'), isNull);
  });
}
