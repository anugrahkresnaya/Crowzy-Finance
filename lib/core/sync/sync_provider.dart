import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/categories/providers/category_provider.dart';
import '../../features/transactions/providers/transaction_provider.dart';
import '../providers/supabase_provider.dart';
import 'sync_service.dart';

part 'sync_provider.g.dart';

@riverpod
SyncService syncService(Ref ref) {
  return SyncService(
    ref.watch(supabaseClientProvider),
    ref.watch(categoryBoxProvider),
    ref.watch(transactionBoxProvider),
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

    try {
      await ref.read(syncServiceProvider).sync(userId);
      ref.invalidate(categoryListProvider);
      ref.invalidate(transactionListProvider);
    } catch (_) {
      // Non-fatal: local data stays usable offline-first; retried on the next
      // app start / resume / write.
    }
  }
}
