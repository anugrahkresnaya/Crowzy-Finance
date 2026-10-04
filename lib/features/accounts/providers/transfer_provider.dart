import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/default_categories.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction_type.dart';
import '../../../data/models/transfer.dart';
import '../../auth/providers/auth_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../utils/transfers.dart';

part 'transfer_provider.g.dart';

/// Remembers which account the user last sent money from, so the next transfer
/// can start there.
class LastTransferSource {
  LastTransferSource(this._box);

  static const _key = 'last_transfer_from';

  final dynamic _box;

  String? get value => _box.get(_key) as String?;

  Future<void> save(String accountId) async => _box.put(_key, accountId);
}

@riverpod
LastTransferSource lastTransferSource(Ref ref) {
  return LastTransferSource(ref.watch(syncMetaBoxProvider));
}

/// Every transfer, put back together from its two transactions. Newest first.
@riverpod
List<Transfer> transferList(Ref ref) {
  return deriveTransfers(ref.watch(transactionListProvider).value ?? const []);
}

/// A transfer's fee expense id → its transfer.
@riverpod
Map<String, Transfer> feeTransfers(Ref ref) {
  return feesByTransfer(ref.watch(transferListProvider));
}

/// The name a transfer's fee is filed under. It matches the category the user
/// already has by this name, and is created for them the first time it is
/// needed.
const adminFeeCategoryName = 'Admin Fee';

// Kept alive: its methods await storage, and a provider read once and not
// listened to would otherwise be disposed part-way through.
@Riverpod(keepAlive: true)
TransferActions transferActions(Ref ref) => TransferActions(ref);

/// Creates, changes and removes transfers. Each is a handful of ordinary
/// transaction writes, all marked unsynced, so they sync like anything else.
class TransferActions {
  TransferActions(this._ref);

  final Ref _ref;

  Future<void> create({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    double fee = 0,
    required DateTime date,
    String? note,
  }) async {
    final userId = _userId();
    final repository = _ref.read(transactionRepositoryProvider);
    final group = const Uuid().v4();
    final now = DateTime.now();

    TransactionModel leg({
      required TransactionType type,
      required String categoryId,
      required String accountId,
    }) =>
        TransactionModel(
          id: const Uuid().v4(),
          userId: userId,
          amount: amount,
          type: type,
          categoryId: categoryId,
          note: note,
          accountId: accountId,
          transferGroupId: group,
          date: date,
          createdAt: now,
          updatedAt: now,
          isSynced: false,
        );

    await repository.save(leg(
      type: TransactionType.income,
      categoryId: DefaultCategories.transferInId,
      accountId: toAccountId,
    ));
    await repository.save(leg(
      type: TransactionType.expense,
      categoryId: DefaultCategories.transferOutId,
      accountId: fromAccountId,
    ));
    if (fee > 0) await _writeFee(group, userId, fee, fromAccountId, date, now);

    _ref.invalidate(transactionListProvider);
  }

  Future<void> update(
    Transfer transfer, {
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    double fee = 0,
    required DateTime date,
    String? note,
  }) async {
    final userId = _userId();
    final repository = _ref.read(transactionRepositoryProvider);
    final now = DateTime.now();

    Future<void> change(String id, String accountId) async {
      final leg = repository.findIncludingDeleted(id);
      if (leg == null) return;
      await repository.save(leg.copyWith(
        amount: amount,
        accountId: accountId,
        note: note,
        date: date,
        updatedAt: now,
        isSynced: false,
      ));
    }

    await change(transfer.outLegId, fromAccountId);
    await change(transfer.inLegId, toAccountId);

    final feeRow = repository.findIncludingDeleted(feeIdFor(transfer.id));
    if (fee > 0) {
      await _writeFee(transfer.id, userId, fee, fromAccountId, date, now);
    } else if (feeRow != null && !feeRow.isDeleted) {
      await repository.save(feeRow.copyWith(isDeleted: true, updatedAt: now, isSynced: false));
    }

    _ref.invalidate(transactionListProvider);
  }

  Future<void> delete(Transfer transfer) async {
    final repository = _ref.read(transactionRepositoryProvider);
    final now = DateTime.now();

    for (final id in [transfer.outLegId, transfer.inLegId, feeIdFor(transfer.id)]) {
      final row = repository.findIncludingDeleted(id);
      if (row == null || row.isDeleted) continue;
      await repository.save(row.copyWith(isDeleted: true, updatedAt: now, isSynced: false));
    }

    _ref.invalidate(transactionListProvider);
  }

  String _userId() {
    final id = _ref.read(currentUserProvider)?.id;
    if (id == null) throw StateError('No authenticated user');
    return id;
  }

  /// Writes (or revives) the fee expense on the source account.
  Future<void> _writeFee(
    String group,
    String userId,
    double fee,
    String fromAccountId,
    DateTime date,
    DateTime now,
  ) async {
    final repository = _ref.read(transactionRepositoryProvider);
    final existing = repository.findIncludingDeleted(feeIdFor(group));

    await repository.save(
      TransactionModel(
        id: feeIdFor(group),
        userId: userId,
        amount: fee,
        type: TransactionType.expense,
        categoryId: existing?.categoryId ?? await _adminFeeCategoryId(userId),
        note: 'Transfer fee',
        accountId: fromAccountId,
        date: date,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
        isSynced: false,
      ),
    );
  }

  Future<String> _adminFeeCategoryId(String userId) async {
    final repository = _ref.read(categoryRepositoryProvider);
    for (final category in repository.getAll()) {
      if (category.type == TransactionType.expense &&
          category.name.trim().toLowerCase() == adminFeeCategoryName.toLowerCase()) {
        return category.id;
      }
    }

    final now = DateTime.now();
    final created = CategoryModel(
      id: const Uuid().v4(),
      userId: userId,
      name: adminFeeCategoryName,
      icon: 'payments',
      type: TransactionType.expense,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
    );
    await repository.save(created);
    _ref.invalidate(categoryListProvider);
    return created.id;
  }
}
