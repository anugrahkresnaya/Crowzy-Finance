import 'package:crowzy_finance/core/theme/app_colors.dart';
import 'package:crowzy_finance/data/models/category_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/features/reports/repository/report_repository.dart';
import 'package:crowzy_finance/features/reports/ui/widgets/category_breakdown_list.dart';
import 'package:crowzy_finance/features/reports/ui/widgets/day_detail_card.dart';
import 'package:crowzy_finance/features/reports/ui/widgets/expense_comparison_card.dart';
import 'package:crowzy_finance/features/reports/ui/widgets/ranked_days_list.dart';
import 'package:crowzy_finance/features/reports/ui/widgets/report_calendar_grid.dart';
import 'package:crowzy_finance/features/reports/ui/widgets/spending_bars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> settle(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 2)); // fires bar-grow delays
  await tester.pumpAndSettle();
}

Widget host(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: child)),
    );

void main() {
  final october = DateTime(2026, 10);

  group('SpendingBars', () {
    List<double> amounts() => [
          for (var i = 0; i < 31; i++) i == 0 ? 3700000.0 : (i == 2 ? 236500.0 : 0.0),
        ];

    testWidgets('has one tappable bar per day, labelled with its date and amount', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        host(SpendingBars(amounts: amounts(), month: october, selectedDay: 1, onSelect: (_) {})),
      );
      await settle(tester);

      expect(find.bySemanticsLabel(RegExp(r'^\d+ Oct, Rp')), findsNWidgets(31));
      expect(find.bySemanticsLabel('3 Oct, ${_rp(236500)}'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('tapping a bar selects that day', (tester) async {
      final semantics = tester.ensureSemantics();
      final picked = <int>[];
      await tester.pumpWidget(
        host(SpendingBars(amounts: amounts(), month: october, selectedDay: 1, onSelect: picked.add)),
      );
      await settle(tester);

      await tester.tap(find.bySemanticsLabel('3 Oct, ${_rp(236500)}'));

      expect(picked, [3]);
      semantics.dispose();
    });

    testWidgets('shows the first, middle and last day under the chart', (tester) async {
      await tester.pumpWidget(
        host(SpendingBars(amounts: amounts(), month: october, selectedDay: null, onSelect: (_) {})),
      );
      await settle(tester);

      expect(find.text('1'), findsOneWidget);
      expect(find.text('16'), findsOneWidget);
      expect(find.text('31'), findsOneWidget);
    });

    testWidgets('does not fail when nothing was spent', (tester) async {
      await tester.pumpWidget(
        host(
          SpendingBars(
            amounts: List.filled(30, 0),
            month: DateTime(2026, 9),
            selectedDay: null,
            onSelect: (_) {},
          ),
        ),
      );
      await settle(tester);

      expect(tester.takeException(), isNull);
    });
  });

  group('ReportCalendarGrid', () {
    test('the 1st lands under the right weekday (weeks start on Monday)', () {
      expect(ReportCalendarGrid.leadingBlanks(DateTime(2026, 10)), 3); // Thursday
      expect(ReportCalendarGrid.leadingBlanks(DateTime(2026, 9)), 1); // Tuesday
      expect(ReportCalendarGrid.leadingBlanks(DateTime(2026, 8)), 5); // Saturday
      expect(ReportCalendarGrid.leadingBlanks(DateTime(2026, 6)), 0); // Monday
      expect(ReportCalendarGrid.leadingBlanks(DateTime(2026, 2)), 6); // Sunday
    });

    test('dot strength follows the share of the biggest day', () {
      expect(ReportCalendarGrid.levelColor(100, 100), AppColors.brass);
      expect(ReportCalendarGrid.levelColor(51, 100), AppColors.brass);
      expect(ReportCalendarGrid.levelColor(50, 100), AppColors.brassMid);
      expect(ReportCalendarGrid.levelColor(21, 100), AppColors.brassMid);
      expect(ReportCalendarGrid.levelColor(20, 100), AppColors.brassDim);
      expect(ReportCalendarGrid.levelColor(5, 0), AppColors.brassDim);
    });

    testWidgets('shows every day and reports taps', (tester) async {
      final picked = <int>[];
      await tester.pumpWidget(
        host(
          ReportCalendarGrid(
            month: october,
            amounts: [for (var i = 0; i < 31; i++) i == 2 ? 500.0 : 0.0],
            selectedDay: 3,
            onSelect: picked.add,
          ),
        ),
      );

      for (final day in ['1', '15', '31']) {
        expect(find.text(day), findsOneWidget);
      }
      expect(find.text('M'), findsOneWidget);
      expect(find.text('Less'), findsOneWidget);

      await tester.tap(find.text('15'));
      expect(picked, [15]);
    });
  });

  group('RankedDaysList', () {
    testWidgets('lists the biggest days first and reports taps', (tester) async {
      final picked = <int>[];
      await tester.pumpWidget(
        host(
          RankedDaysList(
            month: october,
            amounts: [for (var i = 0; i < 31; i++) i == 0 ? 3700000.0 : (i == 4 ? 900000.0 : 0.0)],
            onSelect: picked.add,
          ),
        ),
      );
      await settle(tester);

      expect(find.text('1 Oct'), findsOneWidget);
      expect(find.text('5 Oct'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('1 Oct')).dy,
        lessThan(tester.getTopLeft(find.text('5 Oct')).dy),
      );

      await tester.tap(find.text('5 Oct'));
      expect(picked, [5]);
    });

    testWidgets('says so when there was no spending', (tester) async {
      await tester.pumpWidget(
        host(RankedDaysList(month: october, amounts: List.filled(31, 0), onSelect: (_) {})),
      );

      expect(find.text('No spending this month'), findsOneWidget);
    });
  });

  group('CategoryBreakdownList', () {
    CategoryBreakdownEntry entry(String name, double total, double pct, int count) =>
        CategoryBreakdownEntry(
          category: CategoryModel(
            id: name,
            name: name,
            icon: 'category',
            type: TransactionType.expense,
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
          total: total,
          percentage: pct,
          count: count,
        );

    testWidgets('shows each category with its total and share', (tester) async {
      await tester.pumpWidget(
        host(
          CategoryBreakdownList(
            entries: [entry('Housing', 3500000, 61.2, 1), entry('Food', 1240000, 21.6, 14)],
          ),
        ),
      );
      await settle(tester);

      expect(find.text('Housing'), findsOneWidget);
      expect(find.textContaining('3.500.000'), findsOneWidget);
      expect(find.textContaining('61%'), findsOneWidget);
      expect(find.textContaining('22%'), findsOneWidget);
    });

    testWidgets('tapping a row opens its detail and tapping again closes it', (tester) async {
      await tester.pumpWidget(
        host(CategoryBreakdownList(entries: [entry('Food', 1240000, 100, 14)])),
      );
      await settle(tester);

      expect(find.textContaining('transactions'), findsNothing);

      await tester.tap(find.text('Food'));
      await settle(tester);
      expect(find.text('14 transactions · average ${_rp(1240000 / 14)}'), findsOneWidget);

      await tester.tap(find.text('Food'));
      await settle(tester);
      expect(find.textContaining('transactions'), findsNothing);
    });

    testWidgets('only one row is open at a time', (tester) async {
      await tester.pumpWidget(
        host(
          CategoryBreakdownList(
            entries: [entry('Housing', 3500000, 60, 1), entry('Food', 1240000, 40, 14)],
          ),
        ),
      );
      await settle(tester);

      await tester.tap(find.text('Housing'));
      await settle(tester);
      expect(find.text('1 transaction · average ${_rp(3500000)}'), findsOneWidget);

      await tester.tap(find.text('Food'));
      await settle(tester);
      expect(find.textContaining('1 transaction ·'), findsNothing);
      expect(find.textContaining('14 transactions ·'), findsOneWidget);
    });
  });

  group('DayDetailCard', () {
    test('multiplierText uses a decimal comma and handles empty days', () {
      expect(DayDetailCard.multiplierText(236500, 286600), '0,8× your daily average');
      expect(DayDetailCard.multiplierText(1000, 100), '10,0× your daily average');
      expect(DayDetailCard.multiplierText(0, 100), 'No spending this day');
      expect(DayDetailCard.multiplierText(500, 0), '');
    });

    testWidgets('shows the date, the note and the amount', (tester) async {
      await tester.pumpWidget(
        host(
          DayDetailCard(
            date: DateTime(2026, 10, 1),
            amount: 3700000,
            average: 286600,
            isBiggestDay: true,
          ),
        ),
      );

      expect(find.text('1 OCTOBER'), findsOneWidget);
      expect(find.text('12,9× your daily average · biggest day'), findsOneWidget);
      expect(find.text('−3.700.000'), findsOneWidget);
    });

    testWidgets('a day with no spending reads as zero', (tester) async {
      await tester.pumpWidget(
        host(
          DayDetailCard(
            date: DateTime(2026, 10, 2),
            amount: 0,
            average: 286600,
            isBiggestDay: false,
          ),
        ),
      );

      expect(find.text('No spending this day'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });
  });

  group('ExpenseComparisonCard', () {
    testWidgets('less spending reads as good news', (tester) async {
      await tester.pumpWidget(
        host(const ExpenseComparisonCard(previousMonthName: 'September', changePercent: -12.4)),
      );

      expect(find.text('VERSUS SEPTEMBER'), findsOneWidget);
      expect(find.text('You spent less overall'), findsOneWidget);
      expect(find.text('−12%'), findsOneWidget);
    });

    testWidgets('more spending is called out', (tester) async {
      await tester.pumpWidget(
        host(const ExpenseComparisonCard(previousMonthName: 'August', changePercent: 7.6)),
      );

      expect(find.text('You spent more overall'), findsOneWidget);
      expect(find.text('+8%'), findsOneWidget);
    });
  });
}

String _rp(num amount) => 'Rp ${amount.round().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';
