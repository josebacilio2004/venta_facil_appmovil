import '../entities/category.dart';

abstract class CategoriesRepository {
  Future<List<CategoryEntity>> getCategories();
  Future<int> addCategory(CategoryEntity category);
  Future<void> deleteCategory(int id);
}
