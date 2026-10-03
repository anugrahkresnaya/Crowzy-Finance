// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AlertModel _$AlertModelFromJson(Map<String, dynamic> json) => _AlertModel(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  type: $enumDecode(_$AlertTypeEnumMap, json['type']),
  categoryId: json['category_id'] as String?,
  period: json['period'] as String,
  message: json['message'] as String,
  metadata:
      json['metadata'] as Map<String, dynamic>? ?? const <String, dynamic>{},
  createdAt: DateTime.parse(json['created_at'] as String),
  readAt: json['read_at'] == null
      ? null
      : DateTime.parse(json['read_at'] as String),
  pushedAt: json['pushed_at'] == null
      ? null
      : DateTime.parse(json['pushed_at'] as String),
);

Map<String, dynamic> _$AlertModelToJson(_AlertModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'type': _$AlertTypeEnumMap[instance.type]!,
      'category_id': instance.categoryId,
      'period': instance.period,
      'message': instance.message,
      'metadata': instance.metadata,
      'created_at': instance.createdAt.toIso8601String(),
      'read_at': instance.readAt?.toIso8601String(),
      'pushed_at': instance.pushedAt?.toIso8601String(),
    };

const _$AlertTypeEnumMap = {
  AlertType.categorySpike: 'category_spike',
  AlertType.overspend: 'overspend',
  AlertType.wishlistOffPace: 'wishlist_off_pace',
  AlertType.incomeDrop: 'income_drop',
};
