import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/hive_constants.dart';
import '../../../core/notifications/notification_provider.dart';
import '../../../data/models/wishlist_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../repository/wishlist_repository.dart';

part 'wishlist_provider.g.dart';

@riverpod
Box<Map> wishlistBox(Ref ref) => Hive.box<Map>(HiveConstants.wishlistBox);

@riverpod
WishlistRepository wishlistRepository(Ref ref) {
  return WishlistRepository(ref.watch(wishlistBoxProvider));
}

@riverpod
class WishlistList extends _$WishlistList {
  @override
  Future<List<WishlistModel>> build() async {
    return ref.watch(wishlistRepositoryProvider).getAll();
  }

  Future<void> addGoal({
    required String name,
    required double targetAmount,
    DateTime? deadline,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(wishlistRepositoryProvider);
      final userId = ref.read(currentUserProvider)?.id;
      if (userId == null) throw StateError('No authenticated user');

      final now = DateTime.now();
      await repository.save(
        WishlistModel(
          id: const Uuid().v4(),
          userId: userId,
          name: name,
          targetAmount: targetAmount,
          deadline: deadline,
          createdAt: now,
          updatedAt: now,
          isSynced: false,
        ),
      );
      return repository.getAll();
    });
  }

  Future<void> updateGoal(WishlistModel goal) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(wishlistRepositoryProvider);
      await repository.save(
        goal.copyWith(updatedAt: DateTime.now(), isSynced: false),
      );
      return repository.getAll();
    });
  }

  /// Adds [amount] as a contribution toward the goal's current_amount.
  /// Fires a completion notification exactly once, the first time the goal
  /// crosses its target.
  Future<void> addToCurrentAmount(String id, double amount) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(wishlistRepositoryProvider);
      final existing = repository.getAll().firstWhere((g) => g.id == id);

      final newAmount = existing.currentAmount + amount;
      final wasCompleted = existing.currentAmount >= existing.targetAmount;
      final isNowCompleted = newAmount >= existing.targetAmount;

      final updated = existing.copyWith(
        currentAmount: newAmount,
        updatedAt: DateTime.now(),
        isSynced: false,
        notifiedCompleted: existing.notifiedCompleted || isNowCompleted,
      );
      await repository.save(updated);

      if (!wasCompleted && isNowCompleted && !existing.notifiedCompleted) {
        await ref.read(notificationServiceProvider).showGoalCompleted(updated);
      }
      return repository.getAll();
    });
  }

  Future<void> deleteGoal(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(wishlistRepositoryProvider);
      await repository.softDelete(id);
      return repository.getAll();
    });
  }
}

@riverpod
List<WishlistModel> activeWishlistGoals(Ref ref) {
  final goals = ref.watch(wishlistListProvider).value ?? const [];
  return goals.where((g) => !g.isCompleted).toList();
}
