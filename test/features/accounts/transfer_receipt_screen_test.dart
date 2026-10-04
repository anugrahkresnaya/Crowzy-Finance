import 'package:crowzy_finance/core/theme/app_colors.dart';
import 'package:crowzy_finance/core/theme/app_theme.dart';
import 'package:crowzy_finance/data/models/account_model.dart';
import 'package:crowzy_finance/data/models/account_type.dart';
import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transfer_model.dart';
import 'package:crowzy_finance/features/accounts/providers/account_provider.dart';
import 'package:crowzy_finance/features/accounts/providers/transfer_provider.dart';
import 'package:crowzy_finance/features/accounts/ui/transfer_receipt_screen.dart';
import 'package:crowzy_finance/features/transactions/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

final _at = DateTime(2026, 10, 2);

late List<TransferModel> _transfers;
late List<AccountModel> _accounts;
final _deleted = <String>[];

class _FakeTransfers extends TransferList {
  @override
  Future<List<TransferModel>> build() async => _transfers;

  @override
  Future<void> deleteTransfer(String id) async {
    _deleted.add(id);
    _transfers = _transfers.where((t) => t.id != id).toList();
    state = AsyncData(_transfers);
  }
}

class _FakeAccounts extends AccountList {
  @override
  Future<List<AccountModel>> build() async => _accounts;
}

class _FakeTransactions extends TransactionList {
  @override
  Future<List<TransactionModel>> build() async => const [];
}

class _Memory implements LastTransferSource {
  @override
  String? get value => null;

  @override
  Future<void> save(String accountId) async {}
}

AccountModel _account(String id, String name) => AccountModel(
      id: id,
      userId: 'u1',
      name: name,
      type: AccountType.bank,
      createdAt: _at,
      updatedAt: _at,
    );

TransferModel _transfer({
  double amount = 500000,
  double fee = 2500,
  String? note = 'Top up DANA',
  bool isSynced = true,
}) =>
    TransferModel(
      id: 't1',
      userId: 'u1',
      fromAccountId: 'bca',
      toAccountId: 'dana',
      amount: amount,
      fee: fee,
      note: note,
      date: DateTime(2026, 10, 2), // a Friday
      createdAt: _at,
      updatedAt: _at,
      isSynced: isSynced,
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    _transfers = [_transfer()];
    _accounts = [_account('bca', 'BCA'), _account('dana', 'DANA')];
    _deleted.clear();
  });

  Future<void> pump(WidgetTester tester, {String id = 't1'}) async {
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transferListProvider.overrideWith(_FakeTransfers.new),
          accountListProvider.overrideWith(_FakeAccounts.new),
          transactionListProvider.overrideWith(_FakeTransactions.new),
          defaultAccountIdProvider.overrideWithValue('bca'),
          lastTransferSourceProvider.overrideWithValue(_Memory()),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => TransferReceiptScreen(transferId: id)),
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

  testWidgets('shows the transfer as a receipt, as on the canvas', (tester) async {
    await pump(tester);

    expect(find.text('Transfer'), findsOneWidget); // app bar
    expect(find.text('CROWZY FINANCE'), findsOneWidget);
    expect(find.text('TRANSFER RECEIPT'), findsOneWidget);
    expect(find.text('TOP UP DANA'), findsOneWidget); // the note, as the headline
    expect(find.text('BCA'), findsNWidgets(2)); // route and FROM row
    expect(find.text('DANA'), findsNWidgets(2));
    expect(find.text('500.000'), findsNWidgets(2)); // big figure and REACHED
    expect(find.text('IDR · MOVED, NOT SPENT'), findsOneWidget);
    expect(find.text('FROM'), findsOneWidget);
    expect(find.text('TO'), findsOneWidget);
    expect(find.text('FEE'), findsOneWidget);
    expect(find.text('2.500'), findsOneWidget);
    expect(find.text('Fri 2 Oct 2026'), findsOneWidget);
    expect(find.text('NOTE'), findsOneWidget);
    expect(find.text('THANK YOU FOR TRACKING'), findsOneWidget);
  });

  testWidgets('adds up what left one account and what reached the other', (tester) async {
    await pump(tester);

    expect(find.text('LEFT BCA'), findsOneWidget);
    expect(find.text('502.500'), findsOneWidget); // amount plus fee
    expect(find.text('REACHED DANA'), findsOneWidget);
  });

  testWidgets('the amount is plain ink with no sign, since it was moved and not spent', (tester) async {
    await pump(tester);

    final figure = tester.widgetList<Text>(find.text('500.000')).first;
    expect(figure.style!.color, AppColors.ink);
    expect(find.text('−500.000'), findsNothing);
    expect(find.text('+500.000'), findsNothing);
  });

  testWidgets('with no fee it says None and the two totals are equal', (tester) async {
    _transfers = [_transfer(fee: 0)];
    await pump(tester);

    expect(find.text('None'), findsOneWidget);
    expect(find.text('500.000'), findsNWidgets(3)); // figure, LEFT and REACHED
  });

  testWidgets('without a note it is headed TRANSFER and has no note row', (tester) async {
    _transfers = [_transfer(note: null)];
    await pump(tester);

    expect(find.text('TRANSFER'), findsOneWidget);
    expect(find.text('NOTE'), findsNothing);
  });

  testWidgets('says whether it has been synced', (tester) async {
    await pump(tester);
    expect(find.text('Synced'), findsOneWidget);

    _transfers = [_transfer(isSynced: false)];
    await tester.pumpWidget(const SizedBox());
    await pump(tester);
    expect(find.text('Waiting to sync'), findsOneWidget);
  });

  testWidgets('an account that is gone is called unknown rather than breaking', (tester) async {
    _accounts = [_account('bca', 'BCA')];
    await pump(tester);

    expect(find.text('Unknown account'), findsNWidgets(2));
    expect(find.text('REACHED UNKNOWN ACCOUNT'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Edit opens the form for this transfer', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Edit transfer'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '500.000'), findsOneWidget);
  });

  testWidgets('Delete asks first, then removes it and returns', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete transfer?'), findsOneWidget);
    expect(_deleted, isEmpty);

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(_deleted, ['t1']);
    expect(find.text('TRANSFER RECEIPT'), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('cancelling the delete keeps the receipt', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(_deleted, isEmpty);
    expect(find.text('TRANSFER RECEIPT'), findsOneWidget);
  });

  testWidgets('a transfer that no longer exists says so', (tester) async {
    await pump(tester, id: 'gone');

    expect(find.text('This transfer no longer exists'), findsOneWidget);
    expect(find.text('TRANSFER RECEIPT'), findsNothing);
  });
}
