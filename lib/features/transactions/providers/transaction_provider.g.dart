// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(transactionBox)
final transactionBoxProvider = TransactionBoxProvider._();

final class TransactionBoxProvider
    extends
        $FunctionalProvider<
          Box<Map<dynamic, dynamic>>,
          Box<Map<dynamic, dynamic>>,
          Box<Map<dynamic, dynamic>>
        >
    with $Provider<Box<Map<dynamic, dynamic>>> {
  TransactionBoxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionBoxProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionBoxHash();

  @$internal
  @override
  $ProviderElement<Box<Map<dynamic, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Box<Map<dynamic, dynamic>> create(Ref ref) {
    return transactionBox(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Box<Map<dynamic, dynamic>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Box<Map<dynamic, dynamic>>>(value),
    );
  }
}

String _$transactionBoxHash() => r'f7652bf6411d4b16bcf145f4e0d6cc4115d8c400';

@ProviderFor(syncMetaBox)
final syncMetaBoxProvider = SyncMetaBoxProvider._();

final class SyncMetaBoxProvider
    extends $FunctionalProvider<Box<dynamic>, Box<dynamic>, Box<dynamic>>
    with $Provider<Box<dynamic>> {
  SyncMetaBoxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncMetaBoxProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncMetaBoxHash();

  @$internal
  @override
  $ProviderElement<Box<dynamic>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Box<dynamic> create(Ref ref) {
    return syncMetaBox(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Box<dynamic> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Box<dynamic>>(value),
    );
  }
}

String _$syncMetaBoxHash() => r'dd75f3f321137c385bc0b52bbb0d6684cd499d11';

@ProviderFor(transactionRepository)
final transactionRepositoryProvider = TransactionRepositoryProvider._();

final class TransactionRepositoryProvider
    extends
        $FunctionalProvider<
          TransactionRepository,
          TransactionRepository,
          TransactionRepository
        >
    with $Provider<TransactionRepository> {
  TransactionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionRepositoryHash();

  @$internal
  @override
  $ProviderElement<TransactionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TransactionRepository create(Ref ref) {
    return transactionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionRepository>(value),
    );
  }
}

String _$transactionRepositoryHash() =>
    r'7bc99ae5b59baab49d949dd23b761f9da0247e46';

@ProviderFor(TransactionList)
final transactionListProvider = TransactionListProvider._();

final class TransactionListProvider
    extends $AsyncNotifierProvider<TransactionList, List<TransactionModel>> {
  TransactionListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionListHash();

  @$internal
  @override
  TransactionList create() => TransactionList();
}

String _$transactionListHash() => r'1a82fa459adfee7153e2990763542e63f28895d0';

abstract class _$TransactionList
    extends $AsyncNotifier<List<TransactionModel>> {
  FutureOr<List<TransactionModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<TransactionModel>>, List<TransactionModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<TransactionModel>>,
                List<TransactionModel>
              >,
              AsyncValue<List<TransactionModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(lastUsedCategoryId)
final lastUsedCategoryIdProvider = LastUsedCategoryIdFamily._();

final class LastUsedCategoryIdProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  LastUsedCategoryIdProvider._({
    required LastUsedCategoryIdFamily super.from,
    required TransactionType super.argument,
  }) : super(
         retry: null,
         name: r'lastUsedCategoryIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lastUsedCategoryIdHash();

  @override
  String toString() {
    return r'lastUsedCategoryIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    final argument = this.argument as TransactionType;
    return lastUsedCategoryId(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LastUsedCategoryIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lastUsedCategoryIdHash() =>
    r'4ba4a1c1e2c9d600aa355cb5aa077f6c393ec414';

final class LastUsedCategoryIdFamily extends $Family
    with $FunctionalFamilyOverride<String?, TransactionType> {
  LastUsedCategoryIdFamily._()
    : super(
        retry: null,
        name: r'lastUsedCategoryIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LastUsedCategoryIdProvider call(TransactionType type) =>
      LastUsedCategoryIdProvider._(argument: type, from: this);

  @override
  String toString() => r'lastUsedCategoryIdProvider';
}

@ProviderFor(recentTransactions)
final recentTransactionsProvider = RecentTransactionsProvider._();

final class RecentTransactionsProvider
    extends
        $FunctionalProvider<
          List<TransactionModel>,
          List<TransactionModel>,
          List<TransactionModel>
        >
    with $Provider<List<TransactionModel>> {
  RecentTransactionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentTransactionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentTransactionsHash();

  @$internal
  @override
  $ProviderElement<List<TransactionModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<TransactionModel> create(Ref ref) {
    return recentTransactions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TransactionModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TransactionModel>>(value),
    );
  }
}

String _$recentTransactionsHash() =>
    r'2832a694e5071ee392e1a19f85b1ee6381911512';

@ProviderFor(allTimeBalance)
final allTimeBalanceProvider = AllTimeBalanceProvider._();

final class AllTimeBalanceProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  AllTimeBalanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allTimeBalanceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allTimeBalanceHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return allTimeBalance(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$allTimeBalanceHash() => r'30e3b8595fc9396e503468ec211355cec5c4793a';

@ProviderFor(thisMonthBalance)
final thisMonthBalanceProvider = ThisMonthBalanceProvider._();

final class ThisMonthBalanceProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  ThisMonthBalanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'thisMonthBalanceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$thisMonthBalanceHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return thisMonthBalance(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$thisMonthBalanceHash() => r'e2ff422b2d3b20ffc736d6254082f3bf53de1ff3';
