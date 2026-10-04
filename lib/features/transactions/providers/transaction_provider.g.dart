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

String _$transactionListHash() => r'6ea3bf4326549b3d6b6b9865e56a56ce425a6f3b';

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

/// The account the last transaction was added to, so the next one starts there.

@ProviderFor(lastUsedAccountId)
final lastUsedAccountIdProvider = LastUsedAccountIdProvider._();

/// The account the last transaction was added to, so the next one starts there.

final class LastUsedAccountIdProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// The account the last transaction was added to, so the next one starts there.
  LastUsedAccountIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastUsedAccountIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastUsedAccountIdHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return lastUsedAccountId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$lastUsedAccountIdHash() => r'd8313e005234bb809172a872ec58121dd32ae489';

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

/// Transactions that are spending or earning, which leaves out the two legs
/// of every transfer. Reports, budgets, summaries and the AI read this.

@ProviderFor(spendingTransactions)
final spendingTransactionsProvider = SpendingTransactionsProvider._();

/// Transactions that are spending or earning, which leaves out the two legs
/// of every transfer. Reports, budgets, summaries and the AI read this.

final class SpendingTransactionsProvider
    extends
        $FunctionalProvider<
          List<TransactionModel>,
          List<TransactionModel>,
          List<TransactionModel>
        >
    with $Provider<List<TransactionModel>> {
  /// Transactions that are spending or earning, which leaves out the two legs
  /// of every transfer. Reports, budgets, summaries and the AI read this.
  SpendingTransactionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'spendingTransactionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$spendingTransactionsHash();

  @$internal
  @override
  $ProviderElement<List<TransactionModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<TransactionModel> create(Ref ref) {
    return spendingTransactions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TransactionModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TransactionModel>>(value),
    );
  }
}

String _$spendingTransactionsHash() =>
    r'48713c497dc33fc7355aa274ed93e7828fd0c47f';

/// Everything held across all accounts: initial balances plus every
/// transaction. A transfer's legs cancel, so it leaves this unchanged (its fee
/// is an expense and does not).

@ProviderFor(allTimeBalance)
final allTimeBalanceProvider = AllTimeBalanceProvider._();

/// Everything held across all accounts: initial balances plus every
/// transaction. A transfer's legs cancel, so it leaves this unchanged (its fee
/// is an expense and does not).

final class AllTimeBalanceProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  /// Everything held across all accounts: initial balances plus every
  /// transaction. A transfer's legs cancel, so it leaves this unchanged (its fee
  /// is an expense and does not).
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

String _$allTimeBalanceHash() => r'f004130eea089fdcaf306aede960a032fbf008c8';

@ProviderFor(thisMonthSummary)
final thisMonthSummaryProvider = ThisMonthSummaryProvider._();

final class ThisMonthSummaryProvider
    extends $FunctionalProvider<MonthSummary, MonthSummary, MonthSummary>
    with $Provider<MonthSummary> {
  ThisMonthSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'thisMonthSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$thisMonthSummaryHash();

  @$internal
  @override
  $ProviderElement<MonthSummary> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MonthSummary create(Ref ref) {
    return thisMonthSummary(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MonthSummary value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MonthSummary>(value),
    );
  }
}

String _$thisMonthSummaryHash() => r'0de6d14c14e4036c1f9aeb5f4a9365d9a12442d3';
