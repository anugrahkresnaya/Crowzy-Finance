// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Current balance of every account, by account id.

@ProviderFor(accountBalanceMap)
final accountBalanceMapProvider = AccountBalanceMapProvider._();

/// Current balance of every account, by account id.

final class AccountBalanceMapProvider
    extends
        $FunctionalProvider<
          Map<String, double>,
          Map<String, double>,
          Map<String, double>
        >
    with $Provider<Map<String, double>> {
  /// Current balance of every account, by account id.
  AccountBalanceMapProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountBalanceMapProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountBalanceMapHash();

  @$internal
  @override
  $ProviderElement<Map<String, double>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, double> create(Ref ref) {
    return accountBalanceMap(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, double> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, double>>(value),
    );
  }
}

String _$accountBalanceMapHash() => r'59b7ff47871d7880a955c7e2a4eec61ba301aa6d';

/// Entries on each account this month, for the Accounts list subtitles.

@ProviderFor(accountEntriesThisMonth)
final accountEntriesThisMonthProvider = AccountEntriesThisMonthProvider._();

/// Entries on each account this month, for the Accounts list subtitles.

final class AccountEntriesThisMonthProvider
    extends
        $FunctionalProvider<
          Map<String, int>,
          Map<String, int>,
          Map<String, int>
        >
    with $Provider<Map<String, int>> {
  /// Entries on each account this month, for the Accounts list subtitles.
  AccountEntriesThisMonthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountEntriesThisMonthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountEntriesThisMonthHash();

  @$internal
  @override
  $ProviderElement<Map<String, int>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Map<String, int> create(Ref ref) {
    return accountEntriesThisMonth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, int>>(value),
    );
  }
}

String _$accountEntriesThisMonthHash() =>
    r'622c74f50e6066dc1931a48589c94e923cf48b84';
