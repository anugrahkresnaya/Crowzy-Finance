import 'package:crowzy_finance/core/theme/app_colors.dart';
import 'package:crowzy_finance/core/theme/app_theme.dart';
import 'package:crowzy_finance/data/models/account_model.dart';
import 'package:crowzy_finance/data/models/account_type.dart';
import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/data/models/transfer_model.dart';
import 'package:crowzy_finance/features/accounts/providers/account_provider.dart';
import 'package:crowzy_finance/features/accounts/providers/transfer_provider.dart';
import 'package:crowzy_finance/features/accounts/ui/transfer_form_screen.dart';
import 'package:crowzy_finance/features/transactions/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

final _at = DateTime(2026, 10, 1);

AccountModel _account(String id, String name, AccountType type, double opening, int order,
        {bool archived = false}) =>
    AccountModel(
      id: id,
      userId: 'u1',
      name: name,
      type: type,
      openingBalance: opening,
      isArchived: archived,
      createdAt: _at.add(Duration(minutes: order)),
      updatedAt: _at,
    );

late List<AccountModel> _accounts;
late List<TransactionModel> _transactions;
late List<TransferModel> _transfers;
final _added = <({String from, String to, double amount, double fee, String? note, DateTime date})>[];
final _updated = <TransferModel>[];
final _deleted = <String>[];

class _FakeAccounts extends AccountList {
  @override
  Future<List<AccountModel>> build() async =>
      ([..._accounts]..sort((a, b) => a.createdAt.compareTo(b.createdAt)));
}

class _FakeTransactions extends TransactionList {
  @override
  Future<List<TransactionModel>> build() async => _transactions;
}

class _FakeTransfers extends TransferList {
  @override
  Future<List<TransferModel>> build() async => _transfers;

  @override
  Future<void> addTransfer({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    double fee = 0,
    required DateTime date,
    String? note,
  }) async {
    _added.add((from: fromAccountId, to: toAccountId, amount: amount, fee: fee, note: note, date: date));
  }

  @override
  Future<void> updateTransfer(TransferModel transfer) async => _updated.add(transfer);

  @override
  Future<void> deleteTransfer(String id) async => _deleted.add(id);
}

class _Memory implements LastTransferSource {
  String? remembered;

  @override
  String? get value => remembered;

  @override
  Future<void> save(String accountId) async => remembered = accountId;
}

