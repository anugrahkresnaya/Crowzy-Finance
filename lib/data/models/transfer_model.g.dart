// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TransferModel _$TransferModelFromJson(Map<String, dynamic> json) =>
    _TransferModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fromAccountId: json['from_account_id'] as String,
      toAccountId: json['to_account_id'] as String,
      amount: _amountFromJson(json['amount']),
      fee: json['fee'] == null ? 0 : _amountFromJson(json['fee']),
      note: json['note'] as String?,
      date: DateTime.parse(json['date'] as String),
      isDeleted: json['is_deleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isSynced: json['is_synced'] as bool? ?? true,
    );

Map<String, dynamic> _$TransferModelToJson(_TransferModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'from_account_id': instance.fromAccountId,
      'to_account_id': instance.toAccountId,
      'amount': _amountToJson(instance.amount),
      'fee': _amountToJson(instance.fee),
      'note': instance.note,
      'date': instance.date.toIso8601String(),
      'is_deleted': instance.isDeleted,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'is_synced': instance.isSynced,
    };
