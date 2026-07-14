// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(categoryBox)
final categoryBoxProvider = CategoryBoxProvider._();

final class CategoryBoxProvider
    extends
        $FunctionalProvider<
          Box<Map<dynamic, dynamic>>,
          Box<Map<dynamic, dynamic>>,
          Box<Map<dynamic, dynamic>>
        >
    with $Provider<Box<Map<dynamic, dynamic>>> {
  CategoryBoxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryBoxProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryBoxHash();

  @$internal
  @override
  $ProviderElement<Box<Map<dynamic, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Box<Map<dynamic, dynamic>> create(Ref ref) {
    return categoryBox(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Box<Map<dynamic, dynamic>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Box<Map<dynamic, dynamic>>>(value),
    );
  }
}

String _$categoryBoxHash() => r'ce2a1227da4af3718e12fc05269df4222a2e3b0d';

@ProviderFor(categoryRepository)
final categoryRepositoryProvider = CategoryRepositoryProvider._();

final class CategoryRepositoryProvider
    extends
        $FunctionalProvider<
          CategoryRepository,
          CategoryRepository,
          CategoryRepository
        >
    with $Provider<CategoryRepository> {
  CategoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<CategoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CategoryRepository create(Ref ref) {
    return categoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryRepository>(value),
    );
  }
}

String _$categoryRepositoryHash() =>
    r'2b67da78714e14881d41f0b8e16ce73b1adc2e1e';

@ProviderFor(CategoryList)
final categoryListProvider = CategoryListProvider._();

final class CategoryListProvider
    extends $AsyncNotifierProvider<CategoryList, List<CategoryModel>> {
  CategoryListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryListHash();

  @$internal
  @override
  CategoryList create() => CategoryList();
}

String _$categoryListHash() => r'944150de41a12278c15c44caf6a16aad1bd9231e';

abstract class _$CategoryList extends $AsyncNotifier<List<CategoryModel>> {
  FutureOr<List<CategoryModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<CategoryModel>>, List<CategoryModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<CategoryModel>>, List<CategoryModel>>,
              AsyncValue<List<CategoryModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(incomeCategories)
final incomeCategoriesProvider = IncomeCategoriesProvider._();

final class IncomeCategoriesProvider
    extends
        $FunctionalProvider<
          List<CategoryModel>,
          List<CategoryModel>,
          List<CategoryModel>
        >
    with $Provider<List<CategoryModel>> {
  IncomeCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'incomeCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$incomeCategoriesHash();

  @$internal
  @override
  $ProviderElement<List<CategoryModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<CategoryModel> create(Ref ref) {
    return incomeCategories(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<CategoryModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<CategoryModel>>(value),
    );
  }
}

String _$incomeCategoriesHash() => r'f8bf9e627207e0dfb24295391c60d5698da70827';

@ProviderFor(expenseCategories)
final expenseCategoriesProvider = ExpenseCategoriesProvider._();

final class ExpenseCategoriesProvider
    extends
        $FunctionalProvider<
          List<CategoryModel>,
          List<CategoryModel>,
          List<CategoryModel>
        >
    with $Provider<List<CategoryModel>> {
  ExpenseCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseCategoriesHash();

  @$internal
  @override
  $ProviderElement<List<CategoryModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<CategoryModel> create(Ref ref) {
    return expenseCategories(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<CategoryModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<CategoryModel>>(value),
    );
  }
}

String _$expenseCategoriesHash() => r'd107bd289953abc400df4f947db539383cd906be';
