import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/accounts/providers/account_provider.dart';
import '../../features/accounts/providers/transfer_provider.dart';
import '../../features/alerts/providers/alert_provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/budgets/providers/budget_provider.dart';
import '../../features/categories/providers/category_provider.dart';
import '../../features/transactions/providers/transaction_provider.dart';
import '../../features/wishlist/providers/wishlist_provider.dart';
import '../notifications/notification_provider.dart';
import '../providers/supabase_provider.dart';
import 'sync_scheduler.dart';
import 'sync_service.dart';

part 'sync_provider.g.dart';

@riverpod
SyncService syncService(Ref ref) {
  return SyncService(
    ref.watch(supabaseClientProvider),
    ref.watch(categoryBoxProvider),
    ref.watch(transactionBoxProvider),
    ref.watch(wishlistBoxProvider),
    ref.watch(budgetsBoxProvider),
    ref.watch(accountsBoxProvider),
    ref.watch(transfersBoxProvider),
    ref.watch(alertsBoxProvider),
    ref.watch(syncMetaBoxProvider),
  );
}

// keepAlive: the controller owns the write-triggered SyncScheduler, which
// must outlive individual reads of the notifier.
@Riverpod(keepAlive: true)
class SyncController extends _$SyncController {
  Future<void>? _inFlight;

  @override
  Future<void> build() async {
    final scheduler = SyncScheduler(
      boxes: [
        ref.read(categoryBoxProvider),
        ref.read(transactionBoxProvider),
        ref.read(wishlistBoxProvider),
        ref.read(budgetsBoxProvider),
        ref.read(accountsBoxProvider),
        ref.read(transfersBoxProvider),
      ],
      onSync: syncNow,
    );
    ref.onDispose(scheduler.dispose);
  }

  /// Never throws: local data stays usable offline-first and the next
  /// start/resume retries. Failures are logged and surfaced as this
  /// controller's [AsyncError] state, and whatever did sync is still applied.
  ///
  /// Concurrent calls (resume, login, write-triggered) share one run.
  Future<void> syncNow() => _inFlight ??= _syncNow().whenComplete(() => _inFlight = null);

  Future<void> _syncNow() async {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    final beforeUnread = ref.read(unreadAlertsProvider).length;

    Object? failure;
    StackTrace? failureTrace;
    try {
      await ref.read(syncServiceProvider).sync(userId);
    } catch (error, stackTrace) {
      failure = error;
      failureTrace = stackTrace;
      debugPrint('Sync failed: $error');
    }

    // Partial success is still success for the steps that completed.
    ref.invalidate(categoryListProvider);
    ref.invalidate(transactionListProvider);
    ref.invalidate(wishlistListProvider);
    ref.invalidate(alertListProvider);
    ref.invalidate(budgetListProvider);
    ref.invalidate(accountListProvider);
    ref.invalidate(transferListProvider);

    final newUnread = ref.read(unreadAlertsProvider).length - beforeUnread;
    if (newUnread > 0) {
      try {
        await ref.read(notificationServiceProvider).showNewAlerts(newUnread);
      } catch (error) {
        debugPrint('Showing alert notification failed: $error');
      }
    }

    state = failure == null
        ? const AsyncData(null)
        : AsyncError(failure, failureTrace!);
  }
}
