// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TransactionModel {

 String get id;@JsonKey(name: 'user_id') String get userId;@JsonKey(fromJson: _amountFromJson, toJson: _amountToJson) double get amount; TransactionType get type;@JsonKey(name: 'category_id') String get categoryId; String? get note; DateTime get date;@JsonKey(name: 'is_deleted') bool get isDeleted;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;@JsonKey(name: 'is_synced') bool get isSynced;
/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionModelCopyWith<TransactionModel> get copyWith => _$TransactionModelCopyWithImpl<TransactionModel>(this as TransactionModel, _$identity);

  /// Serializes this TransactionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.type, type) || other.type == type)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.note, note) || other.note == note)&&(identical(other.date, date) || other.date == date)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isSynced, isSynced) || other.isSynced == isSynced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,amount,type,categoryId,note,date,isDeleted,createdAt,updatedAt,isSynced);

@override
String toString() {
  return 'TransactionModel(id: $id, userId: $userId, amount: $amount, type: $type, categoryId: $categoryId, note: $note, date: $date, isDeleted: $isDeleted, createdAt: $createdAt, updatedAt: $updatedAt, isSynced: $isSynced)';
}


}

/// @nodoc
abstract mixin class $TransactionModelCopyWith<$Res>  {
  factory $TransactionModelCopyWith(TransactionModel value, $Res Function(TransactionModel) _then) = _$TransactionModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(fromJson: _amountFromJson, toJson: _amountToJson) double amount, TransactionType type,@JsonKey(name: 'category_id') String categoryId, String? note, DateTime date,@JsonKey(name: 'is_deleted') bool isDeleted,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'is_synced') bool isSynced
});




}
/// @nodoc
class _$TransactionModelCopyWithImpl<$Res>
    implements $TransactionModelCopyWith<$Res> {
  _$TransactionModelCopyWithImpl(this._self, this._then);

  final TransactionModel _self;
  final $Res Function(TransactionModel) _then;

/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? amount = null,Object? type = null,Object? categoryId = null,Object? note = freezed,Object? date = null,Object? isDeleted = null,Object? createdAt = null,Object? updatedAt = null,Object? isSynced = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isSynced: null == isSynced ? _self.isSynced : isSynced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionModel].
extension TransactionModelPatterns on TransactionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionModel value)  $default,){
final _that = this;
switch (_that) {
case _TransactionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionModel value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(fromJson: _amountFromJson, toJson: _amountToJson)  double amount,  TransactionType type, @JsonKey(name: 'category_id')  String categoryId,  String? note,  DateTime date, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'is_synced')  bool isSynced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
return $default(_that.id,_that.userId,_that.amount,_that.type,_that.categoryId,_that.note,_that.date,_that.isDeleted,_that.createdAt,_that.updatedAt,_that.isSynced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(fromJson: _amountFromJson, toJson: _amountToJson)  double amount,  TransactionType type, @JsonKey(name: 'category_id')  String categoryId,  String? note,  DateTime date, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'is_synced')  bool isSynced)  $default,) {final _that = this;
switch (_that) {
case _TransactionModel():
return $default(_that.id,_that.userId,_that.amount,_that.type,_that.categoryId,_that.note,_that.date,_that.isDeleted,_that.createdAt,_that.updatedAt,_that.isSynced);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(fromJson: _amountFromJson, toJson: _amountToJson)  double amount,  TransactionType type, @JsonKey(name: 'category_id')  String categoryId,  String? note,  DateTime date, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt, @JsonKey(name: 'is_synced')  bool isSynced)?  $default,) {final _that = this;
switch (_that) {
case _TransactionModel() when $default != null:
return $default(_that.id,_that.userId,_that.amount,_that.type,_that.categoryId,_that.note,_that.date,_that.isDeleted,_that.createdAt,_that.updatedAt,_that.isSynced);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransactionModel implements TransactionModel {
  const _TransactionModel({required this.id, @JsonKey(name: 'user_id') required this.userId, @JsonKey(fromJson: _amountFromJson, toJson: _amountToJson) required this.amount, required this.type, @JsonKey(name: 'category_id') required this.categoryId, this.note, required this.date, @JsonKey(name: 'is_deleted') this.isDeleted = false, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, @JsonKey(name: 'is_synced') this.isSynced = true});
  factory _TransactionModel.fromJson(Map<String, dynamic> json) => _$TransactionModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(fromJson: _amountFromJson, toJson: _amountToJson) final  double amount;
@override final  TransactionType type;
@override@JsonKey(name: 'category_id') final  String categoryId;
@override final  String? note;
@override final  DateTime date;
@override@JsonKey(name: 'is_deleted') final  bool isDeleted;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
@override@JsonKey(name: 'is_synced') final  bool isSynced;

/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionModelCopyWith<_TransactionModel> get copyWith => __$TransactionModelCopyWithImpl<_TransactionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.type, type) || other.type == type)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.note, note) || other.note == note)&&(identical(other.date, date) || other.date == date)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isSynced, isSynced) || other.isSynced == isSynced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,amount,type,categoryId,note,date,isDeleted,createdAt,updatedAt,isSynced);

@override
String toString() {
  return 'TransactionModel(id: $id, userId: $userId, amount: $amount, type: $type, categoryId: $categoryId, note: $note, date: $date, isDeleted: $isDeleted, createdAt: $createdAt, updatedAt: $updatedAt, isSynced: $isSynced)';
}


}

/// @nodoc
abstract mixin class _$TransactionModelCopyWith<$Res> implements $TransactionModelCopyWith<$Res> {
  factory _$TransactionModelCopyWith(_TransactionModel value, $Res Function(_TransactionModel) _then) = __$TransactionModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(fromJson: _amountFromJson, toJson: _amountToJson) double amount, TransactionType type,@JsonKey(name: 'category_id') String categoryId, String? note, DateTime date,@JsonKey(name: 'is_deleted') bool isDeleted,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt,@JsonKey(name: 'is_synced') bool isSynced
});




}
/// @nodoc
class __$TransactionModelCopyWithImpl<$Res>
    implements _$TransactionModelCopyWith<$Res> {
  __$TransactionModelCopyWithImpl(this._self, this._then);

  final _TransactionModel _self;
  final $Res Function(_TransactionModel) _then;

/// Create a copy of TransactionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? amount = null,Object? type = null,Object? categoryId = null,Object? note = freezed,Object? date = null,Object? isDeleted = null,Object? createdAt = null,Object? updatedAt = null,Object? isSynced = null,}) {
  return _then(_TransactionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isSynced: null == isSynced ? _self.isSynced : isSynced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
