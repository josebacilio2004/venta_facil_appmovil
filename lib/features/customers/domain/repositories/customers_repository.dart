import '../entities/customer.dart';

abstract class CustomersRepository {
  Future<List<CustomerEntity>> getCustomers({String? query});
  Future<CustomerEntity?> getCustomerById(int id);
  Future<int> addCustomer(CustomerEntity customer);
  Future<void> updateCustomer(CustomerEntity customer);
  Future<void> deleteCustomer(int id);
}
