import '../../../../core/database/app_database.dart';

abstract class CategoriesLocalDataSource {
  Future<List<Category>> getCategories();
  Future<int> addCategory(CategoriesCompanion category);
  Future<void> deleteCategory(int id);
}

class CategoriesLocalDataSourceImpl implements CategoriesLocalDataSource {
  final AppDatabase _db;

  CategoriesLocalDataSourceImpl(this._db);

  @override
  Future<List<Category>> getCategories() async {
    return _db.select(_db.categories).get();
  }

  @override
  Future<int> addCategory(CategoriesCompanion category) async {
    return _db.into(_db.categories).insert(category);
  }

  @override
  Future<void> deleteCategory(int id) async {
    await (_db.delete(_db.categories)..where((tbl) => tbl.id.equals(id))).go();
  }
}
