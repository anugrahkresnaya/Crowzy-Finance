import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../accounts/providers/transfer_provider.dart';
import '../utils/activity_feed.dart';
import 'transaction_provider.dart';

part 'activity_provider.g.dart';

/// Every transaction and transfer as one list, newest first.
@riverpod
List<ActivityEntry> activityEntries(Ref ref) {
  return mergeActivity(
    ref.watch(transactionListProvider).value ?? const [],
    ref.watch(transferListProvider).value ?? const [],
  );
}

/// The latest few entries, for Home.
@riverpod
List<ActivityEntry> recentActivity(Ref ref) {
  return ref.watch(activityEntriesProvider).take(5).toList();
}
