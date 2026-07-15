// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_analyzer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(aiAnalyzerRepository)
final aiAnalyzerRepositoryProvider = AiAnalyzerRepositoryProvider._();

final class AiAnalyzerRepositoryProvider
    extends
        $FunctionalProvider<
          AiAnalyzerRepository,
          AiAnalyzerRepository,
          AiAnalyzerRepository
        >
    with $Provider<AiAnalyzerRepository> {
  AiAnalyzerRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aiAnalyzerRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aiAnalyzerRepositoryHash();

  @$internal
  @override
  $ProviderElement<AiAnalyzerRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AiAnalyzerRepository create(Ref ref) {
    return aiAnalyzerRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AiAnalyzerRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AiAnalyzerRepository>(value),
    );
  }
}

String _$aiAnalyzerRepositoryHash() =>
    r'c0038e2935ef35f68ae8d6f1519784855a4dc866';

@ProviderFor(TransactionParser)
final transactionParserProvider = TransactionParserProvider._();

final class TransactionParserProvider
    extends
        $NotifierProvider<
          TransactionParser,
          AsyncValue<AiTransactionSuggestion?>
        > {
  TransactionParserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionParserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionParserHash();

  @$internal
  @override
  TransactionParser create() => TransactionParser();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<AiTransactionSuggestion?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<AiTransactionSuggestion?>>(value),
    );
  }
}

String _$transactionParserHash() => r'a3bb8e8cc6cfde065dca793ab66d0d45f970d54f';

abstract class _$TransactionParser
    extends $Notifier<AsyncValue<AiTransactionSuggestion?>> {
  AsyncValue<AiTransactionSuggestion?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<AiTransactionSuggestion?>,
              AsyncValue<AiTransactionSuggestion?>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<AiTransactionSuggestion?>,
                AsyncValue<AiTransactionSuggestion?>
              >,
              AsyncValue<AiTransactionSuggestion?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
