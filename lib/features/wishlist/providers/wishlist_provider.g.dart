// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(wishlistBox)
final wishlistBoxProvider = WishlistBoxProvider._();

final class WishlistBoxProvider
    extends
        $FunctionalProvider<
          Box<Map<dynamic, dynamic>>,
          Box<Map<dynamic, dynamic>>,
          Box<Map<dynamic, dynamic>>
        >
    with $Provider<Box<Map<dynamic, dynamic>>> {
  WishlistBoxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wishlistBoxProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wishlistBoxHash();

  @$internal
  @override
  $ProviderElement<Box<Map<dynamic, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Box<Map<dynamic, dynamic>> create(Ref ref) {
    return wishlistBox(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Box<Map<dynamic, dynamic>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Box<Map<dynamic, dynamic>>>(value),
    );
  }
}

String _$wishlistBoxHash() => r'de13993f2868fed679f8a68b00a53159ac190e54';

@ProviderFor(wishlistRepository)
final wishlistRepositoryProvider = WishlistRepositoryProvider._();

final class WishlistRepositoryProvider
    extends
        $FunctionalProvider<
          WishlistRepository,
          WishlistRepository,
          WishlistRepository
        >
    with $Provider<WishlistRepository> {
  WishlistRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wishlistRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wishlistRepositoryHash();

  @$internal
  @override
  $ProviderElement<WishlistRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WishlistRepository create(Ref ref) {
    return wishlistRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WishlistRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WishlistRepository>(value),
    );
  }
}

String _$wishlistRepositoryHash() =>
    r'f5ea2d99f8e2fa301f6fe5f94b2fd0bf258fd11d';

@ProviderFor(WishlistList)
final wishlistListProvider = WishlistListProvider._();

final class WishlistListProvider
    extends $AsyncNotifierProvider<WishlistList, List<WishlistModel>> {
  WishlistListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wishlistListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wishlistListHash();

  @$internal
  @override
  WishlistList create() => WishlistList();
}

String _$wishlistListHash() => r'82cd5eed5b3a209dfba7d41a4152319e40ecaec0';

abstract class _$WishlistList extends $AsyncNotifier<List<WishlistModel>> {
  FutureOr<List<WishlistModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<WishlistModel>>, List<WishlistModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<WishlistModel>>, List<WishlistModel>>,
              AsyncValue<List<WishlistModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(activeWishlistGoals)
final activeWishlistGoalsProvider = ActiveWishlistGoalsProvider._();

final class ActiveWishlistGoalsProvider
    extends
        $FunctionalProvider<
          List<WishlistModel>,
          List<WishlistModel>,
          List<WishlistModel>
        >
    with $Provider<List<WishlistModel>> {
  ActiveWishlistGoalsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeWishlistGoalsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeWishlistGoalsHash();

  @$internal
  @override
  $ProviderElement<List<WishlistModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<WishlistModel> create(Ref ref) {
    return activeWishlistGoals(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<WishlistModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<WishlistModel>>(value),
    );
  }
}

String _$activeWishlistGoalsHash() =>
    r'8b82ed5d2e320dc3a5d3364f309999c55c887cf7';
