import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/features/transactions/ui/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TransactionModel tx({String? note}) => TransactionModel(
        id: 't1',
        userId: 'u1',
        amount: 25000,
        type: TransactionType.expense,
        categoryId: 'c1',
        note: note,
        date: DateTime(2026, 10, 3),
        createdAt: DateTime(2026, 10, 3),
        updatedAt: DateTime(2026, 10, 3),
      );

  Future<void> pump(WidgetTester tester, TransactionTile tile) =>
      tester.pumpWidget(MaterialApp(home: Scaffold(body: tile)));

  testWidgets('shows the date by default', (tester) async {
    await pump(tester, TransactionTile(transaction: tx(), category: null));
    expect(find.text('3 Oct 2026'), findsOneWidget);
  });

  testWidgets('combines date and note on one line', (tester) async {
    await pump(tester, TransactionTile(transaction: tx(note: 'Lunch'), category: null));
    expect(find.text('3 Oct 2026 · Lunch'), findsOneWidget);
  });

  testWidgets('hides the date when showDate is false, keeping the note', (tester) async {
    await pump(
      tester,
      TransactionTile(transaction: tx(note: 'Lunch'), category: null, showDate: false),
    );
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.textContaining('Oct'), findsNothing);
  });

  testWidgets('shows no subtitle without a date or a note', (tester) async {
    await pump(tester, TransactionTile(transaction: tx(), category: null, showDate: false));
    expect(find.textContaining('Oct'), findsNothing);
  });
}
