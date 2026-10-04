import '../../../data/models/account_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction_type.dart';
import '../../../data/models/transfer_model.dart';

/// What each account holds: its opening balance, plus income and minus expense
/// recorded on it, plus transfers in and minus transfers out. A transaction
/// with no account belongs to [defaultAccountId]. A transfer's fee is already
/// an expense on the source account, so it is not subtracted a second time.
///
/// [excludingTransferId] leaves one transfer (and its fee expense) out, which
/// gives the balances as they stood before it. The transfer form uses that to
/// work out "after" figures while editing.
///
/// Deleted rows are expected to be filtered out already, as the repositories do.
Map<String, double> accountBalances({
  required Iterable<AccountModel> accounts,
  required Iterable<TransactionModel> transactions,
  required Iterable<TransferModel> transfers,
  required String? defaultAccountId,
  String? excludingTransferId,
}) {
  final balances = {for (final account in accounts) account.id: account.openingBalance};

  void add(String? accountId, double amount) {
    if (accountId == null || !balances.containsKey(accountId)) return;
    balances[accountId] = balances[accountId]! + amount;
  }

  for (final transaction in transactions) {
    if (excludingTransferId != null && transaction.transferId == excludingTransferId) continue;
    final signed = transaction.type == TransactionType.income
        ? transaction.amount
        : -transaction.amount;
    add(transaction.accountId ?? defaultAccountId, signed);
  }

  for (final transfer in transfers) {
    if (transfer.id == excludingTransferId) continue;
    add(transfer.fromAccountId, -transfer.amount);
    add(transfer.toAccountId, transfer.amount);
  }

  return balances;
}

/// Everything the user holds across all accounts, archived ones included.
/// A transfer moves money between accounts, so only the opening balances and
/// the transactions (fees among them) change the total.
double totalBalance({
  required Iterable<AccountModel> accounts,
  required Iterable<TransactionModel> transactions,
}) {
  var total = openingTotal(accounts);
  for (final transaction in transactions) {
    total += transaction.type == TransactionType.income
        ? transaction.amount
        : -transaction.amount;
  }
  return total;
}

/// What all accounts held when they were added.
double openingTotal(Iterable<AccountModel> accounts) {
  var total = 0.0;
  for (final account in accounts) {
    total += account.openingBalance;
  }
  return total;
}
