import 'package:freezed_annotation/freezed_annotation.dart';

import 'transaction_type.dart';

part 'ai_transaction_suggestion.freezed.dart';
part 'ai_transaction_suggestion.g.dart';

enum AiConfidence {
  @JsonValue('high')
  high,
  @JsonValue('medium')
  medium,
  @JsonValue('low')
  low,
}

/// Ephemeral, non-persisted result of parsing free text via the
/// `parse-transaction` Edge Function. Never written to Hive/Supabase as-is;
/// the user must confirm before a real transaction is created.
@freezed
abstract class AiTransactionSuggestion with _$AiTransactionSuggestion {
  const factory AiTransactionSuggestion({
    required double amount,
    required TransactionType type,
    required DateTime date,
    String? note,
    @JsonKey(name: 'matched_category_id') String? matchedCategoryId,
    @JsonKey(name: 'proposed_new_category') AiProposedCategory? proposedNewCategory,
    required AiConfidence confidence,
  }) = _AiTransactionSuggestion;

  factory AiTransactionSuggestion.fromJson(Map<String, dynamic> json) =>
      _$AiTransactionSuggestionFromJson(json);
}

@freezed
abstract class AiProposedCategory with _$AiProposedCategory {
  const factory AiProposedCategory({
    required String name,
    required String icon,
    required TransactionType type,
  }) = _AiProposedCategory;

  factory AiProposedCategory.fromJson(Map<String, dynamic> json) =>
      _$AiProposedCategoryFromJson(json);
}
