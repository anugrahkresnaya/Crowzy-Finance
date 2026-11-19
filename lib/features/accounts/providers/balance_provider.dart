import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../transactions/providers/transaction_provider.dart';
import '../utils/account_activity.dart';
import '../utils/account_balance.dart';
import '../utils/transfers.dart';
import 'account_provider.dart';
import 'transfer_provider.dart';

part 'balance_provider.g.dart';

/// Current balance of every account, by account id, plus the money on no
/// account under [unassignedAccountId] when there is any.
@riverpod
Map<String, double> accountBalanceMap(Ref ref) {
  return accountBalances(
    accounts: ref.watch(accountListProvider).value ?? const [],
    transactions: ref.watch(transactionListProvider).value ?? const [],
  );
}

/// Entries on each account this month, for the Accounts list subtitles.
@riverpod
Map<String, int> accountEntriesThisMonth(Ref ref) {
  final transfers = ref.watch(transferListProvider);
  final legs = legIdsOf(transfers);
  final transactions = (ref.watch(transactionListProvider).value ?? const [])
      .where((t) => !legs.contains(t.id))
      .toList();

  return entriesInMonth(
    transactions: transactions,
    transfers: transfers,
    month: DateTime.now(),
    feeIds: {for (final t in transfers) ?t.feeId},
  );
}
