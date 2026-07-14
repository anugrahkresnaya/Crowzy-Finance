// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wishlist_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WishlistModel {

 String get id;@JsonKey(name: 'user_id') String get userId; String get name;@JsonKey(name: 'target_amount', fromJson: _amountFromJson, toJson: _amountToJson) double get targetAmount;@JsonKey(name: 'current_amount', fromJson: _amountFromJson, toJson: _amountToJson) double get currentAmount; DateTime? get deadline;@JsonKey(name: 'notified_completed') bool get notifiedCompleted;@JsonKey(name: 'is_deleted') bool get isDeleted;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;@JsonKey(name: 'is_synced') bool get isSynced;
/// Create a copy of WishlistModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WishlistModelCopyWith<WishlistModel> get copyWith => _$WishlistModelCopyWithImpl<WishlistModel>(this as WishlistModel, _$identity);

  /// Serializes this WishlistModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WishlistModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.currentAmount, currentAmount) || other.currentAmount == currentAmount)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.notifiedCompleted, notifiedCompleted) || other.notifiedCompleted == notifiedCompleted)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isSynced, isSynced) || other.isSynced == isSynced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,targetAmount,currentAmount,deadline,notifiedCompleted,isDeleted,createdAt,updatedAt,isSynced);

@override
String toString() {
  return 'WishlistModel(id: $id, userId: $userId, name: $name, targetAmount: $targetAmount, currentAmount: $currentAmount, deadline: $deadline, notifiedCompleted: $notifiedCompleted, isDeleted: $isDeleted, createdAt: $createdAt, updatedAt: $updatedAt, isSynced: $isSynced)';
}


}

