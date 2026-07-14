import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/default_categories.dart';
import '../../../core/constants/hive_constants.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/transaction_type.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../repository/category_repository.dart';

part 'category_provider.g.dart';

class CategoryInUseException implements Exception {
  const CategoryInUseException();

  @override
  String toString() =>
      'This category is used by existing transactions and cannot be deleted.';
}

@riverpod
Box<Map> categoryBox(Ref ref) => Hive.box<Map>(HiveConstants.categoriesBox);

@riverpod
CategoryRepository categoryRepository(Ref ref) {
  return CategoryRepository(ref.watch(categoryBoxProvider));
}

@riverpod
class CategoryList extends _$CategoryList {
  @override
  Future<List<CategoryModel>> build() async {
    final repository = ref.watch(categoryRepositoryProvider);
    var categories = repository.getAll();
    if (categories.isEmpty) {
      for (final category in DefaultCategories.build()) {
        await repository.save(category);
      }
      categories = repository.getAll();
    }
    return categories;
  }

  Future<void> addCustomCategory({
    required String userId,
    required String name,
    required String icon,
    required TransactionType type,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(categoryRepositoryProvider);
      final now = DateTime.now();
      await repository.save(
        CategoryModel(
          id: const Uuid().v4(),
          userId: userId,
          name: name,
          icon: icon,
          type: type,
          createdAt: now,
          updatedAt: now,
          isSynced: false,
        ),
      );
      return repository.getAll();
    });
  }

  Future<void> updateCustomCategory(CategoryModel category) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(categoryRepositoryProvider);
      await repository.save(
        category.copyWith(updatedAt: DateTime.now(), isSynced: false),
      );
      return repository.getAll();
    });
  }

  Future<void> deleteCustomCategory(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (ref.read(transactionRepositoryProvider).isCategoryInUse(id)) {
        throw const CategoryInUseException();
      }
      final repository = ref.read(categoryRepositoryProvider);
      await repository.softDelete(id);
      return repository.getAll();
    });
  }
}

@riverpod
List<CategoryModel> incomeCategories(Ref ref) {
  final categories = ref.watch(categoryListProvider).value ?? const [];
  return categories.where((c) => c.type == TransactionType.income).toList();
}

@riverpod
List<CategoryModel> expenseCategories(Ref ref) {
  final categories = ref.watch(categoryListProvider).value ?? const [];
  return categories.where((c) => c.type == TransactionType.expense).toList();
}
