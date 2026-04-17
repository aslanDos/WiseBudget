import 'package:wisebuget/features/category/data/data_source/category_local_datasource.dart';
import 'package:wisebuget/features/category/data/model/category_model.dart';
import 'package:wisebuget/objectbox.g.dart';

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final Store _store;

  CategoryLocalDataSourceImpl(this._store);

  Box<CategoryModel> get _box => _store.box<CategoryModel>();

  @override
  Future<List<CategoryModel>> getCategories() async {
    final query = _box.query()..order(CategoryModel_.sortOrder);
    return query.build().find();
  }

  @override
  Future<CategoryModel?> getCategoryByUuid(String uuid) async {
    final query = _box.query(CategoryModel_.uuid.equals(uuid)).build();
    return query.findFirst();
  }

  @override
  Future<CategoryModel> createCategory(CategoryModel category) async {
    _box.put(category);
    return category;
  }

  @override
  Future<CategoryModel> updateCategory(CategoryModel category) async {
    final existing = await getCategoryByUuid(category.uuid);
    if (existing != null) {
      category.id = existing.id;
    }
    _box.put(category);
    return category;
  }

  @override
  Future<void> deleteCategory(String uuid) async {
    final query = _box.query(CategoryModel_.uuid.equals(uuid)).build();
    final category = query.findFirst();
    if (category != null) {
      _box.remove(category.id);
    }
  }
}
