import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/alerts/providers/alert_provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/categories/providers/category_provider.dart';
import '../../features/transactions/providers/transaction_provider.dart';
import '../../features/wishlist/providers/wishlist_provider.dart';
import '../notifications/notification_provider.dart';
import '../providers/supabase_provider.dart';
import 'sync_service.dart';

part 'sync_provider.g.dart';

@riverpod
SyncService syncService(Ref ref) {
  return SyncService(
    ref.watch(supabaseClientProvider),
    ref.watch(categoryBoxProvider),
    ref.watch(transactionBoxProvider),
    ref.watch(wishlistBoxProvider),
    ref.watch(alertsBoxProvider),
    ref.watch(syncMetaBoxProvider),
  );
}

@riverpod
class SyncController extends _$SyncController {
  @override
  Future<void> build() async {}

  Future<void> syncNow() async {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    final beforeUnread = ref.read(unreadAlertsProvider).length;

    try {
      await ref.read(syncServiceProvider).sync(userId);
      ref.invalidate(categoryListProvider);
      ref.invalidate(transactionListProvider);
      ref.invalidate(wishlistListProvider);
      ref.invalidate(alertListProvider);

      final newUnread = ref.read(unreadAlertsProvider).length - beforeUnread;
      if (newUnread > 0) {
        await ref.read(notificationServiceProvider).showNewAlerts(newUnread);
      }
    } catch (_) {
      // Non-fatal: local data stays usable offline-first; retried on the next
      // app start / resume / write.
    }
  }
}
