// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(accountsBox)
final accountsBoxProvider = AccountsBoxProvider._();

final class AccountsBoxProvider
    extends
        $FunctionalProvider<
          Box<Map<dynamic, dynamic>>,
          Box<Map<dynamic, dynamic>>,
          Box<Map<dynamic, dynamic>>
        >
    with $Provider<Box<Map<dynamic, dynamic>>> {
  AccountsBoxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountsBoxProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountsBoxHash();

  @$internal
  @override
  $ProviderElement<Box<Map<dynamic, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Box<Map<dynamic, dynamic>> create(Ref ref) {
    return accountsBox(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Box<Map<dynamic, dynamic>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Box<Map<dynamic, dynamic>>>(value),
    );
  }
}

String _$accountsBoxHash() => r'909d19eee06c060feef828b6f960e06fe01cb9c2';

@ProviderFor(accountRepository)
final accountRepositoryProvider = AccountRepositoryProvider._();

final class AccountRepositoryProvider
    extends
        $FunctionalProvider<
          AccountRepository,
          AccountRepository,
          AccountRepository
        >
    with $Provider<AccountRepository> {
  AccountRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountRepositoryHash();

  @$internal
  @override
  $ProviderElement<AccountRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AccountRepository create(Ref ref) {
    return accountRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountRepository>(value),
    );
  }
}

String _$accountRepositoryHash() => r'9327053aea8775bd9b7aaefa53927b21b3ccdd96';

@ProviderFor(AccountList)
final accountListProvider = AccountListProvider._();

final class AccountListProvider
    extends $AsyncNotifierProvider<AccountList, List<AccountModel>> {
  AccountListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountListHash();

  @$internal
  @override
  AccountList create() => AccountList();
}

String _$accountListHash() => r'ce5dfecb15839a4683974af6435244f43534751a';

abstract class _$AccountList extends $AsyncNotifier<List<AccountModel>> {
  FutureOr<List<AccountModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<AccountModel>>, List<AccountModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<AccountModel>>, List<AccountModel>>,
              AsyncValue<List<AccountModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// The account a new transaction starts on: the main one, else the one last
/// used, else the first, as long as it is active. Null when there is none.

@ProviderFor(startingAccountId)
final startingAccountIdProvider = StartingAccountIdProvider._();

/// The account a new transaction starts on: the main one, else the one last
/// used, else the first, as long as it is active. Null when there is none.

final class StartingAccountIdProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// The account a new transaction starts on: the main one, else the one last
  /// used, else the first, as long as it is active. Null when there is none.
  StartingAccountIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'startingAccountIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$startingAccountIdHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return startingAccountId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$startingAccountIdHash() => r'e151778334c4195a0e6cc9a764eb691028a7ac6f';

/// The account marked as main, which new transactions and transfers start on.
/// Null when none is, or the main one is archived.

@ProviderFor(mainAccountId)
final mainAccountIdProvider = MainAccountIdProvider._();

/// The account marked as main, which new transactions and transfers start on.
/// Null when none is, or the main one is archived.

final class MainAccountIdProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// The account marked as main, which new transactions and transfers start on.
  /// Null when none is, or the main one is archived.
  MainAccountIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mainAccountIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mainAccountIdHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return mainAccountId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$mainAccountIdHash() => r'4f08564f0603504e28d3415d2fdaf2c6c7b6663e';