void main() {
  late _Memory meta;

  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    meta = _Memory();
    _accounts = [
      _account('bca', 'BCA', AccountType.bank, 9730000, 1),
      _account('dana', 'DANA', AccountType.ewallet, 1850000, 2),
      _account('cash', 'Cash', AccountType.cash, 900000, 0),
    ];
    _transactions = [];
    _transfers = [];
    _added.clear();
    _updated.clear();
    _deleted.clear();
  });

  Future<void> pump(
    WidgetTester tester, {
    TransferModel? transfer,
    String? from,
    bool reducedMotion = true,
  }) async {
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountListProvider.overrideWith(_FakeAccounts.new),
          transactionListProvider.overrideWith(_FakeTransactions.new),
          transferListProvider.overrideWith(_FakeTransfers.new),
          defaultAccountIdProvider.overrideWithValue('cash'),
          lastTransferSourceProvider.overrideWithValue(meta),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: reducedMotion),
            child: child!,
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => TransferFormScreen(transfer: transfer, initialFromAccountId: from),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Finder amountField() => find.byType(TextFormField).first;
  Finder feeField() => find.byType(TextField).at(1);

  Future<void> choose(WidgetTester tester, {required String card, required String account}) async {
    await tester.tap(find.bySemanticsLabel(RegExp('^$card account')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(account).last);
    await tester.pumpAndSettle();
  }

  double top(WidgetTester tester, String text) => tester.getTopLeft(find.text(text)).dy;

  group('a new transfer', () {
    testWidgets('has the amount, both cards, the fee card and the hint from the design', (tester) async {
      await pump(tester, from: 'bca');

      expect(find.text('New transfer'), findsOneWidget);
      expect(find.text('AMOUNT'), findsOneWidget);
      expect(find.text('FROM'), findsOneWidget);
      expect(find.text('TO'), findsOneWidget);
      expect(find.text('Fee (optional)'), findsOneWidget);
      expect(find.text('Date'), findsOneWidget);
      expect(find.text('Note'), findsOneWidget);
      expect(find.text('Save transfer'), findsOneWidget);
      expect(find.text('Delete'), findsNothing);
      expect(
        find.text('The fee leaves BCA and is counted as an expense under Fees. The transfer itself is not.'),
        findsOneWidget,
      );
    });

    testWidgets('starts from the given account to the first other one, oldest first', (tester) async {
      await pump(tester, from: 'bca');

      // Cash is the oldest account, so it is the first "other" account.
      expect(top(tester, 'BCA'), lessThan(top(tester, 'Cash')));
      expect(find.text('DANA'), findsNothing);
    });

    testWidgets('without a hint it starts from the oldest account', (tester) async {
      await pump(tester);

      expect(top(tester, 'Cash'), lessThan(top(tester, 'BCA')));
    });

    testWidgets('remembers the last source account', (tester) async {
      meta.remembered = 'dana';
      await pump(tester);

      expect(top(tester, 'DANA'), lessThan(top(tester, 'Cash')));
    });

    testWidgets('shows each balance and what it will be once the amount and fee are entered', (tester) async {
      await pump(tester, from: 'bca');
      await choose(tester, card: 'TO', account: 'DANA');

      await tester.enterText(amountField(), '500000');
      await tester.enterText(feeField(), '2500');
      await tester.pump();

      expect(find.text('Balance 9.730.000\nafter 9.227.500'), findsOneWidget);
      expect(find.text('Balance 1.850.000\nafter 2.350.000'), findsOneWidget);
    });

    testWidgets('the picker offers active accounts only and the choice replaces the card', (tester) async {
      _accounts = [..._accounts, _account('old', 'Old card', AccountType.bank, 0, 5, archived: true)];
      await pump(tester, from: 'bca');

      await tester.tap(find.bySemanticsLabel(RegExp('^TO account')));
      await tester.pumpAndSettle();
      expect(find.text('Choose an account'), findsOneWidget);
      expect(find.text('Old card'), findsNothing);

      await tester.tap(find.text('DANA'));
      await tester.pumpAndSettle();
      expect(find.text('DANA'), findsOneWidget);
      expect(find.text('Choose an account'), findsNothing);
    });

    testWidgets('typing an amount groups thousands', (tester) async {
      await pump(tester, from: 'bca');

      await tester.enterText(amountField(), '1250000');
      await tester.pump();

      expect(find.widgetWithText(TextFormField, '1.250.000'), findsOneWidget);
    });

    testWidgets('saves the transfer and remembers the source account', (tester) async {
      await pump(tester, from: 'bca');
      await choose(tester, card: 'TO', account: 'DANA');

      await tester.enterText(amountField(), '500000');
      await tester.enterText(feeField(), '2.500');
      await tester.enterText(find.widgetWithText(TextField, 'Optional'), '  Top up DANA ');
      await tester.tap(find.text('Save transfer'));
      await tester.pumpAndSettle();

      expect(_added, hasLength(1));
      expect(_added.single.from, 'bca');
      expect(_added.single.to, 'dana');
      expect(_added.single.amount, 500000);
      expect(_added.single.fee, 2500);
      expect(_added.single.note, 'Top up DANA');
      expect(meta.remembered, 'bca');
      expect(find.text('New transfer'), findsNothing); // closed
    });

    testWidgets('no fee and no note save as zero and nothing', (tester) async {
      await pump(tester, from: 'bca');

      await tester.enterText(amountField(), '1000');
      await tester.tap(find.text('Save transfer'));
      await tester.pumpAndSettle();

      expect(_added.single.fee, 0);
      expect(_added.single.note, isNull);
    });

    testWidgets('needs an amount', (tester) async {
      await pump(tester, from: 'bca');

      await tester.tap(find.text('Save transfer'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid amount'), findsOneWidget);
      expect(_added, isEmpty);
    });

    testWidgets('with only one account there is nowhere to send it, and it says so', (tester) async {
      _accounts = [_accounts.last];
      await pump(tester, from: 'cash');

      expect(find.text('Choose an account'), findsOneWidget);
      await tester.enterText(amountField(), '1000');
      await tester.tap(find.text('Save transfer'));
      await tester.pumpAndSettle();

      expect(find.text('Choose both accounts first'), findsOneWidget);
      expect(_added, isEmpty);
    });
  });

  group('when the source cannot cover it', () {
    Future<void> lowBalance(WidgetTester tester) async {
      await pump(tester, from: 'dana');
      await choose(tester, card: 'TO', account: 'BCA');
      await tester.enterText(amountField(), '2000000');
      await tester.enterText(feeField(), '2500');
      await tester.pump();
    }

    testWidgets('warns, shows the negative balance, but still allows saving', (tester) async {
      await lowBalance(tester);

      expect(
        find.text('DANA holds 1.850.000, less than this transfer plus its fee. You can still save it, '
            'for example if the balance is out of date.'),
        findsOneWidget,
      );
      final after = find.text('Balance 1.850.000\nafter −152.500');
      expect(after, findsOneWidget);
      expect(tester.widget<Text>(after).style!.color, AppColors.expense);
      expect(find.text('Save transfer'), findsNothing);
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNotNull);
    });

    testWidgets('"Save anyway" saves it', (tester) async {
      await lowBalance(tester);

      await tester.tap(find.text('Save anyway'));
      await tester.pumpAndSettle();

      expect(_added.single.amount, 2000000);
      expect(_added.single.from, 'dana');
    });

    testWidgets('the warning goes away when the amount fits', (tester) async {
      await lowBalance(tester);

      await tester.enterText(amountField(), '1000000');
      await tester.pump();

      expect(find.textContaining('less than this transfer'), findsNothing);
      expect(find.text('Save transfer'), findsOneWidget);
    });
  });

  group('the same account on both sides', () {
    Future<void> same(WidgetTester tester) async {
      await pump(tester, from: 'bca');
      await choose(tester, card: 'TO', account: 'BCA');
      await tester.enterText(amountField(), '1000');
      await tester.pump();
    }

    testWidgets('is flagged on the To card and in a notice', (tester) async {
      await same(tester);

      expect(find.text('Same as From\npick another'), findsOneWidget);
      expect(
        find.text('From and To are both BCA. Pick a different account to move money to.'),
        findsOneWidget,
      );
    });

    testWidgets('cannot be saved', (tester) async {
      await same(tester);

      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
      await tester.tap(find.text('Save transfer'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(_added, isEmpty);
    });

    testWidgets('choosing a different account clears it', (tester) async {
      await same(tester);

      await choose(tester, card: 'TO', account: 'DANA');

      expect(find.textContaining('Pick a different account'), findsNothing);
      expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNotNull);
    });
  });

  group('swapping', () {
    testWidgets('trades the two accounts, and the figures follow', (tester) async {
      await pump(tester, from: 'bca');
      await choose(tester, card: 'TO', account: 'DANA');
      await tester.enterText(amountField(), '500000');
      await tester.pump();
      expect(top(tester, 'BCA'), lessThan(top(tester, 'DANA')));

      await tester.tap(find.bySemanticsLabel('Swap accounts'));
      await tester.pumpAndSettle();

      expect(top(tester, 'DANA'), lessThan(top(tester, 'BCA')));
      expect(find.text('Balance 1.850.000\nafter 1.350.000'), findsOneWidget); // DANA is now From
      expect(find.text('Balance 9.730.000\nafter 10.230.000'), findsOneWidget);
    });

    testWidgets('swapping twice restores the original order', (tester) async {
      await pump(tester, from: 'bca');
      await choose(tester, card: 'TO', account: 'DANA');

      await tester.tap(find.bySemanticsLabel('Swap accounts'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Swap accounts'));
      await tester.pumpAndSettle();

      expect(top(tester, 'BCA'), lessThan(top(tester, 'DANA')));
    });

    testWidgets('with motion the names glide over 400 ms rather than jump', (tester) async {
      await pump(tester, from: 'bca', reducedMotion: false);
      await choose(tester, card: 'TO', account: 'DANA');
      final bcaStart = top(tester, 'BCA');
      final danaStart = top(tester, 'DANA');

      await tester.tap(find.bySemanticsLabel('Swap accounts'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final bcaEarly = top(tester, 'BCA');
      await tester.pump(const Duration(milliseconds: 150));
      final bcaLater = top(tester, 'BCA');

      expect(bcaEarly, greaterThan(bcaStart)); // moving down
      expect(bcaLater, greaterThan(bcaEarly)); // still moving
      expect(bcaLater, lessThan(danaStart)); // not there yet

      await tester.pumpAndSettle();
      expect(top(tester, 'BCA'), closeTo(danaStart, 0.5));
      expect(top(tester, 'DANA'), closeTo(bcaStart, 0.5));
    });

    testWidgets('with reduced motion it is immediate', (tester) async {
      await pump(tester, from: 'bca');
      await choose(tester, card: 'TO', account: 'DANA');

      await tester.tap(find.bySemanticsLabel('Swap accounts'));
      await tester.pump();

      expect(top(tester, 'DANA'), lessThan(top(tester, 'BCA')));
    });
  });

  group('editing', () {
    late TransferModel existing;

    setUp(() {
      existing = TransferModel(
        id: 't1',
        userId: 'u1',
        fromAccountId: 'bca',
        toAccountId: 'dana',
        amount: 500000,
        fee: 2500,
        note: 'Top up DANA',
        date: DateTime(2026, 10, 2),
        createdAt: _at,
        updatedAt: _at,
      );
      _transfers = [existing];
      _transactions = [
        TransactionModel(
          id: 'fee',
          userId: 'u1',
          amount: 2500,
          type: TransactionType.expense,
          categoryId: 'fees',
          accountId: 'bca',
          transferId: 't1',
          date: DateTime(2026, 10, 2),
          createdAt: _at,
          updatedAt: _at,
        ),
      ];
    });

    testWidgets('is pre-filled, with Save changes beside Delete and the edit hint', (tester) async {
      await pump(tester, transfer: existing);

      expect(find.text('Edit transfer'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '500.000'), findsOneWidget);
      expect(find.widgetWithText(TextField, '2.500'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Top up DANA'), findsOneWidget);
      expect(find.text('Save changes'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Save transfer'), findsNothing);
      expect(
        find.text('Saving also updates this transfer’s fee entry in Activity. Deleting removes '
            'both and puts the money back.'),
        findsOneWidget,
      );
    });

    testWidgets('balances are worked out without the transfer itself', (tester) async {
      await pump(tester, transfer: existing);

      // BCA held 9.730.000 before the transfer and its fee.
      expect(find.text('Balance 9.730.000\nafter 9.227.500'), findsOneWidget);
      expect(find.text('Balance 1.850.000\nafter 2.350.000'), findsOneWidget);
    });

    testWidgets('saving applies the changes to the same transfer', (tester) async {
      await pump(tester, transfer: existing);

      await tester.enterText(amountField(), '750000');
      await tester.enterText(find.widgetWithText(TextField, '2.500'), '');
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(_updated, hasLength(1));
      expect(_updated.single.id, 't1');
      expect(_updated.single.amount, 750000);
      expect(_updated.single.fee, 0);
      expect(_updated.single.fromAccountId, 'bca');
      expect(_updated.single.note, 'Top up DANA');
      expect(_added, isEmpty);
    });

    testWidgets('can change the accounts and clear the note', (tester) async {
      await pump(tester, transfer: existing);

      await choose(tester, card: 'TO', account: 'Cash');
      await tester.enterText(find.widgetWithText(TextField, 'Top up DANA'), '');
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(_updated.single.toAccountId, 'cash');
      expect(_updated.single.note, isNull);
    });

    testWidgets('Delete asks first, and cancelling keeps the transfer', (tester) async {
      await pump(tester, transfer: existing);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Delete transfer?'), findsOneWidget);
      expect(find.text('This also removes its fee entry and puts the money back.'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(_deleted, isEmpty);
      expect(find.text('Edit transfer'), findsOneWidget);
    });

    testWidgets('confirming deletes it and closes the page', (tester) async {
      await pump(tester, transfer: existing);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(_deleted, ['t1']);
      expect(find.text('Edit transfer'), findsNothing);
    });

    testWidgets('does not touch the remembered source account', (tester) async {
      await pump(tester, transfer: existing);

      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(meta.remembered, 'bca'); // it is the transfer's own source
    });
  });
}
