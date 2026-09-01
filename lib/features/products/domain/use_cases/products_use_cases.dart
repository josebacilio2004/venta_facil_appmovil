import '../entities/product.dart';
import '../repositories/products_repository.dart';

class GetProductsUseCase {
  final ProductsRepository repository;

  GetProductsUseCase(this.repository);

  Future<List<ProductEntity>> call({String? query, int? categoryId}) {
    return repository.getProducts(query: query, categoryId: categoryId);
  }
}

class AddProductUseCase {
  final ProductsRepository repository;

  AddProductUseCase(this.repository);

  Future<int> call(ProductEntity product) {
    return repository.addProduct(product);
  }
}

class UpdateProductUseCase {
  final ProductsRepository repository;

  UpdateProductUseCase(this.repository);

  Future<void> call(ProductEntity product) {
    return repository.updateProduct(product);
  }
}

class DeleteProductUseCase {
  final ProductsRepository repository;

  DeleteProductUseCase(this.repository);

  Future<void> call(int id) {
    return repository.deleteProduct(id);
  }
}

class UpdateProductStockUseCase {
  final ProductsRepository repository;

  UpdateProductStockUseCase(this.repository);

  Future<void> call(int productId, int newStock) {
    return repository.updateProductStock(productId, newStock);
  }
}
