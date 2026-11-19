import '../../../data/models/account_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction_type.dart';

/// The key under which money on no account is reported by [accountBalances].
const unassignedAccountId = '__unassigned__';

double _signed(TransactionModel transaction) => transaction.type == TransactionType.income
    ? transaction.amount
    : -transaction.amount;

/// What each account holds: its initial balance plus income and minus expense
/// recorded on it. A transfer needs no special treatment, because its two legs
/// (an expense on the source, an income on the destination) move the money
/// themselves, and a transfer's fee is an ordinary expense.
///
/// Transactions on no account, or on one that is gone, are totalled under
/// [unassignedAccountId], which is present only when there is something in it.
///
/// [excludingTransactionIds] leaves some transactions out, which gives the
/// balances as they stood before them. The transfer form uses that to work out
/// "after" figures while editing a transfer.
///
/// Deleted rows are expected to be filtered out already, as the repositories do.
Map<String, double> accountBalances({
  required Iterable<AccountModel> accounts,
  required Iterable<TransactionModel> transactions,
  Set<String> excludingTransactionIds = const {},
}) {
  final balances = {for (final account in accounts) account.id: account.initialBalance};
  var unassigned = 0.0;
  var hasUnassigned = false;

  for (final transaction in transactions) {
    if (excludingTransactionIds.contains(transaction.id)) continue;
    final id = transaction.accountId;
    if (id != null && balances.containsKey(id)) {
      balances[id] = balances[id]! + _signed(transaction);
    } else {
      unassigned += _signed(transaction);
      hasUnassigned = true;
    }
  }

  if (hasUnassigned) balances[unassignedAccountId] = unassigned;
  return balances;
}

/// Everything the user holds, archived accounts and unassigned money included.
/// A transfer leaves it unchanged (its legs cancel); its fee lowers it.
double totalBalance({
  required Iterable<AccountModel> accounts,
  required Iterable<TransactionModel> transactions,
}) {
  var total = initialTotal(accounts);
  for (final transaction in transactions) {
    total += _signed(transaction);
  }
  return total;
}

/// What all accounts held when they were added.
double initialTotal(Iterable<AccountModel> accounts) {
  var total = 0.0;
  for (final account in accounts) {
    total += account.initialBalance;
  }
  return total;
}
