import 'package:drift/drift.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_local_datasource.dart';
import '../../../../core/database/app_database.dart' as db;

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsLocalDataSource _localDataSource;

  ProductsRepositoryImpl(this._localDataSource);

  @override
  Future<List<ProductEntity>> getProducts({String? query, int? categoryId}) async {
    final list = await _localDataSource.getProducts(query: query, categoryId: categoryId);
    return list.map(_mapToEntity).toList();
  }

  @override
  Future<ProductEntity?> getProductById(int id) async {
    final product = await _localDataSource.getProductById(id);
    if (product == null) return null;
    return _mapToEntity(product);
  }

  @override
  Future<int> addProduct(ProductEntity product) async {
    final companion = _mapToCompanion(product);
    return _localDataSource.addProduct(companion);
  }

  @override
  Future<void> updateProduct(ProductEntity product) async {
    final companion = _mapToCompanion(product);
    await _localDataSource.updateProduct(companion);
  }

  @override
  Future<void> deleteProduct(int id) async {
    await _localDataSource.deleteProduct(id);
  }

  @override
  Future<void> updateProductStock(int productId, int newStock) async {
    await _localDataSource.updateProductStock(productId, newStock);
  }

  ProductEntity _mapToEntity(db.Product product) {
    return ProductEntity(
      id: product.id,
      categoryId: product.categoryId,
      name: product.name,
      description: product.description,
      purchasePrice: product.purchasePrice,
      sellingPrice: product.sellingPrice,
      stock: product.stock,
      minStock: product.minStock,
      sku: product.sku,
      isActive: product.isActive,
      createdAt: product.createdAt,
    );
  }

  db.ProductsCompanion _mapToCompanion(ProductEntity product) {
    return db.ProductsCompanion(
      id: product.id == 0 ? const Value.absent() : Value(product.id),
      categoryId: Value(product.categoryId),
      name: Value(product.name),
      description: Value(product.description),
      purchasePrice: Value(product.purchasePrice),
      sellingPrice: Value(product.sellingPrice),
      stock: Value(product.stock),
      minStock: Value(product.minStock),
      sku: Value(product.sku),
      isActive: Value(product.isActive),
      createdAt: Value(product.createdAt),
    );
  }
}
