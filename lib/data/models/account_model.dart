import 'package:freezed_annotation/freezed_annotation.dart';

import 'account_type.dart';

part 'account_model.freezed.dart';
part 'account_model.g.dart';

double _amountFromJson(dynamic value) =>
    value is String ? double.parse(value) : (value as num).toDouble();

dynamic _amountToJson(double value) => value;

/// A place money is held (a bank, an e-wallet, cash). A transaction with no
/// account is unassigned: it still counts in the total but is on no account.
/// [isMain] marks the account new transactions and transfers start from.
@freezed
abstract class AccountModel with _$AccountModel {
  const factory AccountModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    required AccountType type,
    @JsonKey(name: 'initial_balance', fromJson: _amountFromJson, toJson: _amountToJson)
    @Default(0)
    double initialBalance,
    @JsonKey(name: 'is_main') @Default(false) bool isMain,
    @JsonKey(name: 'is_archived') @Default(false) bool isArchived,
    @JsonKey(name: 'is_deleted') @Default(false) bool isDeleted,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'is_synced') @Default(true) bool isSynced,
  }) = _AccountModel;

  factory AccountModel.fromJson(Map<String, dynamic> json) => _$AccountModelFromJson(json);
}

extension AccountModelSupabase on AccountModel {
  Map<String, dynamic> toSupabaseRow() => toJson()..remove('is_synced');
}
