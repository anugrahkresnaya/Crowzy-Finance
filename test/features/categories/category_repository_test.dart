import 'dart:io';

import 'package:crowzy_finance/data/models/category_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/features/categories/repository/category_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Box<Map> box;
  late CategoryRepository repository;

  setUp(() async {
    Hive.init(Directory.systemTemp.createTempSync().path);
    box = await Hive.openBox<Map>('test_categories');
    repository = CategoryRepository(box);
  });

  tearDown(() async {
    await box.deleteFromDisk();
  });

  CategoryModel buildCategory({String id = 'c1', String? userId = 'u1'}) {
    final now = DateTime(2026, 1, 1);
    return CategoryModel(
      id: id,
      userId: userId,
      name: 'Food',
      icon: 'restaurant',
      type: TransactionType.expense,
      createdAt: now,
      updatedAt: now,
    );
  }

  test('save then getAll returns the category', () async {
    await repository.save(buildCategory());
    final all = repository.getAll();
    expect(all, hasLength(1));
    expect(all.first.name, 'Food');
  });

  test('softDelete marks isDeleted and excludes it from getAll', () async {
    await repository.save(buildCategory());
    await repository.softDelete('c1');

    expect(repository.getAll(), isEmpty);

    final raw = box.get('c1');
    final stored = CategoryModel.fromJson(Map<String, dynamic>.from(raw!));
    expect(stored.isDeleted, isTrue);
    expect(stored.isSynced, isFalse);
  });

  test('getAll sorts categories by name', () async {
    await repository.save(buildCategory(id: 'c1').copyWith(name: 'Zebra'));
    await repository.save(buildCategory(id: 'c2').copyWith(name: 'Apple'));

    final all = repository.getAll();
    expect(all.map((c) => c.name), ['Apple', 'Zebra']);
  });
}
