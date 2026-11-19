import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/hive_constants.dart';
import '../../../data/models/budget_model.dart';
import '../../../data/models/transaction_type.dart';
import '../../auth/providers/auth_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../repository/budget_repository.dart';
import '../utils/category_spend.dart';

part 'budget_provider.g.dart';

@riverpod
Box<Map> budgetsBox(Ref ref) => Hive.box<Map>(HiveConstants.budgetsBox);

@riverpod
BudgetRepository budgetRepository(Ref ref) {
  return BudgetRepository(ref.watch(budgetsBoxProvider));
}

@riverpod
class BudgetList extends _$BudgetList {
  @override
  Future<List<BudgetModel>> build() async {
    return ref.watch(budgetRepositoryProvider).getAll();
  }

  /// Sets the monthly limit for a category, or removes it when [limit] is null.
  Future<void> setLimit(String categoryId, double? limit) async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(budgetRepositoryProvider);
      if (limit == null) {
        await repository.clearLimit(categoryId);
      } else {
        final userId = ref.read(currentUserProvider)?.id;
        if (userId == null) throw StateError('No authenticated user');
        await repository.setLimit(userId: userId, categoryId: categoryId, limit: limit);
      }
      return repository.getAll();
    });
  }
}

/// Limit by category id, for the categories that have one.
@riverpod
Map<String, double> categoryLimits(Ref ref) {
  final budgets = ref.watch(budgetListProvider).value ?? const [];
  return {for (final b in budgets) b.categoryId: b.monthlyLimit};
}

/// This month's spending by category id.
@riverpod
Map<String, double> categorySpendThisMonth(Ref ref) {
  final transactions = ref.watch(transactionListProvider).value ?? const [];
  return totalsByCategory(transactions, DateTime.now());
}

/// This month's income by category id.
@riverpod
Map<String, double> categoryEarnedThisMonth(Ref ref) {
  final transactions = ref.watch(transactionListProvider).value ?? const [];
  return totalsByCategory(transactions, DateTime.now(), type: TransactionType.income);
}
