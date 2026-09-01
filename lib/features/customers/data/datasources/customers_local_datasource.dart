import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';

abstract class CustomersLocalDataSource {
  Future<List<Customer>> getCustomers({String? query});
  Future<Customer?> getCustomerById(int id);
  Future<int> addCustomer(CustomersCompanion customer);
  Future<void> updateCustomer(CustomersCompanion customer);
  Future<void> deleteCustomer(int id);
}

class CustomersLocalDataSourceImpl implements CustomersLocalDataSource {
  final AppDatabase _db;

  CustomersLocalDataSourceImpl(this._db);

  @override
  Future<List<Customer>> getCustomers({String? query}) async {
    final statement = _db.select(_db.customers);
    if (query != null && query.isNotEmpty) {
      statement.where((tbl) => tbl.name.like('%$query%') | tbl.phone.like('%$query%'));
    }
    return statement.get();
  }

  @override
  Future<Customer?> getCustomerById(int id) async {
    return (_db.select(_db.customers)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  @override
  Future<int> addCustomer(CustomersCompanion customer) async {
    return _db.into(_db.customers).insert(customer);
  }

  @override
  Future<void> updateCustomer(CustomersCompanion customer) async {
    await _db.update(_db.customers).replace(customer);
  }

  @override
  Future<void> deleteCustomer(int id) async {
    await (_db.delete(_db.customers)..where((tbl) => tbl.id.equals(id))).go();
  }
}
