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

    final raw = _box.get(id);
    if (raw == null) return;
    final alert = AlertModel.fromJson(Map<String, dynamic>.from(raw));
    await _box.put(id, alert.copyWith(readAt: now).toJson());
  }
}
