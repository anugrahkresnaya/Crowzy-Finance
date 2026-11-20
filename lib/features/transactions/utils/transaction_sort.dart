import 'activity_feed.dart';

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
List<ActivityEntry> sortActivity(List<ActivityEntry> entries, TransactionSort sort) {
  const byNewest = compareNewestFirst;

  final compare = switch (sort) {
    TransactionSort.newest => byNewest,
    TransactionSort.oldest => (ActivityEntry a, ActivityEntry b) => -byNewest(a, b),
    TransactionSort.highestAmount => (ActivityEntry a, ActivityEntry b) {
        final byAmount = b.amount.compareTo(a.amount);
        return byAmount != 0 ? byAmount : byNewest(a, b);
      },
    TransactionSort.lowestAmount => (ActivityEntry a, ActivityEntry b) {
        final byAmount = a.amount.compareTo(b.amount);
        return byAmount != 0 ? byAmount : byNewest(a, b);
      },
  };

  return [...entries]..sort(compare);
}
