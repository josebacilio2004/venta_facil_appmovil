import 'package:drift/drift.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/categories_repository.dart';
import '../datasources/categories_local_datasource.dart';
import '../../../../core/database/app_database.dart' as db;

class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoriesLocalDataSource _localDataSource;

  CategoriesRepositoryImpl(this._localDataSource);

  @override
  Future<List<CategoryEntity>> getCategories() async {
    final list = await _localDataSource.getCategories();
    return list.map(_mapToEntity).toList();
  }

  @override
  Future<int> addCategory(CategoryEntity category) async {
    final companion = _mapToCompanion(category);
    return _localDataSource.addCategory(companion);
  }

  @override
  Future<void> deleteCategory(int id) async {
    await _localDataSource.deleteCategory(id);
  }

  CategoryEntity _mapToEntity(db.Category category) {
    return CategoryEntity(
      id: category.id,
      name: category.name,
      description: category.description,
    );
  }

  db.CategoriesCompanion _mapToCompanion(CategoryEntity category) {
    return db.CategoriesCompanion(
      id: category.id == 0 ? const Value.absent() : Value(category.id),
      name: Value(category.name),
      description: Value(category.description),
    );
  }
}
