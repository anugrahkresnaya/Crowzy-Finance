import 'package:crowzy_finance/core/theme/app_theme.dart';
import 'package:crowzy_finance/data/models/category_model.dart';
import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/features/categories/providers/category_provider.dart';
import 'package:crowzy_finance/features/transactions/providers/transaction_provider.dart';
import 'package:crowzy_finance/features/transactions/ui/transaction_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

late List<TransactionModel> _seed;

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

  Future<void> pump(WidgetTester tester, List<TransactionModel> transactions) async {
    _seed = transactions;
    await tester.binding.setSurfaceSize(const Size(390, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionListProvider.overrideWith(_FakeTransactions.new),
          categoryListProvider.overrideWith(_FakeCategories.new),
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
    expect(find.text('Today · Food'), findsNWidgets(2));
    expect(
      tester.getTopLeft(find.text('Big')).dy,
      lessThan(tester.getTopLeft(find.text('Small')).dy),
    );
  });

  testWidgets('an empty month says so', (tester) async {
    await pump(tester, const []);

    expect(find.textContaining('No transactions in'), findsOneWidget);
  });
}
