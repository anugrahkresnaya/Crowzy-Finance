import 'package:hive/hive.dart';

import '../../../data/models/category_model.dart';

class CategoryRepository {
  CategoryRepository(this._box);

  final Box<Map> _box;

  List<CategoryModel> getAll() {
    return _box.values
        .map((raw) => CategoryModel.fromJson(Map<String, dynamic>.from(raw)))
        .where((category) => !category.isDeleted)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> save(CategoryModel category) async {
    await _box.put(category.id, category.toJson());
  }

  Future<void> softDelete(String id) async {
    final raw = _box.get(id);
    if (raw == null) return;
    final category = CategoryModel.fromJson(Map<String, dynamic>.from(raw));
    await save(
      category.copyWith(
        isDeleted: true,
        updatedAt: DateTime.now(),
        isSynced: false,
      ),
    );
  }
}
