import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/hive_constants.dart';
import '../../../data/models/account_model.dart';
import '../../../data/models/account_type.dart';
import '../../auth/providers/auth_provider.dart';
import '../repository/account_repository.dart';

part 'account_provider.g.dart';

@riverpod
Box<Map> accountsBox(Ref ref) => Hive.box<Map>(HiveConstants.accountsBox);

@riverpod
AccountRepository accountRepository(Ref ref) {
  return AccountRepository(ref.watch(accountsBoxProvider));
}

@riverpod
class AccountList extends _$AccountList {
  @override
  Future<List<AccountModel>> build() async {
    return ref.watch(accountRepositoryProvider).getAll();
  }

  Future<void> addAccount({
    required String name,
    required AccountType type,
    required double initialBalance,
  }) async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(accountRepositoryProvider);
      final userId = ref.read(currentUserProvider)?.id;
      if (userId == null) throw StateError('No authenticated user');

      final now = DateTime.now();
      await repository.save(
        AccountModel(
          id: const Uuid().v4(),
          userId: userId,
          name: name,
          type: type,
          initialBalance: initialBalance,
          createdAt: now,
          updatedAt: now,
          isSynced: false,
        ),
      );
      return repository.getAll();
    });
  }

  Future<void> updateAccount(AccountModel account) async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(accountRepositoryProvider);
      await repository.save(account.copyWith(updatedAt: DateTime.now(), isSynced: false));
      return repository.getAll();
    });
  }
}

/// The account marked as main, which new transactions and transfers start on.
/// Null when none is, or the main one is archived.
@riverpod
String? mainAccountId(Ref ref) {
  final accounts = ref.watch(accountListProvider).value ?? const [];
  for (final account in accounts) {
    if (account.isMain && !account.isArchived) return account.id;
  }
  return null;
}
