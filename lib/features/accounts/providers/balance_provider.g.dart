// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Current balance of every account, by account id, plus the money on no
/// account under [unassignedAccountId] when there is any.

@ProviderFor(accountBalanceMap)
final accountBalanceMapProvider = AccountBalanceMapProvider._();

/// Current balance of every account, by account id, plus the money on no
/// account under [unassignedAccountId] when there is any.

final class AccountBalanceMapProvider
    extends
        $FunctionalProvider<
          Map<String, double>,
          Map<String, double>,
          Map<String, double>
        >
    with $Provider<Map<String, double>> {
  /// Current balance of every account, by account id, plus the money on no
  /// account under [unassignedAccountId] when there is any.
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

String _$accountBalanceMapHash() => r'c24152e76a6a47e85a17d9e17fbe76d8f70eeed5';

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
    r'dc08421b27c8f466886af0afb8ca62928bc5dcba';
