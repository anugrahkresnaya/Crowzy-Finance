import '../../../data/models/ai_correction_intent.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/transaction_model.dart';

const _maxCandidates = 20;
const _dateWindow = Duration(days: 3);
const _amountTolerance = 0.05;

/// Finds candidate transactions matching structured hints extracted from a
/// correction chat message, entirely client-side — no transaction data is
/// ever sent to the LLM for this step.
List<TransactionModel> matchCorrectionCandidates({
  required AiCorrectionIntent intent,
  required List<TransactionModel> transactions,
  required List<CategoryModel> categories,
}) {
  var candidates = transactions;

  if (intent.categoryHint != null) {
    final hint = intent.categoryHint!.toLowerCase();
    final matchingCategoryIds = categories
        .where((c) => c.name.toLowerCase().contains(hint))
        .map((c) => c.id)
        .toSet();
    if (matchingCategoryIds.isNotEmpty) {
      final narrowed =
          candidates.where((t) => matchingCategoryIds.contains(t.categoryId)).toList();
      if (narrowed.isNotEmpty) candidates = narrowed;
    }
  }

  if (intent.dateHint != null) {
    final start = intent.dateHint!.subtract(_dateWindow);
    final end = intent.dateHint!.add(_dateWindow);
    final narrowed = candidates.where((t) => !t.date.isBefore(start) && !t.date.isAfter(end)).toList();
    if (narrowed.isNotEmpty) candidates = narrowed;
  }

  if (intent.oldAmountHint != null) {
    final target = intent.oldAmountHint!;
    var narrowed = candidates.where((t) => t.amount == target).toList();
    if (narrowed.isEmpty) {
      final tolerance = target * _amountTolerance;
      narrowed = candidates.where((t) => (t.amount - target).abs() <= tolerance).toList();
    }
    if (narrowed.isNotEmpty) candidates = narrowed;
  }

  if (candidates.length > 1 && intent.targetDescription != null) {
    final hint = intent.targetDescription!.toLowerCase();
    final narrowed = candidates.where((t) => t.note?.toLowerCase().contains(hint) ?? false).toList();
    if (narrowed.isNotEmpty) candidates = narrowed;
  }

  final sorted = [...candidates]..sort((a, b) => b.date.compareTo(a.date));
  return sorted.take(_maxCandidates).toList();
}
