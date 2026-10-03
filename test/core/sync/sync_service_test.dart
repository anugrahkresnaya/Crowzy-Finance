import 'dart:convert';
import 'dart:io';

import 'package:crowzy_finance/core/sync/sync_service.dart';
import 'package:crowzy_finance/data/models/alert_model.dart';
import 'package:crowzy_finance/data/models/alert_type.dart';
import 'package:crowzy_finance/data/models/category_model.dart';
import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/data/models/wishlist_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeBaseRequest extends Fake implements http.BaseRequest {}

/// SupabaseClient's query builders are thenables that can't be stubbed call
/// by call, so the mock sits one level lower, at the HTTP client. SyncService
/// runs against the real postgrest client and a canned in-memory "server".
void main() {
  const userId = 'u1';

  late MockHttpClient httpClient;
  late SupabaseClient supabase;
  late Box<Map> categories;
  late Box<Map> transactions;
  late Box<Map> wishlist;
  late Box<Map> alerts;
  late Box syncMeta;
  late SyncService service;

  /// Rows the fake server returns for GET /rest/v1/<table> at offset 0.
  late Map<String, List<Map<String, dynamic>>> remote;
  late List<http.Request> requests;
  int? failPostWithStatus;

  setUpAll(() => registerFallbackValue(FakeBaseRequest()));

  setUp(() async {
    remote = {};
    requests = [];
    failPostWithStatus = null;

    httpClient = MockHttpClient();
    when(() => httpClient.send(any())).thenAnswer((invocation) async {
      final request = invocation.positionalArguments.first as http.Request;
      requests.add(request);

      final table = request.url.pathSegments.last;
      late final int status;
      late final String body;
      if (request.method == 'POST') {
        status = failPostWithStatus ?? 201;
        body = failPostWithStatus == null
            ? ''
            : jsonEncode({'message': 'boom', 'code': 'XX000'});
      } else {
        final offset = int.parse(request.url.queryParameters['offset'] ?? '0');
        status = 200;
        body = jsonEncode(offset == 0 ? remote[table] ?? [] : []);
      }
      return http.StreamedResponse(
        Stream.value(utf8.encode(body)),
        status,
        headers: {'content-type': 'application/json; charset=utf-8'},
        request: request,
      );
    });

    supabase = SupabaseClient(
      'https://example.supabase.co',
      'anon-key',
      httpClient: httpClient,
    );

    Hive.init(Directory.systemTemp.createTempSync().path);
    categories = await Hive.openBox<Map>('t_categories');
    transactions = await Hive.openBox<Map>('t_transactions');
    wishlist = await Hive.openBox<Map>('t_wishlist');
    alerts = await Hive.openBox<Map>('t_alerts');
    syncMeta = await Hive.openBox('t_sync_meta');

    service = SyncService(supabase, categories, transactions, wishlist, alerts, syncMeta);
  });

  tearDown(() async {
    await supabase.dispose();
    for (final box in [categories, transactions, wishlist, alerts, syncMeta]) {
      await box.deleteFromDisk();
    }
  });

  CategoryModel category(String id, {bool isSynced = true, DateTime? updatedAt, String name = 'Food'}) =>
      CategoryModel(
        id: id,
        userId: userId,
        name: name,
        icon: 'restaurant',
        type: TransactionType.expense,
        createdAt: DateTime.utc(2026, 7, 1),
        updatedAt: updatedAt ?? DateTime.utc(2026, 7, 1),
        isSynced: isSynced,
      );

  TransactionModel transaction(
    String id, {
    bool isSynced = true,
    DateTime? updatedAt,
    double amount = 10,
  }) =>
      TransactionModel(
        id: id,
        userId: userId,
        amount: amount,
        type: TransactionType.expense,
        categoryId: 'c1',
        date: DateTime.utc(2026, 7, 5),
        createdAt: DateTime.utc(2026, 7, 1),
        updatedAt: updatedAt ?? DateTime.utc(2026, 7, 1),
        isSynced: isSynced,
      );

  AlertModel alert(String id, {DateTime? readAt}) => AlertModel(
        id: id,
        userId: userId,
        type: AlertType.overspend,
        period: '2026-07',
        message: 'You spent more than you earned this month.',
        createdAt: DateTime.utc(2026, 7, 10),
        readAt: readAt,
      );

  List<http.Request> posts(String table) =>
      requests.where((r) => r.method == 'POST' && r.url.pathSegments.last == table).toList();

  group('push', () {
    test('uploads only unsynced rows, without the local is_synced flag, then marks them synced', () async {
      await transactions.put('dirty', transaction('dirty', isSynced: false).toJson());
      await transactions.put('clean', transaction('clean').toJson());

      await service.sync(userId);

      final sent = posts('transactions');
      expect(sent, hasLength(1));
      final rows = jsonDecode(sent.single.body) as List;
      expect(rows.map((r) => r['id']), ['dirty']);
      expect(rows.single.containsKey('is_synced'), isFalse);

      final stored = TransactionModel.fromJson(Map<String, dynamic>.from(transactions.get('dirty')!));
      expect(stored.isSynced, isTrue);
    });

    test('makes no write request when everything is already synced', () async {
      await categories.put('c1', category('c1').toJson());

      await service.sync(userId);

      expect(requests.where((r) => r.method == 'POST'), isEmpty);
    });

    test('a failed push leaves rows dirty and is reported, but the other steps still run', () async {
      await transactions.put('dirty', transaction('dirty', isSynced: false).toJson());
      remote['wishlist'] = [
        WishlistModel(
          id: 'w1',
          userId: userId,
          name: 'Laptop',
          targetAmount: 1000,
          createdAt: DateTime.utc(2026, 7, 1),
          updatedAt: DateTime.utc(2026, 7, 4),
        ).toSupabaseRow(),
      ];
      failPostWithStatus = 500;

      final error = await service.sync(userId).then<Object?>((_) => null, onError: (e) => e);

      expect(error, isA<SyncException>());
      expect((error! as SyncException).failures.map((f) => f.step), ['push transactions']);

      final stored = TransactionModel.fromJson(Map<String, dynamic>.from(transactions.get('dirty')!));
      expect(stored.isSynced, isFalse);
      // Pulls still ran, so unrelated remote data arrived.
      expect(wishlist.containsKey('w1'), isTrue);
    });

    test('a local row whose push failed is not overwritten by the following pull', () async {
      await transactions.put('t1', transaction('t1', amount: 50, isSynced: false).toJson());
      remote['transactions'] = [
        transaction('t1', amount: 10, updatedAt: DateTime.utc(2026, 7, 9)).toSupabaseRow(),
      ];
      failPostWithStatus = 500;

      await expectLater(service.sync(userId), throwsA(isA<SyncException>()));

      final stored = TransactionModel.fromJson(Map<String, dynamic>.from(transactions.get('t1')!));
      expect(stored.amount, 50);
      expect(stored.isSynced, isFalse);
    });
  });

  group('pull', () {
    test('stores remote rows as synced and records the newest updated_at', () async {
      remote['transactions'] = [
        transaction('r1', updatedAt: DateTime.utc(2026, 7, 2)).toSupabaseRow(),
        transaction('r2', updatedAt: DateTime.utc(2026, 7, 3)).toSupabaseRow(),
      ];

      await service.sync(userId);

      expect(transactions.keys, containsAll(['r1', 'r2']));
      final stored = TransactionModel.fromJson(Map<String, dynamic>.from(transactions.get('r1')!));
      expect(stored.isSynced, isTrue);
      expect(
        DateTime.parse(syncMeta.get('last_synced_transactions_$userId') as String),
        DateTime.utc(2026, 7, 3),
      );
    });

    test('a newer remote row overwrites a synced local copy', () async {
      await transactions.put('t1', transaction('t1', amount: 10).toJson());
      remote['transactions'] = [
        transaction('t1', amount: 99, updatedAt: DateTime.utc(2026, 7, 9)).toSupabaseRow(),
      ];

      await service.sync(userId);

      final stored = TransactionModel.fromJson(Map<String, dynamic>.from(transactions.get('t1')!));
      expect(stored.amount, 99);
    });

    test('an older remote row does not overwrite a newer local copy', () async {
      await transactions.put(
        't1',
        transaction('t1', amount: 50, updatedAt: DateTime.utc(2026, 7, 9)).toJson(),
      );
      remote['transactions'] = [
        transaction('t1', amount: 10, updatedAt: DateTime.utc(2026, 7, 2)).toSupabaseRow(),
      ];

      await service.sync(userId);

      final stored = TransactionModel.fromJson(Map<String, dynamic>.from(transactions.get('t1')!));
      expect(stored.amount, 50);
    });

    test('pulls global categories alongside the user\'s own', () async {
      remote['categories'] = [
        category('global', name: 'Salary').copyWith(userId: null).toSupabaseRow(),
      ];

      await service.sync(userId);

      final stored = CategoryModel.fromJson(Map<String, dynamic>.from(categories.get('global')!));
      expect(stored.isGlobal, isTrue);
      final get = requests.firstWhere((r) => r.url.pathSegments.last == 'categories' && r.method == 'GET');
      expect(get.url.queryParameters['or'], '(user_id.eq.$userId,user_id.is.null)');
    });

    test('the second sync only asks for rows newer than the first sync\'s watermark', () async {
      remote['wishlist'] = [
        WishlistModel(
          id: 'w1',
          userId: userId,
          name: 'Laptop',
          targetAmount: 1000,
          createdAt: DateTime.utc(2026, 7, 1),
          updatedAt: DateTime.utc(2026, 7, 4),
        ).toSupabaseRow(),
      ];

      await service.sync(userId);
      requests.clear();
      await service.sync(userId);

      final get = requests.firstWhere((r) => r.url.pathSegments.last == 'wishlist');
      final since = DateTime.parse(get.url.queryParameters['updated_at']!.replaceFirst('gt.', ''));
      expect(since, DateTime.utc(2026, 7, 4));
    });
  });

  group('alerts', () {
    test('are pulled but never pushed', () async {
      remote['alerts'] = [alert('a1').toJson()];

      await service.sync(userId);

      expect(alerts.containsKey('a1'), isTrue);
      expect(posts('alerts'), isEmpty);
    });

    test('a stale unread remote copy does not clobber a locally read alert', () async {
      final readAt = DateTime.utc(2026, 7, 11);
      await alerts.put('a1', alert('a1', readAt: readAt).toJson());
      remote['alerts'] = [alert('a1').toJson()];

      await service.sync(userId);

      final stored = AlertModel.fromJson(Map<String, dynamic>.from(alerts.get('a1')!));
      expect(stored.readAt, readAt);
    });

    test('a remote read_at is accepted when the local copy is unread', () async {
      await alerts.put('a1', alert('a1').toJson());
      remote['alerts'] = [alert('a1', readAt: DateTime.utc(2026, 7, 12)).toJson()];

      await service.sync(userId);

      final stored = AlertModel.fromJson(Map<String, dynamic>.from(alerts.get('a1')!));
      expect(stored.readAt, DateTime.utc(2026, 7, 12));
    });
  });
}
