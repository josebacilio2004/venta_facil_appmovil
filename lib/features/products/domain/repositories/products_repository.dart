import '../entities/product.dart';

abstract class ProductsRepository {
  Future<List<ProductEntity>> getProducts({String? query, int? categoryId});
  Future<ProductEntity?> getProductById(int id);
  Future<int> addProduct(ProductEntity product);
  Future<void> updateProduct(ProductEntity product);
  Future<void> deleteProduct(int id);
  Future<void> updateProductStock(int productId, int newStock);
}
