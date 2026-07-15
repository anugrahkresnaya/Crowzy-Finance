// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_correction_intent.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AiCorrectionIntent {

@JsonKey(name: 'is_correction') bool get isCorrection;@JsonKey(name: 'target_description') String? get targetDescription;@JsonKey(name: 'category_hint') String? get categoryHint;@JsonKey(name: 'date_hint') DateTime? get dateHint;@JsonKey(name: 'old_amount_hint') double? get oldAmountHint;@JsonKey(name: 'new_amount') double? get newAmount;@JsonKey(name: 'new_category_hint') String? get newCategoryHint;@JsonKey(name: 'new_date') DateTime? get newDate;@JsonKey(name: 'new_note') String? get newNote; AiConfidence get confidence;
/// Create a copy of AiCorrectionIntent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiCorrectionIntentCopyWith<AiCorrectionIntent> get copyWith => _$AiCorrectionIntentCopyWithImpl<AiCorrectionIntent>(this as AiCorrectionIntent, _$identity);

  /// Serializes this AiCorrectionIntent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiCorrectionIntent&&(identical(other.isCorrection, isCorrection) || other.isCorrection == isCorrection)&&(identical(other.targetDescription, targetDescription) || other.targetDescription == targetDescription)&&(identical(other.categoryHint, categoryHint) || other.categoryHint == categoryHint)&&(identical(other.dateHint, dateHint) || other.dateHint == dateHint)&&(identical(other.oldAmountHint, oldAmountHint) || other.oldAmountHint == oldAmountHint)&&(identical(other.newAmount, newAmount) || other.newAmount == newAmount)&&(identical(other.newCategoryHint, newCategoryHint) || other.newCategoryHint == newCategoryHint)&&(identical(other.newDate, newDate) || other.newDate == newDate)&&(identical(other.newNote, newNote) || other.newNote == newNote)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isCorrection,targetDescription,categoryHint,dateHint,oldAmountHint,newAmount,newCategoryHint,newDate,newNote,confidence);

@override
String toString() {
  return 'AiCorrectionIntent(isCorrection: $isCorrection, targetDescription: $targetDescription, categoryHint: $categoryHint, dateHint: $dateHint, oldAmountHint: $oldAmountHint, newAmount: $newAmount, newCategoryHint: $newCategoryHint, newDate: $newDate, newNote: $newNote, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class $AiCorrectionIntentCopyWith<$Res>  {
  factory $AiCorrectionIntentCopyWith(AiCorrectionIntent value, $Res Function(AiCorrectionIntent) _then) = _$AiCorrectionIntentCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'is_correction') bool isCorrection,@JsonKey(name: 'target_description') String? targetDescription,@JsonKey(name: 'category_hint') String? categoryHint,@JsonKey(name: 'date_hint') DateTime? dateHint,@JsonKey(name: 'old_amount_hint') double? oldAmountHint,@JsonKey(name: 'new_amount') double? newAmount,@JsonKey(name: 'new_category_hint') String? newCategoryHint,@JsonKey(name: 'new_date') DateTime? newDate,@JsonKey(name: 'new_note') String? newNote, AiConfidence confidence
});




}
/// @nodoc
class _$AiCorrectionIntentCopyWithImpl<$Res>
    implements $AiCorrectionIntentCopyWith<$Res> {
  _$AiCorrectionIntentCopyWithImpl(this._self, this._then);

  final AiCorrectionIntent _self;
  final $Res Function(AiCorrectionIntent) _then;

/// Create a copy of AiCorrectionIntent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isCorrection = null,Object? targetDescription = freezed,Object? categoryHint = freezed,Object? dateHint = freezed,Object? oldAmountHint = freezed,Object? newAmount = freezed,Object? newCategoryHint = freezed,Object? newDate = freezed,Object? newNote = freezed,Object? confidence = null,}) {
  return _then(_self.copyWith(
isCorrection: null == isCorrection ? _self.isCorrection : isCorrection // ignore: cast_nullable_to_non_nullable
as bool,targetDescription: freezed == targetDescription ? _self.targetDescription : targetDescription // ignore: cast_nullable_to_non_nullable
as String?,categoryHint: freezed == categoryHint ? _self.categoryHint : categoryHint // ignore: cast_nullable_to_non_nullable
as String?,dateHint: freezed == dateHint ? _self.dateHint : dateHint // ignore: cast_nullable_to_non_nullable
as DateTime?,oldAmountHint: freezed == oldAmountHint ? _self.oldAmountHint : oldAmountHint // ignore: cast_nullable_to_non_nullable
as double?,newAmount: freezed == newAmount ? _self.newAmount : newAmount // ignore: cast_nullable_to_non_nullable
as double?,newCategoryHint: freezed == newCategoryHint ? _self.newCategoryHint : newCategoryHint // ignore: cast_nullable_to_non_nullable
as String?,newDate: freezed == newDate ? _self.newDate : newDate // ignore: cast_nullable_to_non_nullable
as DateTime?,newNote: freezed == newNote ? _self.newNote : newNote // ignore: cast_nullable_to_non_nullable
as String?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as AiConfidence,
  ));
}

}


