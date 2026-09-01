import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../sales/presentation/providers/sales_providers.dart';
import '../../../expenses/presentation/providers/expenses_providers.dart';

class ReportData {
  final double totalIncome;
  final double totalCost;
  final double totalExpenses;
  final double netProfit;
  final List<TopProductData> topProducts;
  final Map<String, double> salesByPaymentMethod;

  const ReportData({
    required this.totalIncome,
    required this.totalCost,
    required this.totalExpenses,
    required this.netProfit,
    required this.topProducts,
    required this.salesByPaymentMethod,
  });
}

class TopProductData {
  final String productName;
  final int quantitySold;
  final double revenue;

  const TopProductData({
    required this.productName,
    required this.quantitySold,
    required this.revenue,
  });
}

final reportsPeriodProvider = StateProvider<String>((ref) => 'mes'); // 'hoy', 'semana', 'mes'

final reportsProvider = FutureProvider<ReportData>((ref) async {
  final sales = await ref.watch(salesListProvider.future);
  final expenses = await ref.watch(expensesListProvider.future);
  final period = ref.watch(reportsPeriodProvider);
  
  final now = DateTime.now();
  final startOfToday = DateTime(now.year, now.month, now.day);
  
  DateTime startDate;
  if (period == 'hoy') {
    startDate = startOfToday;
  } else if (period == 'semana') {
    startDate = startOfToday.subtract(Duration(days: now.weekday - 1));
  } else {
    startDate = DateTime(now.year, now.month, 1);
  }

  final filteredSales = sales.where((s) => s.date.isAfter(startDate)).toList();
  final filteredExpenses = expenses.where((e) => e.date.isAfter(startDate)).toList();

  double totalIncome = 0.0;
  double totalCost = 0.0;
  double totalExpenses = filteredExpenses.fold(0.0, (sum, e) => sum + e.amount);

  final Map<int, int> productQuantities = {};
  final Map<int, String> productNames = {};
  final Map<int, double> productRevenues = {};
  final Map<String, double> paymentMethods = {};

  final salesRepo = ref.watch(salesRepositoryProvider);

  for (final s in filteredSales) {
    totalIncome += s.total;
    paymentMethods[s.paymentMethod] = (paymentMethods[s.paymentMethod] ?? 0.0) + s.total;

    final items = await salesRepo.getSaleItems(s.id);
    for (final item in items) {
      totalCost += (item.quantity * item.unitPurchasePrice);
      
      productQuantities[item.productId] = (productQuantities[item.productId] ?? 0) + item.quantity;
      productNames[item.productId] = item.productName;
      productRevenues[item.productId] = (productRevenues[item.productId] ?? 0.0) + item.subtotal;
    }
  }

  final netProfit = totalIncome - totalCost - totalExpenses;

  final topProducts = <TopProductData>[];
  productQuantities.forEach((id, qty) {
    topProducts.add(TopProductData(
      productName: productNames[id] ?? 'Producto',
      quantitySold: qty,
      revenue: productRevenues[id] ?? 0.0,
    ));
  });
  
  topProducts.sort((a, b) => b.quantitySold.compareTo(a.quantitySold));

  return ReportData(
    totalIncome: totalIncome,
    totalCost: totalCost,
    totalExpenses: totalExpenses,
    netProfit: netProfit,
    topProducts: topProducts.take(5).toList(),
    salesByPaymentMethod: paymentMethods,
  );
});
