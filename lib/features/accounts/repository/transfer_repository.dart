import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/default_categories.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction_type.dart';
import '../../../data/models/transfer_model.dart';
import '../../transactions/repository/transaction_repository.dart';

/// Stores transfers and keeps each one's optional fee in step. The fee is a
/// real expense (category Fees, on the source account) linked to the transfer
/// by `transferId`, so reports, budgets and alerts count it without knowing
/// about transfers. The transfer itself is never a transaction.
class TransferRepository {
  TransferRepository(this._box, this._transactions);

  final Box<Map> _box;
  final TransactionRepository _transactions;

  /// The fee row of a transfer has a derived id, so it can be found, updated
  /// or revived without a lookup by `transferId`.
  static String feeIdFor(String transferId) =>
      const Uuid().v5(Namespace.url.value, 'transfer-fee:$transferId');

  static const feeNote = 'Transfer fee';

  /// Newest first.
  List<TransferModel> getAll() {
    return _box.values
        .map((raw) => TransferModel.fromJson(Map<String, dynamic>.from(raw)))
        .where((transfer) => !transfer.isDeleted)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  TransferModel? getById(String id) {
    final raw = _box.get(id);
    if (raw == null) return null;
    final transfer = TransferModel.fromJson(Map<String, dynamic>.from(raw));
    return transfer.isDeleted ? null : transfer;
  }

  Future<void> create(TransferModel transfer) async {
    await _write(transfer.copyWith(isSynced: false));
  }

  Future<void> update(TransferModel transfer, {DateTime? now}) async {
    await _write(transfer.copyWith(updatedAt: now ?? DateTime.now(), isSynced: false));
  }

  Future<void> delete(String id, {DateTime? now}) async {
    final transfer = getById(id);
    if (transfer == null) return;
    final at = now ?? DateTime.now();
    await _box.put(
      id,
      transfer.copyWith(isDeleted: true, updatedAt: at, isSynced: false).toJson(),
    );
    final fee = _transactions.findIncludingDeleted(feeIdFor(id));
    if (fee != null && !fee.isDeleted) {
      await _transactions.save(fee.copyWith(isDeleted: true, updatedAt: at, isSynced: false));
    }
  }

  /// Brings every transfer's fee expense back in line with the transfer: a
  /// fee that is missing, stale (amount, account, date or category changed) or
  /// left over after the transfer was deleted or its fee removed. This heals a
  /// write that was cut short between the transfer and its fee. Returns whether
  /// anything changed.
  Future<bool> reconcileFees({DateTime? now}) async {
    final at = now ?? DateTime.now();
    var changed = false;

    for (final raw in _box.values.toList()) {
      final transfer = TransferModel.fromJson(Map<String, dynamic>.from(raw));
      final fee = _transactions.findIncludingDeleted(feeIdFor(transfer.id));
      final wanted = !transfer.isDeleted && transfer.fee > 0;

      if (wanted) {
        final inLine = fee != null &&
            !fee.isDeleted &&
            fee.amount == transfer.fee &&
            fee.accountId == transfer.fromAccountId &&
            fee.categoryId == DefaultCategories.feesId &&
            fee.date == transfer.date;
        if (!inLine) {
          await _syncFee(transfer, at: at);
          changed = true;
        }
      } else if (fee != null && !fee.isDeleted) {
        await _transactions.save(fee.copyWith(isDeleted: true, updatedAt: at, isSynced: false));
        changed = true;
      }
    }
    return changed;
  }

  Future<void> _write(TransferModel transfer) async {
    await _box.put(transfer.id, transfer.toJson());
    await _syncFee(transfer);
  }

  Future<void> _syncFee(TransferModel transfer, {DateTime? at}) async {
    final feeId = feeIdFor(transfer.id);
    final existing = _transactions.findIncludingDeleted(feeId);

    if (transfer.fee > 0) {
      await _transactions.save(
        TransactionModel(
          id: feeId,
          userId: transfer.userId,
          amount: transfer.fee,
          type: TransactionType.expense,
          categoryId: DefaultCategories.feesId,
          note: feeNote,
          accountId: transfer.fromAccountId,
          transferId: transfer.id,
          date: transfer.date,
          createdAt: existing?.createdAt ?? transfer.updatedAt,
          updatedAt: at ?? transfer.updatedAt,
          isSynced: false,
        ),
      );
    } else if (existing != null && !existing.isDeleted) {
      await _transactions.save(
        existing.copyWith(isDeleted: true, updatedAt: at ?? transfer.updatedAt, isSynced: false),
      );
    }
  }
}
