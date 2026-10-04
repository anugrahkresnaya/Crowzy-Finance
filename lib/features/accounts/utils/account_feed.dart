import '../../transactions/utils/activity_feed.dart';
import 'account_balance.dart';

/// The entries that belong on one account's page: its own transactions
/// (including the fee of a transfer that left it) and every transfer it took
/// part in. Pass [unassignedAccountId] for the transactions on no account.
List<ActivityEntry> entriesForAccount(
  Iterable<ActivityEntry> entries, {
  required String accountId,
}) {
  final unassigned = accountId == unassignedAccountId;

  return entries.where((entry) {
    switch (entry) {
      case TransactionEntry(:final transaction):
        return unassigned ? transaction.accountId == null : transaction.accountId == accountId;
      case TransferEntry(:final transfer):
        return !unassigned &&
            (transfer.fromAccountId == accountId || transfer.toAccountId == accountId);
    }
  }).toList();
}
