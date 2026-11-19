import 'package:crowzy_finance/core/theme/app_colors.dart';
import 'package:crowzy_finance/core/theme/app_theme.dart';
import 'package:crowzy_finance/data/models/category_model.dart';
import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/features/categories/providers/category_provider.dart';
import 'package:crowzy_finance/features/transactions/providers/transaction_provider.dart';
import 'package:crowzy_finance/features/transactions/ui/transaction_detail_screen.dart';
import 'package:crowzy_finance/core/widgets/receipt_slip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

late List<TransactionModel> _transactions;
final List<String> _deleted = [];

class _FakeTransactions extends TransactionList {
  @override
  Future<List<TransactionModel>> build() async => _transactions;

  @override
  Future<void> deleteTransaction(String id) async {
    _deleted.add(id);
    _transactions = _transactions.where((t) => t.id != id).toList();
    state = AsyncData(_transactions);
  }
}

class _FakeCategories extends CategoryList {
  @override
  Future<List<CategoryModel>> build() async => [
        for (final (id, name, type) in [
          ('food', 'Food', TransactionType.expense),
          ('salary', 'Salary', TransactionType.income),
        ])
          CategoryModel(
            id: id,
            name: name,
            icon: 'category',
            type: type,
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
      ];
}

TransactionModel _tx({
  String id = 't1',
  double amount = 184500,
  TransactionType type = TransactionType.expense,
  String category = 'food',
  String? note = 'Groceries',
  bool isSynced = true,
}) =>
    TransactionModel(
      id: id,
      userId: 'u1',
      amount: amount,
      type: type,
      categoryId: category,
      note: note,
      date: DateTime(2026, 10, 3), // a Saturday
      createdAt: DateTime(2026, 10, 3, 9, 12),
      updatedAt: DateTime(2026, 10, 3, 9, 12),
      isSynced: isSynced,
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    _transactions = [_tx()];
    _deleted.clear();
  });

  Future<void> pump(WidgetTester tester, {String id = 't1'}) async {
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionListProvider.overrideWith(_FakeTransactions.new),
          categoryListProvider.overrideWith(_FakeCategories.new),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => TransactionDetailScreen(transactionId: id)),
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

  testWidgets('shows the transaction as a receipt', (tester) async {
    await pump(tester);

    expect(find.text('CROWZY FINANCE'), findsOneWidget);
    expect(find.text('TRANSACTION RECEIPT'), findsOneWidget);
    expect(find.text('GROCERIES'), findsOneWidget); // the note, as the headline
    expect(find.text('−184.500'), findsNWidgets(2)); // the big figure and the total
    expect(find.text('IDR · EXPENSE'), findsOneWidget);
    expect(find.text('CATEGORY'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Sat 3 Oct 2026'), findsOneWidget);
    expect(find.text('THANK YOU FOR TRACKING'), findsOneWidget);
  });

  testWidgets('without a note the category is the headline', (tester) async {
    _transactions = [_tx(note: null)];
    await pump(tester);

    expect(find.text('FOOD'), findsOneWidget);
  });

  testWidgets('income reads as a plus in green ink', (tester) async {
    _transactions = [_tx(amount: 18200000, type: TransactionType.income, category: 'salary', note: null)];
    await pump(tester);

    expect(find.text('IDR · INCOME'), findsOneWidget);
    final figure = tester.widgetList<Text>(find.text('+18.200.000')).first;
    expect(figure.style!.color, AppColors.inkIncome);
  });

  testWidgets('an expense is in oxblood ink', (tester) async {
    await pump(tester);

    final figure = tester.widgetList<Text>(find.text('−184.500')).first;
    expect(figure.style!.color, AppColors.oxblood);
  });

  testWidgets('says whether it has been synced', (tester) async {
    await pump(tester);
    expect(find.text('Synced'), findsOneWidget);
  });

  testWidgets('says when it is still waiting to sync', (tester) async {
    _transactions = [_tx(isSynced: false)];
    await pump(tester);

    expect(find.text('Waiting to sync'), findsOneWidget);
    expect(find.text('Synced'), findsNothing);
  });

  testWidgets('Edit opens the form for this transaction', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Edit transaction'), findsOneWidget);
    expect(find.text('184.500'), findsOneWidget);
  });

  testWidgets('Delete asks first, then removes it and returns', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete transaction?'), findsOneWidget);
    expect(_deleted, isEmpty);

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(_deleted, ['t1']);
    expect(find.byType(TransactionDetailScreen), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('declining the delete keeps the receipt', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(_deleted, isEmpty);
    expect(find.text('TRANSACTION RECEIPT'), findsOneWidget);
  });

  testWidgets('a transaction that no longer exists says so instead of failing', (tester) async {
    await pump(tester, id: 'gone');

    expect(find.text('This transaction no longer exists'), findsOneWidget);
    expect(find.text('Edit'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the receipt feeds out of a printer slot', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionListProvider.overrideWith(_FakeTransactions.new),
          categoryListProvider.overrideWith(_FakeCategories.new),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const TransactionDetailScreen(transactionId: 't1'),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50)); // the data arrives and the slip is built
    await tester.pump(const Duration(milliseconds: 1)); // the feed takes its first tick

    double slipTop() => tester.getTopLeft(find.byType(ReceiptSlip)).dy;
    final printing = slipTop();
    await tester.pump(const Duration(seconds: 3));
    final resting = slipTop();

    // The paper starts a paper-height above its place and comes down into it.
    expect(printing, lessThan(resting - 100));
    expect(find.byType(ReceiptPrint), findsOneWidget);
  });
}
