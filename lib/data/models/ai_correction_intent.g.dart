// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_correction_intent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AiCorrectionIntent _$AiCorrectionIntentFromJson(Map<String, dynamic> json) =>
    _AiCorrectionIntent(
      isCorrection: json['is_correction'] as bool,
      targetDescription: json['target_description'] as String?,
      categoryHint: json['category_hint'] as String?,
      dateHint: json['date_hint'] == null
          ? null
          : DateTime.parse(json['date_hint'] as String),
      oldAmountHint: (json['old_amount_hint'] as num?)?.toDouble(),
      newAmount: (json['new_amount'] as num?)?.toDouble(),
      newCategoryHint: json['new_category_hint'] as String?,
      newDate: json['new_date'] == null
          ? null
          : DateTime.parse(json['new_date'] as String),
      newNote: json['new_note'] as String?,
      confidence: $enumDecode(_$AiConfidenceEnumMap, json['confidence']),
    );

Map<String, dynamic> _$AiCorrectionIntentToJson(_AiCorrectionIntent instance) =>
    <String, dynamic>{
      'is_correction': instance.isCorrection,
      'target_description': instance.targetDescription,
      'category_hint': instance.categoryHint,
      'date_hint': instance.dateHint?.toIso8601String(),
      'old_amount_hint': instance.oldAmountHint,
      'new_amount': instance.newAmount,
      'new_category_hint': instance.newCategoryHint,
      'new_date': instance.newDate?.toIso8601String(),
      'new_note': instance.newNote,
      'confidence': _$AiConfidenceEnumMap[instance.confidence]!,
    };

const _$AiConfidenceEnumMap = {
  AiConfidence.high: 'high',
  AiConfidence.medium: 'medium',
  AiConfidence.low: 'low',
};
