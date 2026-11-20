import 'package:freezed_annotation/freezed_annotation.dart';

import 'alert_type.dart';

part 'alert_model.freezed.dart';
part 'alert_model.g.dart';

@freezed
abstract class AlertModel with _$AlertModel {
  const factory AlertModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required AlertType type,
    @JsonKey(name: 'category_id') String? categoryId,
    required String period,
    required String message,
    @Default(<String, dynamic>{}) Map<String, dynamic> metadata,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'read_at') DateTime? readAt,
    @JsonKey(name: 'pushed_at') DateTime? pushedAt,
  }) = _AlertModel;

  factory AlertModel.fromJson(Map<String, dynamic> json) =>
      _$AlertModelFromJson(json);
}

extension AlertModelX on AlertModel {
  bool get isUnread => readAt == null;
}
