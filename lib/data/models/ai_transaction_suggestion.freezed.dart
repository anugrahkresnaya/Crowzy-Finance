// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_transaction_suggestion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AiTransactionSuggestion {

 double get amount; TransactionType get type; DateTime get date; String? get note;@JsonKey(name: 'matched_category_id') String? get matchedCategoryId;@JsonKey(name: 'proposed_new_category') AiProposedCategory? get proposedNewCategory; AiConfidence get confidence;
/// Create a copy of AiTransactionSuggestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiTransactionSuggestionCopyWith<AiTransactionSuggestion> get copyWith => _$AiTransactionSuggestionCopyWithImpl<AiTransactionSuggestion>(this as AiTransactionSuggestion, _$identity);

  /// Serializes this AiTransactionSuggestion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiTransactionSuggestion&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.type, type) || other.type == type)&&(identical(other.date, date) || other.date == date)&&(identical(other.note, note) || other.note == note)&&(identical(other.matchedCategoryId, matchedCategoryId) || other.matchedCategoryId == matchedCategoryId)&&(identical(other.proposedNewCategory, proposedNewCategory) || other.proposedNewCategory == proposedNewCategory)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amount,type,date,note,matchedCategoryId,proposedNewCategory,confidence);

@override
String toString() {
  return 'AiTransactionSuggestion(amount: $amount, type: $type, date: $date, note: $note, matchedCategoryId: $matchedCategoryId, proposedNewCategory: $proposedNewCategory, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class $AiTransactionSuggestionCopyWith<$Res>  {
  factory $AiTransactionSuggestionCopyWith(AiTransactionSuggestion value, $Res Function(AiTransactionSuggestion) _then) = _$AiTransactionSuggestionCopyWithImpl;
@useResult
$Res call({
 double amount, TransactionType type, DateTime date, String? note,@JsonKey(name: 'matched_category_id') String? matchedCategoryId,@JsonKey(name: 'proposed_new_category') AiProposedCategory? proposedNewCategory, AiConfidence confidence
});


$AiProposedCategoryCopyWith<$Res>? get proposedNewCategory;

}
/// @nodoc
class _$AiTransactionSuggestionCopyWithImpl<$Res>
    implements $AiTransactionSuggestionCopyWith<$Res> {
  _$AiTransactionSuggestionCopyWithImpl(this._self, this._then);

  final AiTransactionSuggestion _self;
  final $Res Function(AiTransactionSuggestion) _then;

/// Create a copy of AiTransactionSuggestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? amount = null,Object? type = null,Object? date = null,Object? note = freezed,Object? matchedCategoryId = freezed,Object? proposedNewCategory = freezed,Object? confidence = null,}) {
  return _then(_self.copyWith(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,matchedCategoryId: freezed == matchedCategoryId ? _self.matchedCategoryId : matchedCategoryId // ignore: cast_nullable_to_non_nullable
as String?,proposedNewCategory: freezed == proposedNewCategory ? _self.proposedNewCategory : proposedNewCategory // ignore: cast_nullable_to_non_nullable
as AiProposedCategory?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as AiConfidence,
  ));
}
/// Create a copy of AiTransactionSuggestion
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiProposedCategoryCopyWith<$Res>? get proposedNewCategory {
    if (_self.proposedNewCategory == null) {
    return null;
  }

  return $AiProposedCategoryCopyWith<$Res>(_self.proposedNewCategory!, (value) {
    return _then(_self.copyWith(proposedNewCategory: value));
  });
}
}


