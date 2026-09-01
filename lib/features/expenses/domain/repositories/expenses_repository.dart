import '../entities/expense.dart';

abstract class ExpensesRepository {
  Future<List<ExpenseEntity>> getExpenses({String? category, DateTime? startDate, DateTime? endDate});
  Future<int> addExpense(ExpenseEntity expense);
  Future<void> deleteExpense(int id);
}
