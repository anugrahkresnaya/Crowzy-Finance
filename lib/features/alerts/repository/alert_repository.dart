import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/alert_model.dart';

class AlertRepository {
  AlertRepository(this._box, this._client);

  final Box<Map> _box;
  final SupabaseClient _client;

  List<AlertModel> getAll() {
    return _box.values
        .map((raw) => AlertModel.fromJson(Map<String, dynamic>.from(raw)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Alerts are server-authored — there's no local dirty-flag/push cycle for
  /// them like transactions/categories/wishlist. read_at is written straight
  /// to Supabase and mirrored into the local cache so the UI updates
  /// immediately without waiting for the next sync pull.
  Future<void> markRead(String id) async {
    final now = DateTime.now();
    await _client.from('alerts').update({'read_at': now.toIso8601String()}).eq('id', id);
    await applyReadLocally([id], now);
  }

  /// Marks every unread alert as read with a single request. Does nothing when
  /// there are none.
  Future<void> markAllRead() async {
    final ids = getAll().where((a) => a.isUnread).map((a) => a.id).toList();
    if (ids.isEmpty) return;

    final now = DateTime.now();
    await _client.from('alerts').update({'read_at': now.toIso8601String()}).inFilter('id', ids);
    await applyReadLocally(ids, now);
  }

  /// Mirrors a read-at time into the local cache for [ids], skipping any that
  /// are not cached.
  Future<void> applyReadLocally(Iterable<String> ids, DateTime readAt) async {
    for (final id in ids) {
      final raw = _box.get(id);
      if (raw == null) continue;
      final alert = AlertModel.fromJson(Map<String, dynamic>.from(raw));
      await _box.put(id, alert.copyWith(readAt: readAt).toJson());
    }
  }
}
