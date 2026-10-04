import 'package:crowzy_finance/core/constants/default_categories.dart';
import 'package:crowzy_finance/core/theme/app_theme.dart';
import 'package:crowzy_finance/data/models/account_model.dart';
import 'package:crowzy_finance/data/models/account_type.dart';
import 'package:crowzy_finance/data/models/category_model.dart';
import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/data/models/transfer_model.dart';
import 'package:crowzy_finance/features/accounts/providers/account_provider.dart';
import 'package:crowzy_finance/features/accounts/providers/transfer_provider.dart';
import 'package:crowzy_finance/features/categories/providers/category_provider.dart';
import 'package:crowzy_finance/features/transactions/providers/transaction_provider.dart';
import 'package:crowzy_finance/features/transactions/ui/add_edit_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

class _Saved {
  double? amount;
  TransactionType? type;
  String? categoryId;
  String? note;
  String? accountId;
  TransactionModel? updated;
}

late _Saved _saved;

class _FakeTransactions extends TransactionList {
  @override
  Future<List<TransactionModel>> build() async => const [];

  @override
  Future<void> addTransaction({
    required double amount,
    required TransactionType type,
    required String categoryId,
    required DateTime date,
    String? note,
    String? accountId,
  }) async {
    _saved
      ..accountId = accountId
      ..amount = amount
      ..type = type
      ..categoryId = categoryId
      ..note = note;
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    _saved.updated = transaction;
  }
}

List<AccountModel> _accounts = [];

class _FakeAccounts extends AccountList {
  @override
  Future<List<AccountModel>> build() async => _accounts;
}

class _FakeTransfers extends TransferList {
  @override
  Future<List<TransferModel>> build() async => const [];
}

AccountModel _account(String id, String name, int order,
        {AccountType type = AccountType.bank, bool archived = false}) =>
    AccountModel(
      id: id,
      userId: 'u1',
      name: name,
      type: type,
      isArchived: archived,
      createdAt: DateTime(2026, 1, 1, 0, order),
      updatedAt: DateTime(2026),
    );

class _FakeCategories extends CategoryList {
  @override
  Future<List<CategoryModel>> build() async => [
        _cat('food', 'Food', TransactionType.expense),
        _cat('transport', 'Transport', TransactionType.expense),
        _cat(DefaultCategories.feesId, 'Fees', TransactionType.expense),
        _cat('salary', 'Salary', TransactionType.income),
      ];
}

