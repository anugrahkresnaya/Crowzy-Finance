import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/account_model.dart';
import '../../data/models/alert_model.dart';
import '../../data/models/budget_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/wishlist_model.dart';

class SyncStepFailure {
  const SyncStepFailure(this.step, this.error, this.stackTrace);

  final String step;
  final Object error;
  final StackTrace stackTrace;

  @override
  String toString() => '$step: $error';
}

/// Thrown by [SyncService.sync] after all steps ran, if any of them failed.
class SyncException implements Exception {
  const SyncException(this.failures);

  final List<SyncStepFailure> failures;

  @override
  String toString() => 'Sync failed (${failures.join('; ')})';
}

class SyncService {
  SyncService(
    this._client,
    this._categoryBox,
    this._transactionBox,
    this._wishlistBox,
    this._budgetBox,
    this._accountBox,
    this._alertsBox,
    this._syncMetaBox,
  );

  final SupabaseClient _client;
  final Box<Map> _categoryBox;
  final Box<Map> _transactionBox;
  final Box<Map> _wishlistBox;
  final Box<Map> _budgetBox;
  final Box<Map> _accountBox;
  final Box<Map> _alertsBox;
  final Box _syncMetaBox;

  static const _pageSize = 500;

  /// Runs every push/pull step even if an earlier one fails, so one broken
  /// table (or a transient error mid-way) doesn't starve the others. Pulling
  /// after a failed push is safe: merges never overwrite a local row that is
  /// still unsynced. Throws a [SyncException] listing every failed step once
  /// all steps have been attempted.
  Future<void> sync(String userId) async {
    final failures = <SyncStepFailure>[];

    Future<void> run(String step, Future<void> Function() action) async {
      try {
        await action();
      } catch (error, stackTrace) {
        failures.add(SyncStepFailure(step, error, stackTrace));
      }
    }

    // Accounts go before transactions, which point at them.
    await run('push categories', _pushCategories);
    await run('push accounts', _pushAccounts);
    await run('push transactions', _pushTransactions);
    await run('push wishlist', _pushWishlist);
    await run('push budgets', _pushBudgets);
    await run('pull categories', () => _pullCategories(userId));
    await run('pull accounts', () => _pullAccounts(userId));
    await run('pull transactions', () => _pullTransactions(userId));
    await run('pull wishlist', () => _pullWishlist(userId));
    await run('pull budgets', () => _pullBudgets(userId));
    await run('pull alerts', () => _pullAlerts(userId));

    if (failures.isNotEmpty) throw SyncException(failures);
  }

  Future<void> _pushCategories() async {
    final dirty = _categoryBox.values
        .map((raw) => CategoryModel.fromJson(Map<String, dynamic>.from(raw)))
        .where((category) => !category.isSynced)
        .toList();
    if (dirty.isEmpty) return;

    await _client.from('categories').upsert(dirty.map((c) => c.toSupabaseRow()).toList());
    for (final category in dirty) {
      await _categoryBox.put(category.id, category.copyWith(isSynced: true).toJson());
    }
  }

  Future<void> _pushTransactions() async {
    final dirty = _transactionBox.values
        .map((raw) => TransactionModel.fromJson(Map<String, dynamic>.from(raw)))
        .where((transaction) => !transaction.isSynced)
        .toList();
    if (dirty.isEmpty) return;

    await _client.from('transactions').upsert(dirty.map((t) => t.toSupabaseRow()).toList());
    for (final transaction in dirty) {
      await _transactionBox.put(transaction.id, transaction.copyWith(isSynced: true).toJson());
    }
  }

  Future<void> _pushWishlist() async {
    final dirty = _wishlistBox.values
        .map((raw) => WishlistModel.fromJson(Map<String, dynamic>.from(raw)))
        .where((goal) => !goal.isSynced)
        .toList();
    if (dirty.isEmpty) return;

    await _client.from('wishlist').upsert(dirty.map((g) => g.toSupabaseRow()).toList());
    for (final goal in dirty) {
      await _wishlistBox.put(goal.id, goal.copyWith(isSynced: true).toJson());
    }
  }

  Future<void> _pushBudgets() async {
    final dirty = _budgetBox.values
        .map((raw) => BudgetModel.fromJson(Map<String, dynamic>.from(raw)))
        .where((budget) => !budget.isSynced)
        .toList();
    if (dirty.isEmpty) return;

    await _client.from('budgets').upsert(dirty.map((b) => b.toSupabaseRow()).toList());
    for (final budget in dirty) {
      await _budgetBox.put(budget.id, budget.copyWith(isSynced: true).toJson());
    }
  }

