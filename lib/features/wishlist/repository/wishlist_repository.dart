import 'package:hive/hive.dart';

import '../../../data/models/wishlist_model.dart';

class WishlistRepository {
  WishlistRepository(this._box);

  final Box<Map> _box;

  List<WishlistModel> getAll() {
    return _box.values
        .map((raw) => WishlistModel.fromJson(Map<String, dynamic>.from(raw)))
        .where((goal) => !goal.isDeleted)
        .toList()
      ..sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        if (a.deadline == null && b.deadline == null) {
          return a.createdAt.compareTo(b.createdAt);
        }
        if (a.deadline == null) return 1;
        if (b.deadline == null) return -1;
        return a.deadline!.compareTo(b.deadline!);
      });
  }

  Future<void> save(WishlistModel goal) async {
    await _box.put(goal.id, goal.toJson());
  }

  Future<void> softDelete(String id) async {
    final raw = _box.get(id);
    if (raw == null) return;
    final goal = WishlistModel.fromJson(Map<String, dynamic>.from(raw));
    await save(
      goal.copyWith(
        isDeleted: true,
        updatedAt: DateTime.now(),
        isSynced: false,
      ),
    );
  }
}
