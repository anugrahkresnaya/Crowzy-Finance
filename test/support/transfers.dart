import 'package:crowzy_finance/core/constants/default_categories.dart';
import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/data/models/transfer.dart';
import 'package:crowzy_finance/features/accounts/utils/transfers.dart';

/// A [Transfer] for tests, with ids that follow from [id].
Transfer fakeTransfer(
  String id, {
  String? from = 'bca',
  String? to = 'dana',
  double amount = 500000,
  double fee = 0,
  DateTime? date,
  String? note,
  bool isSynced = true,
}) =>
    Transfer(
      id: id,
      fromAccountId: from,
      toAccountId: to,
      amount: amount,
      fee: fee,
      feeId: fee > 0 ? feeIdFor(id) : null,
      date: date ?? DateTime(2026, 10, 2),
      note: note,
      outLegId: '$id-out',
      inLegId: '$id-in',
      isSynced: isSynced,
    );

/// The two transactions a transfer is stored as, as the server holds them.
List<TransactionModel> legsOf(Transfer transfer, {String userId = 'u1'}) => [
      TransactionModel(
        id: transfer.outLegId,
        userId: userId,
        amount: transfer.amount,
        type: TransactionType.expense,
        categoryId: DefaultCategories.transferOutId,
        note: transfer.note,
        accountId: transfer.fromAccountId,
        transferGroupId: transfer.id,
        date: transfer.date,
        createdAt: transfer.date,
        updatedAt: transfer.date,
        isSynced: transfer.isSynced,
      ),
      TransactionModel(
        id: transfer.inLegId,
        userId: userId,
        amount: transfer.amount,
        type: TransactionType.income,
        categoryId: DefaultCategories.transferInId,
        note: transfer.note,
        accountId: transfer.toAccountId,
        transferGroupId: transfer.id,
        date: transfer.date,
        createdAt: transfer.date,
        updatedAt: transfer.date,
        isSynced: transfer.isSynced,
      ),
    ];

/// A transfer's fee, as an ordinary expense with the derived id.
TransactionModel feeOf(Transfer transfer, {String categoryId = 'admin-fee', String userId = 'u1'}) =>
    TransactionModel(
      id: feeIdFor(transfer.id),
      userId: userId,
      amount: transfer.fee,
      type: TransactionType.expense,
      categoryId: categoryId,
      note: 'Transfer fee',
      accountId: transfer.fromAccountId,
      date: transfer.date,
      createdAt: transfer.date,
      updatedAt: transfer.date,
      isSynced: transfer.isSynced,
    );
