// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alert_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AlertModel {

 String get id;@JsonKey(name: 'user_id') String get userId; AlertType get type;@JsonKey(name: 'category_id') String? get categoryId; String get period; String get message; Map<String, dynamic> get metadata;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'read_at') DateTime? get readAt;@JsonKey(name: 'pushed_at') DateTime? get pushedAt;
/// Create a copy of AlertModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AlertModelCopyWith<AlertModel> get copyWith => _$AlertModelCopyWithImpl<AlertModel>(this as AlertModel, _$identity);

  /// Serializes this AlertModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlertModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.period, period) || other.period == period)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.pushedAt, pushedAt) || other.pushedAt == pushedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,type,categoryId,period,message,const DeepCollectionEquality().hash(metadata),createdAt,readAt,pushedAt);

@override
String toString() {
  return 'AlertModel(id: $id, userId: $userId, type: $type, categoryId: $categoryId, period: $period, message: $message, metadata: $metadata, createdAt: $createdAt, readAt: $readAt, pushedAt: $pushedAt)';
}


}

/// @nodoc
abstract mixin class $AlertModelCopyWith<$Res>  {
  factory $AlertModelCopyWith(AlertModel value, $Res Function(AlertModel) _then) = _$AlertModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, AlertType type,@JsonKey(name: 'category_id') String? categoryId, String period, String message, Map<String, dynamic> metadata,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'read_at') DateTime? readAt,@JsonKey(name: 'pushed_at') DateTime? pushedAt
});




}
/// @nodoc
class _$AlertModelCopyWithImpl<$Res>
    implements $AlertModelCopyWith<$Res> {
  _$AlertModelCopyWithImpl(this._self, this._then);

  final AlertModel _self;
  final $Res Function(AlertModel) _then;

/// Create a copy of AlertModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? categoryId = freezed,Object? period = null,Object? message = null,Object? metadata = null,Object? createdAt = null,Object? readAt = freezed,Object? pushedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AlertType,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,pushedAt: freezed == pushedAt ? _self.pushedAt : pushedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AlertModel].
extension AlertModelPatterns on AlertModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AlertModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AlertModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AlertModel value)  $default,){
final _that = this;
switch (_that) {
case _AlertModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AlertModel value)?  $default,){
final _that = this;
switch (_that) {
case _AlertModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  AlertType type, @JsonKey(name: 'category_id')  String? categoryId,  String period,  String message,  Map<String, dynamic> metadata, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'read_at')  DateTime? readAt, @JsonKey(name: 'pushed_at')  DateTime? pushedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AlertModel() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.categoryId,_that.period,_that.message,_that.metadata,_that.createdAt,_that.readAt,_that.pushedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  AlertType type, @JsonKey(name: 'category_id')  String? categoryId,  String period,  String message,  Map<String, dynamic> metadata, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'read_at')  DateTime? readAt, @JsonKey(name: 'pushed_at')  DateTime? pushedAt)  $default,) {final _that = this;
switch (_that) {
case _AlertModel():
return $default(_that.id,_that.userId,_that.type,_that.categoryId,_that.period,_that.message,_that.metadata,_that.createdAt,_that.readAt,_that.pushedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId,  AlertType type, @JsonKey(name: 'category_id')  String? categoryId,  String period,  String message,  Map<String, dynamic> metadata, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'read_at')  DateTime? readAt, @JsonKey(name: 'pushed_at')  DateTime? pushedAt)?  $default,) {final _that = this;
switch (_that) {
case _AlertModel() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.categoryId,_that.period,_that.message,_that.metadata,_that.createdAt,_that.readAt,_that.pushedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AlertModel implements AlertModel {
  const _AlertModel({required this.id, @JsonKey(name: 'user_id') required this.userId, required this.type, @JsonKey(name: 'category_id') this.categoryId, required this.period, required this.message, final  Map<String, dynamic> metadata = const <String, dynamic>{}, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'read_at') this.readAt, @JsonKey(name: 'pushed_at') this.pushedAt}): _metadata = metadata;
  factory _AlertModel.fromJson(Map<String, dynamic> json) => _$AlertModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  AlertType type;
@override@JsonKey(name: 'category_id') final  String? categoryId;
@override final  String period;
@override final  String message;
 final  Map<String, dynamic> _metadata;
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}

@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'read_at') final  DateTime? readAt;
@override@JsonKey(name: 'pushed_at') final  DateTime? pushedAt;

/// Create a copy of AlertModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AlertModelCopyWith<_AlertModel> get copyWith => __$AlertModelCopyWithImpl<_AlertModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AlertModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AlertModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.period, period) || other.period == period)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.pushedAt, pushedAt) || other.pushedAt == pushedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,type,categoryId,period,message,const DeepCollectionEquality().hash(_metadata),createdAt,readAt,pushedAt);

@override
String toString() {
  return 'AlertModel(id: $id, userId: $userId, type: $type, categoryId: $categoryId, period: $period, message: $message, metadata: $metadata, createdAt: $createdAt, readAt: $readAt, pushedAt: $pushedAt)';
}


}

/// @nodoc
abstract mixin class _$AlertModelCopyWith<$Res> implements $AlertModelCopyWith<$Res> {
  factory _$AlertModelCopyWith(_AlertModel value, $Res Function(_AlertModel) _then) = __$AlertModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, AlertType type,@JsonKey(name: 'category_id') String? categoryId, String period, String message, Map<String, dynamic> metadata,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'read_at') DateTime? readAt,@JsonKey(name: 'pushed_at') DateTime? pushedAt
});




}
/// @nodoc
class __$AlertModelCopyWithImpl<$Res>
    implements _$AlertModelCopyWith<$Res> {
  __$AlertModelCopyWithImpl(this._self, this._then);

  final _AlertModel _self;
  final $Res Function(_AlertModel) _then;

/// Create a copy of AlertModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? categoryId = freezed,Object? period = null,Object? message = null,Object? metadata = null,Object? createdAt = null,Object? readAt = freezed,Object? pushedAt = freezed,}) {
  return _then(_AlertModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AlertType,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,pushedAt: freezed == pushedAt ? _self.pushedAt : pushedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
