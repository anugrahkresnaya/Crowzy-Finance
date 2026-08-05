// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_qa_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(chatContext)
final chatContextProvider = ChatContextProvider._();

final class ChatContextProvider
    extends
        $FunctionalProvider<
          Map<String, dynamic>,
          Map<String, dynamic>,
          Map<String, dynamic>
        >
    with $Provider<Map<String, dynamic>> {
  ChatContextProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatContextProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatContextHash();

  @$internal
  @override
  $ProviderElement<Map<String, dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, dynamic> create(Ref ref) {
    return chatContext(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, dynamic> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, dynamic>>(value),
    );
  }
}

String _$chatContextHash() => r'96448b1fee9c73cb85e0f2223d4725361f371872';

@ProviderFor(ChatQa)
final chatQaProvider = ChatQaProvider._();

final class ChatQaProvider extends $NotifierProvider<ChatQa, ChatQaState> {
  ChatQaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatQaProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatQaHash();

  @$internal
  @override
  ChatQa create() => ChatQa();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatQaState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatQaState>(value),
    );
  }
}

String _$chatQaHash() => r'6aa9ce4a8f2e4f73d68bf1d42d98043efb74d172';

abstract class _$ChatQa extends $Notifier<ChatQaState> {
  ChatQaState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ChatQaState, ChatQaState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatQaState, ChatQaState>,
              ChatQaState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
