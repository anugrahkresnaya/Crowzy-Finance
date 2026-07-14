import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_page_route.dart';
import '../../../core/utils/confirm_dialog.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/category_model.dart';
import '../../categories/providers/category_provider.dart';
import '../providers/transaction_provider.dart';
import 'add_edit_transaction_screen.dart';
import 'widgets/transaction_tile.dart';

class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  DateTimeRange? _dateRange;
  String? _categoryId;

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

  Future<void> _confirmAndDelete(String transactionId) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Delete transaction?',
      message: 'This cannot be undone.',
    );
    if (confirmed) {
      ref.read(transactionListProvider.notifier).deleteTransaction(transactionId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionListProvider);
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            onPressed: () => _pickCategory(categoriesAsync.value ?? const []),
          ),
          IconButton(
            icon: const Icon(Icons.date_range_outlined),
            onPressed: _pickDateRange,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => pushSlide(context, const AddEditTransactionScreen()),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          if (_dateRange != null || _categoryId != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_dateRange != null)
                    Chip(
                      label: Text(
                        '${DateFormatter.dayShort(_dateRange!.start)} - ${DateFormatter.dayShort(_dateRange!.end)}',
                      ),
                      onDeleted: () => setState(() => _dateRange = null),
                    ),
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
                ],
              ),
            ),
          Expanded(
            child: transactionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Failed to load transactions: $error')),
              data: (transactions) {
                final categories = categoriesAsync.value ?? const [];
                final categoryById = {for (final c in categories) c.id: c};

                var filtered = transactions;
                if (_dateRange != null) {
                  filtered = filtered
                      .where((t) =>
                          !t.date.isBefore(_dateRange!.start) &&
                          !t.date.isAfter(_dateRange!.end.add(const Duration(days: 1))))
                      .toList();
                }
                if (_categoryId != null) {
                  filtered = filtered.where((t) => t.categoryId == _categoryId).toList();
                }

                if (filtered.isEmpty) {
                  return const EmptyState(
                    icon: Icons.receipt_long_outlined,
                    message: 'No transactions found',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final transaction = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TransactionTile(
                        transaction: transaction,
                        category: categoryById[transaction.categoryId],
                        onTap: () => pushSlide(
                          context,
                          AddEditTransactionScreen(transaction: transaction),
                        ),
                        onDelete: () => _confirmAndDelete(transaction.id),
                      )
                          .animate()
                          .fadeIn(delay: (40 * index).ms, duration: 250.ms)
                          .slideX(begin: 0.03, end: 0),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
