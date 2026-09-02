import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../products/presentation/providers/products_providers.dart';
import '../../../sales/presentation/providers/sales_providers.dart';
import '../../../expenses/presentation/providers/expenses_providers.dart';
import '../../../products/domain/entities/product.dart';
import '../../../sales/domain/entities/sale.dart';

class DashboardStats {
  final double salesToday;
  final double salesWeek;
  final double salesMonth;
  final double estimatedProfit;
  final double todayExpenses;
  final int productsSold;
  final List<ProductEntity> lowStockProducts;
  final List<SaleEntity> latestSales;

  const DashboardStats({
    required this.salesToday,
    required this.salesWeek,
    required this.salesMonth,
    required this.estimatedProfit,
    required this.todayExpenses,
    required this.productsSold,
    required this.lowStockProducts,
    required this.latestSales,
  });
}

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final sales = await ref.watch(salesListProvider.future);
  final products = await ref.watch(productsListProvider.future);
  // Obtenemos todos los gastos sin filtro de categoría para calcular con precisión los gastos reales del día
  final allExpenses = await ref.watch(getExpensesUseCaseProvider).call();
  
  final now = DateTime.now();
  final startOfToday = DateTime(now.year, now.month, now.day);
  final startOfWeek = startOfToday.subtract(Duration(days: now.weekday - 1));
  final startOfMonth = DateTime(now.year, now.month, 1);

  double salesToday = 0.0;
  double salesWeek = 0.0;
  double salesMonth = 0.0;
  
  for (final s in sales) {
    if (s.date.isAfter(startOfToday)) {
      salesToday += s.total;
    }
    if (s.date.isAfter(startOfWeek)) {
      salesWeek += s.total;
    }
    if (s.date.isAfter(startOfMonth)) {
      salesMonth += s.total;
    }
  }

  double totalProfit = 0.0;
  int productsSold = 0;
  
  final salesRepo = ref.watch(salesRepositoryProvider);
  final monthlySales = sales.where((s) => s.date.isAfter(startOfMonth)).toList();
  for (final s in monthlySales) {
    final items = await salesRepo.getSaleItems(s.id);
    for (final item in items) {
      productsSold += item.quantity;
      totalProfit += item.totalProfit;
    }
    totalProfit -= s.discount;
  }

  double todayExpenses = 0.0;
  for (final e in allExpenses) {
    if (e.date.isAfter(startOfToday)) {
      todayExpenses += e.amount;
    }
  }

  final lowStock = products.where((p) => p.isLowStock && p.isActive).toList();
  final latestSales = sales.take(5).toList();

  return DashboardStats(
    salesToday: salesToday,
    salesWeek: salesWeek,
    salesMonth: salesMonth,
    estimatedProfit: totalProfit,
    todayExpenses: todayExpenses,
    productsSold: productsSold,
    lowStockProducts: lowStock,
    latestSales: latestSales,
  );
});
