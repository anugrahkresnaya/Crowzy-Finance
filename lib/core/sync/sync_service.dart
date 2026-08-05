import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/alert_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/wishlist_model.dart';

class SyncService {
  SyncService(
    this._client,
    this._categoryBox,
    this._transactionBox,
    this._wishlistBox,
    this._alertsBox,
    this._syncMetaBox,
  );

  final SupabaseClient _client;
  final Box<Map> _categoryBox;
  final Box<Map> _transactionBox;
  final Box<Map> _wishlistBox;
  final Box<Map> _alertsBox;
  final Box _syncMetaBox;

  static const _pageSize = 500;

  Future<void> sync(String userId) async {
    await _pushCategories();
    await _pushTransactions();
    await _pushWishlist();
    await _pullCategories(userId);
    await _pullTransactions(userId);
    await _pullWishlist(userId);
    await _pullAlerts(userId);
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
