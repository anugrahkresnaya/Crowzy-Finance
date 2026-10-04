import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/hive_constants.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction_type.dart';
import '../../accounts/providers/account_provider.dart';
import '../../accounts/utils/transfers.dart';
import '../../accounts/utils/account_balance.dart';
import '../../auth/providers/auth_provider.dart';
import '../repository/transaction_repository.dart';
import '../utils/month_summary.dart';

part 'transaction_provider.g.dart';

const _lastUsedCategoryKeyPrefix = 'last_used_category_';
const _lastUsedAccountKey = 'last_used_account';

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
    String? accountId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(transactionRepositoryProvider);
      final userId = ref.read(currentUserProvider)?.id;
      if (userId == null) throw StateError('No authenticated user');

      // No account given (the AI flow, for one) starts on the main account,
      // else the one last used; with neither it is left unassigned.
      final account =
          accountId ?? ref.read(mainAccountIdProvider) ?? ref.read(lastUsedAccountIdProvider);

      final now = DateTime.now();
      await repository.save(
        TransactionModel(
          id: const Uuid().v4(),
          userId: userId,
          amount: amount,
          type: type,
          categoryId: categoryId,
          note: note,
          accountId: account,
          date: date,
          createdAt: now,
          updatedAt: now,
          isSynced: false,
        ),
      );
      await ref
          .read(syncMetaBoxProvider)
          .put('$_lastUsedCategoryKeyPrefix${type.name}', categoryId);
      if (account != null) await ref.read(syncMetaBoxProvider).put(_lastUsedAccountKey, account);
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

/// The account the last transaction was added to, so the next one starts there.
@riverpod
String? lastUsedAccountId(Ref ref) {
  return ref.watch(syncMetaBoxProvider).get(_lastUsedAccountKey) as String?;
}

@riverpod
String? lastUsedCategoryId(Ref ref, TransactionType type) {
  final box = ref.watch(syncMetaBoxProvider);
  return box.get('$_lastUsedCategoryKeyPrefix${type.name}') as String?;
}

/// Transactions that are spending or earning, which leaves out the two legs
/// of every transfer. Reports, budgets, summaries and the AI read this.
@riverpod
List<TransactionModel> spendingTransactions(Ref ref) {
  final transactions = ref.watch(transactionListProvider).value ?? const [];
  return transactions.where((t) => !isTransferLeg(t)).toList();
}

/// Everything held across all accounts: initial balances plus every
/// transaction. A transfer's legs cancel, so it leaves this unchanged (its fee
/// is an expense and does not).
@riverpod
double allTimeBalance(Ref ref) {
  final transactions = ref.watch(transactionListProvider).value ?? const [];
  final accounts = ref.watch(accountListProvider).value ?? const [];
  return totalBalance(accounts: accounts, transactions: transactions);
}

@riverpod
MonthSummary thisMonthSummary(Ref ref) {
  final accounts = ref.watch(accountListProvider).value ?? const [];
  return summarizeMonth(
    ref.watch(spendingTransactionsProvider),
    DateTime.now(),
    initialBalance: initialTotal(accounts),
  );
}