/// @nodoc
abstract mixin class $WishlistModelCopyWith<$Res>  {
  factory $WishlistModelCopyWith(WishlistModel value, $Res Function(WishlistModel) _then) = _$WishlistModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String name,@JsonKey(name: 'target_amount', fromJson: _amountFromJson, toJson: _amountToJson) double targetAmount,@JsonKey(name: 'current_amount', fromJson: _amountFromJson, toJson: _amountToJson) double currentAmount, DateTime? deadline,@JsonKey(name: 'notified_completed') bool notifiedCompleted,@JsonKey(name: 'is_deleted') bool isDeleted,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'is_synced') bool isSynced
});




}
/// @nodoc
class _$WishlistModelCopyWithImpl<$Res>
    implements $WishlistModelCopyWith<$Res> {
  _$WishlistModelCopyWithImpl(this._self, this._then);

  final WishlistModel _self;
  final $Res Function(WishlistModel) _then;

/// Create a copy of WishlistModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? targetAmount = null,Object? currentAmount = null,Object? deadline = freezed,Object? notifiedCompleted = null,Object? isDeleted = null,Object? createdAt = null,Object? updatedAt = null,Object? isSynced = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,targetAmount: null == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as double,currentAmount: null == currentAmount ? _self.currentAmount : currentAmount // ignore: cast_nullable_to_non_nullable
as double,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime?,notifiedCompleted: null == notifiedCompleted ? _self.notifiedCompleted : notifiedCompleted // ignore: cast_nullable_to_non_nullable
as bool,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isSynced: null == isSynced ? _self.isSynced : isSynced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [WishlistModel].
extension WishlistModelPatterns on WishlistModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WishlistModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WishlistModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WishlistModel value)  $default,){
final _that = this;
switch (_that) {
case _WishlistModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WishlistModel value)?  $default,){
final _that = this;
switch (_that) {
case _WishlistModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String name, @JsonKey(name: 'target_amount', fromJson: _amountFromJson, toJson: _amountToJson)  double targetAmount, @JsonKey(name: 'current_amount', fromJson: _amountFromJson, toJson: _amountToJson)  double currentAmount,  DateTime? deadline, @JsonKey(name: 'notified_completed')  bool notifiedCompleted, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'is_synced')  bool isSynced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WishlistModel() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.targetAmount,_that.currentAmount,_that.deadline,_that.notifiedCompleted,_that.isDeleted,_that.createdAt,_that.updatedAt,_that.isSynced);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String name, @JsonKey(name: 'target_amount', fromJson: _amountFromJson, toJson: _amountToJson)  double targetAmount, @JsonKey(name: 'current_amount', fromJson: _amountFromJson, toJson: _amountToJson)  double currentAmount,  DateTime? deadline, @JsonKey(name: 'notified_completed')  bool notifiedCompleted, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'is_synced')  bool isSynced)  $default,) {final _that = this;
switch (_that) {
case _WishlistModel():
return $default(_that.id,_that.userId,_that.name,_that.targetAmount,_that.currentAmount,_that.deadline,_that.notifiedCompleted,_that.isDeleted,_that.createdAt,_that.updatedAt,_that.isSynced);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId,  String name, @JsonKey(name: 'target_amount', fromJson: _amountFromJson, toJson: _amountToJson)  double targetAmount, @JsonKey(name: 'current_amount', fromJson: _amountFromJson, toJson: _amountToJson)  double currentAmount,  DateTime? deadline, @JsonKey(name: 'notified_completed')  bool notifiedCompleted, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'is_synced')  bool isSynced)?  $default,) {final _that = this;
switch (_that) {
case _WishlistModel() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.targetAmount,_that.currentAmount,_that.deadline,_that.notifiedCompleted,_that.isDeleted,_that.createdAt,_that.updatedAt,_that.isSynced);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WishlistModel implements WishlistModel {
  const _WishlistModel({required this.id, @JsonKey(name: 'user_id') required this.userId, required this.name, @JsonKey(name: 'target_amount', fromJson: _amountFromJson, toJson: _amountToJson) required this.targetAmount, @JsonKey(name: 'current_amount', fromJson: _amountFromJson, toJson: _amountToJson) this.currentAmount = 0.0, this.deadline, @JsonKey(name: 'notified_completed') this.notifiedCompleted = false, @JsonKey(name: 'is_deleted') this.isDeleted = false, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, @JsonKey(name: 'is_synced') this.isSynced = true});
  factory _WishlistModel.fromJson(Map<String, dynamic> json) => _$WishlistModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  String name;
@override@JsonKey(name: 'target_amount', fromJson: _amountFromJson, toJson: _amountToJson) final  double targetAmount;
@override@JsonKey(name: 'current_amount', fromJson: _amountFromJson, toJson: _amountToJson) final  double currentAmount;
@override final  DateTime? deadline;
@override@JsonKey(name: 'notified_completed') final  bool notifiedCompleted;
@override@JsonKey(name: 'is_deleted') final  bool isDeleted;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
@override@JsonKey(name: 'is_synced') final  bool isSynced;

/// Create a copy of WishlistModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WishlistModelCopyWith<_WishlistModel> get copyWith => __$WishlistModelCopyWithImpl<_WishlistModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WishlistModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WishlistModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.currentAmount, currentAmount) || other.currentAmount == currentAmount)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.notifiedCompleted, notifiedCompleted) || other.notifiedCompleted == notifiedCompleted)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isSynced, isSynced) || other.isSynced == isSynced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,targetAmount,currentAmount,deadline,notifiedCompleted,isDeleted,createdAt,updatedAt,isSynced);

@override
String toString() {
  return 'WishlistModel(id: $id, userId: $userId, name: $name, targetAmount: $targetAmount, currentAmount: $currentAmount, deadline: $deadline, notifiedCompleted: $notifiedCompleted, isDeleted: $isDeleted, createdAt: $createdAt, updatedAt: $updatedAt, isSynced: $isSynced)';
}


}

/// @nodoc
abstract mixin class _$WishlistModelCopyWith<$Res> implements $WishlistModelCopyWith<$Res> {
  factory _$WishlistModelCopyWith(_WishlistModel value, $Res Function(_WishlistModel) _then) = __$WishlistModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String name,@JsonKey(name: 'target_amount', fromJson: _amountFromJson, toJson: _amountToJson) double targetAmount,@JsonKey(name: 'current_amount', fromJson: _amountFromJson, toJson: _amountToJson) double currentAmount, DateTime? deadline,@JsonKey(name: 'notified_completed') bool notifiedCompleted,@JsonKey(name: 'is_deleted') bool isDeleted,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'is_synced') bool isSynced
});




}
/// @nodoc
class __$WishlistModelCopyWithImpl<$Res>
    implements _$WishlistModelCopyWith<$Res> {
  __$WishlistModelCopyWithImpl(this._self, this._then);

  final _WishlistModel _self;
  final $Res Function(_WishlistModel) _then;

/// Create a copy of WishlistModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? targetAmount = null,Object? currentAmount = null,Object? deadline = freezed,Object? notifiedCompleted = null,Object? isDeleted = null,Object? createdAt = null,Object? updatedAt = null,Object? isSynced = null,}) {
  return _then(_WishlistModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,targetAmount: null == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as double,currentAmount: null == currentAmount ? _self.currentAmount : currentAmount // ignore: cast_nullable_to_non_nullable
as double,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime?,notifiedCompleted: null == notifiedCompleted ? _self.notifiedCompleted : notifiedCompleted // ignore: cast_nullable_to_non_nullable
as bool,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isSynced: null == isSynced ? _self.isSynced : isSynced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
