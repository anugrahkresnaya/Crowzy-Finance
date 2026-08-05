import 'dart:io';

import 'package:crowzy_finance/data/models/alert_model.dart';
import 'package:crowzy_finance/data/models/alert_type.dart';
import 'package:crowzy_finance/features/alerts/repository/alert_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  late Box<Map> box;
  late AlertRepository repository;

  setUp(() async {
    Hive.init(Directory.systemTemp.createTempSync().path);
    box = await Hive.openBox<Map>('test_alerts');
    // getAll() never touches the network, so a client pointed at a
    // placeholder project is enough — no Supabase.initialize() needed.
    repository = AlertRepository(box, SupabaseClient('https://example.supabase.co', 'anon-key'));
  });

  tearDown(() async {
    await box.deleteFromDisk();
  });

  AlertModel buildAlert({String id = 'a1', DateTime? createdAt, DateTime? readAt}) {
    return AlertModel(
      id: id,
      userId: 'u1',
      type: AlertType.overspend,
      period: '2026-07',
      message: 'You spent more than you earned this month.',
      createdAt: createdAt ?? DateTime(2026, 7, 1),
      readAt: readAt,
    );
  }

  test('getAll returns alerts sorted newest first', () async {
    await box.put('a1', buildAlert(id: 'a1', createdAt: DateTime(2026, 7, 1)).toJson());
    await box.put('a2', buildAlert(id: 'a2', createdAt: DateTime(2026, 7, 10)).toJson());

    final all = repository.getAll();
    expect(all.map((a) => a.id), ['a2', 'a1']);
  });

  test('AlertModel.isUnread is true when read_at is null', () {
    final unread = buildAlert();
    final read = buildAlert(readAt: DateTime(2026, 7, 2));

    expect(unread.isUnread, isTrue);
    expect(read.isUnread, isFalse);
  });
}
