import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/datasources/products_local_datasource.dart';
import '../../data/datasources/categories_local_datasource.dart';
import '../../data/repository_implementations/products_repository_impl.dart';
import '../../data/repository_implementations/categories_repository_impl.dart';
import '../../domain/repositories/products_repository.dart';
import '../../domain/repositories/categories_repository.dart';
import '../../domain/use_cases/products_use_cases.dart';
import '../../domain/use_cases/categories_use_cases.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';

// Datasources
final productsLocalDataSourceProvider = Provider<ProductsLocalDataSource>((ref) {
  final db = ref.watch(databaseProvider);
  return ProductsLocalDataSourceImpl(db);
});

final categoriesLocalDataSourceProvider = Provider<CategoriesLocalDataSource>((ref) {
  final db = ref.watch(databaseProvider);
  return CategoriesLocalDataSourceImpl(db);
});

// Repositories
final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  final localDS = ref.watch(productsLocalDataSourceProvider);
  return ProductsRepositoryImpl(localDS);
});

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  final localDS = ref.watch(categoriesLocalDataSourceProvider);
  return CategoriesRepositoryImpl(localDS);
});

// Use Cases
final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
  return GetProductsUseCase(ref.watch(productsRepositoryProvider));
});

final addProductUseCaseProvider = Provider<AddProductUseCase>((ref) {
  return AddProductUseCase(ref.watch(productsRepositoryProvider));
});

final updateProductUseCaseProvider = Provider<UpdateProductUseCase>((ref) {
  return UpdateProductUseCase(ref.watch(productsRepositoryProvider));
});

final deleteProductUseCaseProvider = Provider<DeleteProductUseCase>((ref) {
  return DeleteProductUseCase(ref.watch(productsRepositoryProvider));
});

final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  return GetCategoriesUseCase(ref.watch(categoriesRepositoryProvider));
});

final addCategoryUseCaseProvider = Provider<AddCategoryUseCase>((ref) {
  return AddCategoryUseCase(ref.watch(categoriesRepositoryProvider));
});

final deleteCategoryUseCaseProvider = Provider<DeleteCategoryUseCase>((ref) {
  return DeleteCategoryUseCase(ref.watch(categoriesRepositoryProvider));
});

// Categories Notifier
class CategoriesListNotifier extends AsyncNotifier<List<CategoryEntity>> {
  @override
  Future<List<CategoryEntity>> build() async {
    return ref.watch(getCategoriesUseCaseProvider).call();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return ref.read(getCategoriesUseCaseProvider).call();
    });
  }

  Future<void> addCategory(String name) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(addCategoryUseCaseProvider).call(CategoryEntity(id: 0, name: name));
      return ref.read(getCategoriesUseCaseProvider).call();
    });
  }

  Future<void> deleteCategory(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteCategoryUseCaseProvider).call(id);
      return ref.read(getCategoriesUseCaseProvider).call();
    });
  }
}

final categoriesListProvider = AsyncNotifierProvider<CategoriesListNotifier, List<CategoryEntity>>(() {
  return CategoriesListNotifier();
});

// Products Filter
class ProductsFilter {
  final String query;
  final int? categoryId;
  final bool? onlyLowStock;

  const ProductsFilter({this.query = '', this.categoryId, this.onlyLowStock});

  ProductsFilter copyWith({String? query, int? categoryId, bool clearCategory = false, bool? onlyLowStock}) {
    return ProductsFilter(
      query: query ?? this.query,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      onlyLowStock: onlyLowStock ?? this.onlyLowStock,
    );
  }
}

final productsFilterProvider = StateProvider<ProductsFilter>((ref) => const ProductsFilter());

// Products Notifier
class ProductsListNotifier extends AsyncNotifier<List<ProductEntity>> {
  @override
  Future<List<ProductEntity>> build() async {
    final filter = ref.watch(productsFilterProvider);
    final list = await ref.watch(getProductsUseCaseProvider).call(
      query: filter.query,
      categoryId: filter.categoryId,
    );
    if (filter.onlyLowStock == true) {
      return list.where((p) => p.isLowStock).toList();
    }
    return list;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final filter = ref.read(productsFilterProvider);
      final list = await ref.read(getProductsUseCaseProvider).call(
        query: filter.query,
        categoryId: filter.categoryId,
      );
      if (filter.onlyLowStock == true) {
        return list.where((p) => p.isLowStock).toList();
      }
      return list;
    });
  }

  Future<void> addProduct(ProductEntity product) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(addProductUseCaseProvider).call(product);
      final filter = ref.read(productsFilterProvider);
      final list = await ref.read(getProductsUseCaseProvider).call(
        query: filter.query,
        categoryId: filter.categoryId,
      );
      if (filter.onlyLowStock == true) {
        return list.where((p) => p.isLowStock).toList();
      }
      return list;
    });
  }

  Future<void> updateProduct(ProductEntity product) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(updateProductUseCaseProvider).call(product);
      final filter = ref.read(productsFilterProvider);
      final list = await ref.read(getProductsUseCaseProvider).call(
        query: filter.query,
        categoryId: filter.categoryId,
      );
      if (filter.onlyLowStock == true) {
        return list.where((p) => p.isLowStock).toList();
      }
      return list;
    });
  }

  Future<void> deleteProduct(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteProductUseCaseProvider).call(id);
      final filter = ref.read(productsFilterProvider);
      final list = await ref.read(getProductsUseCaseProvider).call(
        query: filter.query,
        categoryId: filter.categoryId,
      );
      if (filter.onlyLowStock == true) {
        return list.where((p) => p.isLowStock).toList();
      }
      return list;
    });
  }
}

final productsListProvider = AsyncNotifierProvider<ProductsListNotifier, List<ProductEntity>>(() {
  return ProductsListNotifier();
});
