import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/app_page_route.dart';
import '../../../core/widgets/balance_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/entrance.dart';
import '../../alerts/providers/alert_provider.dart';
import '../../alerts/ui/alerts_list_screen.dart';
import '../../alerts/ui/widgets/alerts_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../categories/ui/category_list_screen.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/ui/transaction_list_screen.dart';
import '../../transactions/ui/widgets/transaction_tile.dart';
import '../../wishlist/providers/wishlist_provider.dart';
import '../../wishlist/ui/widgets/goal_highlight_tile.dart';
import '../../wishlist/ui/wishlist_list_screen.dart';
import '../utils/greeting.dart';
import 'widgets/home_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final allTimeBalance = ref.watch(allTimeBalanceProvider);
    final month = ref.watch(thisMonthSummaryProvider);
    final recentTransactions = ref.watch(recentTransactionsProvider).take(3).toList();
    final activeGoals = ref.watch(activeWishlistGoalsProvider);
    final unreadAlerts = ref.watch(unreadAlertsProvider);
    final categories = ref.watch(categoryListProvider).value ?? const [];
    final categoryById = {for (final c in categories) c.id: c};

    final goal = activeGoals.isEmpty ? null : activeGoals.first;
    final hasNotice = unreadAlerts.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            HomeHeader(
              name: friendlyName(user?.email),
              unreadAlerts: unreadAlerts.length,
              onOpenAlerts: () => pushSlide(context, const AlertsListScreen()),
              onSignOut: () => ref.read(authControllerProvider.notifier).signOut(),
            ).entrance(context, duration: AppMotion.slow),
            const SizedBox(height: 22),
            BalanceCard(
              balance: allTimeBalance,
              monthIncome: month.income,
              monthExpense: month.expense,
              changePercent: month.changePercent,
            ).entrance(
              context,
              delay: const Duration(milliseconds: 80),
              duration: AppMotion.slow,
            ),
            if (goal != null || hasNotice) ...[
              const SizedBox(height: 12),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (goal != null)
                      Expanded(
                        child: GoalHighlightTile(
                          goal: goal,
                          onTap: () => pushSlide(context, const WishlistListScreen()),
                        ),
                      ),
                    if (goal != null && hasNotice) const SizedBox(width: 10),
                    if (hasNotice) const Expanded(child: AlertsCard()),
                  ],
                ),
              ).entrance(
                context,
                delay: const Duration(milliseconds: 160),
                duration: AppMotion.slow,
              ),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent', style: Theme.of(context).textTheme.titleMedium),
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
            Text('MANAGE', style: AppText.eyebrow(context)),
            const SizedBox(height: 4),
            _ManageRow(
              icon: Icons.category_outlined,
              label: 'Categories',
              onTap: () => pushSlide(context, const CategoryListScreen()),
            ),
            _ManageRow(
              icon: Icons.savings_outlined,
              label: 'Wishlist goals',
              onTap: () => pushSlide(context, const WishlistListScreen()),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManageRow extends StatelessWidget {
  const _ManageRow({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 2),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.divider)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.brass),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textFaint),
            ],
          ),
        ),
      ),
    );
  }
}
