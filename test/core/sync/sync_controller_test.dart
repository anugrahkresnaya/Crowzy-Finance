import 'dart:io';

import 'package:crowzy_finance/core/notifications/notification_provider.dart';
import 'package:crowzy_finance/core/notifications/notification_service.dart';
import 'package:crowzy_finance/core/sync/sync_provider.dart';
import 'package:crowzy_finance/core/sync/sync_service.dart';
import 'package:crowzy_finance/data/models/alert_model.dart';
import 'package:crowzy_finance/data/models/budget_model.dart';
import 'package:crowzy_finance/data/models/category_model.dart';
import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/wishlist_model.dart';
import 'package:crowzy_finance/features/alerts/providers/alert_provider.dart';
import 'package:crowzy_finance/features/auth/providers/auth_provider.dart';
import 'package:crowzy_finance/features/budgets/providers/budget_provider.dart';
import 'package:crowzy_finance/features/categories/providers/category_provider.dart';
import 'package:crowzy_finance/features/transactions/providers/transaction_provider.dart';
import 'package:crowzy_finance/features/wishlist/providers/wishlist_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeSyncService implements SyncService {
  @override
  Future<void> sync(String userId) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeNotifications implements NotificationService {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

var _builds = <String, int>{};

class _CountingCategories extends CategoryList {
  @override
  Future<List<CategoryModel>> build() async {
    _builds['categories'] = (_builds['categories'] ?? 0) + 1;
    return const [];
  }
}

class _CountingTransactions extends TransactionList {
  @override
  Future<List<TransactionModel>> build() async {
    _builds['transactions'] = (_builds['transactions'] ?? 0) + 1;
    return const [];
  }
}

class _CountingWishlist extends WishlistList {
  @override
  Future<List<WishlistModel>> build() async {
    _builds['wishlist'] = (_builds['wishlist'] ?? 0) + 1;
    return const [];
  }
}

class _CountingAlerts extends AlertList {
  @override
  Future<List<AlertModel>> build() async {
    _builds['alerts'] = (_builds['alerts'] ?? 0) + 1;
    return const [];
  }
}

class _CountingBudgets extends BudgetList {
  @override
  Future<List<BudgetModel>> build() async {
    _builds['budgets'] = (_builds['budgets'] ?? 0) + 1;
    return const [];
  }
}

void main() {
  test('syncNow refreshes every synced list, budgets included', () async {
    _builds = {};
    Hive.init(Directory.systemTemp.createTempSync().path);
    final boxes = [
      for (final name in ['t_cat', 't_tx', 't_wish', 't_budget']) await Hive.openBox<Map>(name),
    ];

    final container = ProviderContainer(overrides: [
      currentUserProvider.overrideWithValue(
        const User(id: 'u1', appMetadata: {}, userMetadata: {}, aud: '', createdAt: ''),
      ),
      syncServiceProvider.overrideWithValue(_FakeSyncService()),
      notificationServiceProvider.overrideWithValue(_FakeNotifications()),
      categoryBoxProvider.overrideWithValue(boxes[0]),
      transactionBoxProvider.overrideWithValue(boxes[1]),
      wishlistBoxProvider.overrideWithValue(boxes[2]),
      budgetsBoxProvider.overrideWithValue(boxes[3]),
      categoryListProvider.overrideWith(_CountingCategories.new),
      transactionListProvider.overrideWith(_CountingTransactions.new),
      wishlistListProvider.overrideWith(_CountingWishlist.new),
      alertListProvider.overrideWith(_CountingAlerts.new),
      budgetListProvider.overrideWith(_CountingBudgets.new),
    ]);
    addTearDown(() async {
      container.dispose();
      for (final box in boxes) {
        await box.deleteFromDisk();
      }
    });

    // Keep each list alive and built once before the sync.
    Future<void> warm<T>(ProviderListenable<AsyncValue<T>> provider, Future<T> future) async {
      container.listen(provider, (_, _) {});
      await future;
    }

    await warm(categoryListProvider, container.read(categoryListProvider.future));
    await warm(transactionListProvider, container.read(transactionListProvider.future));
    await warm(wishlistListProvider, container.read(wishlistListProvider.future));
    await warm(alertListProvider, container.read(alertListProvider.future));
    await warm(budgetListProvider, container.read(budgetListProvider.future));
    await container.read(syncControllerProvider.future);
    expect(_builds.values, everyElement(1));

    await container.read(syncControllerProvider.notifier).syncNow();
    await Future<void>.delayed(Duration.zero);

    expect(_builds, {
      'categories': 2,
      'transactions': 2,
      'wishlist': 2,
      'alerts': 2,
      'budgets': 2,
    });
  });
}
