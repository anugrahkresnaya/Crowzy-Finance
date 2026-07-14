import 'package:freezed_annotation/freezed_annotation.dart';

part 'wishlist_model.freezed.dart';
part 'wishlist_model.g.dart';

double _amountFromJson(dynamic value) =>
    value is String ? double.parse(value) : (value as num).toDouble();

dynamic _amountToJson(double value) => value;

@freezed
abstract class WishlistModel with _$WishlistModel {
  const factory WishlistModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    @JsonKey(name: 'target_amount', fromJson: _amountFromJson, toJson: _amountToJson)
    required double targetAmount,
    @JsonKey(name: 'current_amount', fromJson: _amountFromJson, toJson: _amountToJson)
    @Default(0.0) double currentAmount,
    DateTime? deadline,
    @JsonKey(name: 'notified_completed') @Default(false) bool notifiedCompleted,
    @JsonKey(name: 'is_deleted') @Default(false) bool isDeleted,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'is_synced') @Default(true) bool isSynced,
  }) = _WishlistModel;

  factory WishlistModel.fromJson(Map<String, dynamic> json) =>
      _$WishlistModelFromJson(json);
}

extension WishlistModelSupabase on WishlistModel {
  bool get isCompleted => currentAmount >= targetAmount;

  bool get isExpired =>
      deadline != null && deadline!.isBefore(DateTime.now()) && !isCompleted;

  Map<String, dynamic> toSupabaseRow() => toJson()..remove('is_synced');
}
