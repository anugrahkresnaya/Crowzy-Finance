import 'package:freezed_annotation/freezed_annotation.dart';

import 'transaction_type.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

double _amountFromJson(dynamic value) =>
    value is String ? double.parse(value) : (value as num).toDouble();

dynamic _amountToJson(double value) => value;

@freezed
abstract class TransactionModel with _$TransactionModel {
  const factory TransactionModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(fromJson: _amountFromJson, toJson: _amountToJson)
    required double amount,
    required TransactionType type,
    @JsonKey(name: 'category_id') required String categoryId,
    String? note,
    required DateTime date,
    @JsonKey(name: 'is_deleted') @Default(false) bool isDeleted,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'is_synced') @Default(true) bool isSynced,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);
}

extension TransactionModelSupabase on TransactionModel {
  Map<String, dynamic> toSupabaseRow() => toJson()..remove('is_synced');
}
