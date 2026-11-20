import 'package:crowzy_finance/core/theme/app_theme.dart';
import 'package:crowzy_finance/data/models/account_model.dart';
import 'package:crowzy_finance/data/models/account_type.dart';
import 'package:crowzy_finance/data/models/alert_model.dart';
import 'package:crowzy_finance/data/models/alert_type.dart';
import 'package:crowzy_finance/data/models/category_model.dart';
import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/data/models/wishlist_model.dart';
import 'package:crowzy_finance/features/accounts/providers/account_provider.dart';
import 'package:crowzy_finance/features/accounts/providers/transfer_provider.dart';
import 'package:crowzy_finance/features/accounts/ui/accounts_screen.dart';
import 'package:crowzy_finance/data/models/transfer.dart';
import 'package:crowzy_finance/features/alerts/providers/alert_provider.dart';
import 'package:crowzy_finance/features/auth/providers/auth_provider.dart';
import 'package:crowzy_finance/features/categories/providers/category_provider.dart';
import 'package:crowzy_finance/core/widgets/root_shell.dart';
import 'package:crowzy_finance/features/home/ui/home_screen.dart';
import 'package:crowzy_finance/features/transactions/providers/activity_provider.dart';
import 'package:crowzy_finance/features/transactions/providers/transaction_provider.dart';
import 'package:crowzy_finance/features/transactions/utils/activity_feed.dart';
import 'package:crowzy_finance/core/theme/app_colors.dart';
import 'package:crowzy_finance/features/transactions/utils/month_summary.dart';
import 'package:crowzy_finance/features/wishlist/providers/wishlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../support/transfers.dart';

List<TransactionModel> _all = [];

class _FakeTransactions extends TransactionList {
  @override
  Future<List<TransactionModel>> build() async => _all;
}

List<AccountModel> _accounts = [];

class _NoMemory implements LastTransferSource {
  @override
  String? get value => null;

  @override
  Future<void> save(String accountId) async {}
}

class _FakeAccounts extends AccountList {
  @override
  Future<List<AccountModel>> build() async => _accounts;
}

