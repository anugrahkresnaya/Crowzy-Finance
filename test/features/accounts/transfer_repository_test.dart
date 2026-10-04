import 'dart:io';

import 'package:crowzy_finance/core/constants/default_categories.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/data/models/transfer_model.dart';
import 'package:crowzy_finance/features/accounts/repository/transfer_repository.dart';
import 'package:crowzy_finance/features/transactions/repository/transaction_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Box<Map> transferBox;
  late Box<Map> transactionBox;
  late TransferRepository repository;
  late TransactionRepository transactions;

  setUp(() async {
    Hive.init(Directory.systemTemp.createTempSync().path);
    transferBox = await Hive.openBox<Map>('test_transfers');
    transactionBox = await Hive.openBox<Map>('test_transfer_transactions');
    transactions = TransactionRepository(transactionBox);
    repository = TransferRepository(transferBox, transactions);
  });

  tearDown(() async {
    await transferBox.deleteFromDisk();
    await transactionBox.deleteFromDisk();
  });

  TransferModel transfer({
    String id = 't1',
    double amount = 500000,
    double fee = 2500,
    DateTime? date,
  }) =>
      TransferModel(
        id: id,
        userId: 'u1',
        fromAccountId: 'bca',
        toAccountId: 'dana',
        amount: amount,
        fee: fee,
        note: 'Top up DANA',
        date: date ?? DateTime.utc(2026, 10, 2),
        createdAt: DateTime.utc(2026, 10, 2),
        updatedAt: DateTime.utc(2026, 10, 2),
      );

  group('create', () {
    test('stores the transfer unsynced', () async {
      await repository.create(transfer());

      final stored = repository.getAll().single;
      expect(stored.amount, 500000);
      expect(stored.isSynced, isFalse);
    });

    test('records the fee as an expense in Fees on the source account, linked to the transfer', () async {
      await repository.create(transfer());

      final fee = transactions.getAll().single;
      expect(fee.id, TransferRepository.feeIdFor('t1'));
      expect(fee.amount, 2500);
      expect(fee.type, TransactionType.expense);
      expect(fee.categoryId, DefaultCategories.feesId);
      expect(fee.accountId, 'bca');
      expect(fee.transferId, 't1');
      expect(fee.note, TransferRepository.feeNote);
      expect(fee.date, DateTime.utc(2026, 10, 2));
      expect(fee.isSynced, isFalse);
    });

    test('writes no transaction at all when there is no fee, so nothing counts as spending', () async {
      await repository.create(transfer(fee: 0));

      expect(transactions.getAll(), isEmpty);
    });
  });

  group('update', () {
    test('changing the fee updates the linked expense in place', () async {
      await repository.create(transfer());

      await repository.update(transfer(fee: 4000), now: DateTime.utc(2026, 10, 3));

      final fees = transactions.getAll();
      expect(fees, hasLength(1));
      expect(fees.single.amount, 4000);
      expect(fees.single.updatedAt, DateTime.utc(2026, 10, 3));
    });

    test('moving the date or source account moves the fee with it', () async {
      await repository.create(transfer());

      await repository.update(
        transfer(date: DateTime.utc(2026, 10, 5)).copyWith(fromAccountId: 'cash'),
      );

      final fee = transactions.getAll().single;
      expect(fee.date, DateTime.utc(2026, 10, 5));
      expect(fee.accountId, 'cash');
    });

    test('removing the fee soft-deletes the linked expense, adding it back revives it', () async {
      await repository.create(transfer());

      await repository.update(transfer(fee: 0));
      expect(transactions.getAll(), isEmpty);
      expect(transactionBox.get(TransferRepository.feeIdFor('t1')), isNotNull);

      await repository.update(transfer(fee: 3000));
      final revived = transactions.getAll().single;
      expect(revived.amount, 3000);
      expect(revived.isDeleted, isFalse);
      expect(revived.createdAt, DateTime.utc(2026, 10, 2));
    });

    test('adding a fee to a transfer that had none creates the expense', () async {
      await repository.create(transfer(fee: 0));

      await repository.update(transfer(fee: 1000));

      expect(transactions.getAll().single.amount, 1000);
    });

    test('marks the transfer unsynced again', () async {
      await repository.create(transfer());
      await transferBox.put('t1', repository.getById('t1')!.copyWith(isSynced: true).toJson());

      await repository.update(transfer(amount: 1));

      expect(repository.getById('t1')!.isSynced, isFalse);
    });
  });

  group('delete', () {
    test('soft-deletes the transfer and its fee expense and marks both unsynced', () async {
      await repository.create(transfer());

      await repository.delete('t1', now: DateTime.utc(2026, 10, 4));

      expect(repository.getAll(), isEmpty);
      expect(transactions.getAll(), isEmpty);
      final rawTransfer = Map<String, dynamic>.from(transferBox.get('t1')!);
      expect(rawTransfer['is_deleted'], isTrue);
      expect(rawTransfer['is_synced'], isFalse);
      final rawFee = Map<String, dynamic>.from(transactionBox.get(TransferRepository.feeIdFor('t1'))!);
      expect(rawFee['is_deleted'], isTrue);
      expect(rawFee['is_synced'], isFalse);
    });

    test('a transfer without a fee deletes cleanly and an unknown id is ignored', () async {
      await repository.create(transfer(fee: 0));

      await repository.delete('t1');
      await repository.delete('missing');

      expect(repository.getAll(), isEmpty);
      expect(transactionBox.isEmpty, isTrue);
    });
  });

  group('reconcileFees', () {
    Future<void> storeTransferOnly(TransferModel t) => transferBox.put(t.id, t.toJson());

    test('restores a fee that is missing, as after a write cut short', () async {
      await storeTransferOnly(transfer());

      final changed = await repository.reconcileFees(now: DateTime.utc(2026, 10, 4));

      expect(changed, isTrue);
      final fee = transactions.getAll().single;
      expect(fee.amount, 2500);
      expect(fee.transferId, 't1');
      expect(fee.isSynced, isFalse);
      expect(fee.updatedAt, DateTime.utc(2026, 10, 4));
    });

    test('corrects a fee that no longer matches its transfer', () async {
      await repository.create(transfer());
      final fee = transactions.getAll().single;
      await transactionBox.put(
        fee.id,
        fee.copyWith(amount: 99, accountId: 'dana', categoryId: 'food').toJson(),
      );

      final changed = await repository.reconcileFees();

      expect(changed, isTrue);
      final fixed = transactions.getAll().single;
      expect(fixed.amount, 2500);
      expect(fixed.accountId, 'bca');
      expect(fixed.categoryId, DefaultCategories.feesId);
    });

    test('removes a fee left behind by a deleted transfer or a removed fee', () async {
      await repository.create(transfer());
      final fee = transactions.getAll().single;
      await storeTransferOnly(transfer(fee: 0)); // the fee was removed, the expense was not

      expect(await repository.reconcileFees(), isTrue);
      expect(transactions.getAll(), isEmpty);
      expect(transactionBox.get(fee.id), isNotNull);
    });

    test('does nothing, and reports nothing, when everything already agrees', () async {
      await repository.create(transfer());
      await repository.create(transfer(id: 't2', fee: 0));
      final before = Map<String, dynamic>.from(transactionBox.get(TransferRepository.feeIdFor('t1'))!);

      final changed = await repository.reconcileFees(now: DateTime.utc(2030));

      expect(changed, isFalse);
      expect(Map<String, dynamic>.from(transactionBox.get(TransferRepository.feeIdFor('t1'))!), before);
    });

    test('with no transfers there is nothing to do', () async {
      expect(await repository.reconcileFees(), isFalse);
    });
  });

  test('getAll lists newest first and leaves out deleted transfers', () async {
    await repository.create(transfer(id: 'old', date: DateTime.utc(2026, 9, 1), fee: 0));
    await repository.create(transfer(id: 'new', date: DateTime.utc(2026, 10, 1), fee: 0));
    await repository.create(transfer(id: 'gone', fee: 0));
    await repository.delete('gone');

    expect(repository.getAll().map((t) => t.id), ['new', 'old']);
  });

  test('fee ids are derived from the transfer id', () {
    expect(TransferRepository.feeIdFor('t1'), TransferRepository.feeIdFor('t1'));
    expect(TransferRepository.feeIdFor('t1'), isNot(TransferRepository.feeIdFor('t2')));
    expect(TransferRepository.feeIdFor('t1'), isNot('t1'));
  });
}
