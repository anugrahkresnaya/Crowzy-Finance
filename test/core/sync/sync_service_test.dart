import 'dart:convert';
import 'dart:io';

import 'package:crowzy_finance/core/sync/sync_service.dart';
import 'package:crowzy_finance/data/models/account_model.dart';
import 'package:crowzy_finance/data/models/account_type.dart';
import 'package:crowzy_finance/data/models/alert_model.dart';
import 'package:crowzy_finance/data/models/alert_type.dart';
import 'package:crowzy_finance/data/models/budget_model.dart';
import 'package:crowzy_finance/data/models/category_model.dart';
import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/data/models/transfer_model.dart';
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
  late Box<Map> budgets;
  late Box<Map> accounts;
  late Box<Map> transfers;
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
    budgets = await Hive.openBox<Map>('t_budgets');
    accounts = await Hive.openBox<Map>('t_accounts');
    transfers = await Hive.openBox<Map>('t_transfers');
    alerts = await Hive.openBox<Map>('t_alerts');
    syncMeta = await Hive.openBox('t_sync_meta');

    service = SyncService(
      supabase,
      categories,
      transactions,
      wishlist,
      budgets,
      accounts,
      transfers,
      alerts,
      syncMeta,
    );
  });

  tearDown(() async {
    await supabase.dispose();
    for (final box in [categories, transactions, wishlist, budgets, accounts, transfers, alerts, syncMeta]) {
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

  BudgetModel budget(
    String id, {
    String categoryId = 'c1',
    double limit = 1000000,
    bool isSynced = true,
    bool isDeleted = false,
    DateTime? updatedAt,
  }) =>
      BudgetModel(
        id: id,
        userId: userId,
        categoryId: categoryId,
        monthlyLimit: limit,
        isDeleted: isDeleted,
        createdAt: DateTime.utc(2026, 7, 1),
        updatedAt: updatedAt ?? DateTime.utc(2026, 7, 1),
        isSynced: isSynced,
      );

  AccountModel account(
    String id, {
    String name = 'BCA',
    double opening = 0,
    bool isSynced = true,
    bool isDeleted = false,
    DateTime? updatedAt,
  }) =>
      AccountModel(
        id: id,
        userId: userId,
        name: name,
        type: AccountType.bank,
        openingBalance: opening,
        isDeleted: isDeleted,
        createdAt: DateTime.utc(2026, 7, 1),
        updatedAt: updatedAt ?? DateTime.utc(2026, 7, 1),
        isSynced: isSynced,
      );

  TransferModel transfer(
    String id, {
    double amount = 500000,
    double fee = 2500,
    bool isSynced = true,
    bool isDeleted = false,
    DateTime? updatedAt,
  }) =>
      TransferModel(
        id: id,
        userId: userId,
        fromAccountId: 'a1',
        toAccountId: 'a2',
        amount: amount,
        fee: fee,
        date: DateTime.utc(2026, 7, 5),
        isDeleted: isDeleted,
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

  group('accounts', () {
    test('an unsynced account is pushed without the local flag and marked synced', () async {
      await accounts.put('a1', account('a1', isSynced: false, opening: 250000).toJson());
      await accounts.put('a2', account('a2', name: 'DANA').toJson());

      await service.sync(userId);

      final rows = jsonDecode(posts('accounts').single.body) as List;
      expect(rows.map((r) => r['id']), ['a1']);
      expect(rows.single.containsKey('is_synced'), isFalse);
      expect(rows.single['opening_balance'], 250000);
      expect(rows.single['type'], 'bank');

      final stored = AccountModel.fromJson(Map<String, dynamic>.from(accounts.get('a1')!));
      expect(stored.isSynced, isTrue);
    });

    test('remote accounts are stored as synced, reading numeric strings too', () async {
      remote['accounts'] = [
        {...account('a1', updatedAt: DateTime.utc(2026, 7, 3)).toSupabaseRow(), 'opening_balance': '1850000.00'},
      ];

      await service.sync(userId);

      final stored = AccountModel.fromJson(Map<String, dynamic>.from(accounts.get('a1')!));
      expect(stored.openingBalance, 1850000);
      expect(stored.isSynced, isTrue);
      expect(
        DateTime.parse(syncMeta.get('last_synced_accounts_$userId') as String),
        DateTime.utc(2026, 7, 3),
      );
    });

    test('an unsynced local account is not overwritten by the pull', () async {
      await accounts.put('a1', account('a1', name: 'Mine', isSynced: false).toJson());
      remote['accounts'] = [
        account('a1', name: 'Theirs', updatedAt: DateTime.utc(2026, 7, 9)).toSupabaseRow(),
      ];
      failPostWithStatus = 500;

      await expectLater(service.sync(userId), throwsA(isA<SyncException>()));

      final stored = AccountModel.fromJson(Map<String, dynamic>.from(accounts.get('a1')!));
      expect(stored.name, 'Mine');
    });
  });

  group('transfers', () {
    test('an unsynced transfer is pushed with its fee and marked synced', () async {
      await transfers.put('t1', transfer('t1', isSynced: false).toJson());
      await transfers.put('t2', transfer('t2').toJson());

      await service.sync(userId);

      final rows = jsonDecode(posts('transfers').single.body) as List;
      expect(rows.map((r) => r['id']), ['t1']);
      expect(rows.single.containsKey('is_synced'), isFalse);
      expect(rows.single['amount'], 500000);
      expect(rows.single['fee'], 2500);
      expect(rows.single['from_account_id'], 'a1');
      expect(rows.single['to_account_id'], 'a2');

      final stored = TransferModel.fromJson(Map<String, dynamic>.from(transfers.get('t1')!));
      expect(stored.isSynced, isTrue);
    });

    test('a deleted transfer is pushed as a soft delete', () async {
      await transfers.put('t1', transfer('t1', isDeleted: true, isSynced: false).toJson());

      await service.sync(userId);

      final rows = jsonDecode(posts('transfers').single.body) as List;
      expect(rows.single['is_deleted'], isTrue);
    });

    test('accounts and transfers are pushed before the transactions that point at them', () async {
      await categories.put('c1', category('c1', isSynced: false).toJson());
      await transactions.put('x1', transaction('x1', isSynced: false).toJson());
      await transfers.put('t1', transfer('t1', isSynced: false).toJson());
      await accounts.put('a1', account('a1', isSynced: false).toJson());

      await service.sync(userId);

      final order = requests
          .where((r) => r.method == 'POST')
          .map((r) => r.url.pathSegments.last)
          .toList();
      expect(order, ['categories', 'accounts', 'transfers', 'transactions']);
    });

    test('remote transfers are stored as synced, reading numeric strings too', () async {
      remote['transfers'] = [
        {
          ...transfer('t1', updatedAt: DateTime.utc(2026, 7, 3)).toSupabaseRow(),
          'amount': '500000.00',
          'fee': '2500.00',
        },
      ];

      await service.sync(userId);

      final stored = TransferModel.fromJson(Map<String, dynamic>.from(transfers.get('t1')!));
      expect(stored.amount, 500000);
      expect(stored.fee, 2500);
      expect(stored.isSynced, isTrue);
    });

    test('a newer remote transfer replaces a synced local one, an unsynced one is kept', () async {
      await transfers.put('t1', transfer('t1', amount: 100).toJson());
      await transfers.put('t2', transfer('t2', amount: 100, isSynced: false).toJson());
      remote['transfers'] = [
        transfer('t1', amount: 900, updatedAt: DateTime.utc(2026, 7, 9)).toSupabaseRow(),
        transfer('t2', amount: 900, updatedAt: DateTime.utc(2026, 7, 9)).toSupabaseRow(),
      ];
      failPostWithStatus = 500;

      await expectLater(service.sync(userId), throwsA(isA<SyncException>()));

      expect(TransferModel.fromJson(Map<String, dynamic>.from(transfers.get('t1')!)).amount, 900);
      expect(TransferModel.fromJson(Map<String, dynamic>.from(transfers.get('t2')!)).amount, 100);
    });
  });

  group('budgets', () {
    test('an unsynced limit is pushed without the local flag and marked synced', () async {
      await budgets.put('b1', budget('b1', isSynced: false).toJson());
      await budgets.put('b2', budget('b2', categoryId: 'c2').toJson());

      await service.sync(userId);

      final sent = posts('budgets');
      expect(sent, hasLength(1));
      final rows = jsonDecode(sent.single.body) as List;
      expect(rows.map((r) => r['id']), ['b1']);
      expect(rows.single.containsKey('is_synced'), isFalse);
      expect(rows.single['monthly_limit'], 1000000);
      expect(rows.single['category_id'], 'c1');

      final stored = BudgetModel.fromJson(Map<String, dynamic>.from(budgets.get('b1')!));
      expect(stored.isSynced, isTrue);
    });

    test('categories are pushed before budgets so the category exists server-side', () async {
      await categories.put('c1', category('c1', isSynced: false).toJson());
      await budgets.put('b1', budget('b1', isSynced: false).toJson());

      await service.sync(userId);

      final order = requests
          .where((r) => r.method == 'POST')
          .map((r) => r.url.pathSegments.last)
          .toList();
      expect(order, ['categories', 'budgets']);
    });

    test('a cleared limit is pushed as a soft delete', () async {
      await budgets.put('b1', budget('b1', isDeleted: true, isSynced: false).toJson());

      await service.sync(userId);

      final rows = jsonDecode(posts('budgets').single.body) as List;
      expect(rows.single['is_deleted'], isTrue);
    });

    test('remote limits are stored as synced, reading numeric strings too', () async {
      remote['budgets'] = [
        {...budget('b1', updatedAt: DateTime.utc(2026, 7, 3)).toSupabaseRow(), 'monthly_limit': '2500000.00'},
      ];

      await service.sync(userId);

      final stored = BudgetModel.fromJson(Map<String, dynamic>.from(budgets.get('b1')!));
      expect(stored.monthlyLimit, 2500000);
      expect(stored.isSynced, isTrue);
      expect(
        DateTime.parse(syncMeta.get('last_synced_budgets_$userId') as String),
        DateTime.utc(2026, 7, 3),
      );
    });

    test('a newer remote limit replaces a synced local one', () async {
      await budgets.put('b1', budget('b1', limit: 100).toJson());
      remote['budgets'] = [
        budget('b1', limit: 900, updatedAt: DateTime.utc(2026, 7, 9)).toSupabaseRow(),
      ];

      await service.sync(userId);

      final stored = BudgetModel.fromJson(Map<String, dynamic>.from(budgets.get('b1')!));
      expect(stored.monthlyLimit, 900);
    });

    test('an unsynced local limit is not overwritten by the pull', () async {
      await budgets.put('b1', budget('b1', limit: 500, isSynced: false).toJson());
      remote['budgets'] = [
        budget('b1', limit: 900, updatedAt: DateTime.utc(2026, 7, 9)).toSupabaseRow(),
      ];
      failPostWithStatus = 500;

      await expectLater(service.sync(userId), throwsA(isA<SyncException>()));

      final stored = BudgetModel.fromJson(Map<String, dynamic>.from(budgets.get('b1')!));
      expect(stored.monthlyLimit, 500);
      expect(stored.isSynced, isFalse);
    });

    test('only the user\'s own budgets are requested', () async {
      await service.sync(userId);

      final get = requests.firstWhere((r) => r.url.pathSegments.last == 'budgets' && r.method == 'GET');
      expect(get.url.queryParameters['user_id'], 'eq.$userId');
    });
  });
}
