import '../../../data/models/transaction_model.dart';

enum TransactionSort {
  newest('Newest'),
  oldest('Oldest'),
  highestAmount('Highest amount'),
  lowestAmount('Lowest amount');

  const TransactionSort(this.label);

  final String label;
}

/// Returns a sorted copy. Amount sorts fall back to newest-first on ties so
/// the order is deterministic.
List<TransactionModel> sortTransactions(
  List<TransactionModel> transactions,
  TransactionSort sort,
) {
  int byNewest(TransactionModel a, TransactionModel b) => b.date.compareTo(a.date);

  final compare = switch (sort) {
    TransactionSort.newest => byNewest,
    TransactionSort.oldest => (TransactionModel a, TransactionModel b) => a.date.compareTo(b.date),
    TransactionSort.highestAmount => (TransactionModel a, TransactionModel b) {
        final byAmount = b.amount.compareTo(a.amount);
        return byAmount != 0 ? byAmount : byNewest(a, b);
      },
    TransactionSort.lowestAmount => (TransactionModel a, TransactionModel b) {
        final byAmount = a.amount.compareTo(b.amount);
        return byAmount != 0 ? byAmount : byNewest(a, b);
      },
  };

  return [...transactions]..sort(compare);
}
