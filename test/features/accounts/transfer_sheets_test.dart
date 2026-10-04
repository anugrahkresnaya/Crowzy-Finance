import 'package:crowzy_finance/core/theme/app_colors.dart';
import 'package:crowzy_finance/core/theme/app_theme.dart';
import 'package:crowzy_finance/data/models/account_model.dart';
import 'package:crowzy_finance/data/models/account_type.dart';
import 'package:crowzy_finance/features/accounts/ui/widgets/account_picker_sheet.dart';
import 'package:crowzy_finance/features/transactions/ui/widgets/add_chooser_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

AccountModel _account(String id, String name, AccountType type) => AccountModel(
      id: id,
      userId: 'u',
      name: name,
      type: type,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> open(WidgetTester tester, Future<void> Function(BuildContext) onOpen) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(onPressed: () => onOpen(context), child: const Text('open')),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  group('account picker', () {
    final accounts = [
      _account('bca', 'BCA', AccountType.bank),
      _account('dana', 'DANA', AccountType.ewallet),
      _account('cash', 'Cash', AccountType.cash),
    ];
    final balances = {'bca': 9730000.0, 'dana': 1850000.0, 'cash': -900.0};

    testWidgets('lists each account with its balance, flagging a negative one', (tester) async {
      await open(tester, (context) async {
        await showAccountPickerSheet(context, accounts: accounts, balances: balances);
      });

      expect(find.text('ACCOUNT'), findsOneWidget);
      expect(find.text('Choose an account'), findsOneWidget);
      for (final name in ['BCA', 'DANA', 'Cash']) {
        expect(find.text(name), findsOneWidget);
      }
      expect(find.text('Balance 9.730.000'), findsOneWidget);
      expect(find.text('Balance 1.850.000'), findsOneWidget);
      final negative = find.text('Balance −900');
      expect(negative, findsOneWidget);
      expect(tester.widget<Text>(negative).style!.color, AppColors.expense);
    });

    testWidgets('marks the selected account with a check and no other', (tester) async {
      await open(tester, (context) async {
        await showAccountPickerSheet(context, accounts: accounts, balances: balances, selectedId: 'dana');
      });

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      final check = tester.getCenter(find.byIcon(Icons.check_rounded)).dy;
      expect(check, closeTo(tester.getCenter(find.text('DANA')).dy, 20));
    });

    testWidgets('tapping an account returns it', (tester) async {
      AccountModel? picked;
      await open(tester, (context) async {
        picked = await showAccountPickerSheet(context, accounts: accounts, balances: balances);
      });

      await tester.tap(find.text('DANA'));
      await tester.pumpAndSettle();

      expect(picked?.id, 'dana');
      expect(find.text('Choose an account'), findsNothing);
    });

    testWidgets('dismissing it returns nothing', (tester) async {
      AccountModel? picked = accounts.first;
      var finished = false;
      await open(tester, (context) async {
        picked = await showAccountPickerSheet(context, accounts: accounts, balances: balances);
        finished = true;
      });

      await tester.tapAt(const Offset(195, 40));
      await tester.pumpAndSettle();

      expect(finished, isTrue);
      expect(picked, isNull);
    });

    testWidgets('an account missing from the balances falls back to its opening balance', (tester) async {
      await open(tester, (context) async {
        await showAccountPickerSheet(
          context,
          accounts: [_account('x', 'Jago', AccountType.bank).copyWith(openingBalance: 5000)],
          balances: const {},
        );
      });

      expect(find.text('Balance 5.000'), findsOneWidget);
    });
  });

  group('add chooser', () {
    testWidgets('offers Expense, Income and Transfer', (tester) async {
      await open(tester, (context) async {
        await showAddChooserSheet(context);
      });

      expect(find.text('ADD'), findsOneWidget);
      expect(find.text('What happened?'), findsOneWidget);
      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Money you spent'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Money you received'), findsOneWidget);
      expect(find.text('Transfer'), findsOneWidget);
      expect(find.text('Move money between your accounts'), findsOneWidget);
    });

    for (final (label, expected) in [
      ('Expense', AddChoice.expense),
      ('Income', AddChoice.income),
      ('Transfer', AddChoice.transfer),
    ]) {
      testWidgets('tapping $label returns it', (tester) async {
        AddChoice? choice;
        await open(tester, (context) async {
          choice = await showAddChooserSheet(context);
        });

        await tester.tap(find.text(label));
        await tester.pumpAndSettle();

        expect(choice, expected);
      });
    }

    testWidgets('dismissing it returns nothing', (tester) async {
      AddChoice? choice = AddChoice.income;
      var finished = false;
      await open(tester, (context) async {
        choice = await showAddChooserSheet(context);
        finished = true;
      });

      await tester.tapAt(const Offset(195, 40));
      await tester.pumpAndSettle();

      expect(finished, isTrue);
      expect(choice, isNull);
    });
  });
}
