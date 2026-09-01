import 'package:drift/drift.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customers_repository.dart';
import '../datasources/customers_local_datasource.dart';
import '../../../../core/database/app_database.dart' as db;

class CustomersRepositoryImpl implements CustomersRepository {
  final CustomersLocalDataSource _localDataSource;

  CustomersRepositoryImpl(this._localDataSource);

  @override
  Future<List<CustomerEntity>> getCustomers({String? query}) async {
    final list = await _localDataSource.getCustomers(query: query);
    return list.map(_mapToEntity).toList();
  }

  @override
  Future<CustomerEntity?> getCustomerById(int id) async {
    final customer = await _localDataSource.getCustomerById(id);
    if (customer == null) return null;
    return _mapToEntity(customer);
  }

  @override
  Future<int> addCustomer(CustomerEntity customer) async {
    final companion = _mapToCompanion(customer);
    return _localDataSource.addCustomer(companion);
  }

  @override
  Future<void> updateCustomer(CustomerEntity customer) async {
    final companion = _mapToCompanion(customer);
    await _localDataSource.updateCustomer(companion);
  }

  @override
  Future<void> deleteCustomer(int id) async {
    await _localDataSource.deleteCustomer(id);
  }

  CustomerEntity _mapToEntity(db.Customer customer) {
    return CustomerEntity(
      id: customer.id,
      name: customer.name,
      phone: customer.phone,
      email: customer.email,
      notes: customer.notes,
      createdAt: customer.createdAt,
    );
  }

  db.CustomersCompanion _mapToCompanion(CustomerEntity customer) {
    return db.CustomersCompanion(
      id: customer.id == 0 ? const Value.absent() : Value(customer.id),
      name: Value(customer.name),
      phone: Value(customer.phone),
      email: Value(customer.email),
      notes: Value(customer.notes),
      createdAt: Value(customer.createdAt),
    );
  }
}
