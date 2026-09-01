import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/datasources/customers_local_datasource.dart';
import '../../data/repository_implementations/customers_repository_impl.dart';
import '../../domain/repositories/customers_repository.dart';
import '../../domain/use_cases/customers_use_cases.dart';
import '../../domain/entities/customer.dart';

// Datasource
final customersLocalDataSourceProvider = Provider<CustomersLocalDataSource>((ref) {
  final db = ref.watch(databaseProvider);
  return CustomersLocalDataSourceImpl(db);
});

// Repository
final customersRepositoryProvider = Provider<CustomersRepository>((ref) {
  final localDS = ref.watch(customersLocalDataSourceProvider);
  return CustomersRepositoryImpl(localDS);
});

// Use Cases
final getCustomersUseCaseProvider = Provider<GetCustomersUseCase>((ref) {
  return GetCustomersUseCase(ref.watch(customersRepositoryProvider));
});

final addCustomerUseCaseProvider = Provider<AddCustomerUseCase>((ref) {
  return AddCustomerUseCase(ref.watch(customersRepositoryProvider));
});

final updateCustomerUseCaseProvider = Provider<UpdateCustomerUseCase>((ref) {
  return UpdateCustomerUseCase(ref.watch(customersRepositoryProvider));
});

final deleteCustomerUseCaseProvider = Provider<DeleteCustomerUseCase>((ref) {
  return DeleteCustomerUseCase(ref.watch(customersRepositoryProvider));
});

// Filter
final customersSearchQueryProvider = StateProvider<String>((ref) => '');

// Notifier / Controller
class CustomersListNotifier extends AsyncNotifier<List<CustomerEntity>> {
  @override
  Future<List<CustomerEntity>> build() async {
    final query = ref.watch(customersSearchQueryProvider);
    return ref.watch(getCustomersUseCaseProvider).call(query: query);
  }

  Future<void> addCustomer(CustomerEntity customer) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(addCustomerUseCaseProvider).call(customer);
      final query = ref.read(customersSearchQueryProvider);
      return ref.read(getCustomersUseCaseProvider).call(query: query);
    });
  }

  Future<void> updateCustomer(CustomerEntity customer) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(updateCustomerUseCaseProvider).call(customer);
      final query = ref.read(customersSearchQueryProvider);
      return ref.read(getCustomersUseCaseProvider).call(query: query);
    });
  }

  Future<void> deleteCustomer(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteCustomerUseCaseProvider).call(id);
      final query = ref.read(customersSearchQueryProvider);
      return ref.read(getCustomersUseCaseProvider).call(query: query);
    });
  }
}

final customersListProvider = AsyncNotifierProvider<CustomersListNotifier, List<CustomerEntity>>(() {
  return CustomersListNotifier();
});
