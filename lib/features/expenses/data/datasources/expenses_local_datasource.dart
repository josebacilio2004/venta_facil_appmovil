import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';

abstract class ExpensesLocalDataSource {
  Future<List<Expense>> getExpenses({String? category, DateTime? startDate, DateTime? endDate});
  Future<int> addExpense(ExpensesCompanion expense);
  Future<void> deleteExpense(int id);
}

class ExpensesLocalDataSourceImpl implements ExpensesLocalDataSource {
  final AppDatabase _db;

  ExpensesLocalDataSourceImpl(this._db);

  @override
  Future<List<Expense>> getExpenses({String? category, DateTime? startDate, DateTime? endDate}) async {
    final statement = _db.select(_db.expenses);
    if (category != null && category.isNotEmpty) {
      statement.where((tbl) => tbl.category.equals(category));
    }
    if (startDate != null) {
      statement.where((tbl) => tbl.date.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      statement.where((tbl) => tbl.date.isSmallerOrEqualValue(endDate));
    }
    statement.orderBy([(tbl) => OrderingTerm(expression: tbl.date, mode: OrderingMode.desc)]);
    return statement.get();
  }

  @override
  Future<int> addExpense(ExpensesCompanion expense) async {
    return _db.into(_db.expenses).insert(expense);
  }

  @override
  Future<void> deleteExpense(int id) async {
    await (_db.delete(_db.expenses)..where((tbl) => tbl.id.equals(id))).go();
  }
}
