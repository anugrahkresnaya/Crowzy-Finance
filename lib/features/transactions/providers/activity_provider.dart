import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../accounts/providers/transfer_provider.dart';
import '../../accounts/utils/transfers.dart';
import '../utils/activity_feed.dart';
import 'transaction_provider.dart';

part 'activity_provider.g.dart';

/// Every transaction and transfer as one list, newest first. A transfer's two
/// legs show as the one transfer; a leg whose partner is missing stays an
/// ordinary row.
@riverpod
List<ActivityEntry> activityEntries(Ref ref) {
  final transfers = ref.watch(transferListProvider);
  final legs = legIdsOf(transfers);
  final transactions = (ref.watch(transactionListProvider).value ?? const [])
      .where((t) => !legs.contains(t.id));

  return mergeActivity(transactions, transfers);
}

/// The latest few entries, for Home.
@riverpod
List<ActivityEntry> recentActivity(Ref ref) {
  return ref.watch(activityEntriesProvider).take(5).toList();
}
