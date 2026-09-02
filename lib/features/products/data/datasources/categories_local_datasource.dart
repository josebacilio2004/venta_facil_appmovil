import '../../../../core/database/app_database.dart';

abstract class CategoriesLocalDataSource {
  Future<List<Category>> getCategories();
  Future<int> addCategory(CategoriesCompanion category);
  Future<void> deleteCategory(int id);
}

class CategoriesLocalDataSourceImpl implements CategoriesLocalDataSource {
  final AppDatabase _db;

  CategoriesLocalDataSourceImpl(this._db);

  static const List<String> defaultCategoryList = [
    'Abarrotes',
    'Bebidas y Licores',
    'Frutas y Verduras',
    'Carnes y Embutidos',
    'Lácteos y Huevos',
    'Panadería y Pastelería',
    'Cuidado Personal y Belleza',
    'Limpieza y Hogar',
    'Farmacia y Salud',
    'Golosinas y Snacks',
    'Ropa y Calzado',
    'Ferretería y Herramientas',
    'Tecnología y Accesorios',
    'Mascotas',
    'Otros',
  ];

  @override
  Future<List<Category>> getCategories() async {
    final current = await _db.select(_db.categories).get();
    if (current.length < defaultCategoryList.length) {
      final existingNames = current.map((c) => c.name.toLowerCase()).toSet();
      for (final cat in defaultCategoryList) {
        if (!existingNames.contains(cat.toLowerCase())) {
          await _db.into(_db.categories).insert(CategoriesCompanion.insert(name: cat));
        }
      }
      return _db.select(_db.categories).get();
    }
    return current;
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
