import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/hive_constants.dart';
import '../../../data/models/transfer_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../repository/transfer_repository.dart';

part 'transfer_provider.g.dart';

@riverpod
Box<Map> transfersBox(Ref ref) => Hive.box<Map>(HiveConstants.transfersBox);

/// Remembers which account the user last sent money from, so the next transfer
/// can start there.
class LastTransferSource {
  LastTransferSource(this._box);

  static const _key = 'last_transfer_from';

  final Box _box;

  String? get value => _box.get(_key) as String?;

  Future<void> save(String accountId) => _box.put(_key, accountId);
}

@riverpod
LastTransferSource lastTransferSource(Ref ref) {
  return LastTransferSource(ref.watch(syncMetaBoxProvider));
}

@riverpod
TransferRepository transferRepository(Ref ref) {
  return TransferRepository(
    ref.watch(transfersBoxProvider),
    ref.watch(transactionRepositoryProvider),
  );
}

@riverpod
class TransferList extends _$TransferList {
  @override
  Future<List<TransferModel>> build() async {
    return ref.watch(transferRepositoryProvider).getAll();
  }

  Future<void> addTransfer({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    double fee = 0,
    required DateTime date,
    String? note,
  }) async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(transferRepositoryProvider);
      final userId = ref.read(currentUserProvider)?.id;
      if (userId == null) throw StateError('No authenticated user');

      final now = DateTime.now();
      await repository.create(
        TransferModel(
          id: const Uuid().v4(),
          userId: userId,
          fromAccountId: fromAccountId,
          toAccountId: toAccountId,
          amount: amount,
          fee: fee,
          note: note,
          date: date,
          createdAt: now,
          updatedAt: now,
        ),
      );
      return _refresh(repository);
    });
  }

  Future<void> updateTransfer(TransferModel transfer) async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(transferRepositoryProvider);
      await repository.update(transfer);
      return _refresh(repository);
    });
  }

  Future<void> deleteTransfer(String id) async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(transferRepositoryProvider);
      await repository.delete(id);
      return _refresh(repository);
    });
  }

  /// A transfer's fee is a transaction, so the transaction list has changed too.
  List<TransferModel> _refresh(TransferRepository repository) {
    ref.invalidate(transactionListProvider);
    return repository.getAll();
  }
}
