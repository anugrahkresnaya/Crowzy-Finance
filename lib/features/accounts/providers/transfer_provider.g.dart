// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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

/// Every transfer, put back together from its two transactions. Newest first.

@ProviderFor(transferList)
final transferListProvider = TransferListProvider._();

/// Every transfer, put back together from its two transactions. Newest first.

final class TransferListProvider
    extends $FunctionalProvider<List<Transfer>, List<Transfer>, List<Transfer>>
    with $Provider<List<Transfer>> {
  /// Every transfer, put back together from its two transactions. Newest first.
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
  $ProviderElement<List<Transfer>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Transfer> create(Ref ref) {
    return transferList(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Transfer> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Transfer>>(value),
    );
  }
}

String _$transferListHash() => r'bbd9be2a90a1dd5b2ee38603e28e34139a10ac9f';

/// A transfer's fee expense id → its transfer.

@ProviderFor(feeTransfers)
final feeTransfersProvider = FeeTransfersProvider._();

/// A transfer's fee expense id → its transfer.

final class FeeTransfersProvider
    extends
        $FunctionalProvider<
          Map<String, Transfer>,
          Map<String, Transfer>,
          Map<String, Transfer>
        >
    with $Provider<Map<String, Transfer>> {
  /// A transfer's fee expense id → its transfer.
  FeeTransfersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feeTransfersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feeTransfersHash();

  @$internal
  @override
  $ProviderElement<Map<String, Transfer>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, Transfer> create(Ref ref) {
    return feeTransfers(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, Transfer> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, Transfer>>(value),
    );
  }
}

String _$feeTransfersHash() => r'fae3f7a67ea22f79a9aaf3c7a3bed26f4507678c';

@ProviderFor(transferActions)
final transferActionsProvider = TransferActionsProvider._();

final class TransferActionsProvider
    extends
        $FunctionalProvider<TransferActions, TransferActions, TransferActions>
    with $Provider<TransferActions> {
  TransferActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transferActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transferActionsHash();

  @$internal
  @override
  $ProviderElement<TransferActions> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TransferActions create(Ref ref) {
    return transferActions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransferActions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransferActions>(value),
    );
  }
}

String _$transferActionsHash() => r'0a7eba7ff4b133c298355b1407694ddbbe437e28';
