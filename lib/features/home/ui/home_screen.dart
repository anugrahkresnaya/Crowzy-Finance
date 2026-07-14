import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/summary_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../categories/ui/category_list_screen.dart';
import '../../reports/ui/monthly_report_screen.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/ui/add_edit_transaction_screen.dart';
import '../../transactions/ui/transaction_list_screen.dart';
import '../../transactions/ui/widgets/transaction_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final allTimeBalance = ref.watch(allTimeBalanceProvider);
    final thisMonthBalance = ref.watch(thisMonthBalanceProvider);
    final recentTransactions = ref.watch(recentTransactionsProvider);
    final categories = ref.watch(categoryListProvider).value ?? const [];
    final categoryById = {for (final c in categories) c.id: c};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crowzy Finance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MonthlyReportScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.category_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CategoryListScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddEditTransactionScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Logged in as ${user?.email ?? 'unknown'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    label: 'All-time Balance',
                    amount: allTimeBalance,
                    color: allTimeBalance >= 0 ? AppColors.income : AppColors.expense,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    label: 'This Month',
                    amount: thisMonthBalance,
                    color: thisMonthBalance >= 0 ? AppColors.income : AppColors.expense,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Transactions', style: Theme.of(context).textTheme.titleMedium),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TransactionListScreen()),
                  ),
                  child: const Text('See all'),
                ),
              ],
            ),
            if (recentTransactions.isEmpty)
              const EmptyState(
                icon: Icons.receipt_long_outlined,
                message: 'No transactions yet — tap + to add one',
              )
            else
              ...recentTransactions.map(
                (transaction) => TransactionTile(
                  transaction: transaction,
                  category: categoryById[transaction.categoryId],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
