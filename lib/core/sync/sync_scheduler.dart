import 'dart:async';

import 'package:hive/hive.dart';

/// Triggers a sync shortly after local writes, by watching the Hive boxes
/// that [SyncService] pushes. Only writes flagged `is_synced == false` count,
/// so the sync's own writes (marking rows synced, merging pulled rows) never
/// retrigger it. Bursts of writes are debounced into one sync, and writes
/// that land while a sync is running cause exactly one follow-up run.
class SyncScheduler {
  SyncScheduler({
    required Iterable<Box<Map>> boxes,
    required Future<void> Function() onSync,
    this.debounce = const Duration(seconds: 3),
  }) : _onSync = onSync {
    for (final box in boxes) {
      _subscriptions.add(box.watch().listen(_onEvent));
    }
  }

  final Duration debounce;
  final Future<void> Function() _onSync;
  final _subscriptions = <StreamSubscription<BoxEvent>>[];

  Timer? _timer;
  bool _running = false;
  bool _pending = false;
  bool _disposed = false;

  void _onEvent(BoxEvent event) {
    final value = event.value;
    if (event.deleted || value is! Map || value['is_synced'] != false) return;

    _timer?.cancel();
    _timer = Timer(debounce, _run);
  }

  Future<void> _run() async {
    if (_disposed) return;
    if (_running) {
      _pending = true;
      return;
    }
    _running = true;
    try {
      do {
        _pending = false;
        await _onSync();
      } while (_pending && !_disposed);
    } finally {
      _running = false;
    }
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
  }
}
