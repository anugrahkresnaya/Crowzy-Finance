import '../../transactions/utils/activity_feed.dart';

/// The entries that belong on one account's page: its own transactions
/// (including the fee of a transfer that left it) and every transfer it took
/// part in. A transaction with no account belongs to [defaultAccountId].
List<ActivityEntry> entriesForAccount(
  Iterable<ActivityEntry> entries, {
  required String accountId,
  required String? defaultAccountId,
}) {
  return entries.where((entry) {
    switch (entry) {
      case TransactionEntry(:final transaction):
        return (transaction.accountId ?? defaultAccountId) == accountId;
      case TransferEntry(:final transfer):
        return transfer.fromAccountId == accountId || transfer.toAccountId == accountId;
    }
  }).toList();
}
