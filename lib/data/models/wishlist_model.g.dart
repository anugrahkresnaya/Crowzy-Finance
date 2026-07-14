// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WishlistModel _$WishlistModelFromJson(Map<String, dynamic> json) =>
    _WishlistModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      targetAmount: _amountFromJson(json['target_amount']),
      currentAmount: json['current_amount'] == null
          ? 0.0
          : _amountFromJson(json['current_amount']),
      deadline: json['deadline'] == null
          ? null
          : DateTime.parse(json['deadline'] as String),
      notifiedCompleted: json['notified_completed'] as bool? ?? false,
      isDeleted: json['is_deleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isSynced: json['is_synced'] as bool? ?? true,
    );

Map<String, dynamic> _$WishlistModelToJson(_WishlistModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'target_amount': _amountToJson(instance.targetAmount),
      'current_amount': _amountToJson(instance.currentAmount),
      'deadline': instance.deadline?.toIso8601String(),
      'notified_completed': instance.notifiedCompleted,
      'is_deleted': instance.isDeleted,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'is_synced': instance.isSynced,
    };
