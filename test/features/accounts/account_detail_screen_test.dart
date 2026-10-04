import 'package:crowzy_finance/core/theme/app_colors.dart';
import 'package:crowzy_finance/core/theme/app_theme.dart';
import 'package:crowzy_finance/data/models/account_model.dart';
import 'package:crowzy_finance/data/models/account_type.dart';
import 'package:crowzy_finance/data/models/category_model.dart';
import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/data/models/transfer_model.dart';
import 'package:crowzy_finance/features/accounts/providers/account_provider.dart';
import 'package:crowzy_finance/features/accounts/providers/transfer_provider.dart';
import 'package:crowzy_finance/features/accounts/ui/account_detail_screen.dart';
import 'package:crowzy_finance/features/categories/providers/category_provider.dart';
import 'package:crowzy_finance/features/transactions/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

final _now = DateTime.now();
final _today = DateTime(_now.year, _now.month, _now.day, 12);
final _yesterday = _today.subtract(const Duration(days: 1));

late List<AccountModel> _accounts;
late List<TransactionModel> _transactions;
late List<TransferModel> _transfers;

class _FakeAccounts extends AccountList {
  @override
  Future<List<AccountModel>> build() async => _accounts;
}

class _FakeTransactions extends TransactionList {
  @override
  Future<List<TransactionModel>> build() async => _transactions;
}

class _FakeTransfers extends TransferList {
  @override
  Future<List<TransferModel>> build() async => _transfers;
}

class _FakeCategories extends CategoryList {
  @override
  Future<List<CategoryModel>> build() async => [
        for (final (id, name) in [('food', 'Food'), ('fees', 'Fees'), ('salary', 'Salary')])
          CategoryModel(
            id: id,
            name: name,
            icon: 'category',
            type: id == 'salary' ? TransactionType.income : TransactionType.expense,
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
      ];
}

class _NoMemory implements LastTransferSource {
  @override
  String? get value => null;

