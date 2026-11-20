import 'package:freezed_annotation/freezed_annotation.dart';

import 'ai_transaction_suggestion.dart';

part 'ai_correction_intent.freezed.dart';
part 'ai_correction_intent.g.dart';

/// Ephemeral, non-persisted result of classifying+extracting a correction
/// request via the `parse-correction` Edge Function. Contains only filter
/// hints for client-side transaction matching (see transaction_matcher.dart)
/// — never a matched transaction itself, and the LLM never sees the user's
/// transaction data to produce this.
@freezed
abstract class AiCorrectionIntent with _$AiCorrectionIntent {
  const factory AiCorrectionIntent({
    @JsonKey(name: 'is_correction') required bool isCorrection,
    @JsonKey(name: 'target_description') String? targetDescription,
    @JsonKey(name: 'category_hint') String? categoryHint,
    @JsonKey(name: 'date_hint') DateTime? dateHint,
    @JsonKey(name: 'old_amount_hint') double? oldAmountHint,
    @JsonKey(name: 'new_amount') double? newAmount,
    @JsonKey(name: 'new_category_hint') String? newCategoryHint,
    @JsonKey(name: 'new_date') DateTime? newDate,
    @JsonKey(name: 'new_note') String? newNote,
    required AiConfidence confidence,
  }) = _AiCorrectionIntent;

  factory AiCorrectionIntent.fromJson(Map<String, dynamic> json) =>
      _$AiCorrectionIntentFromJson(json);
}
