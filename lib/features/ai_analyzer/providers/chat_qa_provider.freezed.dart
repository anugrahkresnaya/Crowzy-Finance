// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_qa_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatQaState {

 List<ChatMessage> get messages; bool get isLoading;
/// Create a copy of ChatQaState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatQaStateCopyWith<ChatQaState> get copyWith => _$ChatQaStateCopyWithImpl<ChatQaState>(this as ChatQaState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatQaState&&const DeepCollectionEquality().equals(other.messages, messages)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(messages),isLoading);

@override
String toString() {
  return 'ChatQaState(messages: $messages, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class $ChatQaStateCopyWith<$Res>  {
  factory $ChatQaStateCopyWith(ChatQaState value, $Res Function(ChatQaState) _then) = _$ChatQaStateCopyWithImpl;
@useResult
$Res call({
 List<ChatMessage> messages, bool isLoading
});




}
/// @nodoc
class _$ChatQaStateCopyWithImpl<$Res>
    implements $ChatQaStateCopyWith<$Res> {
  _$ChatQaStateCopyWithImpl(this._self, this._then);

  final ChatQaState _self;
  final $Res Function(ChatQaState) _then;

/// Create a copy of ChatQaState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? messages = null,Object? isLoading = null,}) {
  return _then(_self.copyWith(
messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatQaState].
extension ChatQaStatePatterns on ChatQaState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatQaState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatQaState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatQaState value)  $default,){
final _that = this;
switch (_that) {
case _ChatQaState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatQaState value)?  $default,){
final _that = this;
switch (_that) {
case _ChatQaState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ChatMessage> messages,  bool isLoading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatQaState() when $default != null:
return $default(_that.messages,_that.isLoading);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ChatMessage> messages,  bool isLoading)  $default,) {final _that = this;
switch (_that) {
case _ChatQaState():
return $default(_that.messages,_that.isLoading);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ChatMessage> messages,  bool isLoading)?  $default,) {final _that = this;
switch (_that) {
case _ChatQaState() when $default != null:
return $default(_that.messages,_that.isLoading);case _:
  return null;

}
}

}

/// @nodoc


class _ChatQaState implements ChatQaState {
  const _ChatQaState({final  List<ChatMessage> messages = const [], this.isLoading = false}): _messages = messages;
  

 final  List<ChatMessage> _messages;
@override@JsonKey() List<ChatMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

@override@JsonKey() final  bool isLoading;

/// Create a copy of ChatQaState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatQaStateCopyWith<_ChatQaState> get copyWith => __$ChatQaStateCopyWithImpl<_ChatQaState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatQaState&&const DeepCollectionEquality().equals(other._messages, _messages)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_messages),isLoading);

@override
String toString() {
  return 'ChatQaState(messages: $messages, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class _$ChatQaStateCopyWith<$Res> implements $ChatQaStateCopyWith<$Res> {
  factory _$ChatQaStateCopyWith(_ChatQaState value, $Res Function(_ChatQaState) _then) = __$ChatQaStateCopyWithImpl;
@override @useResult
$Res call({
 List<ChatMessage> messages, bool isLoading
});




}
/// @nodoc
class __$ChatQaStateCopyWithImpl<$Res>
    implements _$ChatQaStateCopyWith<$Res> {
  __$ChatQaStateCopyWithImpl(this._self, this._then);

  final _ChatQaState _self;
  final $Res Function(_ChatQaState) _then;

/// Create a copy of ChatQaState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? messages = null,Object? isLoading = null,}) {
  return _then(_ChatQaState(
messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<ChatMessage>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
