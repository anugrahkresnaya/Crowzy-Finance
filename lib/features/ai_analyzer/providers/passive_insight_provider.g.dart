// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passive_insight_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(passiveInsightContext)
final passiveInsightContextProvider = PassiveInsightContextProvider._();

final class PassiveInsightContextProvider
    extends
        $FunctionalProvider<
          PassiveInsightContext,
          PassiveInsightContext,
          PassiveInsightContext
        >
    with $Provider<PassiveInsightContext> {
  PassiveInsightContextProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'passiveInsightContextProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$passiveInsightContextHash();

  @$internal
  @override
  $ProviderElement<PassiveInsightContext> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PassiveInsightContext create(Ref ref) {
    return passiveInsightContext(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PassiveInsightContext value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PassiveInsightContext>(value),
    );
  }
}

String _$passiveInsightContextHash() =>
    r'039bf3de1b4181e43d722893c72387c8e532df3c';

@ProviderFor(PassiveInsightController)
final passiveInsightControllerProvider = PassiveInsightControllerProvider._();

final class PassiveInsightControllerProvider
    extends $AsyncNotifierProvider<PassiveInsightController, PassiveInsight?> {
  PassiveInsightControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'passiveInsightControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$passiveInsightControllerHash();

  @$internal
  @override
  PassiveInsightController create() => PassiveInsightController();
}

String _$passiveInsightControllerHash() =>
    r'5253d33586e9d7f9afb2079ad8b854c8e322055b';

abstract class _$PassiveInsightController
    extends $AsyncNotifier<PassiveInsight?> {
  FutureOr<PassiveInsight?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PassiveInsight?>, PassiveInsight?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PassiveInsight?>, PassiveInsight?>,
              AsyncValue<PassiveInsight?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
