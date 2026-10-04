import 'package:crowzy_finance/core/theme/app_colors.dart';
import 'package:crowzy_finance/core/theme/app_theme.dart';
import 'package:crowzy_finance/data/models/account_model.dart';
import 'package:crowzy_finance/data/models/account_type.dart';
import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/data/models/transfer_model.dart';
import 'package:crowzy_finance/features/accounts/providers/account_provider.dart';
import 'package:crowzy_finance/features/accounts/providers/transfer_provider.dart';
import 'package:crowzy_finance/features/accounts/ui/account_form_screen.dart';
import 'package:crowzy_finance/features/accounts/ui/accounts_screen.dart';
import 'package:crowzy_finance/features/transactions/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

final _at = DateTime(2026, 10, 1);
final _now = DateTime.now();

AccountModel _account(
  String id,
  String name,
  AccountType type, {
  double opening = 0,
  bool archived = false,
  DateTime? createdAt,
}) =>
    AccountModel(
      id: id,
      userId: 'u1',
      name: name,
      type: type,
      openingBalance: opening,
      isArchived: archived,
      createdAt: createdAt ?? _at,
      updatedAt: _at,
    );

TransactionModel _tx(String id, double amount, {String? accountId, bool income = false}) =>
    TransactionModel(
      id: id,
      userId: 'u1',
      amount: amount,
      type: income ? TransactionType.income : TransactionType.expense,
      categoryId: 'c',
      accountId: accountId,
      date: _now,
      createdAt: _at,
      updatedAt: _at,
    );

late List<AccountModel> _accounts;
late List<TransactionModel> _transactions;
late List<TransferModel> _transfers;
final _added = <({String name, AccountType type, double opening})>[];
final _updated = <AccountModel>[];

class _FakeAccounts extends AccountList {
  @override
  Future<List<AccountModel>> build() async => _accounts;

  @override
  Future<void> addAccount({
    required String name,
    required AccountType type,
    required double openingBalance,
  }) async {
    _added.add((name: name, type: type, opening: openingBalance));
  }

  @override
  Future<void> updateAccount(AccountModel account) async {
    _updated.add(account);
  }
}

class _FakeTransactions extends TransactionList {
  @override
  Future<List<TransactionModel>> build() async => _transactions;
}

