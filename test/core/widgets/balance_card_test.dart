import 'package:crowzy_finance/core/theme/app_theme.dart';
import 'package:crowzy_finance/core/utils/currency_formatter.dart';
import 'package:crowzy_finance/core/widgets/balance_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Widget _app(BalanceCard card, {bool disableAnimations = false}) {
  return MaterialApp(
    theme: AppTheme.dark,
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: card)),
    ),
  );
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('shows the balance, income and expenses', (tester) async {
    await tester.pumpWidget(
      _app(
        const BalanceCard(
          balance: 12480000,
          monthIncome: 18200000,
          monthExpense: 5720000,
          changePercent: 8.4,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('TOTAL BALANCE'), findsOneWidget);
    expect(find.text('Rp'), findsOneWidget);
    expect(find.text('12.480.000'), findsOneWidget);
    expect(find.text('+18.200.000'), findsOneWidget);
    expect(find.text('−5.720.000'), findsOneWidget);
    expect(find.text('+8,4% this month'), findsOneWidget);
  });

  testWidgets('hides the monthly change when there is none', (tester) async {
    await tester.pumpWidget(
      _app(const BalanceCard(balance: 100, monthIncome: 0, monthExpense: 0)),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('this month'), findsNothing);
  });

  testWidgets('a negative balance gets a true minus sign', (tester) async {
    await tester.pumpWidget(
      _app(const BalanceCard(balance: -350000, monthIncome: 0, monthExpense: 350000)),
    );
    await tester.pumpAndSettle();

    expect(find.text('−350.000'), findsWidgets);
  });

  testWidgets('counts up from zero on first show', (tester) async {
    await tester.pumpWidget(
      _app(const BalanceCard(balance: 12480000, monthIncome: 0, monthExpense: 0)),
    );
    expect(find.text('0'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('12.480.000'), findsOneWidget);
  });

  testWidgets('shows the final figure immediately when motion is reduced', (tester) async {
    await tester.pumpWidget(
      _app(
        const BalanceCard(balance: 12480000, monthIncome: 0, monthExpense: 0),
        disableAnimations: true,
      ),
    );
    await tester.pump();

    expect(find.text('12.480.000'), findsOneWidget);
  });

  testWidgets('reads as one summary to assistive technology', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(const BalanceCard(balance: 1000, monthIncome: 500, monthExpense: 200)),
    );
    await tester.pumpAndSettle();

    final label = 'Total balance ${CurrencyFormatter.format(1000)}. '
        'Income this month ${CurrencyFormatter.format(500)}. '
        'Expenses this month ${CurrencyFormatter.format(200)}.';
    expect(find.bySemanticsLabel(label), findsOneWidget);
    semantics.dispose();
  });

  group('accounts strip', () {
    testWidgets('shows the summary with a Manage link that can be tapped', (tester) async {
      var opened = 0;
      await tester.pumpWidget(
        _app(
          BalanceCard(
            balance: 100,
            monthIncome: 0,
            monthExpense: 0,
            accountsSummary: '3 accounts · BCA, DANA, Cash',
            onManageAccounts: () => opened++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('3 accounts · BCA, DANA, Cash'), findsOneWidget);
      expect(find.text('Manage ›'), findsOneWidget);

      await tester.tap(find.text('Manage ›'));
      expect(opened, 1);
      await tester.tap(find.text('3 accounts · BCA, DANA, Cash'));
      expect(opened, 2);
    });

    testWidgets('is absent without a summary', (tester) async {
      await tester.pumpWidget(
        _app(const BalanceCard(balance: 100, monthIncome: 0, monthExpense: 0)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Manage ›'), findsNothing);
    });

    testWidgets('is exposed to screen readers as a button, apart from the figures', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          BalanceCard(
            balance: 100,
            monthIncome: 0,
            monthExpense: 0,
            accountsSummary: '2 accounts · BCA, Cash',
            onManageAccounts: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(RegExp('Manage accounts. 2 accounts')),
        findsOneWidget,
      );
      handle.dispose();
    });
  });
}
