import 'package:crowzy_finance/core/theme/app_theme.dart';
import 'package:crowzy_finance/data/models/ai_transaction_suggestion.dart';
import 'package:crowzy_finance/data/models/category_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/features/ai_analyzer/ui/widgets/ai_suggestion_confirm_sheet.dart';
import 'package:crowzy_finance/features/categories/providers/category_provider.dart';
import 'package:crowzy_finance/core/widgets/receipt_slip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

class _FakeCategories extends CategoryList {
  @override
  Future<List<CategoryModel>> build() async => [
        for (final (id, name, type) in [
          ('dining', 'Dining', TransactionType.expense),
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

AiTransactionSuggestion _suggestion({
  double amount = 85000,
  TransactionType type = TransactionType.expense,
  String? note = 'Dinner',
  String? matched = 'dining',
  AiProposedCategory? proposed,
  AiConfidence confidence = AiConfidence.high,
}) =>
    AiTransactionSuggestion(
      amount: amount,
      type: type,
      date: DateTime(2026, 10, 2), // a Friday
      note: note,
      matchedCategoryId: matched,
      proposedNewCategory: proposed,
      confidence: confidence,
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  AiConfirmResult? result;
  var finished = false;

  Future<void> open(WidgetTester tester, AiTransactionSuggestion suggestion) async {
    result = null;
    finished = false;
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [categoryListProvider.overrideWith(_FakeCategories.new)],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await showAiSuggestionConfirmSheet(context, suggestion);
                  finished = true;
                },
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

  group('the draft slip', () {
    testWidgets('shows what was read, stamped as a draft', (tester) async {
      await open(tester, _suggestion());

      expect(find.text('DRAFT SLIP'), findsOneWidget);
      expect(find.text('READ FROM YOUR MESSAGE'), findsOneWidget);
      expect(find.text('DRAFT'), findsOneWidget);
      expect(find.text('Dinner'), findsOneWidget); // item
      expect(find.text('Dining'), findsOneWidget); // category
      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Fri 2 Oct 2026'), findsOneWidget);
      expect(find.text('−85.000'), findsOneWidget);
    });

    testWidgets('an income draft reads as a plus', (tester) async {
      await open(tester, _suggestion(type: TransactionType.income, matched: 'salary', note: 'Bonus'));

      expect(find.text('Income'), findsOneWidget);
      expect(find.text('+85.000'), findsOneWidget);
      expect(find.text('Salary'), findsOneWidget);
    });

    testWidgets('without a note the item is the category', (tester) async {
      await open(tester, _suggestion(note: null));

      expect(find.text('Dining'), findsNWidgets(2)); // item and category rows
    });

    testWidgets('a proposed new category is labelled as new', (tester) async {
      await open(
        tester,
        _suggestion(
          matched: null,
          proposed: const AiProposedCategory(name: 'Pets', icon: 'pets', type: TransactionType.expense),
        ),
      );

      expect(find.text('Pets (new)'), findsOneWidget);
    });

    testWidgets('a low-confidence reading asks you to double-check', (tester) async {
      await open(tester, _suggestion(confidence: AiConfidence.low));

      expect(find.textContaining('Not sure about this one'), findsOneWidget);
      expect(find.textContaining('Use Edit details'), findsNothing);
    });

    testWidgets('a confident reading points to Edit details', (tester) async {
      await open(tester, _suggestion());

      expect(find.textContaining('Use Edit details'), findsOneWidget);
    });
  });

  group('adding', () {
    testWidgets('Add transaction returns the values as read', (tester) async {
      await open(tester, _suggestion());

      await tester.tap(find.text('Add transaction'));
      await tester.pumpAndSettle();

      expect(finished, isTrue);
      expect(result!.amount, 85000);
      expect(result!.type, TransactionType.expense);
      expect(result!.categoryId, 'dining');
      expect(result!.newCategory, isNull);
      expect(result!.note, 'Dinner');
      expect(result!.date, DateTime(2026, 10, 2));
    });

    testWidgets('a proposed new category comes back to be created', (tester) async {
      const proposed = AiProposedCategory(name: 'Pets', icon: 'pets', type: TransactionType.expense);
      await open(tester, _suggestion(matched: null, proposed: proposed));

      await tester.tap(find.text('Add transaction'));
      await tester.pumpAndSettle();

      expect(result!.categoryId, isNull);
      expect(result!.newCategory, proposed);
    });

    testWidgets('Cancel returns nothing', (tester) async {
      await open(tester, _suggestion());

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(finished, isTrue);
      expect(result, isNull);
    });

    testWidgets('with no category it opens the form instead of adding', (tester) async {
      await open(tester, _suggestion(matched: null));

      expect(find.text('Choose one'), findsWidgets);
      await tester.tap(find.text('Add transaction'));
      await tester.pumpAndSettle();

      expect(finished, isFalse);
      expect(find.text('Back to the slip'), findsOneWidget);
    });

    testWidgets('with no usable amount it opens the form instead of adding', (tester) async {
      await open(tester, _suggestion(amount: 0));

      await tester.tap(find.text('Add transaction'));
      await tester.pumpAndSettle();

      expect(finished, isFalse);
      expect(find.text('Back to the slip'), findsOneWidget);
    });
  });

  group('editing', () {
    testWidgets('Edit details opens the form with the values filled in', (tester) async {
      await open(tester, _suggestion());

      await tester.tap(find.text('Edit details'));
      await tester.pumpAndSettle();

      expect(find.text('85.000'), findsOneWidget);
      expect(find.text('Dinner'), findsOneWidget);
      expect(find.text('Back to the slip'), findsOneWidget);
      expect(find.text('DRAFT SLIP'), findsNothing);
    });

    testWidgets('edits show up on the slip and in the result', (tester) async {
      await open(tester, _suggestion());

      await tester.tap(find.text('Edit details'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, '120000');
      await tester.enterText(find.byType(TextFormField).last, 'Team dinner');
      await tester.pump();
      await tester.ensureVisible(find.text('Back to the slip'));
      await tester.tap(find.text('Back to the slip'));
      await tester.pumpAndSettle();

      expect(find.text('−120.000'), findsOneWidget);
      expect(find.text('Team dinner'), findsOneWidget);

      await tester.tap(find.text('Add transaction'));
      await tester.pumpAndSettle();

      expect(result!.amount, 120000);
      expect(result!.note, 'Team dinner');
    });

    testWidgets('switching to income shows income categories and clears the old one', (tester) async {
      await open(tester, _suggestion());

      await tester.tap(find.text('Edit details'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Income'));
      await tester.pumpAndSettle();

      // No income category is chosen yet, so adding falls back to the form.
      await tester.ensureVisible(find.text('Add transaction'));
      await tester.tap(find.text('Add transaction'));
      await tester.pumpAndSettle();
      expect(finished, isFalse);
      expect(find.text('Back to the slip'), findsOneWidget);
    });

    testWidgets('the new-category switch can be turned off to pick an existing one', (tester) async {
      const proposed = AiProposedCategory(name: 'Pets', icon: 'pets', type: TransactionType.expense);
      await open(tester, _suggestion(matched: null, proposed: proposed));

      await tester.tap(find.text('Edit details'));
      await tester.pumpAndSettle();
      expect(find.textContaining("New category 'Pets'"), findsOneWidget);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(find.text('Category'), findsOneWidget); // the dropdown appears
    });
  });

  group('printing', () {
    double revealed(WidgetTester tester) {
      final clip = tester.renderObject<RenderClipRect>(
        find.descendant(of: find.byType(ReceiptPrint), matching: find.byType(ClipRect)).first,
      );
      return clip.clipper!.getClip(const Size(100, 100)).height;
    }

    Future<void> openWithoutSettling(WidgetTester tester) async {
      result = null;
      finished = false;
      await tester.binding.setSurfaceSize(const Size(390, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [categoryListProvider.overrideWith(_FakeCategories.new)],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => showAiSuggestionConfirmSheet(context, _suggestion()),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      // Let the sheet finish rising so only the slip is still printing.
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump(const Duration(milliseconds: 500));
    }

    testWidgets('the slip is unrolled after the sheet rises, then stamped', (tester) async {
      await openWithoutSettling(tester);

      expect(revealed(tester), lessThan(20)); // still blank when the sheet arrives
      await tester.pump(const Duration(milliseconds: 600));
      expect(revealed(tester), greaterThan(20)); // being uncovered
      await tester.pump(const Duration(seconds: 3));
      expect(revealed(tester), 100);
      await tester.pump(const Duration(milliseconds: 500)); // the stamp lands after the lines

      final stamp = tester.widget<FadeTransition>(
        find.descendant(of: find.byType(ReceiptStamp), matching: find.byType(FadeTransition)),
      );
      expect(stamp.opacity.value, 1);
    });

    testWidgets('it does not print again when you come back from editing', (tester) async {
      await openWithoutSettling(tester);
      await tester.pump(const Duration(seconds: 3));

      await tester.tap(find.text('Edit details'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Back to the slip'));
      await tester.tap(find.text('Back to the slip'));
      await tester.pump(); // build the slip again
      await tester.pump(const Duration(milliseconds: 1));

      // Shown straight away: no unrolling and no stamp animation.
      expect(find.text('DRAFT SLIP'), findsOneWidget);
      expect(
        find.descendant(of: find.byType(ReceiptPrint), matching: find.byType(ClipRect)),
        findsNothing,
      );
      expect(
        find.descendant(of: find.byType(ReceiptStamp), matching: find.byType(FadeTransition)),
        findsNothing,
      );
    });
  });
}
