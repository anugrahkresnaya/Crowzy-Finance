import 'package:crowzy_finance/core/theme/app_colors.dart';
import 'package:crowzy_finance/core/theme/app_theme.dart';
import 'package:crowzy_finance/data/models/transfer.dart';
import 'package:crowzy_finance/features/accounts/ui/widgets/transfer_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../support/transfers.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  final now = DateTime.now();

  Transfer transfer({String? note = 'Top up DANA', DateTime? date}) => fakeTransfer(
        't1',
        from: 'a',
        to: 'b',
        amount: 500000,
        fee: 2500,
        note: note,
        date: date ?? now,
      );

  Future<void> pump(WidgetTester tester, TransferTile tile) => tester.pumpWidget(
        MaterialApp(theme: AppTheme.dark, home: Scaffold(body: tile)),
      );

  TransferTile tile(Transfer t, {bool showDate = true, VoidCallback? onTap}) => TransferTile(
        transfer: t,
        fromName: 'BCA',
        toName: 'DANA',
        showDate: showDate,
        onTap: onTap,
      );

  testWidgets('inside a day it reads "BCA → DANA · Transfer" under the note', (tester) async {
    await pump(tester, tile(transfer(), showDate: false));

    expect(find.text('Top up DANA'), findsOneWidget);
    expect(find.text('BCA → DANA · Transfer'), findsOneWidget);
  });

  testWidgets('with a date it reads "Today · BCA → DANA"', (tester) async {
    await pump(tester, tile(transfer()));

    expect(find.text('Today · BCA → DANA'), findsOneWidget);
  });

  testWidgets('without a note it is headed Transfer, with just the route beneath', (tester) async {
    await pump(tester, tile(transfer(note: null), showDate: false));

    expect(find.text('Transfer'), findsOneWidget);
    expect(find.text('BCA → DANA'), findsOneWidget);
    expect(find.textContaining('· Transfer'), findsNothing);
  });

  testWidgets('the amount is brass and has no sign, and the fee is not added to it', (tester) async {
    await pump(tester, tile(transfer()));

    final amount = tester.widget<Text>(find.text('500.000'));
    expect(amount.style!.color, AppColors.brass);
    expect(find.text('+500.000'), findsNothing);
    expect(find.text('−500.000'), findsNothing);
    expect(find.text('502.500'), findsNothing);
  });

  testWidgets('has a swap icon in a brass-outlined circle rather than a category icon', (tester) async {
    await pump(tester, tile(transfer()));

    expect(find.byIcon(Icons.swap_horiz_rounded), findsOneWidget);
    final circle = tester.widget<Container>(
      find.ancestor(of: find.byIcon(Icons.swap_horiz_rounded), matching: find.byType(Container)).first,
    );
    final decoration = circle.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.hero);
    expect((decoration.border! as Border).top.color, AppColors.brassOutline);
  });

  testWidgets('can be tapped', (tester) async {
    var taps = 0;
    await pump(tester, tile(transfer(), onTap: () => taps++));

    await tester.tap(find.text('Top up DANA'));

    expect(taps, 1);
  });
}
