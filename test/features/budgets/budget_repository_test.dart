import 'dart:io';

import 'package:crowzy_finance/data/models/budget_model.dart';
import 'package:crowzy_finance/features/budgets/repository/budget_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Box<Map> box;
  late BudgetRepository repository;

  setUp(() async {
    Hive.init(Directory.systemTemp.createTempSync().path);
    box = await Hive.openBox<Map>('test_budgets');
    repository = BudgetRepository(box);
  });

  tearDown(() async {
    await box.deleteFromDisk();
  });

  final t1 = DateTime.utc(2026, 10, 1);
  final t2 = DateTime.utc(2026, 10, 5);

  group('idFor', () {
    test('is stable for the same user and category', () {
      expect(BudgetRepository.idFor('u1', 'food'), BudgetRepository.idFor('u1', 'food'));
    });

    test('differs per category and per user', () {
      final base = BudgetRepository.idFor('u1', 'food');
      expect(BudgetRepository.idFor('u1', 'dining'), isNot(base));
      expect(BudgetRepository.idFor('u2', 'food'), isNot(base));
    });

    test('is a valid uuid', () {
      expect(
        BudgetRepository.idFor('u1', 'food'),
        matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-5[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')),
      );
    });
  });

  group('setLimit reusing a row that already exists', () {
    BudgetModel remote(String id, {bool deleted = false, String category = 'food', String user = 'u1'}) =>
        BudgetModel(
          id: id,
          userId: user,
          categoryId: category,
          monthlyLimit: 500,
          isDeleted: deleted,
          createdAt: t1,
          updatedAt: t1,
        );

    test('a limit another device created under its own id is updated, not duplicated', () async {
      await repository.save(remote('server-made'));

      await repository.setLimit(userId: 'u1', categoryId: 'food', limit: 900, now: t2);

      expect(box.length, 1);
      final budget = repository.forCategory('food')!;
      expect(budget.id, 'server-made');
      expect(budget.monthlyLimit, 900);
      expect(budget.isSynced, isFalse);
    });

    test('a removed limit under another id is revived rather than a second row made', () async {
      await repository.save(remote('server-made', deleted: true));

      await repository.setLimit(userId: 'u1', categoryId: 'food', limit: 900, now: t2);

      expect(box.length, 1);
      expect(repository.forCategory('food')!.id, 'server-made');
      expect(repository.forCategory('food')!.isDeleted, isFalse);
    });

    test('an active row wins over a removed one for the same category', () async {
      await repository.save(remote('old', deleted: true));
      await repository.save(remote('live'));

      await repository.setLimit(userId: 'u1', categoryId: 'food', limit: 900, now: t2);

      expect(repository.forCategory('food')!.id, 'live');
      expect(Map<String, dynamic>.from(box.get('old')!)['is_deleted'], isTrue);
    });

    test('a limit for another category or another user does not get in the way', () async {
      await repository.save(remote('dining-row', category: 'dining'));
      await repository.save(remote('their-row', user: 'u2'));

      await repository.setLimit(userId: 'u1', categoryId: 'food', limit: 900, now: t2);

      expect(repository.forCategory('food')!.id, BudgetRepository.idFor('u1', 'food'));
      expect(box.length, 3);
    });
  });

  group('setLimit', () {
    test('creates an unsynced budget under the derived id', () async {
      await repository.setLimit(userId: 'u1', categoryId: 'food', limit: 2000000, now: t1);

      final budget = repository.forCategory('food')!;
      expect(budget.id, BudgetRepository.idFor('u1', 'food'));
      expect(budget.monthlyLimit, 2000000);
      expect(budget.userId, 'u1');
      expect(budget.isSynced, isFalse);
      expect(budget.isDeleted, isFalse);
      expect(budget.createdAt, t1);
    });

    test('changing a limit updates the same row and keeps its creation time', () async {
      await repository.setLimit(userId: 'u1', categoryId: 'food', limit: 2000000, now: t1);
      await repository.setLimit(userId: 'u1', categoryId: 'food', limit: 2500000, now: t2);

      expect(repository.getAll(), hasLength(1));
      final budget = repository.forCategory('food')!;
      expect(budget.monthlyLimit, 2500000);
      expect(budget.createdAt, t1);
      expect(budget.updatedAt, t2);
      expect(budget.isSynced, isFalse);
    });

    test('limits for different categories are independent', () async {
      await repository.setLimit(userId: 'u1', categoryId: 'food', limit: 1, now: t1);
      await repository.setLimit(userId: 'u1', categoryId: 'dining', limit: 2, now: t1);

      expect(repository.getAll(), hasLength(2));
      expect(repository.forCategory('food')!.monthlyLimit, 1);
      expect(repository.forCategory('dining')!.monthlyLimit, 2);
    });
  });

  group('clearLimit', () {
    test('hides the limit but keeps the row as an unsynced soft delete', () async {
      await repository.setLimit(userId: 'u1', categoryId: 'food', limit: 2000000, now: t1);
      await repository.clearLimit('food', now: t2);

      expect(repository.forCategory('food'), isNull);
      expect(repository.getAll(), isEmpty);

      final raw = BudgetModel.fromJson(
        Map<String, dynamic>.from(box.get(BudgetRepository.idFor('u1', 'food'))!),
      );
      expect(raw.isDeleted, isTrue);
      expect(raw.isSynced, isFalse);
      expect(raw.updatedAt, t2);
    });

    test('setting a limit again revives the same row', () async {
      await repository.setLimit(userId: 'u1', categoryId: 'food', limit: 2000000, now: t1);
      await repository.clearLimit('food', now: t2);
      await repository.setLimit(
        userId: 'u1',
        categoryId: 'food',
        limit: 3000000,
        now: DateTime.utc(2026, 10, 9),
      );

      expect(box.length, 1);
      final budget = repository.forCategory('food')!;
      expect(budget.monthlyLimit, 3000000);
      expect(budget.isDeleted, isFalse);
    });

    test('does nothing for a category with no limit', () async {
      await repository.clearLimit('food');

      expect(box.isEmpty, isTrue);
    });

    test('leaves other categories alone', () async {
      await repository.setLimit(userId: 'u1', categoryId: 'food', limit: 1, now: t1);
      await repository.setLimit(userId: 'u1', categoryId: 'dining', limit: 2, now: t1);

      await repository.clearLimit('food');

      expect(repository.forCategory('dining')!.monthlyLimit, 2);
    });
  });

  test('getAll skips deleted budgets that arrived from sync', () async {
    final deleted = BudgetModel(
      id: 'b1',
      userId: 'u1',
      categoryId: 'food',
      monthlyLimit: 5,
      isDeleted: true,
      createdAt: t1,
      updatedAt: t1,
    );
    await repository.save(deleted);

    expect(repository.getAll(), isEmpty);
  });
}
