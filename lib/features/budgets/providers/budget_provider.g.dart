// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(budgetsBox)
final budgetsBoxProvider = BudgetsBoxProvider._();

final class BudgetsBoxProvider
    extends
        $FunctionalProvider<
          Box<Map<dynamic, dynamic>>,
          Box<Map<dynamic, dynamic>>,
          Box<Map<dynamic, dynamic>>
        >
    with $Provider<Box<Map<dynamic, dynamic>>> {
  BudgetsBoxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetsBoxProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetsBoxHash();

  @$internal
  @override
  $ProviderElement<Box<Map<dynamic, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Box<Map<dynamic, dynamic>> create(Ref ref) {
    return budgetsBox(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Box<Map<dynamic, dynamic>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Box<Map<dynamic, dynamic>>>(value),
    );
  }
}

String _$budgetsBoxHash() => r'23df628faca9e8f372d8d4272c2f5d986bb67f84';

@ProviderFor(budgetRepository)
final budgetRepositoryProvider = BudgetRepositoryProvider._();

final class BudgetRepositoryProvider
    extends
        $FunctionalProvider<
          BudgetRepository,
          BudgetRepository,
          BudgetRepository
        >
    with $Provider<BudgetRepository> {
  BudgetRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetRepositoryHash();

  @$internal
  @override
  $ProviderElement<BudgetRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BudgetRepository create(Ref ref) {
    return budgetRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BudgetRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BudgetRepository>(value),
    );
  }
}

String _$budgetRepositoryHash() => r'826d4074413f0dc620cda7e85c4db35d6fce42ce';

@ProviderFor(BudgetList)
final budgetListProvider = BudgetListProvider._();

final class BudgetListProvider
    extends $AsyncNotifierProvider<BudgetList, List<BudgetModel>> {
  BudgetListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetListHash();

  @$internal
  @override
  BudgetList create() => BudgetList();
}

String _$budgetListHash() => r'57f23a70939ce0934fe3f22fbde58e6c882f6d4e';

abstract class _$BudgetList extends $AsyncNotifier<List<BudgetModel>> {
  FutureOr<List<BudgetModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<BudgetModel>>, List<BudgetModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<BudgetModel>>, List<BudgetModel>>,
              AsyncValue<List<BudgetModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Limit by category id, for the categories that have one.

@ProviderFor(categoryLimits)
final categoryLimitsProvider = CategoryLimitsProvider._();

/// Limit by category id, for the categories that have one.

final class CategoryLimitsProvider
    extends
        $FunctionalProvider<
          Map<String, double>,
          Map<String, double>,
          Map<String, double>
        >
    with $Provider<Map<String, double>> {
  /// Limit by category id, for the categories that have one.
  CategoryLimitsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryLimitsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryLimitsHash();

  @$internal
  @override
  $ProviderElement<Map<String, double>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, double> create(Ref ref) {
    return categoryLimits(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, double> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, double>>(value),
    );
  }
}

String _$categoryLimitsHash() => r'74f74b448fb347435ba58f5c8ddcb3402c808203';

/// This month's spending by category id.

@ProviderFor(categorySpendThisMonth)
final categorySpendThisMonthProvider = CategorySpendThisMonthProvider._();

/// This month's spending by category id.

final class CategorySpendThisMonthProvider
    extends
        $FunctionalProvider<
          Map<String, double>,
          Map<String, double>,
          Map<String, double>
        >
    with $Provider<Map<String, double>> {
  /// This month's spending by category id.
  CategorySpendThisMonthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categorySpendThisMonthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categorySpendThisMonthHash();

  @$internal
  @override
  $ProviderElement<Map<String, double>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, double> create(Ref ref) {
    return categorySpendThisMonth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, double> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, double>>(value),
    );
  }
}

String _$categorySpendThisMonthHash() =>
    r'adb034f36105f36c0640d97cd7d6da177b65eba7';

/// This month's income by category id.

@ProviderFor(categoryEarnedThisMonth)
final categoryEarnedThisMonthProvider = CategoryEarnedThisMonthProvider._();

/// This month's income by category id.

final class CategoryEarnedThisMonthProvider
    extends
        $FunctionalProvider<
          Map<String, double>,
          Map<String, double>,
          Map<String, double>
        >
    with $Provider<Map<String, double>> {
  /// This month's income by category id.
  CategoryEarnedThisMonthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryEarnedThisMonthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryEarnedThisMonthHash();

  @$internal
  @override
  $ProviderElement<Map<String, double>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, double> create(Ref ref) {
    return categoryEarnedThisMonth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, double> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, double>>(value),
    );
  }
}

String _$categoryEarnedThisMonthHash() =>
    r'68fc535c8418438f429c3f651fbd761fddaa3ab5';
