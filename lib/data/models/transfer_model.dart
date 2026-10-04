import 'package:freezed_annotation/freezed_annotation.dart';

part 'transfer_model.freezed.dart';
part 'transfer_model.g.dart';

double _amountFromJson(dynamic value) =>
    value is String ? double.parse(value) : (value as num).toDouble();

dynamic _amountToJson(double value) => value;

/// Money moved from one account to another. It is not income or expense, so it
/// lives apart from transactions; an optional [fee] is recorded separately as
/// a linked expense transaction (see `TransferList`).
@freezed
abstract class TransferModel with _$TransferModel {
  const factory TransferModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'from_account_id') required String fromAccountId,
    @JsonKey(name: 'to_account_id') required String toAccountId,
    @JsonKey(fromJson: _amountFromJson, toJson: _amountToJson) required double amount,
    @JsonKey(fromJson: _amountFromJson, toJson: _amountToJson) @Default(0) double fee,
    String? note,
    required DateTime date,
    @JsonKey(name: 'is_deleted') @Default(false) bool isDeleted,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'is_synced') @Default(true) bool isSynced,
  }) = _TransferModel;

  factory TransferModel.fromJson(Map<String, dynamic> json) => _$TransferModelFromJson(json);
}

extension TransferModelSupabase on TransferModel {
  Map<String, dynamic> toSupabaseRow() => toJson()..remove('is_synced');
}
