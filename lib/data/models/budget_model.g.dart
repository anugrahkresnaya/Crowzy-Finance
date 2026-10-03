// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BudgetModel _$BudgetModelFromJson(Map<String, dynamic> json) => _BudgetModel(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  categoryId: json['category_id'] as String,
  monthlyLimit: _amountFromJson(json['monthly_limit']),
  isDeleted: json['is_deleted'] as bool? ?? false,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  isSynced: json['is_synced'] as bool? ?? true,
);

Map<String, dynamic> _$BudgetModelToJson(_BudgetModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'category_id': instance.categoryId,
      'monthly_limit': _amountToJson(instance.monthlyLimit),
      'is_deleted': instance.isDeleted,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'is_synced': instance.isSynced,
    };
