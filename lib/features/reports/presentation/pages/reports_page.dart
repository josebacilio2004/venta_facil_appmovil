import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_card.dart';
import '../providers/reports_providers.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(reportsPeriodProvider);
    final reportAsync = ref.watch(reportsProvider);

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'REPORTES DE NEGOCIO',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            // Selector de Periodo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPeriodTab(ref, period, 'hoy', 'Hoy', Icons.today),
                    _buildPeriodTab(ref, period, 'semana', 'Semana', Icons.view_week),
                    _buildPeriodTab(ref, period, 'mes', 'Mes', Icons.calendar_month),
                  ],
                ),
              ),
            ),

            // Contenido de Reporte
            Expanded(
              child: reportAsync.when(
                data: (data) => RefreshIndicator(
                  color: const Color(0xFF0F766E),
                  onRefresh: () async => ref.invalidate(reportsProvider),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      // Balance de Pérdidas y Ganancias
                      _buildBalanceSheet(context, data),
                      const SizedBox(height: 16),

                      // Productos más vendidos (Gráfico de Barras)
                      _buildTopProductsCard(context, data.topProducts),
                      const SizedBox(height: 16),

                      // Métodos de pago (Gráfico Circular / Distribución)
                      _buildPaymentMethodsCard(context, data.salesByPaymentMethod),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                error: (err, _) => Center(
                  child: Text(
                    'Error al cargar reportes: $err',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodTab(WidgetRef ref, String activePeriod, String value, String label, IconData icon) {
    final isActive = activePeriod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(reportsPeriodProvider.notifier).state = value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white.withOpacity(0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isActive ? Colors.tealAccent : Colors.white70),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white70,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceSheet(BuildContext context, ReportData data) {
    final isLoss = data.netProfit < 0;
    
    // Calculate values for comparison
    final maxVal = [data.totalIncome, data.totalCost, data.totalExpenses, data.netProfit.abs()]
        .reduce((a, b) => a > b ? a : b);

    return GlassCard(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_outlined, color: Colors.tealAccent),
              const SizedBox(width: 8),
              const Text(
                'Balance Financiero',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),
          
          // Visual comparison bars
          _buildBalanceBar('Ingresos (Ventas)', data.totalIncome, Colors.greenAccent, maxVal),
          _buildBalanceBar('Costo Mercadería', data.totalCost, Colors.redAccent, maxVal),
          _buildBalanceBar('Gastos Operativos', data.totalExpenses, Colors.orangeAccent, maxVal),
          
          const Divider(color: Colors.white12, height: 28),
          
          // Net Profit row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ganancia Neta Estimada',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                CurrencyFormatter.format(data.netProfit),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isLoss ? Colors.pinkAccent : Colors.tealAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Visual profit comparison bar
          Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: maxVal > 0 ? (data.netProfit.abs() / maxVal).clamp(0.0, 1.0) : 0.0,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: isLoss ? Colors.pinkAccent : Colors.tealAccent,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: (isLoss ? Colors.pinkAccent : Colors.tealAccent).withOpacity(0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceBar(String label, double value, Color color, double maxVal) {
    final percentage = maxVal > 0 ? (value / maxVal).clamp(0.0, 1.0) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              Text(
                CurrencyFormatter.format(value),
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Stack(
            children: [
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopProductsCard(BuildContext context, List<TopProductData> products) {
    // Determine maximum revenue to scale bars
    final maxRevenue = products.isEmpty ? 0.0 : products.map((p) => p.revenue).reduce((a, b) => a > b ? a : b);

    return GlassCard(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_outline, color: Colors.amberAccent),
              const SizedBox(width: 8),
              const Text(
                'Productos más Vendidos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white12),
          const SizedBox(height: 8),
          
          if (products.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: Text(
                  'No hay ventas registradas en este periodo.',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
            )
          else
            Column(
              children: products.map((p) {
                final pctWidth = maxRevenue > 0 ? (p.revenue / maxRevenue).clamp(0.0, 1.0) : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              p.productName,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${p.quantitySold} uds - ${CurrencyFormatter.format(p.revenue)}',
                            style: const TextStyle(color: Colors.tealAccent, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: pctWidth,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.cyanAccent, Colors.tealAccent],
                                ),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.tealAccent.withOpacity(0.3),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsCard(BuildContext context, Map<String, double> paymentMethods) {
    final sortedMethods = paymentMethods.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final totalSales = paymentMethods.values.fold(0.0, (sum, val) => sum + val);

    final colors = {
      'efectivo': Colors.greenAccent,
      'yape': Colors.purpleAccent,
      'plin': Colors.blueAccent,
      'tarjeta': Colors.amberAccent,
      'transferencia': Colors.tealAccent,
      'otro': Colors.orangeAccent,
    };

    return GlassCard(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payment_outlined, color: Colors.cyanAccent),
              const SizedBox(width: 8),
              const Text(
                'Ventas por Método de Pago',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white12),
          const SizedBox(height: 8),

          if (sortedMethods.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: Text(
                  'No hay ventas registradas en este periodo.',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
            )
          else
            Column(
              children: sortedMethods.map((entry) {
                final color = colors[entry.key.toLowerCase()] ?? Colors.blueGrey;
                final percentage = totalSales > 0 ? (entry.value / totalSales) : 0.0;
                final pctText = (percentage * 100).toStringAsFixed(1);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                entry.key.toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                          Text(
                            '$pctText% (${CurrencyFormatter.format(entry.value)})',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Stack(
                        children: [
                          Container(
                            height: 6,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: percentage,
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
