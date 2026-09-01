import '../entities/customer.dart';
import '../repositories/customers_repository.dart';

class GetCustomersUseCase {
  final CustomersRepository repository;

  GetCustomersUseCase(this.repository);

  Future<List<CustomerEntity>> call({String? query}) {
    return repository.getCustomers(query: query);
  }
}

class AddCustomerUseCase {
  final CustomersRepository repository;

  AddCustomerUseCase(this.repository);

  Future<int> call(CustomerEntity customer) {
    return repository.addCustomer(customer);
  }
}

class UpdateCustomerUseCase {
  final CustomersRepository repository;

  UpdateCustomerUseCase(this.repository);

  Future<void> call(CustomerEntity customer) {
    return repository.updateCustomer(customer);
  }
}

class DeleteCustomerUseCase {
  final CustomersRepository repository;

  DeleteCustomerUseCase(this.repository);

  Future<void> call(int id) {
    return repository.deleteCustomer(id);
  }
}
