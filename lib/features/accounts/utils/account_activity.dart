import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transfer.dart';
import 'account_balance.dart';

/// How many things happened on each account in [month]: its own transactions
/// and the transfers it took part in. The legs of a transfer are counted once,
/// as the transfer, and its fee is part of the transfer and not counted again.
/// Transactions on no account count under [unassignedAccountId].
///
/// [transactions] should already leave out the legs of the given [transfers].
Map<String, int> entriesInMonth({
  required Iterable<TransactionModel> transactions,
  required Iterable<Transfer> transfers,
  required DateTime month,
  Set<String> feeIds = const {},
}) {
  final counts = <String, int>{};

  void bump(String? accountId) {
    final key = accountId ?? unassignedAccountId;
    counts[key] = (counts[key] ?? 0) + 1;
  }

  for (final transaction in transactions) {
    if (feeIds.contains(transaction.id)) continue;
    if (!DateFormatter.isSameMonth(transaction.date, month)) continue;
    bump(transaction.accountId);
  }
  for (final transfer in transfers) {
    if (!DateFormatter.isSameMonth(transfer.date, month)) continue;
    bump(transfer.fromAccountId);
    bump(transfer.toAccountId);
  }
  return counts;
}

/// "Main account", or how busy the account has been this month.
String accountSubtitle({required bool isMain, required int entriesThisMonth}) {
  if (isMain) return 'Main account';
  return switch (entriesThisMonth) {
    0 => 'No activity this month',
    1 => '1 entry this month',
    final n => '$n entries this month',
  };
}
