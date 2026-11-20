// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every transaction and transfer as one list, newest first. A transfer's two
/// legs show as the one transfer; a leg whose partner is missing stays an
/// ordinary row.

@ProviderFor(activityEntries)
final activityEntriesProvider = ActivityEntriesProvider._();

/// Every transaction and transfer as one list, newest first. A transfer's two
/// legs show as the one transfer; a leg whose partner is missing stays an
/// ordinary row.

final class ActivityEntriesProvider
    extends
        $FunctionalProvider<
          List<ActivityEntry>,
          List<ActivityEntry>,
          List<ActivityEntry>
        >
    with $Provider<List<ActivityEntry>> {
  /// Every transaction and transfer as one list, newest first. A transfer's two
  /// legs show as the one transfer; a leg whose partner is missing stays an
  /// ordinary row.
  ActivityEntriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activityEntriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activityEntriesHash();

  @$internal
  @override
  $ProviderElement<List<ActivityEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<ActivityEntry> create(Ref ref) {
    return activityEntries(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ActivityEntry> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ActivityEntry>>(value),
    );
  }
}

String _$activityEntriesHash() => r'2920faf02127f30c16976b586e160b6473e24c7d';

/// The latest few entries, for Home.

@ProviderFor(recentActivity)
final recentActivityProvider = RecentActivityProvider._();

/// The latest few entries, for Home.

final class RecentActivityProvider
    extends
        $FunctionalProvider<
          List<ActivityEntry>,
          List<ActivityEntry>,
          List<ActivityEntry>
        >
    with $Provider<List<ActivityEntry>> {
  /// The latest few entries, for Home.
  RecentActivityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentActivityProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentActivityHash();

  @$internal
  @override
  $ProviderElement<List<ActivityEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<ActivityEntry> create(Ref ref) {
    return recentActivity(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ActivityEntry> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ActivityEntry>>(value),
    );
  }
}

String _$recentActivityHash() => r'7bb0cc97344407fb08654f5abe280aab3621e539';