  Future<void> _pushAccounts() async {
    final dirty = _accountBox.values
        .map((raw) => AccountModel.fromJson(Map<String, dynamic>.from(raw)))
        .where((account) => !account.isSynced)
        .toList();
    if (dirty.isEmpty) return;

    await _client.from('accounts').upsert(dirty.map((a) => a.toSupabaseRow()).toList());
    for (final account in dirty) {
      await _accountBox.put(account.id, account.copyWith(isSynced: true).toJson());
    }
  }

  Future<void> _pullCategories(String userId) async {
    final since = _lastSyncedAt('categories', userId);
    var offset = 0;
    DateTime? newestSeen;

    while (true) {
      final rows = await _client
          .from('categories')
          .select()
          .or('user_id.eq.$userId,user_id.is.null')
          .gt('updated_at', since.toIso8601String())
          .order('updated_at')
          .range(offset, offset + _pageSize - 1);
      if (rows.isEmpty) break;

      for (final row in rows) {
        final remote =
            CategoryModel.fromJson(Map<String, dynamic>.from(row)).copyWith(isSynced: true);
        await _mergeCategory(remote);
        if (newestSeen == null || remote.updatedAt.isAfter(newestSeen)) {
          newestSeen = remote.updatedAt;
        }
      }
      if (rows.length < _pageSize) break;
      offset += _pageSize;
    }

    if (newestSeen != null) await _setLastSyncedAt('categories', userId, newestSeen);
  }

  Future<void> _pullTransactions(String userId) async {
    final since = _lastSyncedAt('transactions', userId);
    var offset = 0;
    DateTime? newestSeen;

    while (true) {
      final rows = await _client
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .gt('updated_at', since.toIso8601String())
          .order('updated_at')
          .range(offset, offset + _pageSize - 1);
      if (rows.isEmpty) break;

      for (final row in rows) {
        final remote =
            TransactionModel.fromJson(Map<String, dynamic>.from(row)).copyWith(isSynced: true);
        await _mergeTransaction(remote);
        if (newestSeen == null || remote.updatedAt.isAfter(newestSeen)) {
          newestSeen = remote.updatedAt;
        }
      }
      if (rows.length < _pageSize) break;
      offset += _pageSize;
    }

    if (newestSeen != null) await _setLastSyncedAt('transactions', userId, newestSeen);
  }

  Future<void> _pullWishlist(String userId) async {
    final since = _lastSyncedAt('wishlist', userId);
    var offset = 0;
    DateTime? newestSeen;

    while (true) {
      final rows = await _client
          .from('wishlist')
          .select()
          .eq('user_id', userId)
          .gt('updated_at', since.toIso8601String())
          .order('updated_at')
          .range(offset, offset + _pageSize - 1);
      if (rows.isEmpty) break;

      for (final row in rows) {
        final remote =
            WishlistModel.fromJson(Map<String, dynamic>.from(row)).copyWith(isSynced: true);
        await _mergeWishlist(remote);
        if (newestSeen == null || remote.updatedAt.isAfter(newestSeen)) {
          newestSeen = remote.updatedAt;
        }
      }
      if (rows.length < _pageSize) break;
      offset += _pageSize;
    }

    if (newestSeen != null) await _setLastSyncedAt('wishlist', userId, newestSeen);
  }

  Future<void> _pullBudgets(String userId) async {
    final since = _lastSyncedAt('budgets', userId);
    var offset = 0;
    DateTime? newestSeen;

    while (true) {
      final rows = await _client
          .from('budgets')
          .select()
          .eq('user_id', userId)
          .gt('updated_at', since.toIso8601String())
          .order('updated_at')
          .range(offset, offset + _pageSize - 1);
      if (rows.isEmpty) break;

      for (final row in rows) {
        final remote = BudgetModel.fromJson(Map<String, dynamic>.from(row)).copyWith(isSynced: true);
        await _mergeBudget(remote);
        if (newestSeen == null || remote.updatedAt.isAfter(newestSeen)) {
          newestSeen = remote.updatedAt;
        }
      }
      if (rows.length < _pageSize) break;
      offset += _pageSize;
    }

    if (newestSeen != null) await _setLastSyncedAt('budgets', userId, newestSeen);
  }

