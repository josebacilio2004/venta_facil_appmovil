import '../entities/sale.dart';
import '../entities/sale_item.dart';
import '../repositories/sales_repository.dart';

class RegisterSaleUseCase {
  final SalesRepository repository;

  RegisterSaleUseCase(this.repository);

  Future<int> call(SaleEntity sale, List<SaleItemEntity> items) {
    return repository.addSale(sale, items);
  }
}

class GetSalesUseCase {
  final SalesRepository repository;

  GetSalesUseCase(this.repository);

  Future<List<SaleEntity>> call({DateTime? startDate, DateTime? endDate}) {
    return repository.getSales(startDate: startDate, endDate: endDate);
  }
}

class GetSaleItemsUseCase {
  final SalesRepository repository;

  GetSaleItemsUseCase(this.repository);

  Future<List<SaleItemEntity>> call(int saleId) {
    return repository.getSaleItems(saleId);
  }
}
