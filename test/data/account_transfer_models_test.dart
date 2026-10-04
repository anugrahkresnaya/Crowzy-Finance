import 'package:crowzy_finance/core/constants/default_categories.dart';
import 'package:crowzy_finance/data/models/account_model.dart';
import 'package:crowzy_finance/data/models/account_type.dart';
import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/data/models/transfer_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AccountModel', () {
    final json = {
      'id': 'a1',
      'user_id': 'u1',
      'name': 'DANA',
      'type': 'ewallet',
      'opening_balance': '250000.00',
      'is_archived': true,
      'created_at': '2026-07-01T00:00:00.000Z',
      'updated_at': '2026-07-02T00:00:00.000Z',
    };

    test('reads a numeric string balance and the e-wallet type', () {
      final account = AccountModel.fromJson(json);
      expect(account.openingBalance, 250000);
      expect(account.type, AccountType.ewallet);
      expect(account.isArchived, isTrue);
      expect(account.isDeleted, isFalse);
      expect(account.isSynced, isTrue);
    });

    test('defaults to an empty, active account and leaves the local flag out of the Supabase row', () {
      final account = AccountModel.fromJson(
        {...json}..remove('opening_balance')..remove('is_archived'),
      );
      expect(account.openingBalance, 0);
      expect(account.isArchived, isFalse);

      final row = account.toSupabaseRow();
      expect(row.containsKey('is_synced'), isFalse);
      expect(row['type'], 'ewallet');
      expect(row['opening_balance'], 0);
    });

    test('type labels match the canvas', () {
      expect(AccountType.values.map((t) => t.label), ['Bank', 'E-wallet', 'Cash']);
    });
  });

  group('TransferModel', () {
    final json = {
      'id': 't1',
      'user_id': 'u1',
      'from_account_id': 'a1',
      'to_account_id': 'a2',
      'amount': '500000.00',
      'fee': '2500.00',
      'note': 'Top up DANA',
      'date': '2026-10-02T00:00:00.000Z',
      'created_at': '2026-10-02T00:00:00.000Z',
      'updated_at': '2026-10-02T00:00:00.000Z',
    };

    test('reads numeric string amounts and keeps the route', () {
      final transfer = TransferModel.fromJson(json);
      expect(transfer.amount, 500000);
      expect(transfer.fee, 2500);
      expect(transfer.fromAccountId, 'a1');
      expect(transfer.toAccountId, 'a2');
    });

    test('a missing fee means no fee, and the Supabase row has no local flag', () {
      final transfer = TransferModel.fromJson({...json}..remove('fee'));
      expect(transfer.fee, 0);
      expect(transfer.toSupabaseRow().containsKey('is_synced'), isFalse);
      expect(transfer.toSupabaseRow()['from_account_id'], 'a1');
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

    test('rows saved before accounts existed have neither field', () {
      final transaction = TransactionModel.fromJson(base);
      expect(transaction.accountId, isNull);
      expect(transaction.transferId, isNull);
    });

    test('both fields round-trip', () {
      final transaction = TransactionModel.fromJson({...base, 'account_id': 'a1', 'transfer_id': 't1'});
      expect(transaction.accountId, 'a1');
      expect(transaction.transferId, 't1');
      expect(transaction.toSupabaseRow()['account_id'], 'a1');
      expect(transaction.toSupabaseRow()['transfer_id'], 't1');
    });

    test('copyWith keeps them, so editing a transaction does not lose its account', () {
      final transaction = TransactionModel.fromJson({...base, 'account_id': 'a1'});
      expect(transaction.copyWith(amount: 20).accountId, 'a1');
    });
  });

  group('DefaultCategories', () {
    test('includes the Fees expense category with its fixed id', () {
      final fees = DefaultCategories.build().singleWhere((c) => c.id == DefaultCategories.feesId);
      expect(fees.name, 'Fees');
      expect(fees.type, TransactionType.expense);
      expect(DefaultCategories.feesId, '00000000-0000-4000-8000-000000000013');
    });

    test('missingFrom returns only the defaults an older install lacks', () {
      final all = DefaultCategories.build();
      final older = all.where((c) => c.id != DefaultCategories.feesId).map((c) => c.id);

      expect(DefaultCategories.missingFrom(older).map((c) => c.id), [DefaultCategories.feesId]);
      expect(DefaultCategories.missingFrom(all.map((c) => c.id)), isEmpty);
      expect(DefaultCategories.missingFrom(const []), hasLength(all.length));
    });
  });
}