/// Adds pattern-matching-related methods to [AiTransactionSuggestion].
extension AiTransactionSuggestionPatterns on AiTransactionSuggestion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiTransactionSuggestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiTransactionSuggestion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiTransactionSuggestion value)  $default,){
final _that = this;
switch (_that) {
case _AiTransactionSuggestion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiTransactionSuggestion value)?  $default,){
final _that = this;
switch (_that) {
case _AiTransactionSuggestion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double amount,  TransactionType type,  DateTime date,  String? note, @JsonKey(name: 'matched_category_id')  String? matchedCategoryId, @JsonKey(name: 'proposed_new_category')  AiProposedCategory? proposedNewCategory,  AiConfidence confidence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiTransactionSuggestion() when $default != null:
return $default(_that.amount,_that.type,_that.date,_that.note,_that.matchedCategoryId,_that.proposedNewCategory,_that.confidence);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double amount,  TransactionType type,  DateTime date,  String? note, @JsonKey(name: 'matched_category_id')  String? matchedCategoryId, @JsonKey(name: 'proposed_new_category')  AiProposedCategory? proposedNewCategory,  AiConfidence confidence)  $default,) {final _that = this;
switch (_that) {
case _AiTransactionSuggestion():
return $default(_that.amount,_that.type,_that.date,_that.note,_that.matchedCategoryId,_that.proposedNewCategory,_that.confidence);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double amount,  TransactionType type,  DateTime date,  String? note, @JsonKey(name: 'matched_category_id')  String? matchedCategoryId, @JsonKey(name: 'proposed_new_category')  AiProposedCategory? proposedNewCategory,  AiConfidence confidence)?  $default,) {final _that = this;
switch (_that) {
case _AiTransactionSuggestion() when $default != null:
return $default(_that.amount,_that.type,_that.date,_that.note,_that.matchedCategoryId,_that.proposedNewCategory,_that.confidence);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiTransactionSuggestion implements AiTransactionSuggestion {
  const _AiTransactionSuggestion({required this.amount, required this.type, required this.date, this.note, @JsonKey(name: 'matched_category_id') this.matchedCategoryId, @JsonKey(name: 'proposed_new_category') this.proposedNewCategory, required this.confidence});
  factory _AiTransactionSuggestion.fromJson(Map<String, dynamic> json) => _$AiTransactionSuggestionFromJson(json);

@override final  double amount;
@override final  TransactionType type;
@override final  DateTime date;
@override final  String? note;
@override@JsonKey(name: 'matched_category_id') final  String? matchedCategoryId;
@override@JsonKey(name: 'proposed_new_category') final  AiProposedCategory? proposedNewCategory;
@override final  AiConfidence confidence;

/// Create a copy of AiTransactionSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiTransactionSuggestionCopyWith<_AiTransactionSuggestion> get copyWith => __$AiTransactionSuggestionCopyWithImpl<_AiTransactionSuggestion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiTransactionSuggestionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiTransactionSuggestion&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.type, type) || other.type == type)&&(identical(other.date, date) || other.date == date)&&(identical(other.note, note) || other.note == note)&&(identical(other.matchedCategoryId, matchedCategoryId) || other.matchedCategoryId == matchedCategoryId)&&(identical(other.proposedNewCategory, proposedNewCategory) || other.proposedNewCategory == proposedNewCategory)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amount,type,date,note,matchedCategoryId,proposedNewCategory,confidence);

@override
String toString() {
  return 'AiTransactionSuggestion(amount: $amount, type: $type, date: $date, note: $note, matchedCategoryId: $matchedCategoryId, proposedNewCategory: $proposedNewCategory, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class _$AiTransactionSuggestionCopyWith<$Res> implements $AiTransactionSuggestionCopyWith<$Res> {
  factory _$AiTransactionSuggestionCopyWith(_AiTransactionSuggestion value, $Res Function(_AiTransactionSuggestion) _then) = __$AiTransactionSuggestionCopyWithImpl;
@override @useResult
$Res call({
 double amount, TransactionType type, DateTime date, String? note,@JsonKey(name: 'matched_category_id') String? matchedCategoryId,@JsonKey(name: 'proposed_new_category') AiProposedCategory? proposedNewCategory, AiConfidence confidence
});


@override $AiProposedCategoryCopyWith<$Res>? get proposedNewCategory;

}
/// @nodoc
class __$AiTransactionSuggestionCopyWithImpl<$Res>
    implements _$AiTransactionSuggestionCopyWith<$Res> {
  __$AiTransactionSuggestionCopyWithImpl(this._self, this._then);

  final _AiTransactionSuggestion _self;
  final $Res Function(_AiTransactionSuggestion) _then;

/// Create a copy of AiTransactionSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? amount = null,Object? type = null,Object? date = null,Object? note = freezed,Object? matchedCategoryId = freezed,Object? proposedNewCategory = freezed,Object? confidence = null,}) {
  return _then(_AiTransactionSuggestion(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,matchedCategoryId: freezed == matchedCategoryId ? _self.matchedCategoryId : matchedCategoryId // ignore: cast_nullable_to_non_nullable
as String?,proposedNewCategory: freezed == proposedNewCategory ? _self.proposedNewCategory : proposedNewCategory // ignore: cast_nullable_to_non_nullable
as AiProposedCategory?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as AiConfidence,
  ));
}

/// Create a copy of AiTransactionSuggestion
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiProposedCategoryCopyWith<$Res>? get proposedNewCategory {
    if (_self.proposedNewCategory == null) {
    return null;
  }

  return $AiProposedCategoryCopyWith<$Res>(_self.proposedNewCategory!, (value) {
    return _then(_self.copyWith(proposedNewCategory: value));
  });
}
}


/// @nodoc
mixin _$AiProposedCategory {

 String get name; String get icon; TransactionType get type;
/// Create a copy of AiProposedCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiProposedCategoryCopyWith<AiProposedCategory> get copyWith => _$AiProposedCategoryCopyWithImpl<AiProposedCategory>(this as AiProposedCategory, _$identity);

  /// Serializes this AiProposedCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiProposedCategory&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,icon,type);

@override
String toString() {
  return 'AiProposedCategory(name: $name, icon: $icon, type: $type)';
}


}

/// @nodoc
abstract mixin class $AiProposedCategoryCopyWith<$Res>  {
  factory $AiProposedCategoryCopyWith(AiProposedCategory value, $Res Function(AiProposedCategory) _then) = _$AiProposedCategoryCopyWithImpl;
@useResult
$Res call({
 String name, String icon, TransactionType type
});




}
/// @nodoc
class _$AiProposedCategoryCopyWithImpl<$Res>
    implements $AiProposedCategoryCopyWith<$Res> {
  _$AiProposedCategoryCopyWithImpl(this._self, this._then);

  final AiProposedCategory _self;
  final $Res Function(AiProposedCategory) _then;

/// Create a copy of AiProposedCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? icon = null,Object? type = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,
  ));
}

}


