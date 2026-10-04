import 'package:uuid/uuid.dart';

import '../../../core/constants/default_categories.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction_type.dart';
import '../../../data/models/transfer.dart';

/// Whether [transaction] is one leg of a transfer, which moves money between
/// accounts and is therefore neither spending nor earning. A leg is recognised
/// by its group id or by its Transfer In / Transfer Out category.
bool isTransferLeg(TransactionModel transaction) =>
    transaction.transferGroupId != null ||
    DefaultCategories.isTransferCategory(transaction.categoryId);

/// The fee of a transfer is an ordinary expense whose id is derived from the
/// transfer's group id, so it can be found, updated or removed without any
/// column linking the two.
String feeIdFor(String groupId) =>
    const Uuid().v5(Namespace.url.value, 'transfer-fee:$groupId');

/// Puts transfers back together from [transactions] (live rows only).
///
/// A transfer is a group with exactly one Transfer Out expense and one
/// Transfer In income. Anything else (a leg whose partner was deleted, a group
/// with extra legs) is not a transfer here and stays an ordinary row, so one
/// odd group never breaks the list. Newest first.
List<Transfer> deriveTransfers(Iterable<TransactionModel> transactions) {
  final byId = {for (final t in transactions) t.id: t};
  final groups = <String, List<TransactionModel>>{};
  for (final transaction in transactions) {
    final group = transaction.transferGroupId;
    if (group != null) groups.putIfAbsent(group, () => []).add(transaction);
  }

  final transfers = <Transfer>[];
  for (final MapEntry(key: groupId, value: rows) in groups.entries) {
    final outs = rows
        .where((t) =>
            t.type == TransactionType.expense &&
            t.categoryId == DefaultCategories.transferOutId)
        .toList();
    final ins = rows
        .where((t) =>
            t.type == TransactionType.income && t.categoryId == DefaultCategories.transferInId)
        .toList();
    if (outs.length != 1 || ins.length != 1) continue;

    final out = outs.single;
    final into = ins.single;
    final note = out.note?.isNotEmpty == true ? out.note : into.note;
    final feeRow = byId[feeIdFor(groupId)];

    transfers.add(
      Transfer(
        id: groupId,
        fromAccountId: out.accountId,
        toAccountId: into.accountId,
        amount: out.amount,
        fee: feeRow?.amount ?? 0,
        feeId: feeRow?.id,
        date: out.date,
        note: note?.isNotEmpty == true ? note : null,
        outLegId: out.id,
        inLegId: into.id,
        isSynced: out.isSynced && into.isSynced && (feeRow?.isSynced ?? true),
      ),
    );
  }

  return transfers..sort((a, b) => b.date.compareTo(a.date));
}

/// Ids of the transactions that make up [transfers]' legs.
Set<String> legIdsOf(Iterable<Transfer> transfers) => {
      for (final t in transfers) ...[t.outLegId, t.inLegId],
    };

/// Fee expense id → its transfer, for rows that should read as part of one.
Map<String, Transfer> feesByTransfer(Iterable<Transfer> transfers) => {
      for (final t in transfers)
        if (t.feeId != null) t.feeId!: t,
    };
