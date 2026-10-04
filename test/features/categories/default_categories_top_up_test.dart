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

  test('a fresh install is seeded with every default, Fees included', () async {
    final categories = await container().read(categoryListProvider.future);

    expect(categories, hasLength(DefaultCategories.build().length));
    expect(categories.any((c) => c.id == DefaultCategories.feesId), isTrue);
  });

  test('an install seeded before Fees existed gets it added, and nothing else changes', () async {
    for (final category in DefaultCategories.build().where((c) => c.id != DefaultCategories.feesId)) {
      await box.put(category.id, category.toJson());
    }
    final before = box.length;

    final categories = await container().read(categoryListProvider.future);

    expect(box.length, before + 1);
    expect(categories.where((c) => c.id == DefaultCategories.feesId), hasLength(1));
  });

  test('running it again adds nothing more', () async {
    await container().read(categoryListProvider.future);
    final after = box.length;

    await container().read(categoryListProvider.future);

    expect(box.length, after);
  });
}
