import 'package:crowzy_finance/core/theme/app_theme.dart';
import 'package:crowzy_finance/data/models/category_model.dart';
import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/features/categories/providers/category_provider.dart';
import 'package:crowzy_finance/features/reports/providers/report_provider.dart';
import 'package:crowzy_finance/features/reports/ui/monthly_report_screen.dart';
import 'package:crowzy_finance/features/transactions/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

// A fixed month in the past, so the tests do not depend on today's date.
final _may = DateTime(2020, 5);

class _FixedMonth extends SelectedReportMonth {
  @override
  DateTime build() => _may;
}

class _FakeTransactions extends TransactionList {
  @override
  Future<List<TransactionModel>> build() async => [
        _tx('housing', DateTime(2020, 5, 1), 3500000, 'housing'),
        _tx('salary', DateTime(2020, 5, 1), 1000000, 'salary', income: true),
        _tx('groceries', DateTime(2020, 5, 5), 184500, 'food', note: 'Groceries'),
        _tx('ride', DateTime(2020, 5, 5), 52000, 'transport'),
        _tx('april', DateTime(2020, 4, 10), 4000000, 'housing'),
      ];
}

class _FakeCategories extends CategoryList {
  @override
  Future<List<CategoryModel>> build() async => [
        _cat('housing', 'Housing'),
        _cat('food', 'Food'),
        _cat('transport', 'Transport'),
        _cat('salary', 'Salary', income: true),
      ];
}

CategoryModel _cat(String id, String name, {bool income = false}) => CategoryModel(
      id: id,
      name: name,
      icon: 'category',
      type: income ? TransactionType.income : TransactionType.expense,
      createdAt: DateTime(2020),
      updatedAt: DateTime(2020),
    );

TransactionModel _tx(
  String id,
  DateTime date,
  double amount,
  String category, {
  bool income = false,
  String? note,
}) =>
    TransactionModel(
      id: id,
      userId: 'u1',
      amount: amount,
      type: income ? TransactionType.income : TransactionType.expense,
      categoryId: category,
      note: note,
      date: date,
      createdAt: date,
      updatedAt: date,
    );

Future<void> settle(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pump(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedReportMonthProvider.overrideWith(_FixedMonth.new),
          transactionListProvider.overrideWith(_FakeTransactions.new),
          categoryListProvider.overrideWith(_FakeCategories.new),
        ],
        child: MaterialApp(theme: AppTheme.dark, home: const MonthlyReportScreen()),
      ),
    );
    await settle(tester);
  }

  testWidgets('shows the month with its income and expenses', (tester) async {
    await pump(tester);

    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('MAY 2020'), findsOneWidget);
    expect(find.text('1.000.000'), findsOneWidget); // income
    expect(find.text('3.736.500'), findsOneWidget); // 3.500.000 + 184.500 + 52.000
  });

  testWidgets('starts on the biggest spending day', (tester) async {
    await pump(tester);

    expect(find.text('1 MAY'), findsOneWidget);
    expect(find.text('−3.500.000'), findsOneWidget);
    expect(find.textContaining('biggest day'), findsOneWidget);
  });

  testWidgets('tapping a bar selects another day', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);

    await tester.tap(find.bySemanticsLabel('5 May, Rp 236.500'));
    await settle(tester);

    expect(find.text('5 MAY'), findsOneWidget);
    expect(find.text('−236.500'), findsOneWidget);
    expect(find.textContaining('biggest day'), findsNothing);
    semantics.dispose();
  });

  testWidgets('lists spending by category and opens a row for its detail', (tester) async {
    await pump(tester);

    expect(find.text('BY CATEGORY'), findsOneWidget);
    expect(find.text('Housing'), findsOneWidget);
    expect(find.text('INCOME BY CATEGORY'), findsOneWidget);
    expect(find.text('Salary'), findsOneWidget);

    await tester.tap(find.text('Food'));
    await settle(tester);

    expect(find.text('1 transaction · average Rp 184.500'), findsOneWidget);
  });

  testWidgets('compares expenses with the previous month', (tester) async {
    await pump(tester);

    // 3.736.500 against 4.000.000 is 6,6% less.
    expect(find.text('VERSUS APRIL'), findsOneWidget);
    expect(find.text('You spent less overall'), findsOneWidget);
    expect(find.text('−7%'), findsOneWidget);
  });

  testWidgets('the Calendar tab shows the month and selecting a day updates the card', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Calendar'));
    await settle(tester);

    expect(find.text('Less'), findsOneWidget);
    expect(find.text('31'), findsOneWidget);
    expect(find.text('SPENDING BY DAY'), findsNothing);

    await tester.tap(find.text('5'));
    await settle(tester);

    expect(find.text('5 MAY'), findsOneWidget);
  });

  testWidgets('the Days tab ranks the biggest days and tapping one opens it in Overview', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Days'));
    await settle(tester);

    expect(find.text('BIGGEST SPENDING DAYS'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('1 May')).dy,
      lessThan(tester.getTopLeft(find.text('5 May')).dy),
    );

    await tester.tap(find.text('5 May'));
    await settle(tester);

    expect(find.text('SPENDING BY DAY'), findsOneWidget);
    expect(find.text('5 MAY'), findsOneWidget);
  });

  testWidgets('moving to another month starts again from its biggest day', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);

    await tester.tap(find.bySemanticsLabel('5 May, Rp 236.500'));
    await settle(tester);
    expect(find.text('5 MAY'), findsOneWidget);

    await tester.tap(find.byTooltip('Previous month'));
    await settle(tester);

    expect(find.text('APRIL 2020'), findsOneWidget);
    expect(find.text('10 APRIL'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('a month with no transactions says so', (tester) async {
    await pump(tester);

    await tester.tap(find.byTooltip('Previous month'));
    await settle(tester);
    await tester.tap(find.byTooltip('Previous month'));
    await settle(tester);

    expect(find.text('No transactions in March 2020'), findsOneWidget);
    expect(find.text('SPENDING BY DAY'), findsNothing);
  });
}
