// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AccountModel _$AccountModelFromJson(Map<String, dynamic> json) =>
    _AccountModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$AccountTypeEnumMap, json['type']),
      initialBalance: json['initial_balance'] == null
          ? 0
          : _amountFromJson(json['initial_balance']),
      isMain: json['is_main'] as bool? ?? false,
      isArchived: json['is_archived'] as bool? ?? false,
      isDeleted: json['is_deleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isSynced: json['is_synced'] as bool? ?? true,
    );

Map<String, dynamic> _$AccountModelToJson(_AccountModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'type': _$AccountTypeEnumMap[instance.type]!,
      'initial_balance': _amountToJson(instance.initialBalance),
      'is_main': instance.isMain,
      'is_archived': instance.isArchived,
      'is_deleted': instance.isDeleted,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'is_synced': instance.isSynced,
    };

const _$AccountTypeEnumMap = {
  AccountType.bank: 'bank',
  AccountType.ewallet: 'e_wallet',
  AccountType.cash: 'cash',
};
