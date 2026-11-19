import 'package:hive/hive.dart';

import '../../../data/models/account_model.dart';

class AccountRepository {
  AccountRepository(this._box);

  final Box<Map> _box;

  /// Active and archived accounts, oldest first. Deleted ones are left out.
  List<AccountModel> getAll() {
    final accounts = _box.values
        .map((raw) => AccountModel.fromJson(Map<String, dynamic>.from(raw)))
        .where((account) => !account.isDeleted)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return accounts;
  }

  AccountModel? getById(String id) {
    final raw = _box.get(id);
    if (raw == null) return null;
    final account = AccountModel.fromJson(Map<String, dynamic>.from(raw));
    return account.isDeleted ? null : account;
  }

  Future<void> save(AccountModel account) async {
    await _box.put(account.id, account.toJson());
  }
}
