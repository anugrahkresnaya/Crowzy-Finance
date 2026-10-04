// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(transfersBox)
final transfersBoxProvider = TransfersBoxProvider._();

final class TransfersBoxProvider
    extends
        $FunctionalProvider<
          Box<Map<dynamic, dynamic>>,
          Box<Map<dynamic, dynamic>>,
          Box<Map<dynamic, dynamic>>
        >
    with $Provider<Box<Map<dynamic, dynamic>>> {
  TransfersBoxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transfersBoxProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transfersBoxHash();

  @$internal
  @override
  $ProviderElement<Box<Map<dynamic, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Box<Map<dynamic, dynamic>> create(Ref ref) {
    return transfersBox(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Box<Map<dynamic, dynamic>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Box<Map<dynamic, dynamic>>>(value),
    );
  }
}

String _$transfersBoxHash() => r'ffe2b92fa44a5684621ae5fa8c3a5cb8e0139aa7';

@ProviderFor(lastTransferSource)
final lastTransferSourceProvider = LastTransferSourceProvider._();

final class LastTransferSourceProvider
    extends
        $FunctionalProvider<
          LastTransferSource,
          LastTransferSource,
          LastTransferSource
        >
    with $Provider<LastTransferSource> {
  LastTransferSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastTransferSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastTransferSourceHash();

  @$internal
  @override
  $ProviderElement<LastTransferSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LastTransferSource create(Ref ref) {
    return lastTransferSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LastTransferSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LastTransferSource>(value),
    );
  }
}

String _$lastTransferSourceHash() =>
    r'2bdba0602f84e368e6ee2a3ce8f0af0b8ee9bf31';

@ProviderFor(transferRepository)
final transferRepositoryProvider = TransferRepositoryProvider._();

final class TransferRepositoryProvider
    extends
        $FunctionalProvider<
          TransferRepository,
          TransferRepository,
          TransferRepository
        >
    with $Provider<TransferRepository> {
  TransferRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transferRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transferRepositoryHash();

  @$internal
  @override
  $ProviderElement<TransferRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TransferRepository create(Ref ref) {
    return transferRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransferRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransferRepository>(value),
    );
  }
}

String _$transferRepositoryHash() =>
    r'2bb2f237ad5be9222e580712e13e37e16a7fcebe';

@ProviderFor(TransferList)
final transferListProvider = TransferListProvider._();

final class TransferListProvider
    extends $AsyncNotifierProvider<TransferList, List<TransferModel>> {
  TransferListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transferListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transferListHash();

  @$internal
  @override
  TransferList create() => TransferList();
}

String _$transferListHash() => r'ca800547e9f3b7174d8e0c31f50ec3bb2f3c59f3';

abstract class _$TransferList extends $AsyncNotifier<List<TransferModel>> {
  FutureOr<List<TransferModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<TransferModel>>, List<TransferModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<TransferModel>>, List<TransferModel>>,
              AsyncValue<List<TransferModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
