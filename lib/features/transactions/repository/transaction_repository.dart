import 'package:hive/hive.dart';

import '../../../data/models/transaction_model.dart';

class TransactionRepository {
  TransactionRepository(this._box);

  final Box<Map> _box;

  List<TransactionModel> getAll() {
    return _box.values
        .map((raw) => TransactionModel.fromJson(Map<String, dynamic>.from(raw)))
        .where((transaction) => !transaction.isDeleted)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> save(TransactionModel transaction) async {
    await _box.put(transaction.id, transaction.toJson());
  }

  bool isCategoryInUse(String categoryId) {
    return _box.values.any((raw) => raw['category_id'] == categoryId);
  }

  Future<void> softDelete(String id) async {
    final raw = _box.get(id);
    if (raw == null) return;
    final transaction = TransactionModel.fromJson(Map<String, dynamic>.from(raw));
    await save(
      transaction.copyWith(
        isDeleted: true,
        updatedAt: DateTime.now(),
        isSynced: false,
      ),
    );
  }
}
