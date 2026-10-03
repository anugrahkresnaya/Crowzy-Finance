import 'package:crowzy_finance/core/theme/app_theme.dart';
import 'package:crowzy_finance/data/models/category_model.dart';
import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/features/reports/ui/widgets/day_receipt_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  // A Saturday.
  final saturday = DateTime(2026, 10, 3);

  CategoryModel cat(String id, String name) => CategoryModel(
        id: id,
        name: name,
        icon: 'category',
        type: TransactionType.expense,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

  TransactionModel tx(String id, double amount, String category, DateTime createdAt, {String? note}) =>
      TransactionModel(
        id: id,
        userId: 'u1',
        amount: amount,
        type: TransactionType.expense,
        categoryId: category,
        note: note,
        date: saturday,
        createdAt: createdAt,
        updatedAt: createdAt,
      );

  final categories = {'food': cat('food', 'Food'), 'transport': cat('transport', 'Transport')};

  Widget sheet({
    required List<TransactionModel> expenses,
    double average = 286600,
    VoidCallback? onView,
    VoidCallback? onClose,
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: DayReceiptSheet(
          date: saturday,
          expenses: expenses,
          categoryById: categories,
          average: average,
          onViewInActivity: onView ?? () {},
          onClose: onClose ?? () {},
        ),
      ),
    );
  }

  Future<void> pump(WidgetTester tester, Widget widget) async {
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(widget);
    // Let the receipt finish printing so nothing is left animating.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  }

  final groceries = tx('1', 184500, 'food', DateTime(2026, 10, 3, 9, 12), note: 'Groceries');
  final ride = tx('2', 52000, 'transport', DateTime(2026, 10, 3, 8, 5));

  testWidgets('prints the day, its lines, the total and the daily-average note', (tester) async {
    await pump(tester, sheet(expenses: [ride, groceries]));

    expect(find.text('DAILY RECEIPT'), findsOneWidget);
    expect(find.text('SAT 3 OCTOBER 2026'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('09:12 · FOOD'), findsOneWidget);
    expect(find.text('−184.500'), findsOneWidget);
    expect(find.text('08:05 · TRANSPORT'), findsOneWidget);
    expect(find.text('TOTAL · 2 ITEMS'), findsOneWidget);
    expect(find.text('−236.500'), findsOneWidget);
    expect(find.text('0,8× YOUR DAILY AVERAGE'), findsOneWidget);
  });

  testWidgets('lists the most recent line first', (tester) async {
    await pump(tester, sheet(expenses: [ride, groceries]));

    expect(
      tester.getTopLeft(find.text('Groceries')).dy,
      lessThan(tester.getTopLeft(find.text('Transport')).dy),
    );
  });

  testWidgets('a line without a note is titled by its category', (tester) async {
    await pump(tester, sheet(expenses: [ride]));

    expect(find.text('Transport'), findsOneWidget);
    expect(find.text('TOTAL · 1 ITEM'), findsOneWidget);
  });

  testWidgets('a missing category reads as Uncategorized', (tester) async {
    await pump(tester, sheet(expenses: [tx('3', 1000, 'gone', DateTime(2026, 10, 3, 7))]));

    expect(find.text('Uncategorized'), findsOneWidget);
    expect(find.text('07:00 · UNCATEGORIZED'), findsOneWidget);
  });

  testWidgets('both buttons call back', (tester) async {
    var views = 0;
    var closes = 0;
    await pump(tester, sheet(expenses: [ride], onView: () => views++, onClose: () => closes++));

    await tester.tap(find.text('View in Activity'));
    await tester.tap(find.text('Close'));

    expect(views, 1);
    expect(closes, 1);
  });

  testWidgets('a tall receipt scrolls instead of overflowing', (tester) async {
    final many = [
      for (var i = 0; i < 40; i++) tx('t$i', 1000.0 + i, 'food', DateTime(2026, 10, 3, 6, i)),
    ];
    await tester.binding.setSurfaceSize(const Size(390, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(sheet(expenses: many));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
