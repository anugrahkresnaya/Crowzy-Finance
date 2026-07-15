// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'passive_insight.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PassiveInsight {

 String get headline; String get detail; String? get category; InsightTrend get trend;@JsonKey(name: 'percent_change') double? get percentChange;
/// Create a copy of PassiveInsight
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PassiveInsightCopyWith<PassiveInsight> get copyWith => _$PassiveInsightCopyWithImpl<PassiveInsight>(this as PassiveInsight, _$identity);

  /// Serializes this PassiveInsight to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PassiveInsight&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.category, category) || other.category == category)&&(identical(other.trend, trend) || other.trend == trend)&&(identical(other.percentChange, percentChange) || other.percentChange == percentChange));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,headline,detail,category,trend,percentChange);

@override
String toString() {
  return 'PassiveInsight(headline: $headline, detail: $detail, category: $category, trend: $trend, percentChange: $percentChange)';
}


}

/// @nodoc
abstract mixin class $PassiveInsightCopyWith<$Res>  {
  factory $PassiveInsightCopyWith(PassiveInsight value, $Res Function(PassiveInsight) _then) = _$PassiveInsightCopyWithImpl;
@useResult
$Res call({
 String headline, String detail, String? category, InsightTrend trend,@JsonKey(name: 'percent_change') double? percentChange
});




}
/// @nodoc
class _$PassiveInsightCopyWithImpl<$Res>
    implements $PassiveInsightCopyWith<$Res> {
  _$PassiveInsightCopyWithImpl(this._self, this._then);

  final PassiveInsight _self;
  final $Res Function(PassiveInsight) _then;

/// Create a copy of PassiveInsight
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? headline = null,Object? detail = null,Object? category = freezed,Object? trend = null,Object? percentChange = freezed,}) {
  return _then(_self.copyWith(
headline: null == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,trend: null == trend ? _self.trend : trend // ignore: cast_nullable_to_non_nullable
as InsightTrend,percentChange: freezed == percentChange ? _self.percentChange : percentChange // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [PassiveInsight].
extension PassiveInsightPatterns on PassiveInsight {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PassiveInsight value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PassiveInsight() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PassiveInsight value)  $default,){
final _that = this;
switch (_that) {
case _PassiveInsight():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PassiveInsight value)?  $default,){
final _that = this;
switch (_that) {
case _PassiveInsight() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String headline,  String detail,  String? category,  InsightTrend trend, @JsonKey(name: 'percent_change')  double? percentChange)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PassiveInsight() when $default != null:
return $default(_that.headline,_that.detail,_that.category,_that.trend,_that.percentChange);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String headline,  String detail,  String? category,  InsightTrend trend, @JsonKey(name: 'percent_change')  double? percentChange)  $default,) {final _that = this;
switch (_that) {
case _PassiveInsight():
return $default(_that.headline,_that.detail,_that.category,_that.trend,_that.percentChange);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String headline,  String detail,  String? category,  InsightTrend trend, @JsonKey(name: 'percent_change')  double? percentChange)?  $default,) {final _that = this;
switch (_that) {
case _PassiveInsight() when $default != null:
return $default(_that.headline,_that.detail,_that.category,_that.trend,_that.percentChange);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PassiveInsight implements PassiveInsight {
  const _PassiveInsight({required this.headline, required this.detail, this.category, required this.trend, @JsonKey(name: 'percent_change') this.percentChange});
  factory _PassiveInsight.fromJson(Map<String, dynamic> json) => _$PassiveInsightFromJson(json);

@override final  String headline;
@override final  String detail;
@override final  String? category;
@override final  InsightTrend trend;
@override@JsonKey(name: 'percent_change') final  double? percentChange;

/// Create a copy of PassiveInsight
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PassiveInsightCopyWith<_PassiveInsight> get copyWith => __$PassiveInsightCopyWithImpl<_PassiveInsight>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PassiveInsightToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PassiveInsight&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.category, category) || other.category == category)&&(identical(other.trend, trend) || other.trend == trend)&&(identical(other.percentChange, percentChange) || other.percentChange == percentChange));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,headline,detail,category,trend,percentChange);

@override
String toString() {
  return 'PassiveInsight(headline: $headline, detail: $detail, category: $category, trend: $trend, percentChange: $percentChange)';
}


}

/// @nodoc
abstract mixin class _$PassiveInsightCopyWith<$Res> implements $PassiveInsightCopyWith<$Res> {
  factory _$PassiveInsightCopyWith(_PassiveInsight value, $Res Function(_PassiveInsight) _then) = __$PassiveInsightCopyWithImpl;
@override @useResult
$Res call({
 String headline, String detail, String? category, InsightTrend trend,@JsonKey(name: 'percent_change') double? percentChange
});




}
/// @nodoc
class __$PassiveInsightCopyWithImpl<$Res>
    implements _$PassiveInsightCopyWith<$Res> {
  __$PassiveInsightCopyWithImpl(this._self, this._then);

  final _PassiveInsight _self;
  final $Res Function(_PassiveInsight) _then;

/// Create a copy of PassiveInsight
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? headline = null,Object? detail = null,Object? category = freezed,Object? trend = null,Object? percentChange = freezed,}) {
  return _then(_PassiveInsight(
headline: null == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,trend: null == trend ? _self.trend : trend // ignore: cast_nullable_to_non_nullable
as InsightTrend,percentChange: freezed == percentChange ? _self.percentChange : percentChange // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
