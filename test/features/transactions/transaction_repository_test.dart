import 'dart:io';

import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/features/transactions/repository/transaction_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Box<Map> box;
  late TransactionRepository repository;

  setUp(() async {
    Hive.init(Directory.systemTemp.createTempSync().path);
    box = await Hive.openBox<Map>('test_transactions');
    repository = TransactionRepository(box);
  });

  tearDown(() async {
    await box.deleteFromDisk();
  });

  TransactionModel buildTransaction({
    String id = 't1',
    double amount = 10000,
    DateTime? date,
    TransactionType type = TransactionType.expense,
  }) {
    final now = date ?? DateTime(2026, 1, 15);
    return TransactionModel(
      id: id,
      userId: 'u1',
      amount: amount,
      type: type,
      categoryId: 'c1',
      date: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  test('save then getAll returns transactions sorted by date descending', () async {
    await repository.save(buildTransaction(id: 't1', date: DateTime(2026, 1, 1)));
    await repository.save(buildTransaction(id: 't2', date: DateTime(2026, 1, 15)));

    final all = repository.getAll();
    expect(all.map((t) => t.id), ['t2', 't1']);
  });

  test('softDelete excludes the transaction from getAll', () async {
    await repository.save(buildTransaction());
    await repository.softDelete('t1');

    expect(repository.getAll(), isEmpty);
  });

  test('isCategoryInUse reflects whether any transaction references it', () async {
    expect(repository.isCategoryInUse('c1'), isFalse);

    await repository.save(buildTransaction());
    expect(repository.isCategoryInUse('c1'), isTrue);
    expect(repository.isCategoryInUse('unused'), isFalse);
  });

  test('isCategoryInUse still counts soft-deleted transactions', () async {
    await repository.save(buildTransaction());
    await repository.softDelete('t1');

    expect(repository.isCategoryInUse('c1'), isTrue);
  });
}
