import 'package:crowzy_finance/data/models/ai_correction_intent.dart';
import 'package:crowzy_finance/data/models/ai_transaction_suggestion.dart';
import 'package:crowzy_finance/data/models/category_model.dart';
import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/features/ai_analyzer/utils/transaction_matcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 7, 1);

  CategoryModel category(String id, String name) => CategoryModel(
        id: id,
        name: name,
        icon: 'category',
        type: TransactionType.expense,
        createdAt: now,
        updatedAt: now,
      );

  TransactionModel tx(
    String id, {
    double amount = 10,
    String categoryId = 'food',
    String? note,
    DateTime? date,
  }) =>
      TransactionModel(
        id: id,
        userId: 'u1',
        amount: amount,
        type: TransactionType.expense,
        categoryId: categoryId,
        note: note,
        date: date ?? DateTime(2026, 7, 10),
        createdAt: now,
        updatedAt: now,
      );

  AiCorrectionIntent intent({
    String? targetDescription,
    String? categoryHint,
    DateTime? dateHint,
    double? oldAmountHint,
  }) =>
      AiCorrectionIntent(
        isCorrection: true,
        targetDescription: targetDescription,
        categoryHint: categoryHint,
        dateHint: dateHint,
        oldAmountHint: oldAmountHint,
        confidence: AiConfidence.high,
      );

  final categories = [category('food', 'Food'), category('transport', 'Transport')];

  test('narrows by category hint, case-insensitively', () {
    final result = matchCorrectionCandidates(
      intent: intent(categoryHint: 'FOOD'),
      transactions: [tx('a'), tx('b', categoryId: 'transport')],
      categories: categories,
    );
    expect(result.map((t) => t.id), ['a']);
  });

  test('ignores a category hint that matches nothing instead of emptying results', () {
    final result = matchCorrectionCandidates(
      intent: intent(categoryHint: 'nonexistent'),
      transactions: [tx('a'), tx('b', categoryId: 'transport')],
      categories: categories,
    );
    expect(result, hasLength(2));
  });

  test('narrows by date within the +/-3 day window', () {
    final result = matchCorrectionCandidates(
      intent: intent(dateHint: DateTime(2026, 7, 10)),
      transactions: [
        tx('near', date: DateTime(2026, 7, 12)),
        tx('far', date: DateTime(2026, 7, 20)),
      ],
      categories: categories,
    );
    expect(result.map((t) => t.id), ['near']);
  });

  test('prefers exact amount, then falls back to 5% tolerance', () {
    final transactions = [tx('exact', amount: 100), tx('close', amount: 103)];

    final exact = matchCorrectionCandidates(
      intent: intent(oldAmountHint: 100),
      transactions: transactions,
      categories: categories,
    );
    expect(exact.map((t) => t.id), ['exact']);

    final tolerant = matchCorrectionCandidates(
      intent: intent(oldAmountHint: 102),
      transactions: [tx('close', amount: 103), tx('far', amount: 200)],
      categories: categories,
    );
    expect(tolerant.map((t) => t.id), ['close']);
  });

  test('uses the note only to break ties between multiple candidates', () {
    final multiple = matchCorrectionCandidates(
      intent: intent(targetDescription: 'lunch'),
      transactions: [tx('a', note: 'Lunch with team'), tx('b', note: 'Groceries')],
      categories: categories,
    );
    expect(multiple.map((t) => t.id), ['a']);

    final single = matchCorrectionCandidates(
      intent: intent(targetDescription: 'lunch'),
      transactions: [tx('only', note: 'Groceries')],
      categories: categories,
    );
    expect(single.map((t) => t.id), ['only']);
  });

  test('returns newest first, capped at 20', () {
    final transactions = List.generate(
      25,
      (i) => tx('t$i', date: DateTime(2026, 6, 1).add(Duration(days: i))),
    );
    final result = matchCorrectionCandidates(
      intent: intent(),
      transactions: transactions,
      categories: categories,
    );
    expect(result, hasLength(20));
    expect(result.first.id, 't24');
  });
}
