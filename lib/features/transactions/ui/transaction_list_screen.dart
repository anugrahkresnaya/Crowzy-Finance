import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/app_page_route.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/entrance.dart';
import '../../../core/widgets/month_switcher.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction_type.dart';
import '../../categories/providers/category_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/transaction_filter.dart';
import '../utils/transaction_sort.dart';
import 'transaction_detail_screen.dart';
import 'widgets/transaction_tile.dart';

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
  TransactionType? _type;
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  _typeChip('All', null),
                  const SizedBox(width: 8),
                  _typeChip('Expenses', TransactionType.expense),
                  const SizedBox(width: 8),
                  _typeChip('Income', TransactionType.income),
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
                data: (transactions) => _list(context, transactions, categoriesAsync.value ?? const []),
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

  Widget _typeChip(String label, TransactionType? type) {
    return ChoiceChip(
      label: Text(label),
      selected: _type == type,
      showCheckmark: false,
      onSelected: (_) => setState(() => _type = type),
    );
  }

  Widget _list(
    BuildContext context,
    List<TransactionModel> transactions,
    List<CategoryModel> categories,
  ) {
    final categoryById = {for (final c in categories) c.id: c};
    final query = _searchController.text;

    final filtered = sortTransactions(
      filterTransactions(
        transactions,
        month: _month,
        dateRange: _dateRange,
        categoryId: _categoryId,
        type: _type,
        query: query,
        categoryNames: {for (final c in categories) c.id: c.name},
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
      for (final group in groupByDay(filtered)) {
        entries.add(group);
        for (final transaction in group.transactions) {
          entries.add((transaction: transaction, index: rowIndex++));
        }
      }
    } else {
      for (final transaction in filtered) {
        entries.add((transaction: transaction, index: rowIndex++));
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(22, 4, 22, 16),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final entry = entries[i];
        if (entry is DayGroup) return _DayHeader(group: entry, key: ValueKey(entry.day));

        final (:transaction, :index) = entry as ({TransactionModel transaction, int index});
        return Padding(
          key: ValueKey(transaction.id),
          padding: EdgeInsets.zero,
          child: TransactionTile(
            transaction: transaction,
            category: categoryById[transaction.categoryId],
            showDate: !byDate,
            onTap: () => pushSlide(
              context,
              TransactionDetailScreen(transactionId: transaction.id),
            ),
          ).entrance(context, index: index, axis: Axis.horizontal),
        );
      },
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({super.key, required this.group});

  final DayGroup group;

  @override
  Widget build(BuildContext context) {
    final net = group.net;
    final color = net > 0
        ? AppColors.income
        : net < 0
            ? AppColors.expense
            : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.fromLTRB(2, 18, 2, 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.hairline)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            DateFormatter.relativeDayLong(group.day).toUpperCase(),
            style: AppText.eyebrow(context, color: AppColors.textMuted),
          ),
          Text(
            CurrencyFormatter.signed(net.abs(), income: net >= 0),
            style: AppText.amount(context, size: 16, color: color),
          ),
        ],
      ),
    );
  }
}
