import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transfer_model.dart';

/// How many things happened on each account in [month]: its own transactions
/// and the transfers it took part in. A transfer's fee is part of the transfer
/// and is not counted again. A transaction with no account counts for
/// [defaultAccountId].
Map<String, int> entriesInMonth({
  required Iterable<TransactionModel> transactions,
  required Iterable<TransferModel> transfers,
  required DateTime month,
  required String? defaultAccountId,
}) {
  final counts = <String, int>{};

  void bump(String? accountId) {
    if (accountId == null) return;
    counts[accountId] = (counts[accountId] ?? 0) + 1;
  }

  for (final transaction in transactions) {
    if (transaction.transferId != null) continue;
    if (!DateFormatter.isSameMonth(transaction.date, month)) continue;
    bump(transaction.accountId ?? defaultAccountId);
  }
  for (final transfer in transfers) {
    if (!DateFormatter.isSameMonth(transfer.date, month)) continue;
    bump(transfer.fromAccountId);
    bump(transfer.toAccountId);
  }
  return counts;
}

/// "Default account", or how busy the account has been this month.
String accountSubtitle({required bool isDefault, required int entriesThisMonth}) {
  if (isDefault) return 'Default account';
  return switch (entriesThisMonth) {
    0 => 'No activity this month',
    1 => '1 entry this month',
    final n => '$n entries this month',
  };
}
