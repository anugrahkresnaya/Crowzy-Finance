import 'dart:async';
import 'dart:io';

import 'package:crowzy_finance/core/sync/sync_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  const debounce = Duration(milliseconds: 40);
  const settle = Duration(milliseconds: 150);

  late Box<Map> box;
  late SyncScheduler scheduler;
  late int syncs;
  Completer<void>? gate;

  Future<void> onSync() async {
    syncs++;
    await gate?.future;
  }

  setUp(() async {
    Hive.init(Directory.systemTemp.createTempSync().path);
    box = await Hive.openBox<Map>('t_scheduler');
    syncs = 0;
    gate = null;
    scheduler = SyncScheduler(boxes: [box], onSync: onSync, debounce: debounce);
  });

  tearDown(() async {
    scheduler.dispose();
    await box.deleteFromDisk();
  });

  Future<void> write(String id, {required bool isSynced}) =>
      box.put(id, {'id': id, 'is_synced': isSynced});

  test('an unsynced write triggers a sync after the debounce', () async {
    await write('a', isSynced: false);
    expect(syncs, 0);

    await Future<void>.delayed(settle);
    expect(syncs, 1);
  });

  test('a burst of writes collapses into one sync', () async {
    for (var i = 0; i < 5; i++) {
      await write('a$i', isSynced: false);
    }

    await Future<void>.delayed(settle);
    expect(syncs, 1);
  });

  test('synced writes and deletes do not trigger a sync', () async {
    await write('a', isSynced: true);
    await box.delete('a');

    await Future<void>.delayed(settle);
    expect(syncs, 0);
  });

  test('writes made while a sync is running cause exactly one follow-up', () async {
    gate = Completer<void>();
    await write('a', isSynced: false);
    await Future<void>.delayed(settle);
    expect(syncs, 1);

    await write('b', isSynced: false);
    await write('c', isSynced: false);
    await Future<void>.delayed(settle);
    expect(syncs, 1, reason: 'follow-up must wait for the running sync');

    gate!.complete();
    await Future<void>.delayed(settle);
    expect(syncs, 2);
  });

  test('dispose cancels a pending sync', () async {
    await write('a', isSynced: false);
    scheduler.dispose();

    await Future<void>.delayed(settle);
    expect(syncs, 0);
  });
}
