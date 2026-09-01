import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/datasources/expenses_local_datasource.dart';
import '../../data/repository_implementations/expenses_repository_impl.dart';
import '../../domain/repositories/expenses_repository.dart';
import '../../domain/use_cases/expenses_use_cases.dart';
import '../../domain/entities/expense.dart';

// Datasource
final expensesLocalDataSourceProvider = Provider<ExpensesLocalDataSource>((ref) {
  return ExpensesLocalDataSourceImpl(ref.watch(databaseProvider));
});

// Repository
final expensesRepositoryProvider = Provider<ExpensesRepository>((ref) {
  return ExpensesRepositoryImpl(ref.watch(expensesLocalDataSourceProvider));
});

// Use Cases
final getExpensesUseCaseProvider = Provider<GetExpensesUseCase>((ref) {
  return GetExpensesUseCase(ref.watch(expensesRepositoryProvider));
});

final addExpenseUseCaseProvider = Provider<AddExpenseUseCase>((ref) {
  return AddExpenseUseCase(ref.watch(expensesRepositoryProvider));
});

final deleteExpenseUseCaseProvider = Provider<DeleteExpenseUseCase>((ref) {
  return DeleteExpenseUseCase(ref.watch(expensesRepositoryProvider));
});

// Filtros de Gastos
class ExpensesFilter {
  final String? category;
  final DateTime? startDate;
  final DateTime? endDate;

  const ExpensesFilter({this.category, this.startDate, this.endDate});

  ExpensesFilter copyWith({
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    bool clearCategory = false,
    bool clearDates = false,
  }) {
    return ExpensesFilter(
      category: clearCategory ? null : (category ?? this.category),
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
    );
  }
}

final expensesFilterProvider = StateProvider<ExpensesFilter>((ref) => const ExpensesFilter());

// Notifier / Controller
class ExpensesListNotifier extends AsyncNotifier<List<ExpenseEntity>> {
  @override
  Future<List<ExpenseEntity>> build() async {
    final filter = ref.watch(expensesFilterProvider);
    return ref.watch(getExpensesUseCaseProvider).call(
      category: filter.category,
      startDate: filter.startDate,
      endDate: filter.endDate,
    );
  }

  Future<void> addExpense(ExpenseEntity expense) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(addExpenseUseCaseProvider).call(expense);
      final filter = ref.read(expensesFilterProvider);
      return ref.read(getExpensesUseCaseProvider).call(
        category: filter.category,
        startDate: filter.startDate,
        endDate: filter.endDate,
      );
    });
  }

  Future<void> deleteExpense(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(deleteExpenseUseCaseProvider).call(id);
      final filter = ref.read(expensesFilterProvider);
      return ref.read(getExpensesUseCaseProvider).call(
        category: filter.category,
        startDate: filter.startDate,
        endDate: filter.endDate,
      );
    });
  }
}

final expensesListProvider = AsyncNotifierProvider<ExpensesListNotifier, List<ExpenseEntity>>(() {
  return ExpensesListNotifier();
});
