import 'package:crowzy_finance/core/theme/app_theme.dart';
import 'package:crowzy_finance/data/models/ai_correction_intent.dart';
import 'package:crowzy_finance/data/models/ai_transaction_suggestion.dart';
import 'package:crowzy_finance/data/models/category_model.dart';
import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/features/ai_analyzer/ui/widgets/correction_candidate_picker_sheet.dart';
import 'package:crowzy_finance/features/ai_analyzer/ui/widgets/correction_confirm_sheet.dart';
import 'package:crowzy_finance/features/categories/providers/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

final _categories = [
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

class _FakeCategories extends CategoryList {
  @override
  Future<List<CategoryModel>> build() async => _categories;
}

TransactionModel _transaction(String id, double amount, {String? note}) => TransactionModel(
      id: id,
      userId: 'u',
      amount: amount,
      type: TransactionType.expense,
      categoryId: 'dining',
      note: note,
      date: DateTime(2026, 10, 2),
      createdAt: DateTime(2026, 10, 2),
      updatedAt: DateTime(2026, 10, 2),
    );

Future<void> _launch(WidgetTester tester, Future<void> Function(BuildContext) onOpen) async {
  await tester.binding.setSurfaceSize(const Size(390, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [categoryListProvider.overrideWith(_FakeCategories.new)],
      child: MaterialApp(
        theme: AppTheme.dark,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(onPressed: () => onOpen(context), child: const Text('open')),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('candidate picker', () {
    testWidgets('lists the candidates and returns the one tapped', (tester) async {
      TransactionModel? picked;
      await _launch(tester, (context) async {
        picked = await showCorrectionCandidatePickerSheet(
          context,
          [_transaction('a', 85000, note: 'Dinner'), _transaction('b', 40000, note: 'Lunch')],
          _categories,
        );
      });

      expect(find.text('Which transaction did you mean?'), findsOneWidget);
      expect(find.text('Dinner'), findsOneWidget);
      expect(find.text('Lunch'), findsOneWidget);

      await tester.tap(find.text('Lunch'));
      await tester.pumpAndSettle();
      expect(picked?.id, 'b');
    });

    testWidgets('cancel returns nothing', (tester) async {
      var finished = false;
      TransactionModel? picked = _transaction('x', 1);
      await _launch(tester, (context) async {
        picked = await showCorrectionCandidatePickerSheet(context, [_transaction('a', 1000)], _categories);
        finished = true;
      });

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(finished, isTrue);
      expect(picked, isNull);
    });
  });

  group('confirm sheet', () {
    AiCorrectionIntent intent({double? amount, String? note, AiConfidence confidence = AiConfidence.high}) =>
        AiCorrectionIntent(isCorrection: true, newAmount: amount, newNote: note, confidence: confidence);

    CorrectionConfirmResult? result;

    Future<void> open(WidgetTester tester, AiCorrectionIntent value) async {
      result = null;
      await _launch(tester, (context) async {
        result = await showCorrectionConfirmSheet(
          context,
          matched: _transaction('a', 85000, note: 'Dinner'),
          intent: value,
        );
      });
    }

    testWidgets('puts Expense first and shows the amount with thousands separators', (tester) async {
      await open(tester, intent(amount: 120000));

      final labels = tester
          .widgetList<Text>(find.descendant(of: find.byType(SegmentedButton<TransactionType>), matching: find.byType(Text)))
          .map((t) => t.data)
          .toList();
      expect(labels, ['Expense', 'Income']);
      expect(find.widgetWithText(TextField, '120.000'), findsOneWidget);
      expect(find.textContaining('Was:'), findsWidgets);
    });

    testWidgets('warns when the assistant is unsure', (tester) async {
      await open(tester, intent(amount: 1000, confidence: AiConfidence.low));
      expect(find.textContaining('Not sure about this one'), findsOneWidget);
    });

    testWidgets('confirm returns the corrected fields, parsing the formatted amount', (tester) async {
      await open(tester, intent(amount: 120000));

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(result?.amount, 120000);
      expect(result?.type, TransactionType.expense);
      expect(result?.categoryId, 'dining');
      expect(result?.note, 'Dinner');
    });

    testWidgets('cancel returns nothing', (tester) async {
      await open(tester, intent(amount: 120000));
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(result, isNull);
      expect(find.text('Confirm correction'), findsNothing);
    });
  });
}
