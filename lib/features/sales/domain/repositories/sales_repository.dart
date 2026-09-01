import '../entities/sale.dart';
import '../entities/sale_item.dart';

abstract class SalesRepository {
  Future<List<SaleEntity>> getSales({DateTime? startDate, DateTime? endDate});
  Future<List<SaleItemEntity>> getSaleItems(int saleId);
  Future<int> addSale(SaleEntity sale, List<SaleItemEntity> items);
  Future<void> deleteSale(int saleId);
}
