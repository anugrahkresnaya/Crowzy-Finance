import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/budget_model.dart';

class BudgetRepository {
  BudgetRepository(this._box);

  final Box<Map> _box;

  /// One budget per (user, category), so its id is derived from the pair. That
  /// keeps a limit that is cleared and set again on the same row, and means two
  /// devices setting a limit for the same category never create duplicates.
  static String idFor(String userId, String categoryId) =>
      const Uuid().v5(Namespace.url.value, 'budget:$userId:$categoryId');

  List<BudgetModel> getAll() {
    return _box.values
        .map((raw) => BudgetModel.fromJson(Map<String, dynamic>.from(raw)))
        .where((budget) => !budget.isDeleted)
        .toList();
  }

  BudgetModel? forCategory(String categoryId) {
    for (final budget in getAll()) {
      if (budget.categoryId == categoryId) return budget;
    }
    return null;
  }

  Future<void> save(BudgetModel budget) async {
    await _box.put(budget.id, budget.toJson());
  }

  /// Sets the limit for a category, replacing any earlier one.
  Future<void> setLimit({
    required String userId,
    required String categoryId,
    required double limit,
    DateTime? now,
  }) async {
    final at = now ?? DateTime.now();
    final id = idFor(userId, categoryId);
    final raw = _box.get(id);

    if (raw == null) {
      await save(
        BudgetModel(
          id: id,
          userId: userId,
          categoryId: categoryId,
          monthlyLimit: limit,
          createdAt: at,
          updatedAt: at,
          isSynced: false,
        ),
      );
      return;
    }

    final existing = BudgetModel.fromJson(Map<String, dynamic>.from(raw));
    await save(
      existing.copyWith(
        monthlyLimit: limit,
        isDeleted: false,
        updatedAt: at,
        isSynced: false,
      ),
    );
  }

  /// Removes a category's limit (a soft delete, so the removal syncs).
  Future<void> clearLimit(String categoryId, {DateTime? now}) async {
    final at = now ?? DateTime.now();
    for (final raw in _box.values.toList()) {
      final budget = BudgetModel.fromJson(Map<String, dynamic>.from(raw));
      if (budget.categoryId != categoryId || budget.isDeleted) continue;
      await save(budget.copyWith(isDeleted: true, updatedAt: at, isSynced: false));
    }
  }
}
