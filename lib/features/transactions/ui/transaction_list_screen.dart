import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/entrance.dart';
import '../../../core/widgets/month_switcher.dart';
import '../../../data/models/category_model.dart';
import '../../accounts/providers/account_provider.dart';
import '../../accounts/providers/transfer_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../providers/activity_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/activity_feed.dart';
import '../utils/transaction_sort.dart';
import 'widgets/activity_day_header.dart';
import 'widgets/activity_row.dart';

class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key, this.initialMonth});

  /// The month to open on; defaults to the current one.
  final DateTime? initialMonth;

  @override
  ConsumerState<TransactionListScreen> createState() => _TransactionListScreenState();
}

enum _MenuAction { category, dateRange }

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  late DateTime _month = DateFormatter.startOfMonth(widget.initialMonth ?? DateTime.now());
  DateTimeRange? _dateRange;
  String? _categoryId;
  ActivityFilter _filter = ActivityFilter.all;
  TransactionSort _sort = TransactionSort.newest;
  bool _searching = false;
  final _searchController = TextEditingController();

  static final _circleStyle = IconButton.styleFrom(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.ivory,
    fixedSize: const Size(44, 44),
    shape: const CircleBorder(side: BorderSide(color: AppColors.hairline)),
  );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _isCurrentMonth => !_month.isBefore(DateFormatter.startOfMonth(DateTime.now()));

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (picked != null) setState(() => _dateRange = picked);
  }

  Future<void> _pickCategory(List<CategoryModel> categories) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      sheetAnimationStyle: AppMotion.sheetAnimation(context),
      builder: (context) => ListView(
        shrinkWrap: true,
        children: categories
            .map(
              (c) => ListTile(
                title: Text(c.name),
                onTap: () => Navigator.of(context).pop(c.id),
              ),
            )
            .toList(),
      ),
    );
    if (selected != null) setState(() => _categoryId = selected);
  }

  void _toggleSearch() {
    setState(() {
      _searching = !_searching;
      if (!_searching) _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionListProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Activity', style: textTheme.titleLarge?.copyWith(fontSize: 32)),
                  ),
                  IconButton(
                    tooltip: _searching ? 'Close search' : 'Search',
                    style: _circleStyle,
                    icon: Icon(_searching ? Icons.close_rounded : Icons.search_rounded, size: 20),
                    onPressed: _toggleSearch,
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<Object>(
                    tooltip: 'Sort and filter',
                    style: _circleStyle,
                    icon: const Icon(Icons.tune_rounded, size: 20),
                    onSelected: (value) {
                      switch (value) {
                        case TransactionSort():
                          setState(() => _sort = value);
                        case _MenuAction.category:
                          _pickCategory(categoriesAsync.value ?? const []);
                        case _MenuAction.dateRange:
                          _pickDateRange();
                      }
                    },
                    itemBuilder: (context) => [
                      for (final sort in TransactionSort.values)
                        CheckedPopupMenuItem<Object>(
                          value: sort,
                          checked: sort == _sort,
                          child: Text(sort.label),
                        ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<Object>(
                        value: _MenuAction.category,
                        child: Text('Category…'),
                      ),
                      const PopupMenuItem<Object>(
                        value: _MenuAction.dateRange,
                        child: Text('Date range…'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_searching)
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Search notes and categories',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
            _periodRow(context),
            // Four chips only just fit a phone, so on a narrower one the row scrolls.
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  for (final (index, filter) in ActivityFilter.values.indexed) ...[
                    if (index > 0) const SizedBox(width: 8),
                    _typeChip(filter),
                  ],
                ],
              ),
            ),
            if (_categoryId != null || _sort != TransactionSort.newest)
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    children: [
                      if (_categoryId != null)
                        Chip(
                          label: Text(
                            categoriesAsync.value
                                    ?.firstWhereOrNull((c) => c.id == _categoryId)
                                    ?.name ??
                                'Category',
                          ),
                          onDeleted: () => setState(() => _categoryId = null),
                        ),
                      if (_sort != TransactionSort.newest)
                        Chip(
                          avatar: const Icon(Icons.sort, size: 16),
                          label: Text(_sort.label),
                          onDeleted: () => setState(() => _sort = TransactionSort.newest),
                        ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: transactionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Failed to load transactions: $error')),
                data: (_) => _list(context, categoriesAsync.value ?? const []),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "‹ October 2026 ›", or the chosen date range with a button to clear it.
  Widget _periodRow(BuildContext context) {
    final range = _dateRange;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: range == null
          ? MonthSwitcher(
              label: DateFormatter.monthYear(_month),
              onPrevious: () => setState(() => _month = DateFormatter.previousMonth(_month)),
              onNext: _isCurrentMonth
                  ? null
                  : () => setState(() => _month = DateFormatter.nextMonth(_month)),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 48),
                Text(
                  '${DateFormatter.dayShort(range.start)} – ${DateFormatter.dayShort(range.end)}'
                      .toUpperCase(),
                  style: AppText.eyebrow(context),
                ),
                IconButton(
                  tooltip: 'Clear date range',
                  icon: const Icon(Icons.close_rounded),
                  color: AppColors.brass,
                  onPressed: () => setState(() => _dateRange = null),
                ),
              ],
            ),
    );
  }

  Widget _typeChip(ActivityFilter filter) {
    return ChoiceChip(
      label: Text(filter.label),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      selected: _filter == filter,
      showCheckmark: false,
      onSelected: (_) => setState(() => _filter = filter),
    );
  }

  Widget _list(BuildContext context, List<CategoryModel> categories) {
    final categoryById = {for (final c in categories) c.id: c};
    final accounts = ref.watch(accountListProvider).value ?? const [];
    final accountNames = {for (final a in accounts) a.id: a.name};
    final feeTransfers = ref.watch(feeTransfersProvider);
    final query = _searchController.text;

    final filtered = sortActivity(
      filterActivity(
        ref.watch(activityEntriesProvider),
        month: _month,
        dateRange: _dateRange,
        categoryId: _categoryId,
        filter: _filter,
        query: query,
        categoryNames: {for (final c in categories) c.id: c.name},
        accountNames: accountNames,
      ),
      _sort,
    );

    if (filtered.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long_outlined,
        message: query.trim().isNotEmpty
            ? 'Nothing matches "${query.trim()}"'
            : _dateRange != null
                ? 'No transactions in this range'
                : 'No transactions in ${DateFormatter.monthYear(_month)}',
      );
    }

    // Day headers only make sense when the list runs in date order.
    final byDate = _sort == TransactionSort.newest || _sort == TransactionSort.oldest;
    final entries = <Object>[];
    var rowIndex = 0;
    if (byDate) {
      for (final day in groupActivityByDay(filtered)) {
        entries.add(day);
        for (final entry in day.entries) {
          entries.add((entry: entry, index: rowIndex++));
        }
      }
    } else {
      for (final entry in filtered) {
        entries.add((entry: entry, index: rowIndex++));
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(22, 4, 22, 16),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final item = entries[i];
        if (item is ActivityDay) return ActivityDayHeader(day: item, key: ValueKey(item.day));

        final (:entry, :index) = item as ({ActivityEntry entry, int index});
        return Padding(
          key: ValueKey(entry.id),
          padding: EdgeInsets.zero,
          child: ActivityRow(
            entry: entry,
            categoryById: categoryById,
            accountNames: accountNames,
            feeTransfers: feeTransfers,
            showDate: !byDate,
            showAccount: true,
          ).entrance(context, index: index, axis: Axis.horizontal),
        );
      },
    );
  }
}
