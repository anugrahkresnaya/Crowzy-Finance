import 'package:crowzy_finance/data/models/category_model.dart';
import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/features/transactions/ui/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.now();

  TransactionModel tx({
    String? note,
    DateTime? date,
    TransactionType type = TransactionType.expense,
  }) =>
      TransactionModel(
        id: 't1',
        userId: 'u1',
        amount: 25000,
        type: type,
        categoryId: 'c1',
        note: note,
        date: date ?? now,
        createdAt: now,
        updatedAt: now,
      );

  final food = CategoryModel(
    id: 'c1',
    name: 'Food',
    icon: 'restaurant',
    type: TransactionType.expense,
    createdAt: now,
    updatedAt: now,
  );

  Future<void> pump(WidgetTester tester, TransactionTile tile) =>
      tester.pumpWidget(MaterialApp(home: Scaffold(body: tile)));

  testWidgets('shows a relative date under the category by default', (tester) async {
    await pump(tester, TransactionTile(transaction: tx(), category: food));
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets('uses the note as the headline and the category in the subtitle', (tester) async {
    await pump(tester, TransactionTile(transaction: tx(note: 'Lunch'), category: food));
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('Today · Food'), findsOneWidget);
  });

  testWidgets('falls back to Uncategorized when the category is missing', (tester) async {
    await pump(tester, TransactionTile(transaction: tx(), category: null));
    expect(find.text('Uncategorized'), findsOneWidget);
  });

  testWidgets('hides the date when showDate is false, keeping the category', (tester) async {
    await pump(
      tester,
      TransactionTile(transaction: tx(note: 'Lunch'), category: food, showDate: false),
    );
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.textContaining('Today'), findsNothing);
  });

  testWidgets('shows no subtitle without a date or a note', (tester) async {
    await pump(tester, TransactionTile(transaction: tx(), category: food, showDate: false));
    expect(find.text('Food'), findsOneWidget);
    expect(find.byType(Text), findsNWidgets(2)); // title and amount only
  });

  testWidgets('older transactions show the full date including the year', (tester) async {
    await pump(
      tester,
      TransactionTile(transaction: tx(date: DateTime(2020, 1, 5)), category: food),
    );
    expect(find.text('5 Jan 2020'), findsOneWidget);
  });

  testWidgets('signs the amount with a true minus or a plus', (tester) async {
    await pump(tester, TransactionTile(transaction: tx(), category: food));
    expect(find.text('−25.000'), findsOneWidget);

    await pump(
      tester,
      TransactionTile(transaction: tx(type: TransactionType.income), category: food),
    );
    expect(find.text('+25.000'), findsOneWidget);
  });

  testWidgets('forwards taps', (tester) async {
    var taps = 0;
    await pump(
      tester,
      TransactionTile(transaction: tx(), category: food, onTap: () => taps++),
    );

    await tester.tap(find.text('Food'));

    expect(taps, 1);
  });

  testWidgets('has no delete control; deleting happens on the receipt', (tester) async {
    await pump(tester, TransactionTile(transaction: tx(), category: food, onTap: () {}));

    expect(find.byTooltip('Delete'), findsNothing);
  });

  testWidgets('adds the account to the line beneath when given one', (tester) async {
    await pump(
      tester,
      TransactionTile(
        transaction: tx(note: 'Groceries'),
        category: food,
        showDate: false,
        accountLabel: 'BCA',
      ),
    );

    expect(find.text('Food · BCA'), findsOneWidget);
  });

  testWidgets('with no note the account is the whole line beneath the category headline', (tester) async {
    await pump(
      tester,
      TransactionTile(transaction: tx(), category: food, showDate: false, accountLabel: 'DANA'),
    );

    expect(find.text('Food'), findsOneWidget);
    expect(find.text('DANA'), findsOneWidget);
  });

  testWidgets('the date, category and account are joined in that order', (tester) async {
    await pump(
      tester,
      TransactionTile(
        transaction: tx(note: 'Lunch'),
        category: food,
        accountLabel: 'Cash',
      ),
    );

    expect(find.text('Today · Food · Cash'), findsOneWidget);
  });
}