  Future<void> _pullAccounts(String userId) async {
    final since = _lastSyncedAt('accounts', userId);
    var offset = 0;
    DateTime? newestSeen;

    while (true) {
      final rows = await _client
          .from('accounts')
          .select()
          .eq('user_id', userId)
          .gt('updated_at', since.toIso8601String())
          .order('updated_at')
          .range(offset, offset + _pageSize - 1);
      if (rows.isEmpty) break;

      for (final row in rows) {
        final remote = AccountModel.fromJson(Map<String, dynamic>.from(row)).copyWith(isSynced: true);
        await _mergeAccounts(remote);
        if (newestSeen == null || remote.updatedAt.isAfter(newestSeen)) {
          newestSeen = remote.updatedAt;
        }
      }
      if (rows.length < _pageSize) break;
      offset += _pageSize;
    }

    if (newestSeen != null) await _setLastSyncedAt('accounts', userId, newestSeen);
  }

  /// Alerts are server-authored — there is no _pushAlerts, only a pull.
  Future<void> _pullAlerts(String userId) async {
    final since = _lastSyncedAt('alerts', userId);
    var offset = 0;
    DateTime? newestSeen;

    while (true) {
      final rows = await _client
          .from('alerts')
          .select()
          .eq('user_id', userId)
          .gt('created_at', since.toIso8601String())
          .order('created_at')
          .range(offset, offset + _pageSize - 1);
      if (rows.isEmpty) break;

      for (final row in rows) {
        final remote = AlertModel.fromJson(Map<String, dynamic>.from(row));
        await _mergeAlert(remote);
        if (newestSeen == null || remote.createdAt.isAfter(newestSeen)) {
          newestSeen = remote.createdAt;
        }
      }
      if (rows.length < _pageSize) break;
      offset += _pageSize;
    }

    if (newestSeen != null) await _setLastSyncedAt('alerts', userId, newestSeen);
  }

  Future<void> _mergeCategory(CategoryModel remote) async {
    final raw = _categoryBox.get(remote.id);
    if (raw != null) {
      final local = CategoryModel.fromJson(Map<String, dynamic>.from(raw));
      if (!local.isSynced || local.updatedAt.isAfter(remote.updatedAt)) return;
    }
    await _categoryBox.put(remote.id, remote.toJson());
  }

  Future<void> _mergeTransaction(TransactionModel remote) async {
    final raw = _transactionBox.get(remote.id);
    if (raw != null) {
      final local = TransactionModel.fromJson(Map<String, dynamic>.from(raw));
      if (!local.isSynced || local.updatedAt.isAfter(remote.updatedAt)) return;
    }
    await _transactionBox.put(remote.id, remote.toJson());
  }

  Future<void> _mergeWishlist(WishlistModel remote) async {
    final raw = _wishlistBox.get(remote.id);
    if (raw != null) {
      final local = WishlistModel.fromJson(Map<String, dynamic>.from(raw));
      if (!local.isSynced || local.updatedAt.isAfter(remote.updatedAt)) return;
    }
    await _wishlistBox.put(remote.id, remote.toJson());
  }

  Future<void> _mergeBudget(BudgetModel remote) async {
    final raw = _budgetBox.get(remote.id);
    if (raw != null) {
      final local = BudgetModel.fromJson(Map<String, dynamic>.from(raw));
      if (!local.isSynced || local.updatedAt.isAfter(remote.updatedAt)) return;
    }
    await _budgetBox.put(remote.id, remote.toJson());
  }

  Future<void> _mergeAccounts(AccountModel remote) async {
    final raw = _accountBox.get(remote.id);
    if (raw != null) {
      final local = AccountModel.fromJson(Map<String, dynamic>.from(raw));
      if (!local.isSynced || local.updatedAt.isAfter(remote.updatedAt)) return;
    }
    await _accountBox.put(remote.id, remote.toJson());
  }

  /// Unlike the other merges, this isn't a last-write-wins timestamp
  /// comparison — alerts.created_at never changes, but read_at can be set
  /// locally (via markRead, which writes straight to Supabase + the local
  /// cache) between pulls. Don't let a since-stale remote row with
  /// read_at == null clobber a local copy that's already been marked read.
  Future<void> _mergeAlert(AlertModel remote) async {
    final raw = _alertsBox.get(remote.id);
    if (raw != null) {
      final local = AlertModel.fromJson(Map<String, dynamic>.from(raw));
      if (local.readAt != null && remote.readAt == null) return;
    }
    await _alertsBox.put(remote.id, remote.toJson());
  }

  DateTime _lastSyncedAt(String key, String userId) {
    final iso = _syncMetaBox.get('last_synced_${key}_$userId') as String?;
    return iso != null ? DateTime.parse(iso) : DateTime.fromMillisecondsSinceEpoch(0);
  }

  Future<void> _setLastSyncedAt(String key, String userId, DateTime value) async {
    await _syncMetaBox.put('last_synced_${key}_$userId', value.toIso8601String());
  }
}
