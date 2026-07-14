import 'package:freezed_annotation/freezed_annotation.dart';

import 'transaction_type.dart';

part 'category_model.freezed.dart';
part 'category_model.g.dart';

@freezed
abstract class CategoryModel with _$CategoryModel {
  const factory CategoryModel({
    required String id,
    @JsonKey(name: 'user_id') String? userId,
    required String name,
    required String icon,
    required TransactionType type,
    @JsonKey(name: 'is_deleted') @Default(false) bool isDeleted,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'is_synced') @Default(true) bool isSynced,
  }) = _CategoryModel;

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);
}

extension CategoryModelSupabase on CategoryModel {
  bool get isGlobal => userId == null;

  Map<String, dynamic> toSupabaseRow() => toJson()..remove('is_synced');
}
