import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';

abstract class SalesLocalDataSource {
  Future<List<Sale>> getSales({DateTime? startDate, DateTime? endDate});
  Future<List<SaleItem>> getSaleItems(int saleId);
  Future<int> addSale(SalesCompanion sale, List<SaleItemsCompanion> items);
}

class SalesLocalDataSourceImpl implements SalesLocalDataSource {
  final AppDatabase _db;

  SalesLocalDataSourceImpl(this._db);

  @override
  Future<List<Sale>> getSales({DateTime? startDate, DateTime? endDate}) async {
    final statement = _db.select(_db.sales);
    if (startDate != null) {
      statement.where((tbl) => tbl.date.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      statement.where((tbl) => tbl.date.isSmallerOrEqualValue(endDate));
    }
    // Ordenar de más reciente a más antiguo
    statement.orderBy([(tbl) => OrderingTerm(expression: tbl.date, mode: OrderingMode.desc)]);
    return statement.get();
  }

  @override
  Future<List<SaleItem>> getSaleItems(int saleId) async {
    return (_db.select(_db.saleItems)..where((tbl) => tbl.saleId.equals(saleId))).get();
  }

  @override
  Future<int> addSale(SalesCompanion sale, List<SaleItemsCompanion> items) async {
    return _db.transaction(() async {
      // 1. Guardar la Venta
      final saleId = await _db.into(_db.sales).insert(sale);

      for (final item in items) {
        // 2. Guardar los Items de Venta
        final updatedItem = item.copyWith(saleId: Value(saleId));
        await _db.into(_db.saleItems).insert(updatedItem);

        // 3. Disminuir el stock en el inventario
        final productId = item.productId.value;
        final qty = item.quantity.value;
        
        final product = await (_db.select(_db.products)..where((tbl) => tbl.id.equals(productId))).getSingle();
        final newStock = product.stock - qty;
        
        await (_db.update(_db.products)..where((tbl) => tbl.id.equals(productId)))
            .write(ProductsCompanion(stock: Value(newStock)));
      }

      return saleId;
    });
  }
}
