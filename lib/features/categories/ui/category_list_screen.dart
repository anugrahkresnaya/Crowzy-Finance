import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/confirm_dialog.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/transaction_type.dart';
import '../providers/category_provider.dart';
import 'add_edit_category_screen.dart';

class CategoryListScreen extends ConsumerStatefulWidget {
  const CategoryListScreen({super.key});

  @override
  ConsumerState<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends ConsumerState<CategoryListScreen>
    with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryListProvider);

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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Income'), Tab(text: 'Expense')],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final type = _tabController.index == 0
              ? TransactionType.income
              : TransactionType.expense;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddEditCategoryScreen(initialType: type),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Failed to load categories: $error')),
        data: (categories) {
          return TabBarView(
            controller: _tabController,
            children: [
              _CategoryTab(
                categories: categories.where((c) => c.type == TransactionType.income).toList(),
              ),
              _CategoryTab(
                categories: categories.where((c) => c.type == TransactionType.expense).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryTab extends ConsumerWidget {
  const _CategoryTab({required this.categories});

  final List<CategoryModel> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (categories.isEmpty) {
      return const EmptyState(
        icon: Icons.category_outlined,
        message: 'No categories yet',
      );
    }

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final color = category.type == TransactionType.income
            ? AppColors.income
            : AppColors.expense;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(IconMapper.iconFor(category.icon), color: color),
          ),
          title: Text(category.name),
          trailing: category.isGlobal
              ? null
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddEditCategoryScreen(category: category),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        final confirmed = await confirmDialog(
                          context,
                          title: 'Delete category?',
                          message: 'Delete "${category.name}"? This cannot be undone.',
                        );
                        if (confirmed) {
                          ref
                              .read(categoryListProvider.notifier)
                              .deleteCustomCategory(category.id);
                        }
                      },
                    ),
                  ],
                ),
        );
      },
    );
  }
}
