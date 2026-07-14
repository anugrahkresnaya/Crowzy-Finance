import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/hive_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction_type.dart';
import '../../auth/providers/auth_provider.dart';
import '../repository/transaction_repository.dart';

part 'transaction_provider.g.dart';

const _lastUsedCategoryKeyPrefix = 'last_used_category_';

@riverpod
Box<Map> transactionBox(Ref ref) => Hive.box<Map>(HiveConstants.transactionsBox);

@riverpod
Box syncMetaBox(Ref ref) => Hive.box(HiveConstants.syncMetaBox);

@riverpod
TransactionRepository transactionRepository(Ref ref) {
  return TransactionRepository(ref.watch(transactionBoxProvider));
}

@riverpod
class TransactionList extends _$TransactionList {
  @override
  Future<List<TransactionModel>> build() async {
    return ref.watch(transactionRepositoryProvider).getAll();
  }

  Future<void> addTransaction({
    required double amount,
    required TransactionType type,
    required String categoryId,
    required DateTime date,
    String? note,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(transactionRepositoryProvider);
      final userId = ref.read(currentUserProvider)?.id;
      if (userId == null) throw StateError('No authenticated user');

      final now = DateTime.now();
      await repository.save(
        TransactionModel(
          id: const Uuid().v4(),
          userId: userId,
          amount: amount,
          type: type,
          categoryId: categoryId,
          note: note,
          date: date,
          createdAt: now,
          updatedAt: now,
          isSynced: false,
        ),
      );
      await ref
          .read(syncMetaBoxProvider)
          .put('$_lastUsedCategoryKeyPrefix${type.name}', categoryId);
      return repository.getAll();
    });
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(transactionRepositoryProvider);
      await repository.save(
        transaction.copyWith(updatedAt: DateTime.now(), isSynced: false),
      );
      return repository.getAll();
    });
  }

  Future<void> deleteTransaction(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(transactionRepositoryProvider);
      await repository.softDelete(id);
      return repository.getAll();
    });
  }
}

@riverpod
String? lastUsedCategoryId(Ref ref, TransactionType type) {
  final box = ref.watch(syncMetaBoxProvider);
  return box.get('$_lastUsedCategoryKeyPrefix${type.name}') as String?;
}

@riverpod
List<TransactionModel> recentTransactions(Ref ref) {
  final transactions = ref.watch(transactionListProvider).value ?? const [];
  return transactions.take(5).toList();
}

@riverpod
double allTimeBalance(Ref ref) {
  final transactions = ref.watch(transactionListProvider).value ?? const [];
  return _netOf(transactions);
}

@riverpod
double thisMonthBalance(Ref ref) {
  final transactions = ref.watch(transactionListProvider).value ?? const [];
  final now = DateTime.now();
  final monthTransactions =
      transactions.where((t) => DateFormatter.isSameMonth(t.date, now));
  return _netOf(monthTransactions);
}

double _netOf(Iterable<TransactionModel> transactions) {
  var net = 0.0;
  for (final transaction in transactions) {
    net += transaction.type == TransactionType.income
        ? transaction.amount
        : -transaction.amount;
  }
  return net;
}
