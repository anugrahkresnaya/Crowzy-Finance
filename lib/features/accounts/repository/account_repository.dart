import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/account_model.dart';
import '../../../data/models/account_type.dart';

class AccountRepository {
  AccountRepository(this._box);

  final Box<Map> _box;

  /// Each user has one default Cash account, so its id is derived from the
  /// user. Transactions with no account count as this one, and two devices
  /// creating it independently end up on the same row.
  static String defaultIdFor(String userId) =>
      const Uuid().v5(Namespace.url.value, 'account:$userId:cash');

  /// A default account that was created on this device and never changed is
  /// stamped with the epoch. It stands in until the real one arrives: the push
  /// leaves an existing server row alone, and the pull then replaces this one,
  /// so signing in on a second device never overwrites the first one's Cash.
  static final pristine = DateTime.utc(1970);

  static bool isPristine(AccountModel account) => account.updatedAt == pristine;

  /// Active and archived accounts, oldest first (the default account leads).
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

  /// Creates the default Cash account for [userId] if it does not exist yet.
  /// It is dated [pristine], which also puts it first in the list.
  Future<AccountModel> ensureDefault(String userId) async {
    final id = defaultIdFor(userId);
    final existing = getById(id);
    if (existing != null) return existing;

    final account = AccountModel(
      id: id,
      userId: userId,
      name: 'Cash',
      type: AccountType.cash,
      createdAt: pristine,
      updatedAt: pristine,
      isSynced: false,
    );
    await save(account);
    return account;
  }
}
