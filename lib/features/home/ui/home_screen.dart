import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_motion.dart';
import '../../../core/utils/app_page_route.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/entrance.dart';
import '../../../core/widgets/balance_card.dart';
import '../../ai_analyzer/ui/widgets/passive_insight_card.dart';
import '../../alerts/providers/alert_provider.dart';
import '../../alerts/ui/alerts_list_screen.dart';
import '../../alerts/ui/widgets/alert_tile.dart';
import '../../alerts/ui/widgets/alerts_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../categories/ui/category_list_screen.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/ui/transaction_list_screen.dart';
import '../../transactions/ui/widgets/transaction_tile.dart';
import '../../wishlist/providers/wishlist_provider.dart';
import '../../wishlist/ui/wishlist_list_screen.dart';
import '../../wishlist/ui/widgets/wishlist_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final allTimeBalance = ref.watch(allTimeBalanceProvider);
    final month = ref.watch(thisMonthSummaryProvider);
    final recentTransactions = ref.watch(recentTransactionsProvider);
    final activeGoals = ref.watch(activeWishlistGoalsProvider);
    final unreadAlerts = ref.watch(unreadAlertsProvider);
    final categories = ref.watch(categoryListProvider).value ?? const [];
    final categoryById = {for (final c in categories) c.id: c};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crowzy Finance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Log out',
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Welcome back, ${user?.email?.split('@').first ?? 'there'}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            BalanceCard(
              balance: allTimeBalance,
              monthIncome: month.income,
              monthExpense: month.expense,
              changePercent: month.changePercent,
            ).entrance(context, duration: AppMotion.slow),
            const PassiveInsightCard().entrance(
              context,
              delay: const Duration(milliseconds: 150),
              duration: AppMotion.slow,
            ),
            const AlertsCard().entrance(
              context,
              delay: const Duration(milliseconds: 200),
              duration: AppMotion.slow,
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Transactions', style: Theme.of(context).textTheme.titleMedium),
                TextButton(
                  onPressed: () => pushSlide(context, const TransactionListScreen()),
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
              ...recentTransactions.indexed.map(
                (entry) {
                  final (index, transaction) = entry;
                  return Padding(
                    key: ValueKey(transaction.id),
                    padding: EdgeInsets.zero,
                    child: TransactionTile(
                      transaction: transaction,
                      category: categoryById[transaction.categoryId],
                    ).entrance(context, index: index, axis: Axis.horizontal),
                  );
                },
              ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Goals', style: Theme.of(context).textTheme.titleMedium),
                TextButton(
                  onPressed: () => pushSlide(context, const WishlistListScreen()),
                  child: const Text('See all'),
                ),
              ],
            ),
            if (activeGoals.isEmpty)
              const EmptyState(
                icon: Icons.savings_outlined,
                message: 'No goals yet — tap "See all" to add one',
              )
            else
              ...activeGoals.take(3).indexed.map(
                (entry) {
                  final (index, goal) = entry;
                  return Padding(
                    key: ValueKey(goal.id),
                    padding: const EdgeInsets.only(bottom: 10),
                    child: WishlistTile(goal: goal)
                        .entrance(context, index: index, axis: Axis.horizontal),
                  );
                },
              ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Alerts', style: Theme.of(context).textTheme.titleMedium),
                TextButton(
                  onPressed: () => pushSlide(context, const AlertsListScreen()),
                  child: const Text('See all'),
                ),
              ],
            ),
            if (unreadAlerts.isEmpty)
              const EmptyState(
                icon: Icons.notifications_none_outlined,
                message: 'No alerts — you\'re all caught up',
              )
            else
              ...unreadAlerts.take(3).indexed.map(
                (entry) {
                  final (index, alert) = entry;
                  return Padding(
                    key: ValueKey(alert.id),
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AlertTile(
                      alert: alert,
                      onTap: () => ref.read(alertListProvider.notifier).markRead(alert.id),
                    ).entrance(context, index: index, axis: Axis.horizontal),
                  );
                },
              ),
            const SizedBox(height: 28),
            Text('Manage', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(Icons.category_outlined),
                title: const Text('Categories'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => pushSlide(context, const CategoryListScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
