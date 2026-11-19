import 'package:crowzy_finance/core/theme/app_colors.dart';
import 'package:crowzy_finance/core/theme/app_theme.dart';
import 'package:crowzy_finance/data/models/account_model.dart';
import 'package:crowzy_finance/data/models/account_type.dart';
import 'package:crowzy_finance/data/models/category_model.dart';
import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/data/models/transfer.dart';
import 'package:crowzy_finance/features/accounts/providers/account_provider.dart';
import 'package:crowzy_finance/features/categories/providers/category_provider.dart';
import 'package:crowzy_finance/features/transactions/providers/transaction_provider.dart';
import 'package:crowzy_finance/features/transactions/ui/transaction_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../support/transfers.dart';

late List<TransactionModel> _seed;
class _FakeAccounts extends AccountList {
  @override
  Future<List<AccountModel>> build() async => [
        for (final (id, name, type) in [
          ('cash', 'Cash', AccountType.cash),
          ('bca', 'BCA', AccountType.bank),
          ('dana', 'DANA', AccountType.ewallet),
        ])
          AccountModel(
            id: id,
            userId: 'u1',
            name: name,
            type: type,
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
      ];
}

class _FakeTransactions extends TransactionList {
  @override
  Future<List<TransactionModel>> build() async => _seed;
}

class _FakeCategories extends CategoryList {
  @override
  Future<List<CategoryModel>> build() async => [
        for (final (id, name) in [('food', 'Food'), ('salary', 'Salary')])
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

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day, 12);

  TransactionModel tx(
    String id,
    DateTime date, {
    double amount = 100000,
    TransactionType type = TransactionType.expense,
    String category = 'food',
    String? note,
  }) =>
      TransactionModel(
        id: id,
        userId: 'u1',
        amount: amount,
        type: type,
        categoryId: category,
        note: note,
        date: date,
        createdAt: date,
        updatedAt: date,
      );

  Transfer transfer(
    String id,
    DateTime date, {
    double amount = 500000,
    double fee = 0,
    String from = 'bca',
    String to = 'dana',
    String? note,
  }) =>
      fakeTransfer(id, from: from, to: to, amount: amount, fee: fee, date: date, note: note);

  Future<void> pump(
    WidgetTester tester,
    List<TransactionModel> transactions, {
    List<Transfer> transfers = const [],
  }) async {
    // A transfer is stored as its two legs (and its fee), like on the server.
    _seed = [
      ...transactions,
      for (final t in transfers) ...[
        ...legsOf(t),
        if (t.fee > 0) feeOf(t, categoryId: 'food').copyWith(accountId: t.fromAccountId),
      ],
    ];
    await tester.binding.setSurfaceSize(const Size(390, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionListProvider.overrideWith(_FakeTransactions.new),
          categoryListProvider.overrideWith(_FakeCategories.new),
          accountListProvider.overrideWith(_FakeAccounts.new),
          mainAccountIdProvider.overrideWithValue(null),
        ],
        child: MaterialApp(theme: AppTheme.dark, home: const TransactionListScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('groups the month by day with a net total for each day', (tester) async {
    await pump(tester, [
      tx('a', today, amount: 184500, note: 'Groceries'),
      tx('b', today, amount: 52000, note: 'Ride'),
      tx('c', today, amount: 1000000, type: TransactionType.income, category: 'salary', note: 'Bonus'),
    ]);

    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('+763.500'), findsOneWidget); // 1.000.000 - 184.500 - 52.000
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Bonus'), findsOneWidget);
  });

  testWidgets('shows only the current month and can step back to an earlier one', (tester) async {
    final lastMonth = DateTime(now.year, now.month - 1, 15);
    await pump(tester, [
      tx('now', today, note: 'This month'),
      tx('then', lastMonth, note: 'Last month'),
    ]);

    expect(find.text('This month'), findsOneWidget);
    expect(find.text('Last month'), findsNothing);

    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();

    expect(find.text('This month'), findsNothing);
    expect(find.text('Last month'), findsOneWidget);
  });

  testWidgets('cannot step forward past the current month', (tester) async {
    await pump(tester, [tx('now', today)]);

    final next = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.chevron_right_rounded));
    expect(next.onPressed, isNull);
  });

