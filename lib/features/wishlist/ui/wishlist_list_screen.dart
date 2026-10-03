import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/app_page_route.dart';
import '../../../core/utils/confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/entrance.dart';
import '../../../data/models/wishlist_model.dart';
import '../providers/wishlist_provider.dart';
import 'add_edit_wishlist_screen.dart';
import 'widgets/add_contribution_dialog.dart';
import 'widgets/featured_goal_card.dart';
import 'widgets/wishlist_tile.dart';

class WishlistListScreen extends ConsumerWidget {
  const WishlistListScreen({super.key});

  Future<void> _addContribution(BuildContext context, WidgetRef ref, WishlistModel goal) async {
    final amount = await showAddContributionDialog(context, goal);
    if (amount != null && amount > 0) {
      await ref.read(wishlistListProvider.notifier).addToCurrentAmount(goal.id, amount);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, WishlistModel goal) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Delete goal?',
      message: 'Delete "${goal.name}"? This cannot be undone.',
    );
    if (confirmed) {
      ref.read(wishlistListProvider.notifier).deleteGoal(goal.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(wishlistListProvider);

    ref.listen<AsyncValue<List<WishlistModel>>>(wishlistListProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$error')),
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        actions: [
          IconButton(
            tooltip: 'Add goal',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.burgundy,
              foregroundColor: AppColors.brass,
              fixedSize: const Size(44, 44),
              shape: const CircleBorder(side: BorderSide(color: AppColors.brassOutline)),
            ),
            icon: const Icon(Icons.add_rounded, size: 22),
            onPressed: () => pushSlide(context, const AddEditWishlistScreen()),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Failed to load goals: $error')),
        data: (goals) {
          if (goals.isEmpty) {
            return const EmptyState(
              icon: Icons.savings_outlined,
              message: 'No goals yet — tap + to add one',
            );
          }

          // The first goal still in progress is featured; the rest follow.
          final featured = goals.where((g) => !g.isCompleted).firstOrNull;
          final others = goals.where((g) => g.id != featured?.id).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              if (featured != null)
                FeaturedGoalCard(
                  key: ValueKey(featured.id),
                  goal: featured,
                  onAddContribution: () => _addContribution(context, ref, featured),
                  onEdit: () => pushSlide(context, AddEditWishlistScreen(goal: featured)),
                  onDelete: () => _delete(context, ref, featured),
                ).entrance(context, duration: const Duration(milliseconds: 400)),
              if (others.isNotEmpty) ...[
                SizedBox(height: featured != null ? 22 : 0),
                if (featured != null) Text('OTHER GOALS', style: AppText.eyebrow(context)),
                if (featured != null) const SizedBox(height: 10),
                for (final (index, goal) in others.indexed)
                  Padding(
                    key: ValueKey(goal.id),
                    padding: const EdgeInsets.only(bottom: 10),
                    child: WishlistTile(
                      goal: goal,
                      onTap: () => _addContribution(context, ref, goal),
                      onEdit: () => pushSlide(context, AddEditWishlistScreen(goal: goal)),
                      onDelete: () => _delete(context, ref, goal),
                    ).entrance(context, index: index, axis: Axis.horizontal),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
