import 'dart:io';

import 'package:crowzy_finance/core/constants/default_categories.dart';
import 'package:crowzy_finance/features/categories/providers/category_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Box<Map> box;

  setUp(() async {
    Hive.init(Directory.systemTemp.createTempSync().path);
    box = await Hive.openBox<Map>('test_category_top_up');
  });

  tearDown(() => box.deleteFromDisk());

  ProviderContainer container() {
    final c = ProviderContainer(overrides: [categoryBoxProvider.overrideWithValue(box)]);
    addTearDown(c.dispose);
    return c;
  }

  test('a fresh install is seeded with every default, the transfer categories included', () async {
    final categories = await container().read(categoryListProvider.future);

    expect(categories, hasLength(DefaultCategories.build().length));
    expect(categories.any((c) => c.id == DefaultCategories.transferInId), isTrue);
    expect(categories.any((c) => c.id == DefaultCategories.transferOutId), isTrue);
  });

  test('an install seeded before the transfer categories existed gets them added, and nothing else changes', () async {
    for (final category in DefaultCategories.build().where((c) => !DefaultCategories.isTransferCategory(c.id))) {
      await box.put(category.id, category.toJson());
    }
    final before = box.length;

    final categories = await container().read(categoryListProvider.future);

    expect(box.length, before + 2);
    expect(categories.where((c) => DefaultCategories.isTransferCategory(c.id)), hasLength(2));
  });

  test('a default that was deleted stays deleted instead of coming back', () async {
    final all = DefaultCategories.build();
    for (final category in all) {
      await box.put(category.id, category.toJson());
    }
    final gone = all.first.copyWith(isDeleted: true, isSynced: false);
    await box.put(gone.id, gone.toJson());

    final categories = await container().read(categoryListProvider.future);

    expect(categories.any((c) => c.id == gone.id), isFalse);
    expect(Map<String, dynamic>.from(box.get(gone.id)!)['is_deleted'], isTrue);
  });

  test('running it again adds nothing more', () async {
    await container().read(categoryListProvider.future);
    final after = box.length;

    await container().read(categoryListProvider.future);

    expect(box.length, after);
  });
}