  testWidgets('the Expenses and Income chips filter by type', (tester) async {
    await pump(tester, [
      tx('spend', today, note: 'Lunch'),
      tx('earn', today, type: TransactionType.income, category: 'salary', note: 'Pay'),
    ]);

    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();
    expect(find.text('Pay'), findsOneWidget);
    expect(find.text('Lunch'), findsNothing);

    await tester.tap(find.text('Expenses'));
    await tester.pumpAndSettle();
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('Pay'), findsNothing);

    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('Pay'), findsOneWidget);
  });

  testWidgets('search finds transactions in any month', (tester) async {
    final lastMonth = DateTime(now.year, now.month - 1, 15);
    await pump(tester, [
      tx('now', today, note: 'Lunch'),
      tx('then', lastMonth, note: 'Coffee beans'),
    ]);

    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'coffee');
    await tester.pumpAndSettle();

    expect(find.text('Coffee beans'), findsOneWidget);
    expect(find.text('Lunch'), findsNothing);
  });

  testWidgets('closing the search brings the month back', (tester) async {
    await pump(tester, [tx('now', today, note: 'Lunch')]);

    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('Nothing matches "zzz"'), findsOneWidget);

    await tester.tap(find.byTooltip('Close search'));
    await tester.pumpAndSettle();
    expect(find.text('Lunch'), findsOneWidget);
  });

  testWidgets('sorting by amount drops the day headers and shows dates on rows', (tester) async {
    await pump(tester, [
      tx('small', today, amount: 10000, note: 'Small'),
      tx('big', today, amount: 900000, note: 'Big'),
    ]);

    await tester.tap(find.byTooltip('Sort and filter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Highest amount'));
    await tester.pumpAndSettle();

    expect(find.text('TODAY'), findsNothing);
    expect(find.text('Today · Food'), findsNWidgets(2)); // no account, so none is named
    expect(
      tester.getTopLeft(find.text('Big')).dy,
      lessThan(tester.getTopLeft(find.text('Small')).dy),
    );
  });

  testWidgets('an empty month says so', (tester) async {
    await pump(tester, const []);

    expect(find.textContaining('No transactions in'), findsOneWidget);
  });

  testWidgets('tapping a transaction opens its receipt', (tester) async {
    await pump(tester, [tx('a', today, amount: 184500, note: 'Groceries')]);

    await tester.tap(find.text('Groceries'));
    await tester.pumpAndSettle();

    expect(find.text('TRANSACTION RECEIPT'), findsOneWidget);
  });

  testWidgets('can open on a given month', (tester) async {
    _seed = [tx('then', DateTime(2020, 5, 5), note: 'Long ago')];
    await tester.binding.setSurfaceSize(const Size(390, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionListProvider.overrideWith(_FakeTransactions.new),
          categoryListProvider.overrideWith(_FakeCategories.new),
          accountListProvider.overrideWith(_FakeAccounts.new),
          mainAccountIdProvider.overrideWithValue(null),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: TransactionListScreen(initialMonth: DateTime(2020, 5, 20)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('MAY 2020'), findsOneWidget);
    expect(find.text('Long ago'), findsOneWidget);
  });

  group('transfers', () {
    final yesterday = today.subtract(const Duration(days: 1));

    testWidgets('appear in the day with their own look, route and brass amount', (tester) async {
      await pump(
        tester,
        [tx('a', yesterday, amount: 68000, note: 'Lunch')],
        transfers: [transfer('t', yesterday, note: 'Top up DANA')],
      );

      expect(find.text('Top up DANA'), findsOneWidget);
      expect(find.text('BCA → DANA · Transfer'), findsOneWidget);
      final amount = tester.widget<Text>(find.text('500.000'));
      expect(amount.style!.color, AppColors.brass);
      expect(find.text('+500.000'), findsNothing);
      expect(find.text('−500.000'), findsNothing);
    });

    testWidgets('never count towards the day total, which is only what was spent', (tester) async {
      await pump(
        tester,
        [tx('a', yesterday, amount: 68000, note: 'Lunch')],
        transfers: [transfer('t', yesterday, amount: 5000000)],
      );

      expect(find.text('−68.000'), findsNWidgets(2)); // the row and the day total
      expect(find.text('+4.932.000'), findsNothing);
    });

    testWidgets('a day with only a transfer has no total', (tester) async {
      await pump(tester, const [], transfers: [transfer('t', yesterday, note: 'Top up')]);

      expect(find.text('YESTERDAY'), findsOneWidget);
      expect(find.text('+0'), findsNothing);
      expect(find.text('−0'), findsNothing);
    });

    testWidgets('the fee is a normal expense row, named for its route, and the day total includes it', (tester) async {
      await pump(
        tester,
        [tx('lunch', yesterday, amount: 68000, note: 'Lunch')],
        transfers: [transfer('t', yesterday, fee: 2500, note: 'Top up DANA')],
      );

      expect(find.text('Transfer fee'), findsOneWidget);
      expect(find.text('Food · BCA → DANA'), findsOneWidget);
      expect(find.text('−70.500'), findsOneWidget); // day total
    });

    testWidgets('a transaction names its account, and says nothing for one on no account', (tester) async {
      await pump(tester, [
        tx('a', today, note: 'Lunch'),
        TransactionModel(
          id: 'b',
          userId: 'u1',
          amount: 1,
          type: TransactionType.expense,
          categoryId: 'food',
          note: 'Ride',
          accountId: 'dana',
          date: today,
          createdAt: today,
          updatedAt: today,
        ),
      ]);

      expect(find.text('Food · DANA'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget); // Lunch, on no account
    });

    testWidgets('the Transfers chip shows only transfers', (tester) async {
      await pump(
        tester,
        [tx('a', today, note: 'Lunch')],
        transfers: [transfer('t', today, note: 'Top up DANA')],
      );

      await tester.tap(find.text('Transfers'));
      await tester.pumpAndSettle();

      expect(find.text('Top up DANA'), findsOneWidget);
      expect(find.text('Lunch'), findsNothing);
    });

    testWidgets('Expenses and Income leave them out', (tester) async {
      await pump(
        tester,
        [tx('a', today, note: 'Lunch')],
        transfers: [transfer('t', today, note: 'Top up DANA')],
      );

      await tester.tap(find.text('Expenses'));
      await tester.pumpAndSettle();
      expect(find.text('Top up DANA'), findsNothing);

      await tester.tap(find.text('Income'));
      await tester.pumpAndSettle();
      expect(find.text('Top up DANA'), findsNothing);
    });

    testWidgets('search finds a transfer by an account name', (tester) async {
      await pump(
        tester,
        [tx('a', today, note: 'Lunch')],
        transfers: [transfer('t', today, to: 'cash', note: 'Cash out')],
      );

      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'cash');
      await tester.pumpAndSettle();

      expect(find.text('Cash out'), findsOneWidget);
      expect(find.text('Lunch'), findsNothing);
    });

    testWidgets('sorted by amount a transfer sits among the rest and shows its date', (tester) async {
      await pump(
        tester,
        [tx('small', today, amount: 10000, note: 'Small')],
        transfers: [transfer('t', today, amount: 900000, note: 'Big move')],
      );

      await tester.tap(find.byTooltip('Sort and filter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Highest amount'));
      await tester.pumpAndSettle();

      expect(find.text('TODAY'), findsNothing);
      expect(find.text('Today · BCA → DANA'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Big move')).dy,
        lessThan(tester.getTopLeft(find.text('Small')).dy),
      );
    });

    testWidgets('tapping one opens its receipt', (tester) async {
      await pump(tester, const [], transfers: [transfer('t', today, note: 'Top up DANA')]);

      await tester.tap(find.text('Top up DANA'));
      await tester.pumpAndSettle();

      expect(find.text('TRANSFER RECEIPT'), findsOneWidget);
    });

    testWidgets('tapping a transfer fee opens the transfer receipt, not a transaction one', (tester) async {
      await pump(tester, const [], transfers: [transfer('t', today, fee: 2500, note: 'Top up DANA')]);

      await tester.tap(find.text('Transfer fee'));
      await tester.pumpAndSettle();

      expect(find.text('TRANSFER RECEIPT'), findsOneWidget);
      expect(find.text('TRANSACTION RECEIPT'), findsNothing);
    });

    testWidgets('choosing a category leaves transfers out', (tester) async {
      await pump(
        tester,
        [tx('a', today, note: 'Lunch')],
        transfers: [transfer('t', today, note: 'Top up DANA')],
      );

      await tester.tap(find.byTooltip('Sort and filter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Category…'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Food').last);
      await tester.pumpAndSettle();

      expect(find.text('Lunch'), findsOneWidget);
      expect(find.text('Top up DANA'), findsNothing);
    });
  });
}
