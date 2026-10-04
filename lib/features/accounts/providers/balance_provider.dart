import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../transactions/providers/transaction_provider.dart';
import '../utils/account_balance.dart';
import 'account_provider.dart';
import 'transfer_provider.dart';

part 'balance_provider.g.dart';

/// Current balance of every account, by account id.
@riverpod
Map<String, double> accountBalanceMap(Ref ref) {
  return accountBalances(
    accounts: ref.watch(accountListProvider).value ?? const [],
    transactions: ref.watch(transactionListProvider).value ?? const [],
    transfers: ref.watch(transferListProvider).value ?? const [],
    defaultAccountId: ref.watch(defaultAccountIdProvider),
  );
}