AccountModel _account(String id, String name, {bool archived = false}) => AccountModel(
      id: id,
      userId: 'u',
      name: name,
      type: AccountType.bank,
      isArchived: archived,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

class _FakeCategories extends CategoryList {
  @override
  Future<List<CategoryModel>> build() async => [
        CategoryModel(
          id: 'food',
          name: 'Food',
          icon: 'restaurant',
          type: TransactionType.expense,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      ];
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  final now = DateTime.now();

  TransactionModel tx(String id, double amount, {String? note}) => TransactionModel(
        id: id,
        userId: 'u1',
        amount: amount,
        type: TransactionType.expense,
        categoryId: 'food',
        note: note,
        date: now,
        createdAt: now,
        updatedAt: now,
      );

  WishlistModel goal() => WishlistModel(
        id: 'g1',
        userId: 'u1',
        name: 'Japan trip',
        targetAmount: 100,
        currentAmount: 62,
        createdAt: now,
        updatedAt: now,
      );

  AlertModel alert({AlertType type = AlertType.categorySpike}) => AlertModel(
        id: 'a1',
        userId: 'u1',
        type: type,
        period: '2026-10',
        message: 'Dining is up 40%',
        createdAt: now,
      );

  Future<void> pumpHome(
    WidgetTester tester, {
    List<TransactionModel> recent = const [],
    List<Transfer> transfers = const [],
    List<WishlistModel> goals = const [],
    List<AlertModel> alerts = const [],
    List<AccountModel>? accounts,
    Widget home = const HomeScreen(),
  }) async {
    // A transfer is stored as its two legs, which is how the receipt finds it.
    _all = [...recent, for (final t in transfers) ...legsOf(t)];
    _accounts = accounts ?? [_account('a', 'BCA'), _account('b', 'DANA'), _account('c', 'Cash')];
    await tester.binding.setSurfaceSize(const Size(390, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(null),
          allTimeBalanceProvider.overrideWithValue(12480000),
          thisMonthSummaryProvider.overrideWithValue(
            const MonthSummary(income: 18200000, expense: 5720000, changePercent: 8.4),
          ),
          transactionListProvider.overrideWith(_FakeTransactions.new),
          recentActivityProvider.overrideWithValue(mergeActivity(recent, transfers)),
          activeWishlistGoalsProvider.overrideWithValue(goals),
          unreadAlertsProvider.overrideWithValue(alerts),
          categoryListProvider.overrideWith(_FakeCategories.new),
          accountListProvider.overrideWith(_FakeAccounts.new),
          // What the forms read when the + button opens them.
          lastTransferSourceProvider.overrideWithValue(_NoMemory()),
          lastUsedAccountIdProvider.overrideWithValue(null),
          lastUsedCategoryIdProvider.overrideWith((ref, type) => null),
        ],
        child: MaterialApp(theme: AppTheme.dark, home: home),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the greeting, balance and the manage links', (tester) async {
    await pumpHome(tester);

    expect(find.textContaining('Good '), findsOneWidget);
    expect(find.text('TOTAL BALANCE'), findsOneWidget);
    expect(find.text('12.480.000'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Wishlist goals'), findsOneWidget);
  });

  testWidgets('with nothing yet it asks for a first transaction and hides the tiles', (tester) async {
    await pumpHome(tester);

    expect(find.textContaining('No transactions yet'), findsOneWidget);
    expect(find.text('NOTICE'), findsNothing);
    expect(find.text('JAPAN TRIP'), findsNothing);
  });

  testWidgets('shows the first active goal and the latest notice side by side', (tester) async {
    await pumpHome(tester, goals: [goal()], alerts: [alert()]);

    expect(find.text('JAPAN TRIP'), findsOneWidget);
    expect(find.text('62%'), findsOneWidget);
    expect(find.text('NOTICE'), findsOneWidget);
    expect(find.text('Dining is up 40%'), findsOneWidget);
  });

  testWidgets('shows only the goal when there are no unread alerts', (tester) async {
    await pumpHome(tester, goals: [goal()]);

    expect(find.text('JAPAN TRIP'), findsOneWidget);
    expect(find.text('NOTICE'), findsNothing);
  });

  testWidgets('lists at most the three most recent transactions', (tester) async {
    await pumpHome(
      tester,
      recent: [
        tx('1', 1000, note: 'One'),
        tx('2', 2000, note: 'Two'),
        tx('3', 3000, note: 'Three'),
        tx('4', 4000, note: 'Four'),
        tx('5', 5000, note: 'Five'),
      ],
    );

    expect(find.text('One'), findsOneWidget);
    expect(find.text('Two'), findsOneWidget);
    expect(find.text('Three'), findsOneWidget);
    expect(find.text('Four'), findsNothing);
    expect(find.text('Five'), findsNothing);
    expect(find.textContaining('No transactions yet'), findsNothing);
  });

  testWidgets('a good-news alert is introduced as good news rather than a notice', (tester) async {
    await pumpHome(tester, alerts: [alert(type: AlertType.incomeReceived)]);

    expect(find.text('GOOD NEWS'), findsOneWidget);
    expect(find.text('NOTICE'), findsNothing);
  });

  testWidgets('tapping a recent transaction opens its receipt', (tester) async {
    await pumpHome(tester, recent: [tx('1', 1000, note: 'One')]);

    await tester.tap(find.text('One'));
    await tester.pumpAndSettle();

    expect(find.text('TRANSACTION RECEIPT'), findsOneWidget);
  });

  group('transfers in Recent', () {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));

    Transfer transfer({String? note = 'Top up DANA'}) =>
        fakeTransfer('t1', from: 'a', to: 'b', amount: 500000, note: note, date: yesterday);

    testWidgets('a transfer shows between the transactions with its route and a brass amount', (tester) async {
      await pumpHome(
        tester,
        recent: [tx('1', 1000, note: 'Lunch')],
        transfers: [transfer()],
      );

      expect(find.text('Top up DANA'), findsOneWidget);
      expect(find.text('Yesterday · BCA → DANA'), findsOneWidget);
      final amount = tester.widget<Text>(find.text('500.000'));
      expect(amount.style!.color, AppColors.brass);
      expect(find.text('Lunch'), findsOneWidget);
    });

    testWidgets('only the latest three entries show, transfers counting like any other', (tester) async {
      await pumpHome(
        tester,
        recent: [
          tx('1', 1000, note: 'One'),
          tx('2', 2000, note: 'Two'),
          tx('3', 3000, note: 'Three'),
        ],
        transfers: [transfer()],
      );

      // The transfer is from yesterday, so it ranks after today's three.
      expect(find.text('Top up DANA'), findsNothing);
      expect(find.text('Three'), findsOneWidget);
    });

    testWidgets('a feed of only transfers is not the empty state', (tester) async {
      await pumpHome(tester, transfers: [transfer()]);

      expect(find.textContaining('No transactions yet'), findsNothing);
      expect(find.text('Top up DANA'), findsOneWidget);
    });

    testWidgets('tapping one opens its receipt', (tester) async {
      await pumpHome(tester, transfers: [transfer()]);

      await tester.tap(find.text('Top up DANA'));
      await tester.pumpAndSettle();

      expect(find.text('TRANSFER RECEIPT'), findsOneWidget);
    });

    testWidgets('Recent does not add account names to transaction lines', (tester) async {
      await pumpHome(tester, recent: [tx('1', 1000, note: 'Lunch')]);

      expect(find.textContaining('Food ·'), findsNothing);
    });
  });

  group('accounts strip', () {
    testWidgets('lists the active accounts under the balance', (tester) async {
      await pumpHome(tester);

      expect(find.text('3 accounts · BCA, DANA, Cash'), findsOneWidget);
      expect(find.text('Manage ›'), findsOneWidget);
    });

    testWidgets('leaves archived accounts out and uses the singular for one', (tester) async {
      await pumpHome(tester, accounts: [_account('a', 'BCA'), _account('b', 'Old', archived: true)]);

      expect(find.text('1 account · BCA'), findsOneWidget);
    });

    testWidgets('is still there with no accounts, as the way in to add the first', (tester) async {
      await pumpHome(tester, accounts: []);

      expect(find.text('No accounts yet'), findsOneWidget);
      expect(find.text('Manage ›'), findsOneWidget);

      await tester.tap(find.text('Manage ›'));
      await tester.pumpAndSettle();
      expect(find.byType(AccountsScreen), findsOneWidget);
      expect(find.text('Add your first account with the + button'), findsOneWidget);
    });

    testWidgets('says so when every account is archived', (tester) async {
      await pumpHome(tester, accounts: [_account('a', 'Old', archived: true)]);

      expect(find.text('No accounts yet'), findsOneWidget);
    });

    testWidgets('Home also lists Accounts among the places to manage, ahead of Categories', (tester) async {
      await pumpHome(tester);

      expect(find.text('Accounts'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Accounts')).dy,
        lessThan(tester.getTopLeft(find.text('Categories')).dy),
      );

      await tester.tap(find.text('Accounts'));
      await tester.pumpAndSettle();
      expect(find.byType(AccountsScreen), findsOneWidget);
    });

    testWidgets('Manage opens the Accounts screen', (tester) async {
      await pumpHome(tester);

      await tester.tap(find.text('Manage ›'));
      await tester.pumpAndSettle();

      expect(find.byType(AccountsScreen), findsOneWidget);
    });
  });

  group('the + button in the navigation bar', () {
    testWidgets('opens the Add chooser with Expense, Income and Transfer', (tester) async {
      await pumpHome(tester, home: const RootShell());

      await tester.tap(find.bySemanticsLabel('Add transaction'));
      await tester.pumpAndSettle();

      expect(find.text('What happened?'), findsOneWidget);
      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Transfer'), findsOneWidget);
    });

    testWidgets('Transfer opens the transfer form', (tester) async {
      await pumpHome(tester, home: const RootShell());

      await tester.tap(find.bySemanticsLabel('Add transaction'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Transfer'));
      await tester.pumpAndSettle();

      expect(find.text('New transfer'), findsOneWidget);
    });

    testWidgets('Expense and Income open the transaction form, on the matching side', (tester) async {
      await pumpHome(tester, home: const RootShell());

      await tester.tap(find.bySemanticsLabel('Add transaction'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Income'));
      await tester.pumpAndSettle();

      expect(find.text('New transaction'), findsOneWidget);
      expect(
        tester.widget<SegmentedButton<TransactionType>>(find.byType(SegmentedButton<TransactionType>)).selected,
        {TransactionType.income},
      );
    });
  });
}
