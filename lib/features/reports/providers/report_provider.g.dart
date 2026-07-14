// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(reportRepository)
final reportRepositoryProvider = ReportRepositoryProvider._();

final class ReportRepositoryProvider
    extends
        $FunctionalProvider<
          ReportRepository,
          ReportRepository,
          ReportRepository
        >
    with $Provider<ReportRepository> {
  ReportRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportRepositoryHash();

  @$internal
  @override
  $ProviderElement<ReportRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReportRepository create(Ref ref) {
    return reportRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReportRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReportRepository>(value),
    );
  }
}

String _$reportRepositoryHash() => r'ffbd26802768173b39bfeeed6fd611f0b62ebff6';

@ProviderFor(SelectedReportMonth)
final selectedReportMonthProvider = SelectedReportMonthProvider._();

final class SelectedReportMonthProvider
    extends $NotifierProvider<SelectedReportMonth, DateTime> {
  SelectedReportMonthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedReportMonthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedReportMonthHash();

  @$internal
  @override
  SelectedReportMonth create() => SelectedReportMonth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$selectedReportMonthHash() =>
    r'c7d0da651e4e7c45bc984ea5ae4a43c54b78b2bd';

abstract class _$SelectedReportMonth extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(monthTransactions)
final monthTransactionsProvider = MonthTransactionsProvider._();

final class MonthTransactionsProvider
    extends
        $FunctionalProvider<
          List<TransactionModel>,
          List<TransactionModel>,
          List<TransactionModel>
        >
    with $Provider<List<TransactionModel>> {
  MonthTransactionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'monthTransactionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$monthTransactionsHash();

  @$internal
  @override
  $ProviderElement<List<TransactionModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<TransactionModel> create(Ref ref) {
    return monthTransactions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TransactionModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TransactionModel>>(value),
    );
  }
}

String _$monthTransactionsHash() => r'a3ce507cef0e78a3bddbc9a64d7fe88e3691e406';

@ProviderFor(monthSummary)
final monthSummaryProvider = MonthSummaryProvider._();

final class MonthSummaryProvider
    extends $FunctionalProvider<MonthlySummary, MonthlySummary, MonthlySummary>
    with $Provider<MonthlySummary> {
  MonthSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'monthSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$monthSummaryHash();

  @$internal
  @override
  $ProviderElement<MonthlySummary> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MonthlySummary create(Ref ref) {
    return monthSummary(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MonthlySummary value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MonthlySummary>(value),
    );
  }
}

String _$monthSummaryHash() => r'7278a10dfee5a753aaa41f9d8db445ad0ed6f391';

@ProviderFor(previousMonthSummary)
final previousMonthSummaryProvider = PreviousMonthSummaryProvider._();

final class PreviousMonthSummaryProvider
    extends $FunctionalProvider<MonthlySummary, MonthlySummary, MonthlySummary>
    with $Provider<MonthlySummary> {
  PreviousMonthSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'previousMonthSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$previousMonthSummaryHash();

  @$internal
  @override
  $ProviderElement<MonthlySummary> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MonthlySummary create(Ref ref) {
    return previousMonthSummary(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MonthlySummary value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MonthlySummary>(value),
    );
  }
}

String _$previousMonthSummaryHash() =>
    r'253474d288d3ff3eccc3ea0ac2c985c5c61b01f0';

@ProviderFor(incomeBreakdown)
final incomeBreakdownProvider = IncomeBreakdownProvider._();

final class IncomeBreakdownProvider
    extends
        $FunctionalProvider<
          List<CategoryBreakdownEntry>,
          List<CategoryBreakdownEntry>,
          List<CategoryBreakdownEntry>
        >
    with $Provider<List<CategoryBreakdownEntry>> {
  IncomeBreakdownProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'incomeBreakdownProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$incomeBreakdownHash();

  @$internal
  @override
  $ProviderElement<List<CategoryBreakdownEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<CategoryBreakdownEntry> create(Ref ref) {
    return incomeBreakdown(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<CategoryBreakdownEntry> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<CategoryBreakdownEntry>>(value),
    );
  }
}

String _$incomeBreakdownHash() => r'8b891c2e007acda32afa5b97fbe6b5d0480cf5c1';

@ProviderFor(expenseBreakdown)
final expenseBreakdownProvider = ExpenseBreakdownProvider._();

final class ExpenseBreakdownProvider
    extends
        $FunctionalProvider<
          List<CategoryBreakdownEntry>,
          List<CategoryBreakdownEntry>,
          List<CategoryBreakdownEntry>
        >
    with $Provider<List<CategoryBreakdownEntry>> {
  ExpenseBreakdownProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseBreakdownProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseBreakdownHash();

  @$internal
  @override
  $ProviderElement<List<CategoryBreakdownEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<CategoryBreakdownEntry> create(Ref ref) {
    return expenseBreakdown(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<CategoryBreakdownEntry> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<CategoryBreakdownEntry>>(value),
    );
  }
}

String _$expenseBreakdownHash() => r'fa3b3c1fb66b9932f41d3ac246780738f6cde0c5';

@ProviderFor(reportCalendarMarkers)
final reportCalendarMarkersProvider = ReportCalendarMarkersProvider._();

final class ReportCalendarMarkersProvider
    extends
        $FunctionalProvider<
          Map<DateTime, DayActivity>,
          Map<DateTime, DayActivity>,
          Map<DateTime, DayActivity>
        >
    with $Provider<Map<DateTime, DayActivity>> {
  ReportCalendarMarkersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportCalendarMarkersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportCalendarMarkersHash();

  @$internal
  @override
  $ProviderElement<Map<DateTime, DayActivity>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<DateTime, DayActivity> create(Ref ref) {
    return reportCalendarMarkers(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<DateTime, DayActivity> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<DateTime, DayActivity>>(value),
    );
  }
}

String _$reportCalendarMarkersHash() =>
    r'77c8c5176c828a513f43b8b2638c4e219adeb37f';