  @override
  Future<void> save(String accountId) async {}
}

AccountModel _account(String id, String name, AccountType type, double opening, int order) =>
    AccountModel(
      id: id,
      userId: 'u1',
      name: name,
      type: type,
      openingBalance: opening,
      createdAt: DateTime(2026, 1, 1, 0, order),
      updatedAt: DateTime(2026),
    );

TransactionModel _tx(
  String id,
  DateTime date,
  double amount, {
  String? accountId,
  String? note,
  String category = 'food',
  bool income = false,
  String? transferId,
}) =>
    TransactionModel(
      id: id,
      userId: 'u1',
      amount: amount,
      type: income ? TransactionType.income : TransactionType.expense,
      categoryId: category,
      note: note,
      accountId: accountId,
      transferId: transferId,
      date: date,
      createdAt: date,
      updatedAt: date,
    );

TransferModel _transfer(String id, DateTime date, String from, String to,
        {double amount = 500000, double fee = 0, String? note}) =>
    TransferModel(
      id: id,
      userId: 'u1',
      fromAccountId: from,
      toAccountId: to,
      amount: amount,
      fee: fee,
      note: note,
      date: date,
      createdAt: date,
      updatedAt: date,
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    _accounts = [
      _account('cash', 'Cash', AccountType.cash, 900000, 0),
      _account('bca', 'BCA', AccountType.bank, 9000000, 1),
      _account('dana', 'DANA', AccountType.ewallet, 250000, 2),
    ];
    _transactions = [];
    _transfers = [];
  });

  Future<void> pump(WidgetTester tester, {String id = 'bca'}) async {
    await tester.binding.setSurfaceSize(const Size(390, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountListProvider.overrideWith(_FakeAccounts.new),
          transactionListProvider.overrideWith(_FakeTransactions.new),
          transferListProvider.overrideWith(_FakeTransfers.new),
          categoryListProvider.overrideWith(_FakeCategories.new),
          defaultAccountIdProvider.overrideWithValue('cash'),
          lastTransferSourceProvider.overrideWithValue(_NoMemory()),
          lastUsedAccountIdProvider.overrideWithValue(null),
          lastUsedCategoryIdProvider.overrideWith((ref, type) => null),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => AccountDetailScreen(accountId: id)),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  double top(WidgetTester tester, String text) => tester.getTopLeft(find.text(text)).dy;

  group('header and balance', () {
    testWidgets('shows the account type over its name, and its balance', (tester) async {
      _transactions = [_tx('a', _today, 184500, accountId: 'bca')];
      await pump(tester);

      expect(find.text('BANK'), findsOneWidget);
      expect(find.text('BCA'), findsOneWidget);
      expect(find.text('BALANCE'), findsOneWidget);
      expect(find.text('8.815.500'), findsOneWidget); // 9.000.000 - 184.500
      expect(find.byTooltip('Edit account'), findsOneWidget);
    });

    testWidgets('the balance follows transfers in and out, and the fee', (tester) async {
      _transactions = [_tx('fee', _today, 2500, accountId: 'bca', transferId: 't', note: 'Transfer fee')];
      _transfers = [_transfer('t', _today, 'bca', 'dana', fee: 2500)];
      await pump(tester);

      expect(find.text('8.497.500'), findsOneWidget); // 9.000.000 - 500.000 - 2.500
    });

    testWidgets('a type that has an e-wallet or cash label says so', (tester) async {
      await pump(tester, id: 'dana');
      expect(find.text('E-WALLET'), findsOneWidget);
    });

    testWidgets('an account that does not exist says so', (tester) async {
      await pump(tester, id: 'ghost');

      expect(find.text('This account no longer exists'), findsOneWidget);
    });
  });

  group('this month on the account', () {
    testWidgets('lists only what happened on it, and this month only', (tester) async {
      _transactions = [
        _tx('mine', _today, 1000, accountId: 'bca', note: 'Groceries'),
        _tx('other', _today, 1000, accountId: 'dana', note: 'Ride'),
        _tx('old', DateTime(_now.year, _now.month - 1, 5), 1000, accountId: 'bca', note: 'Last month'),
      ];
      await pump(tester);

      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Ride'), findsNothing);
      expect(find.text('Last month'), findsNothing);
      expect(find.text('Food'), findsOneWidget); // the line beneath, with no account named
    });

    testWidgets('the default account also holds transactions that have no account', (tester) async {
      _transactions = [_tx('legacy', _today, 1000, note: 'Old habit')];

      await pump(tester, id: 'cash');
      expect(find.text('Old habit'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await pump(tester);
      expect(find.text('Old habit'), findsNothing);
    });

    testWidgets('shows the month in capitals and the filter chips', (tester) async {
      await pump(tester);

      final month = ['JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE', 'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'][_now.month - 1];
      expect(find.text('$month ${_now.year}'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Transfers'), findsOneWidget);
    });

    testWidgets('a transfer reads from this account\'s side: out with a minus, in with a plus', (tester) async {
      _transfers = [
        _transfer('out', _yesterday, 'bca', 'dana', amount: 500000, note: 'Top up DANA'),
        _transfer('in', _yesterday, 'cash', 'bca', amount: 200000, note: 'Cash deposit'),
      ];
      await pump(tester);

      expect(find.text('Top up DANA'), findsOneWidget);
      expect(find.text('To DANA · Transfer'), findsOneWidget);
      expect(find.text('−500.000'), findsOneWidget);
      expect(find.text('Cash deposit'), findsOneWidget);
      expect(find.text('From Cash · Transfer'), findsOneWidget);
      expect(find.text('+200.000'), findsOneWidget);
      expect(tester.widget<Text>(find.text('−500.000')).style!.color, AppColors.brass);
      expect(tester.widget<Text>(find.text('+200.000')).style!.color, AppColors.brass);
    });

    testWidgets('the fee row names the route of its transfer', (tester) async {
      _transactions = [
        _tx('fee', _yesterday, 2500, accountId: 'bca', note: 'Transfer fee', category: 'fees', transferId: 't'),
      ];
      _transfers = [_transfer('t', _yesterday, 'bca', 'dana', fee: 2500, note: 'Top up DANA')];
      await pump(tester);

      expect(find.text('Transfer fee'), findsOneWidget);
      expect(find.text('Fees · BCA → DANA'), findsOneWidget);
    });

    testWidgets('day totals leave transfers out, as the footnote says', (tester) async {
      _transactions = [
        _tx('salary', _yesterday, 18200000, accountId: 'bca', category: 'salary', income: true, note: 'Salary'),
        _tx('rent', _yesterday, 3500000, accountId: 'bca', note: 'Rent'),
      ];
      _transfers = [_transfer('in', _yesterday, 'cash', 'bca', amount: 200000, note: 'Cash deposit')];
      await pump(tester);

      expect(find.text('+14.700.000'), findsOneWidget);
      expect(find.text('Transfers move money, so day totals leave them out.'), findsOneWidget);
    });

    testWidgets('a day with only a transfer has no total', (tester) async {
      _transfers = [_transfer('t', _yesterday, 'bca', 'dana', note: 'Top up')];
      await pump(tester);

      expect(find.text('YESTERDAY'), findsOneWidget);
      expect(find.text('+0'), findsNothing);
      expect(find.text('−0'), findsNothing);
    });

    testWidgets('Transfers narrows the list to transfers, and All brings the rest back', (tester) async {
      _transactions = [_tx('a', _today, 1000, accountId: 'bca', note: 'Groceries')];
      _transfers = [_transfer('t', _today, 'bca', 'dana', note: 'Top up DANA')];
      await pump(tester);

      await tester.tap(find.text('Transfers'));
      await tester.pumpAndSettle();
      expect(find.text('Top up DANA'), findsOneWidget);
      expect(find.text('Groceries'), findsNothing);

      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Top up DANA'), findsOneWidget);
    });

    testWidgets('says when there is nothing, and when there are no transfers', (tester) async {
      await pump(tester);
      expect(find.text('No activity this month'), findsOneWidget);
      expect(find.text('Transfers move money, so day totals leave them out.'), findsNothing);

      await tester.tap(find.text('Transfers'));
      await tester.pumpAndSettle();
      expect(find.text('No transfers this month'), findsOneWidget);
    });

    testWidgets('lists newest first', (tester) async {
      _transactions = [
        _tx('old', _yesterday, 1000, accountId: 'bca', note: 'Earlier'),
        _tx('new', _today, 1000, accountId: 'bca', note: 'Later'),
      ];
      await pump(tester);

      expect(top(tester, 'Later'), lessThan(top(tester, 'Earlier')));
    });

    testWidgets('tapping a transfer opens its receipt', (tester) async {
      _transfers = [_transfer('t', _today, 'bca', 'dana', note: 'Top up DANA')];
      await pump(tester);

      await tester.tap(find.text('Top up DANA'));
      await tester.pumpAndSettle();

      expect(find.text('TRANSFER RECEIPT'), findsOneWidget);
    });

    testWidgets('tapping a transaction opens its receipt', (tester) async {
      _transactions = [_tx('a', _today, 1000, accountId: 'bca', note: 'Groceries')];
      await pump(tester);

      await tester.tap(find.text('Groceries'));
      await tester.pumpAndSettle();

      expect(find.text('TRANSACTION RECEIPT'), findsOneWidget);
    });
  });

  group('actions', () {
    testWidgets('Transfer starts a transfer from this account', (tester) async {
      await pump(tester);

      await tester.tap(find.text('Transfer').first);
      await tester.pumpAndSettle();

      expect(find.text('New transfer'), findsOneWidget);
      expect(top(tester, 'BCA'), lessThan(top(tester, 'Cash'))); // From is BCA, To is the next account
    });

    testWidgets('Add transaction opens the form on this account', (tester) async {
      await pump(tester, id: 'dana');

      await tester.tap(find.text('Add transaction'));
      await tester.pumpAndSettle();

      expect(find.text('New transaction'), findsOneWidget);
      expect(find.text('DANA'), findsOneWidget);
    });

    testWidgets('the pencil opens the account for editing', (tester) async {
      await pump(tester);

      await tester.tap(find.byTooltip('Edit account'));
      await tester.pumpAndSettle();

      expect(find.text('Edit account'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'BCA'), findsOneWidget);
    });
  });
}