/// Adds pattern-matching-related methods to [AiProposedCategory].
extension AiProposedCategoryPatterns on AiProposedCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiProposedCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiProposedCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiProposedCategory value)  $default,){
final _that = this;
switch (_that) {
case _AiProposedCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiProposedCategory value)?  $default,){
final _that = this;
switch (_that) {
case _AiProposedCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String icon,  TransactionType type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiProposedCategory() when $default != null:
return $default(_that.name,_that.icon,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String icon,  TransactionType type)  $default,) {final _that = this;
switch (_that) {
case _AiProposedCategory():
return $default(_that.name,_that.icon,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String icon,  TransactionType type)?  $default,) {final _that = this;
switch (_that) {
case _AiProposedCategory() when $default != null:
return $default(_that.name,_that.icon,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiProposedCategory implements AiProposedCategory {
  const _AiProposedCategory({required this.name, required this.icon, required this.type});
  factory _AiProposedCategory.fromJson(Map<String, dynamic> json) => _$AiProposedCategoryFromJson(json);

@override final  String name;
@override final  String icon;
@override final  TransactionType type;

/// Create a copy of AiProposedCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiProposedCategoryCopyWith<_AiProposedCategory> get copyWith => __$AiProposedCategoryCopyWithImpl<_AiProposedCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiProposedCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiProposedCategory&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,icon,type);

@override
String toString() {
  return 'AiProposedCategory(name: $name, icon: $icon, type: $type)';
}


}

/// @nodoc
abstract mixin class _$AiProposedCategoryCopyWith<$Res> implements $AiProposedCategoryCopyWith<$Res> {
  factory _$AiProposedCategoryCopyWith(_AiProposedCategory value, $Res Function(_AiProposedCategory) _then) = __$AiProposedCategoryCopyWithImpl;
@override @useResult
$Res call({
 String name, String icon, TransactionType type
});




}
/// @nodoc
class __$AiProposedCategoryCopyWithImpl<$Res>
    implements _$AiProposedCategoryCopyWith<$Res> {
  __$AiProposedCategoryCopyWithImpl(this._self, this._then);

  final _AiProposedCategory _self;
  final $Res Function(_AiProposedCategory) _then;

/// Create a copy of AiProposedCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? icon = null,Object? type = null,}) {
  return _then(_AiProposedCategory(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,
  ));
}


}

// dart format on
