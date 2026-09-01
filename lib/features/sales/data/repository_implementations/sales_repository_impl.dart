import 'package:drift/drift.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_item.dart';
import '../../domain/repositories/sales_repository.dart';
import '../datasources/sales_local_datasource.dart';
import '../../../../core/database/app_database.dart' as db;

class SalesRepositoryImpl implements SalesRepository {
  final SalesLocalDataSource _localDataSource;
  final db.AppDatabase _database;

  SalesRepositoryImpl(this._localDataSource, this._database);

  @override
  Future<List<SaleEntity>> getSales({DateTime? startDate, DateTime? endDate}) async {
    final list = await _localDataSource.getSales(startDate: startDate, endDate: endDate);
    final entities = <SaleEntity>[];
    for (final sale in list) {
      String? customerName;
      final customerId = sale.customerId;
      if (customerId != null) {
        final cust = await (_database.select(_database.customers)..where((tbl) => tbl.id.equals(customerId))).getSingleOrNull();
        customerName = cust?.name;
      }
      entities.add(_mapToEntity(sale, customerName));
    }
    return entities;
  }

  @override
  Future<List<SaleItemEntity>> getSaleItems(int saleId) async {
    final list = await _localDataSource.getSaleItems(saleId);
    final entities = <SaleItemEntity>[];
    for (final item in list) {
      final product = await (_database.select(_database.products)..where((tbl) => tbl.id.equals(item.productId))).getSingleOrNull();
      final productName = product?.name ?? 'Producto Eliminado';
      entities.add(_mapItemToEntity(item, productName));
    }
    return entities;
  }

  @override
  Future<int> addSale(SaleEntity sale, List<SaleItemEntity> items) async {
    final saleCompanion = _mapToCompanion(sale);
    final itemCompanions = items.map(_mapItemToCompanion).toList();
    return _localDataSource.addSale(saleCompanion, itemCompanions);
  }

  SaleEntity _mapToEntity(db.Sale sale, String? customerName) {
    return SaleEntity(
      id: sale.id,
      customerId: sale.customerId,
      customerName: customerName,
      total: sale.total,
      discount: sale.discount,
      paymentMethod: sale.paymentMethod,
      date: sale.date,
      createdAt: sale.createdAt,
    );
  }

  SaleItemEntity _mapItemToEntity(db.SaleItem item, String productName) {
    return SaleItemEntity(
      id: item.id,
      saleId: item.saleId,
      productId: item.productId,
      productName: productName,
      quantity: item.quantity,
      unitPurchasePrice: item.unitPurchasePrice,
      unitSellingPrice: item.unitSellingPrice,
      subtotal: item.subtotal,
    );
  }

  db.SalesCompanion _mapToCompanion(SaleEntity sale) {
    return db.SalesCompanion(
      id: sale.id == 0 ? const Value.absent() : Value(sale.id),
      customerId: Value(sale.customerId),
      total: Value(sale.total),
      discount: Value(sale.discount),
      paymentMethod: Value(sale.paymentMethod),
      date: Value(sale.date),
      createdAt: Value(sale.createdAt),
    );
  }

  db.SaleItemsCompanion _mapItemToCompanion(SaleItemEntity item) {
    return db.SaleItemsCompanion(
      id: item.id == 0 ? const Value.absent() : Value(item.id),
      saleId: Value(item.saleId),
      productId: Value(item.productId),
      quantity: Value(item.quantity),
      unitPurchasePrice: Value(item.unitPurchasePrice),
      unitSellingPrice: Value(item.unitSellingPrice),
      subtotal: Value(item.subtotal),
    );
  }
}
