import 'dart:io';

import 'package:crowzy_finance/core/constants/default_categories.dart';
import 'package:crowzy_finance/data/models/category_model.dart';
import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/features/accounts/providers/transfer_provider.dart';
import 'package:crowzy_finance/features/accounts/utils/transfers.dart';
import 'package:crowzy_finance/features/auth/providers/auth_provider.dart';
import 'package:crowzy_finance/features/categories/providers/category_provider.dart';
import 'package:crowzy_finance/features/transactions/providers/transaction_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  late Box<Map> transactionBox;
  late Box<Map> categoryBox;
  late ProviderContainer container;

  ProviderContainer build({User? user}) {
    final c = ProviderContainer(overrides: [
      transactionBoxProvider.overrideWithValue(transactionBox),
      categoryBoxProvider.overrideWithValue(categoryBox),
      currentUserProvider.overrideWithValue(
        user ?? const User(id: 'u1', appMetadata: {}, userMetadata: {}, aud: '', createdAt: ''),
      ),
    ]);
    addTearDown(c.dispose);
    c.listen(transactionListProvider, (_, _) {});
    return c;
  }

  setUp(() async {
    Hive.init(Directory.systemTemp.createTempSync().path);
    transactionBox = await Hive.openBox<Map>('test_actions_transactions');
    categoryBox = await Hive.openBox<Map>('test_actions_categories');
    container = build();
    await container.read(transactionListProvider.future);
  });

  tearDown(() async {
    await transactionBox.deleteFromDisk();
    await categoryBox.deleteFromDisk();
  });

  TransferActions actions() => container.read(transferActionsProvider);

  Future<List<TransactionModel>> rows() async {
    container.invalidate(transactionListProvider);
    return container.read(transactionListProvider.future);
  }

  List<TransactionModel> allRows() => [
        for (final raw in transactionBox.values)
          TransactionModel.fromJson(Map<String, dynamic>.from(raw)),
      ];

  Future<void> create({double fee = 0, String? note = 'topup'}) => actions().create(
        fromAccountId: 'bca',
        toAccountId: 'dana',
        amount: 390000,
        fee: fee,
        date: DateTime(2026, 10, 3, 7, 20),
        note: note,
      );

  Future<void> putCategory(String id, String name, {String? userId = 'u1', bool deleted = false}) =>
      categoryBox.put(
        id,
        CategoryModel(
          id: id,
          userId: userId,
          name: name,
          icon: 'work',
          type: TransactionType.expense,
          isDeleted: deleted,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ).toJson(),
      );

  group('create', () {
    test('writes the two legs the way the live server holds a transfer', () async {
      await create();

      final all = allRows();
      expect(all, hasLength(2));
      final out = all.singleWhere((t) => t.type == TransactionType.expense);
      final into = all.singleWhere((t) => t.type == TransactionType.income);

      expect(out.categoryId, DefaultCategories.transferOutId);
      expect(out.accountId, 'bca');
      expect(into.categoryId, DefaultCategories.transferInId);
      expect(into.accountId, 'dana');
      expect(out.transferGroupId, isNotNull);
      expect(into.transferGroupId, out.transferGroupId);
      expect(out.amount, 390000);
      expect(into.amount, 390000);
      expect(out.date, DateTime(2026, 10, 3, 7, 20));
      expect(into.date, out.date);
      expect(out.note, 'topup');
      expect(into.note, 'topup');
      expect(out.userId, 'u1');
      expect(out.isSynced, isFalse);
      expect(into.isSynced, isFalse);
    });

    test('the legs read back as one transfer', () async {
      await create();
      await rows();

      final transfer = container.read(transferListProvider).single;
      expect(transfer.fromAccountId, 'bca');
      expect(transfer.toAccountId, 'dana');
      expect(transfer.amount, 390000);
      expect(transfer.note, 'topup');
      expect(transfer.isSynced, isFalse);
    });

    test('with no fee it writes nothing else', () async {
      await create();

      expect(allRows(), hasLength(2));
    });

    test('a fee is an ordinary expense on the source, with no group id, under the derived id', () async {
      await putCategory('c-fee', 'Admin Fee');
      await create(fee: 2500);

      final group = allRows().firstWhere((t) => t.transferGroupId != null).transferGroupId!;
      final fee = allRows().singleWhere((t) => t.id == feeIdFor(group));

      expect(fee.amount, 2500);
      expect(fee.type, TransactionType.expense);
      expect(fee.accountId, 'bca');
      expect(fee.note, 'Transfer fee');
      expect(fee.transferGroupId, isNull);
      expect(fee.date, DateTime(2026, 10, 3, 7, 20));
      expect(fee.isSynced, isFalse);
      expect(allRows(), hasLength(3));
    });

    test('the fee reads back as part of its transfer', () async {
      await create(fee: 2500);
      await rows();

      expect(container.read(transferListProvider).single.fee, 2500);
      expect(container.read(feeTransfersProvider), hasLength(1));
    });

    test('the fee uses the Admin Fee category the user already has, found by name', () async {
      await putCategory('c-fee', '  admin FEE ');
      await create(fee: 2500);

      final fee = allRows().singleWhere((t) => t.note == 'Transfer fee');
      expect(fee.categoryId, 'c-fee');
      expect(categoryBox.length, 1);
    });

    test('an Admin Fee category that was deleted is not reused', () async {
      await putCategory('c-old', 'Admin Fee', deleted: true);
      await create(fee: 2500);

      final fee = allRows().singleWhere((t) => t.note == 'Transfer fee');
      expect(fee.categoryId, isNot('c-old'));
    });

    test('with no Admin Fee category yet, one is created for the user and used', () async {
      await create(fee: 2500);

      final fee = allRows().singleWhere((t) => t.note == 'Transfer fee');
      final category = CategoryModel.fromJson(Map<String, dynamic>.from(categoryBox.get(fee.categoryId)!));

      expect(category.name, 'Admin Fee');
      expect(category.type, TransactionType.expense);
      expect(category.userId, 'u1');
      expect(category.isSynced, isFalse);
    });

    test('a second fee reuses the category made for the first', () async {
      await create(fee: 100);
      await create(fee: 200);

      expect(categoryBox.length, 1);
    });

    test('needs someone signed in', () async {
      final signedOut = ProviderContainer(overrides: [
        transactionBoxProvider.overrideWithValue(transactionBox),
        categoryBoxProvider.overrideWithValue(categoryBox),
        currentUserProvider.overrideWithValue(null),
      ]);
      addTearDown(signedOut.dispose);

      await expectLater(
        signedOut.read(transferActionsProvider).create(
              fromAccountId: 'a',
              toAccountId: 'b',
              amount: 1,
              date: DateTime(2026),
            ),
        throwsStateError,
      );
      expect(transactionBox.isEmpty, isTrue);
    });
  });

  group('update', () {
    Future<void> change({
      double amount = 500000,
      double fee = 0,
      String from = 'bca',
      String to = 'dana',
      String? note,
    }) async {
      await rows();
      final transfer = container.read(transferListProvider).single;
      await actions().update(
        transfer,
        fromAccountId: from,
        toAccountId: to,
        amount: amount,
        fee: fee,
        date: DateTime(2026, 10, 5),
        note: note,
      );
    }

    test('changes both legs together and marks them unsynced again', () async {
      await create();
      for (final t in allRows()) {
        await transactionBox.put(t.id, t.copyWith(isSynced: true).toJson());
      }

      await change(amount: 750000, from: 'cash', to: 'jago', note: 'rent');

      for (final t in allRows()) {
        expect(t.amount, 750000);
        expect(t.date, DateTime(2026, 10, 5));
        expect(t.note, 'rent');
        expect(t.isSynced, isFalse);
      }
      expect(allRows().singleWhere((t) => t.type == TransactionType.expense).accountId, 'cash');
      expect(allRows().singleWhere((t) => t.type == TransactionType.income).accountId, 'jago');
    });

    test('clearing the note clears it on both legs', () async {
      await create(note: 'topup');

      await change(note: null);

      expect(allRows().every((t) => t.note == null), isTrue);
    });

    test('changing the fee updates the fee expense in place, and follows the source and date', () async {
      await create(fee: 2500);

      await change(fee: 4000, from: 'cash');

      final fee = allRows().singleWhere((t) => t.note == 'Transfer fee');
      expect(fee.amount, 4000);
      expect(fee.accountId, 'cash');
      expect(fee.date, DateTime(2026, 10, 5));
      expect(allRows().where((t) => t.note == 'Transfer fee'), hasLength(1));
    });

    test('adding a fee to a transfer that had none creates it', () async {
      await create();

      await change(fee: 1000);

      expect(allRows().singleWhere((t) => t.note == 'Transfer fee').amount, 1000);
    });

    test('removing the fee soft-deletes the fee expense, and adding it back revives it', () async {
      await create(fee: 2500);
      final created = allRows().singleWhere((t) => t.note == 'Transfer fee').createdAt;

      await change(fee: 0);
      expect(allRows().singleWhere((t) => t.note == 'Transfer fee').isDeleted, isTrue);

      await change(fee: 3000);
      final revived = allRows().singleWhere((t) => t.note == 'Transfer fee');
      expect(revived.isDeleted, isFalse);
      expect(revived.amount, 3000);
      expect(revived.createdAt, created);
    });

    test('keeps the category the fee already has', () async {
      await create(fee: 2500);
      final fee = allRows().singleWhere((t) => t.note == 'Transfer fee');
      await transactionBox.put(fee.id, fee.copyWith(categoryId: 'chosen').toJson());

      await change(fee: 3000);

      expect(allRows().singleWhere((t) => t.note == 'Transfer fee').categoryId, 'chosen');
    });
  });

  group('delete', () {
    test('soft-deletes both legs and the fee, and the transfer is gone', () async {
      await create(fee: 2500);
      await rows();

      await actions().delete(container.read(transferListProvider).single);

      expect(allRows(), hasLength(3));
      expect(allRows().every((t) => t.isDeleted && !t.isSynced), isTrue);
      await rows();
      expect(container.read(transferListProvider), isEmpty);
    });

    test('a transfer with no fee deletes cleanly', () async {
      await create();
      await rows();

      await actions().delete(container.read(transferListProvider).single);

      expect(allRows().every((t) => t.isDeleted), isTrue);
    });

    test('leaves other transfers alone', () async {
      await create(note: 'one');
      await create(note: 'two');
      await rows();
      final first = container.read(transferListProvider).firstWhere((t) => t.note == 'one');

      await actions().delete(first);
      await rows();

      expect(container.read(transferListProvider).single.note, 'two');
    });
  });

  group('LastTransferSource', () {
    test('remembers the account last sent from', () async {
      final meta = await Hive.openBox('test_last_source');
      addTearDown(meta.deleteFromDisk);
      final source = LastTransferSource(meta);

      expect(source.value, isNull);
      await source.save('bca');
      expect(source.value, 'bca');
    });
  });
}