class _FakeTransfers extends TransferList {
  @override
  Future<List<TransferModel>> build() async => _transfers;
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    _accounts = [
      _account('cash', 'Cash', AccountType.cash, opening: 900000, createdAt: DateTime(2026, 9, 1)),
      _account('bca', 'BCA', AccountType.bank, opening: 9730000),
      _account('dana', 'DANA', AccountType.ewallet, opening: 1850000),
    ];
    _transactions = [];
    _transfers = [];
    _added.clear();
    _updated.clear();
  });

  Future<void> pump(WidgetTester tester, Widget screen) async {
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountListProvider.overrideWith(_FakeAccounts.new),
          transactionListProvider.overrideWith(_FakeTransactions.new),
          transferListProvider.overrideWith(_FakeTransfers.new),
          defaultAccountIdProvider.overrideWithValue('cash'),
        ],
        child: MaterialApp(theme: AppTheme.dark, home: screen),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  group('Accounts', () {
    testWidgets('shows the total and each account under Bank, E-wallet and Cash', (tester) async {
      await pump(tester, const AccountsScreen());

      expect(find.text('ACROSS 3 ACCOUNTS'), findsOneWidget);
      expect(find.text('12.480.000'), findsOneWidget); // total
      for (final label in ['BANK', 'E-WALLET', 'CASH']) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.text('9.730.000'), findsOneWidget);
      expect(find.text('1.850.000'), findsOneWidget);
      expect(find.text('900.000'), findsOneWidget);
      expect(find.textContaining('never counts as income or expense'), findsOneWidget);
    });

    testWidgets('groups appear in the order Bank, E-wallet, Cash', (tester) async {
      await pump(tester, const AccountsScreen());

      final tops = [for (final n in ['BANK', 'E-WALLET', 'CASH']) tester.getTopLeft(find.text(n)).dy];
      expect(tops, [...tops]..sort());
    });

    testWidgets('subtitles: default account, activity this month, or none', (tester) async {
      _transactions = [_tx('a', 10, accountId: 'bca'), _tx('b', 10, accountId: 'bca')];
      await pump(tester, const AccountsScreen());

      expect(find.text('Default account'), findsOneWidget);
      expect(find.text('2 entries this month'), findsOneWidget); // BCA
      expect(find.text('No activity this month'), findsOneWidget); // DANA
    });

    testWidgets('balances follow transactions and transfers, and a negative one is flagged', (tester) async {
      _transactions = [_tx('a', 100000, accountId: 'dana', income: true), _tx('b', 3000000, accountId: 'dana')];
      _transfers = [
        TransferModel(
          id: 't',
          userId: 'u1',
          fromAccountId: 'bca',
          toAccountId: 'cash',
          amount: 500000,
          date: _now,
          createdAt: _at,
          updatedAt: _at,
        ),
      ];
      await pump(tester, const AccountsScreen());

      expect(find.text('9.230.000'), findsOneWidget); // BCA after the transfer
      expect(find.text('1.400.000'), findsOneWidget); // Cash after the transfer
      final negative = find.text('−1.050.000'); // DANA
      expect(negative, findsOneWidget);
      expect(tester.widget<Text>(negative).style!.color, AppColors.expense);
    });

    testWidgets('archived accounts are hidden, counted, and revealed on tap, but still in the total', (tester) async {
      _accounts = [..._accounts, _account('old', 'Old card', AccountType.bank, opening: 100, archived: true)];
      await pump(tester, const AccountsScreen());

      expect(find.text('ACROSS 3 ACCOUNTS'), findsOneWidget);
      expect(find.text('12.480.100'), findsOneWidget);
      expect(find.text('Old card'), findsNothing);
      expect(find.text('1 archived account'), findsOneWidget);

      await tester.tap(find.text('1 archived account'));
      await tester.pumpAndSettle();
      expect(find.text('Old card'), findsOneWidget);

      await tester.tap(find.text('1 archived account'));
      await tester.pumpAndSettle();
      expect(find.text('Old card'), findsNothing);
    });

    testWidgets('a single account reads "1 account"', (tester) async {
      _accounts = [_accounts.first];
      await pump(tester, const AccountsScreen());

      expect(find.text('ACROSS 1 ACCOUNT'), findsOneWidget);
    });

    testWidgets('tapping an account edits it, and the + button starts a new one', (tester) async {
      await pump(tester, const AccountsScreen());

      await tester.tap(find.text('DANA'));
      await tester.pumpAndSettle();
      expect(find.text('Edit account'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'DANA'), findsOneWidget);

      Navigator.of(tester.element(find.text('Edit account'))).pop();
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Add account'));
      await tester.pumpAndSettle();
      expect(find.text('New account'), findsOneWidget);
    });
  });

  group('Account form', () {
    testWidgets('a new account starts empty with Bank chosen and no archive switch', (tester) async {
      await pump(tester, const AccountFormScreen());

      expect(find.text('New account'), findsOneWidget);
      expect(find.text('Add account'), findsOneWidget);
      expect(find.text('e.g. Jago, GoPay, Wallet'), findsOneWidget);
      expect(find.textContaining('What this account holds right now'), findsOneWidget);
      expect(find.text('Archive this account'), findsNothing);
      expect(find.byType(Switch), findsNothing);
      expect(
        tester.widget<SegmentedButton<AccountType>>(find.byType(SegmentedButton<AccountType>)).selected,
        {AccountType.bank},
      );
    });

    testWidgets('the type control offers Bank, E-wallet and Cash', (tester) async {
      await pump(tester, const AccountFormScreen());

      for (final label in ['Bank', 'E-wallet', 'Cash']) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('a name is required', (tester) async {
      await pump(tester, const AccountFormScreen());

      await tester.tap(find.text('Add account'));
      await tester.pumpAndSettle();

      expect(find.text('Name is required'), findsOneWidget);
      expect(_added, isEmpty);
    });

    testWidgets('adds the account with its type and opening balance', (tester) async {
      await pump(tester, const AccountFormScreen());

      await tester.enterText(find.widgetWithText(TextFormField, 'e.g. Jago, GoPay, Wallet'), ' Jago ');
      await tester.tap(find.text('E-wallet'));
      await tester.pump();
      await tester.enterText(find.byType(TextFormField).last, '250000');
      await tester.tap(find.text('Add account'));
      await tester.pumpAndSettle();

      expect(_added, hasLength(1));
      expect(_added.single.name, 'Jago');
      expect(_added.single.type, AccountType.ewallet);
      expect(_added.single.opening, 250000);
      expect(find.text('New account'), findsNothing); // closed
    });

    testWidgets('an empty opening balance means zero', (tester) async {
      await pump(tester, const AccountFormScreen());

      await tester.enterText(find.widgetWithText(TextFormField, 'e.g. Jago, GoPay, Wallet'), 'Wallet');
      await tester.tap(find.text('Add account'));
      await tester.pumpAndSettle();

      expect(_added.single.opening, 0);
    });

    testWidgets('editing is pre-filled, explains the current balance, and saves changes', (tester) async {
      _transactions = [_tx('a', 350000, accountId: 'dana')];
      await pump(tester, AccountFormScreen(account: _accounts[2]));

      expect(find.text('Edit account'), findsOneWidget);
      expect(find.text('Save account'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'DANA'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '1.850.000'), findsOneWidget);
      expect(
        find.textContaining('Its current balance, 1.500.000, is worked out from this plus everything since.'),
        findsOneWidget,
      );
      expect(find.text('Archive this account'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextFormField, 'DANA'), 'DANA Main');
      await tester.tap(find.byType(Switch));
      await tester.pump();
      await tester.tap(find.text('Save account'));
      await tester.pumpAndSettle();

      expect(_updated, hasLength(1));
      expect(_updated.single.id, 'dana');
      expect(_updated.single.name, 'DANA Main');
      expect(_updated.single.isArchived, isTrue);
      expect(_updated.single.openingBalance, 1850000);
    });

    testWidgets('the default Cash account cannot be archived', (tester) async {
      await pump(tester, AccountFormScreen(account: _accounts.first));

      expect(find.text('Edit account'), findsOneWidget);
      expect(find.text('Archive this account'), findsNothing);
    });
  });
}