/// Adds pattern-matching-related methods to [AiCorrectionIntent].
extension AiCorrectionIntentPatterns on AiCorrectionIntent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiCorrectionIntent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiCorrectionIntent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiCorrectionIntent value)  $default,){
final _that = this;
switch (_that) {
case _AiCorrectionIntent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiCorrectionIntent value)?  $default,){
final _that = this;
switch (_that) {
case _AiCorrectionIntent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'is_correction')  bool isCorrection, @JsonKey(name: 'target_description')  String? targetDescription, @JsonKey(name: 'category_hint')  String? categoryHint, @JsonKey(name: 'date_hint')  DateTime? dateHint, @JsonKey(name: 'old_amount_hint')  double? oldAmountHint, @JsonKey(name: 'new_amount')  double? newAmount, @JsonKey(name: 'new_category_hint')  String? newCategoryHint, @JsonKey(name: 'new_date')  DateTime? newDate, @JsonKey(name: 'new_note')  String? newNote,  AiConfidence confidence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiCorrectionIntent() when $default != null:
return $default(_that.isCorrection,_that.targetDescription,_that.categoryHint,_that.dateHint,_that.oldAmountHint,_that.newAmount,_that.newCategoryHint,_that.newDate,_that.newNote,_that.confidence);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'is_correction')  bool isCorrection, @JsonKey(name: 'target_description')  String? targetDescription, @JsonKey(name: 'category_hint')  String? categoryHint, @JsonKey(name: 'date_hint')  DateTime? dateHint, @JsonKey(name: 'old_amount_hint')  double? oldAmountHint, @JsonKey(name: 'new_amount')  double? newAmount, @JsonKey(name: 'new_category_hint')  String? newCategoryHint, @JsonKey(name: 'new_date')  DateTime? newDate, @JsonKey(name: 'new_note')  String? newNote,  AiConfidence confidence)  $default,) {final _that = this;
switch (_that) {
case _AiCorrectionIntent():
return $default(_that.isCorrection,_that.targetDescription,_that.categoryHint,_that.dateHint,_that.oldAmountHint,_that.newAmount,_that.newCategoryHint,_that.newDate,_that.newNote,_that.confidence);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'is_correction')  bool isCorrection, @JsonKey(name: 'target_description')  String? targetDescription, @JsonKey(name: 'category_hint')  String? categoryHint, @JsonKey(name: 'date_hint')  DateTime? dateHint, @JsonKey(name: 'old_amount_hint')  double? oldAmountHint, @JsonKey(name: 'new_amount')  double? newAmount, @JsonKey(name: 'new_category_hint')  String? newCategoryHint, @JsonKey(name: 'new_date')  DateTime? newDate, @JsonKey(name: 'new_note')  String? newNote,  AiConfidence confidence)?  $default,) {final _that = this;
switch (_that) {
case _AiCorrectionIntent() when $default != null:
return $default(_that.isCorrection,_that.targetDescription,_that.categoryHint,_that.dateHint,_that.oldAmountHint,_that.newAmount,_that.newCategoryHint,_that.newDate,_that.newNote,_that.confidence);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiCorrectionIntent implements AiCorrectionIntent {
  const _AiCorrectionIntent({@JsonKey(name: 'is_correction') required this.isCorrection, @JsonKey(name: 'target_description') this.targetDescription, @JsonKey(name: 'category_hint') this.categoryHint, @JsonKey(name: 'date_hint') this.dateHint, @JsonKey(name: 'old_amount_hint') this.oldAmountHint, @JsonKey(name: 'new_amount') this.newAmount, @JsonKey(name: 'new_category_hint') this.newCategoryHint, @JsonKey(name: 'new_date') this.newDate, @JsonKey(name: 'new_note') this.newNote, required this.confidence});
  factory _AiCorrectionIntent.fromJson(Map<String, dynamic> json) => _$AiCorrectionIntentFromJson(json);

@override@JsonKey(name: 'is_correction') final  bool isCorrection;
@override@JsonKey(name: 'target_description') final  String? targetDescription;
@override@JsonKey(name: 'category_hint') final  String? categoryHint;
@override@JsonKey(name: 'date_hint') final  DateTime? dateHint;
@override@JsonKey(name: 'old_amount_hint') final  double? oldAmountHint;
@override@JsonKey(name: 'new_amount') final  double? newAmount;
@override@JsonKey(name: 'new_category_hint') final  String? newCategoryHint;
@override@JsonKey(name: 'new_date') final  DateTime? newDate;
@override@JsonKey(name: 'new_note') final  String? newNote;
@override final  AiConfidence confidence;

/// Create a copy of AiCorrectionIntent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiCorrectionIntentCopyWith<_AiCorrectionIntent> get copyWith => __$AiCorrectionIntentCopyWithImpl<_AiCorrectionIntent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiCorrectionIntentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiCorrectionIntent&&(identical(other.isCorrection, isCorrection) || other.isCorrection == isCorrection)&&(identical(other.targetDescription, targetDescription) || other.targetDescription == targetDescription)&&(identical(other.categoryHint, categoryHint) || other.categoryHint == categoryHint)&&(identical(other.dateHint, dateHint) || other.dateHint == dateHint)&&(identical(other.oldAmountHint, oldAmountHint) || other.oldAmountHint == oldAmountHint)&&(identical(other.newAmount, newAmount) || other.newAmount == newAmount)&&(identical(other.newCategoryHint, newCategoryHint) || other.newCategoryHint == newCategoryHint)&&(identical(other.newDate, newDate) || other.newDate == newDate)&&(identical(other.newNote, newNote) || other.newNote == newNote)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isCorrection,targetDescription,categoryHint,dateHint,oldAmountHint,newAmount,newCategoryHint,newDate,newNote,confidence);

@override
String toString() {
  return 'AiCorrectionIntent(isCorrection: $isCorrection, targetDescription: $targetDescription, categoryHint: $categoryHint, dateHint: $dateHint, oldAmountHint: $oldAmountHint, newAmount: $newAmount, newCategoryHint: $newCategoryHint, newDate: $newDate, newNote: $newNote, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class _$AiCorrectionIntentCopyWith<$Res> implements $AiCorrectionIntentCopyWith<$Res> {
  factory _$AiCorrectionIntentCopyWith(_AiCorrectionIntent value, $Res Function(_AiCorrectionIntent) _then) = __$AiCorrectionIntentCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'is_correction') bool isCorrection,@JsonKey(name: 'target_description') String? targetDescription,@JsonKey(name: 'category_hint') String? categoryHint,@JsonKey(name: 'date_hint') DateTime? dateHint,@JsonKey(name: 'old_amount_hint') double? oldAmountHint,@JsonKey(name: 'new_amount') double? newAmount,@JsonKey(name: 'new_category_hint') String? newCategoryHint,@JsonKey(name: 'new_date') DateTime? newDate,@JsonKey(name: 'new_note') String? newNote, AiConfidence confidence
});




}
/// @nodoc
class __$AiCorrectionIntentCopyWithImpl<$Res>
    implements _$AiCorrectionIntentCopyWith<$Res> {
  __$AiCorrectionIntentCopyWithImpl(this._self, this._then);

  final _AiCorrectionIntent _self;
  final $Res Function(_AiCorrectionIntent) _then;

/// Create a copy of AiCorrectionIntent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isCorrection = null,Object? targetDescription = freezed,Object? categoryHint = freezed,Object? dateHint = freezed,Object? oldAmountHint = freezed,Object? newAmount = freezed,Object? newCategoryHint = freezed,Object? newDate = freezed,Object? newNote = freezed,Object? confidence = null,}) {
  return _then(_AiCorrectionIntent(
isCorrection: null == isCorrection ? _self.isCorrection : isCorrection // ignore: cast_nullable_to_non_nullable
as bool,targetDescription: freezed == targetDescription ? _self.targetDescription : targetDescription // ignore: cast_nullable_to_non_nullable
as String?,categoryHint: freezed == categoryHint ? _self.categoryHint : categoryHint // ignore: cast_nullable_to_non_nullable
as String?,dateHint: freezed == dateHint ? _self.dateHint : dateHint // ignore: cast_nullable_to_non_nullable
as DateTime?,oldAmountHint: freezed == oldAmountHint ? _self.oldAmountHint : oldAmountHint // ignore: cast_nullable_to_non_nullable
as double?,newAmount: freezed == newAmount ? _self.newAmount : newAmount // ignore: cast_nullable_to_non_nullable
as double?,newCategoryHint: freezed == newCategoryHint ? _self.newCategoryHint : newCategoryHint // ignore: cast_nullable_to_non_nullable
as String?,newDate: freezed == newDate ? _self.newDate : newDate // ignore: cast_nullable_to_non_nullable
as DateTime?,newNote: freezed == newNote ? _self.newNote : newNote // ignore: cast_nullable_to_non_nullable
as String?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as AiConfidence,
  ));
}


}

// dart format on
