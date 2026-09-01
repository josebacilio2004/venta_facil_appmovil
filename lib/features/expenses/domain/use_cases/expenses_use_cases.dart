import '../entities/expense.dart';
import '../repositories/expenses_repository.dart';

class GetExpensesUseCase {
  final ExpensesRepository repository;

  GetExpensesUseCase(this.repository);

  Future<List<ExpenseEntity>> call({String? category, DateTime? startDate, DateTime? endDate}) {
    return repository.getExpenses(category: category, startDate: startDate, endDate: endDate);
  }
}

class AddExpenseUseCase {
  final ExpensesRepository repository;

  AddExpenseUseCase(this.repository);

  Future<int> call(ExpenseEntity expense) {
    return repository.addExpense(expense);
  }
}

class DeleteExpenseUseCase {
  final ExpensesRepository repository;

  DeleteExpenseUseCase(this.repository);

  Future<void> call(int id) {
    return repository.deleteExpense(id);
  }
}
