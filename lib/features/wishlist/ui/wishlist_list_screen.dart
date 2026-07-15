import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_page_route.dart';
import '../../../core/utils/confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/wishlist_model.dart';
import '../providers/wishlist_provider.dart';
import 'add_edit_wishlist_screen.dart';
import 'widgets/add_contribution_dialog.dart';
import 'widgets/wishlist_tile.dart';

class WishlistListScreen extends ConsumerWidget {
  const WishlistListScreen({super.key});

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
      appBar: AppBar(title: const Text('Wishlist')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => pushSlide(context, const AddEditWishlistScreen()),
        child: const Icon(Icons.add),
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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: WishlistTile(
                  goal: goal,
                  onTap: () async {
                    final amount = await showAddContributionDialog(context, goal);
                    if (amount != null && amount > 0) {
                      await ref
                          .read(wishlistListProvider.notifier)
                          .addToCurrentAmount(goal.id, amount);
                    }
                  },
                  onEdit: () =>
                      pushSlide(context, AddEditWishlistScreen(goal: goal)),
                  onDelete: () async {
                    final confirmed = await confirmDialog(
                      context,
                      title: 'Delete goal?',
                      message: 'Delete "${goal.name}"? This cannot be undone.',
                    );
                    if (confirmed) {
                      ref.read(wishlistListProvider.notifier).deleteGoal(goal.id);
                    }
                  },
                ).animate().fadeIn(delay: (40 * index).ms, duration: 250.ms).slideX(
                      begin: 0.03,
                      end: 0,
                    ),
              );
            },
          );
        },
      ),
    );
  }
}
