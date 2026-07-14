import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_page_route.dart';
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
          pushSlide(context, AddEditCategoryScreen(initialType: type));
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
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final color = category.type == TransactionType.income
            ? AppColors.income
            : AppColors.expense;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.16),
                  ),
                  child: Icon(IconMapper.iconFor(category.icon), color: color),
                ),
                title: Text(
                  category.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: category.isGlobal
                    ? null
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => pushSlide(
                              context,
                              AddEditCategoryScreen(category: category),
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
              ),
            ),
          ),
        ).animate().fadeIn(delay: (40 * index).ms, duration: 250.ms).slideX(begin: 0.03, end: 0);
      },
    );
  }
}
