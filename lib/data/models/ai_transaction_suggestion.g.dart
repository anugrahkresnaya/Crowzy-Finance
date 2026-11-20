// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_transaction_suggestion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AiTransactionSuggestion _$AiTransactionSuggestionFromJson(
  Map<String, dynamic> json,
) => _AiTransactionSuggestion(
  amount: (json['amount'] as num).toDouble(),
  type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
  date: DateTime.parse(json['date'] as String),
  note: json['note'] as String?,
  matchedCategoryId: json['matched_category_id'] as String?,
  proposedNewCategory: json['proposed_new_category'] == null
      ? null
      : AiProposedCategory.fromJson(
          json['proposed_new_category'] as Map<String, dynamic>,
        ),
  confidence: $enumDecode(_$AiConfidenceEnumMap, json['confidence']),
);

Map<String, dynamic> _$AiTransactionSuggestionToJson(
  _AiTransactionSuggestion instance,
) => <String, dynamic>{
  'amount': instance.amount,
  'type': _$TransactionTypeEnumMap[instance.type]!,
  'date': instance.date.toIso8601String(),
  'note': instance.note,
  'matched_category_id': instance.matchedCategoryId,
  'proposed_new_category': instance.proposedNewCategory,
  'confidence': _$AiConfidenceEnumMap[instance.confidence]!,
};

const _$TransactionTypeEnumMap = {
  TransactionType.income: 'income',
  TransactionType.expense: 'expense',
};

const _$AiConfidenceEnumMap = {
  AiConfidence.high: 'high',
  AiConfidence.medium: 'medium',
  AiConfidence.low: 'low',
};

_AiProposedCategory _$AiProposedCategoryFromJson(Map<String, dynamic> json) =>
    _AiProposedCategory(
      name: json['name'] as String,
      icon: json['icon'] as String,
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$AiProposedCategoryToJson(_AiProposedCategory instance) =>
    <String, dynamic>{
      'name': instance.name,
      'icon': instance.icon,
      'type': _$TransactionTypeEnumMap[instance.type]!,
    };
