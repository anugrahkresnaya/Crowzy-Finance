import 'package:freezed_annotation/freezed_annotation.dart';

part 'passive_insight.freezed.dart';
part 'passive_insight.g.dart';

enum InsightTrend {
  @JsonValue('up')
  up,
  @JsonValue('down')
  down,
  @JsonValue('neutral')
  neutral,
}

/// Read-only, LLM-generated commentary on the user's own month-over-month
/// spending, produced by the `passive-insights` Edge Function from a
/// client-aggregated summary. Never triggers a write — purely descriptive.
@freezed
abstract class PassiveInsight with _$PassiveInsight {
  const factory PassiveInsight({
    required String headline,
    required String detail,
    String? category,
    required InsightTrend trend,
    @JsonKey(name: 'percent_change') double? percentChange,
  }) = _PassiveInsight;

  factory PassiveInsight.fromJson(Map<String, dynamic> json) =>
      _$PassiveInsightFromJson(json);
}
