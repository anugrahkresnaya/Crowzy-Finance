import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/app_page_route.dart';
import '../../../core/utils/confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/entrance.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/transaction_type.dart';
import '../../budgets/providers/budget_provider.dart';
import '../providers/category_provider.dart';
import 'add_edit_category_screen.dart';
import 'widgets/category_limit_dialog.dart';
import 'widgets/category_row.dart';

class CategoryListScreen extends ConsumerStatefulWidget {
  const CategoryListScreen({super.key});

  @override
  ConsumerState<CategoryListScreen> createState() => _CategoryListScreenState();
}

enum _RowAction { edit, delete }

class _CategoryListScreenState extends ConsumerState<CategoryListScreen> {
  TransactionType _type = TransactionType.expense;

  Future<void> _editLimit(CategoryModel category) async {
    final current = ref.read(categoryLimitsProvider)[category.id];
    final choice = await showCategoryLimitDialog(
      context,
      category: category,
      currentLimit: current,
    );
    if (choice == null) return;
    await ref.read(budgetListProvider.notifier).setLimit(category.id, choice.limit);
  }

  Future<void> _delete(CategoryModel category) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Delete category?',
      message: 'Delete "${category.name}"? This cannot be undone.',
    );
    if (confirmed) {
      ref.read(categoryListProvider.notifier).deleteCustomCategory(category.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);
    final limits = ref.watch(categoryLimitsProvider);
    final totals = _type == TransactionType.expense
        ? ref.watch(categorySpendThisMonthProvider)
        : ref.watch(categoryEarnedThisMonthProvider);
    final isExpense = _type == TransactionType.expense;

    ref.listen<AsyncValue<List<CategoryModel>>>(categoryListProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$error')),
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            tooltip: 'Add category',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.burgundy,
              foregroundColor: AppColors.brass,
              fixedSize: const Size(44, 44),
              shape: const CircleBorder(side: BorderSide(color: AppColors.brassOutline)),
            ),
            icon: const Icon(Icons.add_rounded, size: 22),
            onPressed: () => pushSlide(context, AddEditCategoryScreen(initialType: _type)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 0),
            child: SegmentedButton<TransactionType>(
              showSelectedIcon: false,
              expandedInsets: EdgeInsets.zero,
              segments: const [
                ButtonSegment(value: TransactionType.expense, label: Text('Expense')),
                ButtonSegment(value: TransactionType.income, label: Text('Income')),
              ],
              selected: {_type},
              onSelectionChanged: (selection) => setState(() => _type = selection.first),
            ),
          ),
          Expanded(
            child: categoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Failed to load categories: $error')),
              data: (all) {
                // Biggest first, so the categories that matter most lead.
                final categories = all.where((c) => c.type == _type).toList()
                  ..sort((a, b) {
                    final byAmount = (totals[b.id] ?? 0).compareTo(totals[a.id] ?? 0);
                    return byAmount != 0 ? byAmount : a.name.compareTo(b.name);
                  });

                if (categories.isEmpty) {
                  return const EmptyState(
                    icon: Icons.category_outlined,
                    message: 'No categories yet',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
                  itemCount: categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          isExpense ? 'SPENT THIS MONTH' : 'EARNED THIS MONTH',
                          style: AppText.eyebrow(context),
                        ),
                      );
                    }

                    final category = categories[index - 1];
                    return CategoryRow(
                      key: ValueKey(category.id),
                      category: category,
                      amount: totals[category.id] ?? 0,
                      limit: limits[category.id],
                      showLimit: isExpense,
                      onTap: isExpense
                          ? () => _editLimit(category)
                          : () {
                              if (!category.isGlobal) {
                                pushSlide(context, AddEditCategoryScreen(category: category));
                              }
                            },
                      trailing: category.isGlobal
                          ? null
                          : PopupMenuButton<_RowAction>(
                              tooltip: 'More',
                              icon: const Icon(Icons.more_vert_rounded, color: AppColors.textFaint),
                              onSelected: (action) {
                                switch (action) {
                                  case _RowAction.edit:
                                    pushSlide(context, AddEditCategoryScreen(category: category));
                                  case _RowAction.delete:
                                    _delete(category);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(value: _RowAction.edit, child: Text('Edit')),
                                PopupMenuItem(value: _RowAction.delete, child: Text('Delete')),
                              ],
                            ),
                    ).entrance(context, index: index - 1, axis: Axis.horizontal);
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
