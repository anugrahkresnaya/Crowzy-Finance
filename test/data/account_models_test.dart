import 'package:crowzy_finance/core/constants/default_categories.dart';
import 'package:crowzy_finance/data/models/account_model.dart';
import 'package:crowzy_finance/data/models/account_type.dart';
import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:flutter_test/flutter_test.dart';

/// The columns the live Supabase tables have. A row this app sends with any
/// other key would be rejected by the server.
const _liveAccountColumns = {
  'id', 'user_id', 'name', 'type', 'initial_balance', 'is_deleted', 'created_at',
  'updated_at', 'is_main', 'is_archived', //
};
const _liveTransactionColumns = {
  'id', 'user_id', 'amount', 'type', 'category_id', 'note', 'date', 'is_deleted',
  'created_at', 'updated_at', 'account_id', 'transfer_group_id', //
};

void main() {
  group('AccountModel', () {
    final json = {
      'id': 'a1',
      'user_id': 'u1',
      'name': 'DANA',
      'type': 'e_wallet',
      'initial_balance': '250000.00',
      'is_main': true,
      'is_archived': true,
      'created_at': '2026-07-01T00:00:00.000Z',
      'updated_at': '2026-07-02T00:00:00.000Z',
    };

    test('reads the live column names: e_wallet, a numeric string balance, main and archived', () {
      final account = AccountModel.fromJson(json);

      expect(account.type, AccountType.ewallet);
      expect(account.initialBalance, 250000);
      expect(account.isMain, isTrue);
      expect(account.isArchived, isTrue);
      expect(account.isDeleted, isFalse);
      expect(account.isSynced, isTrue);
    });

    test('a row from before is_archived existed reads as not archived', () {
      final account = AccountModel.fromJson({...json}..remove('is_archived'));

      expect(account.isArchived, isFalse);
    });

    test('defaults to an empty, active, non-main account', () {
      final account = AccountModel.fromJson(
        {...json}..remove('initial_balance')..remove('is_main')..remove('is_archived'),
      );

      expect(account.initialBalance, 0);
      expect(account.isMain, isFalse);
      expect(account.isArchived, isFalse);
    });

    test('every key it sends is a column the live accounts table has, and the local flag is not sent', () {
      final row = AccountModel.fromJson(json).toSupabaseRow();

      expect(_liveAccountColumns.containsAll(row.keys), isTrue, reason: '${row.keys}');
      expect(row.containsKey('is_synced'), isFalse);
      expect(row['type'], 'e_wallet');
      expect(row['initial_balance'], 250000);
    });

    test('type labels match the canvas', () {
      expect(AccountType.values.map((t) => t.label), ['Bank', 'E-wallet', 'Cash']);
    });

    test('the three types use the values the live check constraint allows', () {
      final values = AccountType.values.map((t) {
        final account = AccountModel.fromJson({...json, 'type': t == AccountType.ewallet ? 'e_wallet' : t.name});
        return account.toSupabaseRow()['type'];
      });

      expect(values, ['bank', 'e_wallet', 'cash']);
    });
  });

  group('TransactionModel account fields', () {
    final base = {
      'id': 'x1',
      'user_id': 'u1',
      'amount': 10,
      'type': 'expense',
      'category_id': 'c1',
      'date': '2026-10-02T00:00:00.000Z',
      'created_at': '2026-10-02T00:00:00.000Z',
      'updated_at': '2026-10-02T00:00:00.000Z',
    };

    test('rows saved before accounts existed have neither field, so they are unassigned', () {
      final transaction = TransactionModel.fromJson(base);

      expect(transaction.accountId, isNull);
      expect(transaction.transferGroupId, isNull);
    });

    test('both fields round-trip under the live column names', () {
      final transaction = TransactionModel.fromJson({
        ...base,
        'account_id': 'a1',
        'transfer_group_id': 'g1',
      });

      expect(transaction.accountId, 'a1');
      expect(transaction.transferGroupId, 'g1');
      expect(transaction.toSupabaseRow()['account_id'], 'a1');
      expect(transaction.toSupabaseRow()['transfer_group_id'], 'g1');
    });

    test('every key it sends is a column the live transactions table has', () {
      final row = TransactionModel.fromJson({...base, 'account_id': 'a1'}).toSupabaseRow();

      expect(_liveTransactionColumns.containsAll(row.keys), isTrue, reason: '${row.keys}');
      expect(row.containsKey('is_synced'), isFalse);
    });

    test('copyWith keeps them, so editing a transaction does not lose its account', () {
      final transaction = TransactionModel.fromJson({...base, 'account_id': 'a1'});

      expect(transaction.copyWith(amount: 20).accountId, 'a1');
    });
  });

  group('DefaultCategories', () {
    test('has the two transfer categories with the ids the server already uses', () {
      final all = DefaultCategories.build();
      final transferIn = all.singleWhere((c) => c.id == DefaultCategories.transferInId);
      final transferOut = all.singleWhere((c) => c.id == DefaultCategories.transferOutId);

      expect(DefaultCategories.transferInId, '00000000-0000-4000-8000-000000000013');
      expect(DefaultCategories.transferOutId, '00000000-0000-4000-8000-000000000014');
      expect(transferIn.name, 'Transfer In');
      expect(transferIn.type, TransactionType.income);
      expect(transferOut.name, 'Transfer Out');
      expect(transferOut.type, TransactionType.expense);
    });

    test('knows which categories are transfer categories', () {
      expect(DefaultCategories.isTransferCategory(DefaultCategories.transferInId), isTrue);
      expect(DefaultCategories.isTransferCategory(DefaultCategories.transferOutId), isTrue);
      expect(DefaultCategories.isTransferCategory('00000000-0000-4000-8000-000000000012'), isFalse);
    });

    test('missingFrom returns only the defaults an older install lacks', () {
      final all = DefaultCategories.build();
      final older = all.where((c) => !DefaultCategories.isTransferCategory(c.id)).map((c) => c.id);

      expect(
        DefaultCategories.missingFrom(older).map((c) => c.id).toSet(),
        {DefaultCategories.transferInId, DefaultCategories.transferOutId},
      );
      expect(DefaultCategories.missingFrom(all.map((c) => c.id)), isEmpty);
      expect(DefaultCategories.missingFrom(const []), hasLength(all.length));
    });
  });
}
