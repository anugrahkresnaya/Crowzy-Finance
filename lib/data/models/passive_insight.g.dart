// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passive_insight.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PassiveInsight _$PassiveInsightFromJson(Map<String, dynamic> json) =>
    _PassiveInsight(
      headline: json['headline'] as String,
      detail: json['detail'] as String,
      category: json['category'] as String?,
      trend: $enumDecode(_$InsightTrendEnumMap, json['trend']),
      percentChange: (json['percent_change'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PassiveInsightToJson(_PassiveInsight instance) =>
    <String, dynamic>{
      'headline': instance.headline,
      'detail': instance.detail,
      'category': instance.category,
      'trend': _$InsightTrendEnumMap[instance.trend]!,
      'percent_change': instance.percentChange,
    };

const _$InsightTrendEnumMap = {
  InsightTrend.up: 'up',
  InsightTrend.down: 'down',
  InsightTrend.neutral: 'neutral',
};