CategoryModel _cat(String id, String name, TransactionType type) => CategoryModel(
      id: id,
      name: name,
      icon: 'category',
      type: type,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  setUp(() {
    _saved = _Saved();
    _accounts = [
      _account('cash', 'Cash', 0, type: AccountType.cash),
      _account('bca', 'BCA', 1),
      _account('dana', 'DANA', 2, type: AccountType.ewallet),
    ];
  });

  Future<void> pump(
    WidgetTester tester, {
    TransactionModel? transaction,
    String? initialAccountId,
    String? lastUsedAccount,
    TransactionType initialType = TransactionType.expense,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionListProvider.overrideWith(_FakeTransactions.new),
          categoryListProvider.overrideWith(_FakeCategories.new),
          lastUsedCategoryIdProvider.overrideWith((ref, type) => null),
          lastUsedAccountIdProvider.overrideWithValue(lastUsedAccount),
          accountListProvider.overrideWith(_FakeAccounts.new),
          transferListProvider.overrideWith(_FakeTransfers.new),
          defaultAccountIdProvider.overrideWithValue('cash'),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: AddEditTransactionScreen(
            transaction: transaction,
            initialAccountId: initialAccountId,
            initialType: initialType,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the form for a new transaction', (tester) async {
    await pump(tester);

    expect(find.text('New transaction'), findsOneWidget);
    expect(find.text('AMOUNT'), findsOneWidget);
    expect(find.text('CATEGORY'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Transport'), findsOneWidget);
    expect(find.text('Salary'), findsNothing); // income category, hidden for expenses
    expect(find.text('New'), findsOneWidget);
    expect(find.text('Save transaction'), findsOneWidget);
    expect(find.text('Describe it in words instead'), findsOneWidget);
  });

  testWidgets('does not offer the Fees category, which only a transfer records into', (tester) async {
    await pump(tester);

    expect(find.text('Fees'), findsNothing);
    expect(find.text('Food'), findsOneWidget);
  });

  testWidgets('groups the amount with dots as it is typed', (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(TextFormField).first, '85000');
    await tester.pump();

    expect(find.text('85.000'), findsOneWidget);
  });

  testWidgets('the first category is preselected and the chosen one is saved', (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(TextFormField).first, '12500');
    await tester.tap(find.text('Transport'));
    await tester.pump();
    await tester.tap(find.text('Save transaction'));
    await tester.pumpAndSettle();

    expect(_saved.amount, 12500);
    expect(_saved.categoryId, 'transport');
    expect(_saved.type, TransactionType.expense);
    expect(_saved.note, isNull);
  });

  testWidgets('preselects the first category once the list has loaded', (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(TextFormField).first, '9000');
    await tester.tap(find.text('Save transaction'));
    await tester.pumpAndSettle();

    expect(_saved.categoryId, 'food');
  });

  testWidgets('saves the note when one is entered', (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(TextFormField).first, '5000');
    await tester.enterText(find.byType(TextField).last, 'Dinner');
    await tester.tap(find.text('Save transaction'));
    await tester.pumpAndSettle();

    expect(_saved.note, 'Dinner');
  });

  testWidgets('does not save without a valid amount', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Save transaction'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid amount'), findsOneWidget);
    expect(_saved.amount, isNull);
  });

  testWidgets('switching to Income shows income categories and saves as income', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();

    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Food'), findsNothing);

    await tester.enterText(find.byType(TextFormField).first, '1000000');
    await tester.tap(find.text('Save transaction'));
    await tester.pumpAndSettle();

    expect(_saved.type, TransactionType.income);
    expect(_saved.categoryId, 'salary');
    expect(_saved.amount, 1000000);
  });

  testWidgets('editing prefills the form, hides the AI shortcut and saves changes', (tester) async {
    final existing = TransactionModel(
      id: 't1',
      userId: 'u1',
      amount: 184500,
      type: TransactionType.expense,
      categoryId: 'food',
      note: 'Groceries',
      date: DateTime(2026, 10, 1),
      createdAt: DateTime(2026, 10, 1),
      updatedAt: DateTime(2026, 10, 1),
    );
    await pump(tester, transaction: existing);

    expect(find.text('Edit transaction'), findsOneWidget);
    expect(find.text('184.500'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('1 October 2026'), findsOneWidget);
    expect(find.text('Describe it in words instead'), findsNothing);

    await tester.enterText(find.byType(TextFormField).first, '200000');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(_saved.updated?.id, 't1');
    expect(_saved.updated?.amount, 200000);
    expect(_saved.updated?.note, 'Groceries');
  });

  group('account', () {
    Future<void> chooseAccount(WidgetTester tester, String name) async {
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(name).last);
      await tester.pumpAndSettle();
    }

    testWidgets('a new transaction has an Account row, first in the card, on Cash by default', (tester) async {
      await pump(tester);

      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Cash'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Account')).dy,
        lessThan(tester.getTopLeft(find.text('Date')).dy),
      );
    });

    testWidgets('starts on the account last used', (tester) async {
      await pump(tester, lastUsedAccount: 'dana');

      expect(find.text('DANA'), findsOneWidget);
      expect(find.text('Cash'), findsNothing);
    });

    testWidgets('starts on the account it was opened from, ahead of the last used one', (tester) async {
      await pump(tester, initialAccountId: 'bca', lastUsedAccount: 'dana');

      expect(find.text('BCA'), findsOneWidget);
    });

    testWidgets('a last used account that is archived is not used', (tester) async {
      _accounts = [..._accounts, _account('old', 'Old card', 3, archived: true)];
      await pump(tester, lastUsedAccount: 'old');

      expect(find.text('Old card'), findsNothing);
      expect(find.text('Cash'), findsOneWidget);
    });

    testWidgets('tapping the row offers the active accounts and the choice is saved', (tester) async {
      _accounts = [..._accounts, _account('old', 'Old card', 3, archived: true)];
      await pump(tester);

      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();
      expect(find.text('Choose an account'), findsOneWidget);
      expect(find.text('Old card'), findsNothing);
      await tester.tap(find.text('BCA'));
      await tester.pumpAndSettle();
      expect(find.text('BCA'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).first, '5000');
      await tester.tap(find.text('Save transaction'));
      await tester.pumpAndSettle();

      expect(_saved.accountId, 'bca');
    });

    testWidgets('the default account is saved when nothing else is chosen', (tester) async {
      await pump(tester);

      await tester.enterText(find.byType(TextFormField).first, '5000');
      await tester.tap(find.text('Save transaction'));
      await tester.pumpAndSettle();

      expect(_saved.accountId, 'cash');
    });

    testWidgets('editing shows the transaction\'s own account and can move it', (tester) async {
      final existing = TransactionModel(
        id: 't1',
        userId: 'u1',
        amount: 100,
        type: TransactionType.expense,
        categoryId: 'food',
        accountId: 'dana',
        date: DateTime(2026, 10, 1),
        createdAt: DateTime(2026, 10, 1),
        updatedAt: DateTime(2026, 10, 1),
      );
      await pump(tester, transaction: existing, lastUsedAccount: 'bca');
      expect(find.text('DANA'), findsOneWidget);

      await chooseAccount(tester, 'BCA');
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(_saved.updated?.accountId, 'bca');
    });

    testWidgets('an older transaction with no account shows, and keeps, the default one', (tester) async {
      final existing = TransactionModel(
        id: 't1',
        userId: 'u1',
        amount: 100,
        type: TransactionType.expense,
        categoryId: 'food',
        date: DateTime(2026, 10, 1),
        createdAt: DateTime(2026, 10, 1),
        updatedAt: DateTime(2026, 10, 1),
      );
      await pump(tester, transaction: existing, lastUsedAccount: 'bca');

      expect(find.text('Cash'), findsOneWidget); // not the last used account
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(_saved.updated?.accountId, 'cash');
    });

    testWidgets('a transaction on an archived account still shows it and offers it in the picker', (tester) async {
      _accounts = [..._accounts, _account('old', 'Old card', 3, archived: true)];
      final existing = TransactionModel(
        id: 't1',
        userId: 'u1',
        amount: 100,
        type: TransactionType.expense,
        categoryId: 'food',
        accountId: 'old',
        date: DateTime(2026, 10, 1),
        createdAt: DateTime(2026, 10, 1),
        updatedAt: DateTime(2026, 10, 1),
      );
      await pump(tester, transaction: existing);
      expect(find.text('Old card'), findsOneWidget);

      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();
      expect(find.text('Old card'), findsNWidgets(2)); // the row and the picker
    });

    testWidgets('can open on Income', (tester) async {
      await pump(tester, initialType: TransactionType.income);

      expect(find.text('Salary'), findsOneWidget);
      expect(find.text('Food'), findsNothing);
    });
  });
}
