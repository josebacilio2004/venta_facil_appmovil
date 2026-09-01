import 'package:drift/drift.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expenses_repository.dart';
import '../datasources/expenses_local_datasource.dart';
import '../../../../core/database/app_database.dart' as db;

class ExpensesRepositoryImpl implements ExpensesRepository {
  final ExpensesLocalDataSource _localDataSource;

  ExpensesRepositoryImpl(this._localDataSource);

  @override
  Future<List<ExpenseEntity>> getExpenses({String? category, DateTime? startDate, DateTime? endDate}) async {
    final list = await _localDataSource.getExpenses(category: category, startDate: startDate, endDate: endDate);
    return list.map(_mapToEntity).toList();
  }

  @override
  Future<int> addExpense(ExpenseEntity expense) async {
    final companion = _mapToCompanion(expense);
    return _localDataSource.addExpense(companion);
  }

  @override
  Future<void> deleteExpense(int id) async {
    await _localDataSource.deleteExpense(id);
  }

  ExpenseEntity _mapToEntity(db.Expense expense) {
    return ExpenseEntity(
      id: expense.id,
      category: expense.category,
      description: expense.description,
      amount: expense.amount,
      date: expense.date,
      observation: expense.observation,
      createdAt: expense.createdAt,
    );
  }

  db.ExpensesCompanion _mapToCompanion(ExpenseEntity expense) {
    return db.ExpensesCompanion(
      id: expense.id == 0 ? const Value.absent() : Value(expense.id),
      category: Value(expense.category),
      description: Value(expense.description),
      amount: Value(expense.amount),
      date: Value(expense.date),
      observation: Value(expense.observation),
      createdAt: Value(expense.createdAt),
    );
  }
}
