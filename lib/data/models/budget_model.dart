import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_model.freezed.dart';
part 'budget_model.g.dart';

double _amountFromJson(dynamic value) =>
    value is String ? double.parse(value) : (value as num).toDouble();

dynamic _amountToJson(double value) => value;

/// An optional monthly spending limit a user has set on one category. A
/// category with no (non-deleted) budget simply has no limit.
@freezed
abstract class BudgetModel with _$BudgetModel {
  const factory BudgetModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'category_id') required String categoryId,
    @JsonKey(name: 'monthly_limit', fromJson: _amountFromJson, toJson: _amountToJson)
    required double monthlyLimit,
    @JsonKey(name: 'is_deleted') @Default(false) bool isDeleted,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'is_synced') @Default(true) bool isSynced,
  }) = _BudgetModel;

  factory BudgetModel.fromJson(Map<String, dynamic> json) => _$BudgetModelFromJson(json);
}

extension BudgetModelSupabase on BudgetModel {
  Map<String, dynamic> toSupabaseRow() => toJson()..remove('is_synced');
}
