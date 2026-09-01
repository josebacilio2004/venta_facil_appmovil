import '../entities/category.dart';
import '../repositories/categories_repository.dart';

class GetCategoriesUseCase {
  final CategoriesRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<List<CategoryEntity>> call() {
    return repository.getCategories();
  }
}

class AddCategoryUseCase {
  final CategoriesRepository repository;

  AddCategoryUseCase(this.repository);

  Future<int> call(CategoryEntity category) {
    return repository.addCategory(category);
  }
}

class DeleteCategoryUseCase {
  final CategoriesRepository repository;

  DeleteCategoryUseCase(this.repository);

  Future<void> call(int id) {
    return repository.deleteCategory(id);
  }
}
