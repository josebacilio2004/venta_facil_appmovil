import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';

abstract class ProductsLocalDataSource {
  Future<List<Product>> getProducts({String? query, int? categoryId});
  Future<Product?> getProductById(int id);
  Future<int> addProduct(ProductsCompanion product);
  Future<void> updateProduct(ProductsCompanion product);
  Future<void> deleteProduct(int id);
  Future<void> updateProductStock(int productId, int newStock);
}

class ProductsLocalDataSourceImpl implements ProductsLocalDataSource {
  final AppDatabase _db;

  ProductsLocalDataSourceImpl(this._db);

  @override
  Future<List<Product>> getProducts({String? query, int? categoryId}) async {
    final statement = _db.select(_db.products);
    if (query != null && query.isNotEmpty) {
      statement.where((tbl) => tbl.name.like('%$query%') | tbl.sku.like('%$query%'));
    }
    if (categoryId != null) {
      statement.where((tbl) => tbl.categoryId.equals(categoryId));
    }
    return statement.get();
  }

  @override
  Future<Product?> getProductById(int id) async {
    return (_db.select(_db.products)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  @override
  Future<int> addProduct(ProductsCompanion product) async {
    return _db.into(_db.products).insert(product);
  }

  @override
  Future<void> updateProduct(ProductsCompanion product) async {
    await _db.update(_db.products).replace(product);
  }

  @override
  Future<void> deleteProduct(int id) async {
    await (_db.delete(_db.products)..where((tbl) => tbl.id.equals(id))).go();
  }

  @override
  Future<void> updateProductStock(int productId, int newStock) async {
    await (_db.update(_db.products)
          ..where((tbl) => tbl.id.equals(productId)))
        .write(ProductsCompanion(stock: Value(newStock)));
  }
}
