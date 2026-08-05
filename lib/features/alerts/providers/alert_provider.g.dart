// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(alertsBox)
final alertsBoxProvider = AlertsBoxProvider._();

final class AlertsBoxProvider
    extends
        $FunctionalProvider<
          Box<Map<dynamic, dynamic>>,
          Box<Map<dynamic, dynamic>>,
          Box<Map<dynamic, dynamic>>
        >
    with $Provider<Box<Map<dynamic, dynamic>>> {
  AlertsBoxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'alertsBoxProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$alertsBoxHash();

  @$internal
  @override
  $ProviderElement<Box<Map<dynamic, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Box<Map<dynamic, dynamic>> create(Ref ref) {
    return alertsBox(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Box<Map<dynamic, dynamic>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Box<Map<dynamic, dynamic>>>(value),
    );
  }
}

String _$alertsBoxHash() => r'abba54d4fb918e78eebb128ae527157a7e6583bf';

@ProviderFor(alertRepository)
final alertRepositoryProvider = AlertRepositoryProvider._();

final class AlertRepositoryProvider
    extends
        $FunctionalProvider<AlertRepository, AlertRepository, AlertRepository>
    with $Provider<AlertRepository> {
  AlertRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'alertRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$alertRepositoryHash();

  @$internal
  @override
  $ProviderElement<AlertRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AlertRepository create(Ref ref) {
    return alertRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AlertRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AlertRepository>(value),
    );
  }
}

String _$alertRepositoryHash() => r'547b2060151080df42404b9f8505528e7148a78f';

@ProviderFor(AlertList)
final alertListProvider = AlertListProvider._();

final class AlertListProvider
    extends $AsyncNotifierProvider<AlertList, List<AlertModel>> {
  AlertListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'alertListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$alertListHash();

  @$internal
  @override
  AlertList create() => AlertList();
}

String _$alertListHash() => r'a4f83a4a827becb240a990b82f6e77d28d5f89c5';

abstract class _$AlertList extends $AsyncNotifier<List<AlertModel>> {
  FutureOr<List<AlertModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<AlertModel>>, List<AlertModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<AlertModel>>, List<AlertModel>>,
              AsyncValue<List<AlertModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(unreadAlerts)
final unreadAlertsProvider = UnreadAlertsProvider._();

final class UnreadAlertsProvider
    extends
        $FunctionalProvider<
          List<AlertModel>,
          List<AlertModel>,
          List<AlertModel>
        >
    with $Provider<List<AlertModel>> {
  UnreadAlertsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadAlertsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadAlertsHash();

  @$internal
  @override
  $ProviderElement<List<AlertModel>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<AlertModel> create(Ref ref) {
    return unreadAlerts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<AlertModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<AlertModel>>(value),
    );
  }
}

String _$unreadAlertsHash() => r'2704ac738f5024b4caa690ea62b1b3d20ddef782';
