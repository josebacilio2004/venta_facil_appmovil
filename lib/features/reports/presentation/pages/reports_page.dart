import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/fintech_card.dart';
import '../providers/reports_providers.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(reportsPeriodProvider);
    final reportAsync = ref.watch(reportsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.onSurfaceColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Reportes y Ganancias',
          style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.onSurfaceColor, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          // Selector de Periodo
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 12.0),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.outlineVariantColor),
              ),
              child: Row(
                children: [
                  _buildPeriodTab(ref, period, 'hoy', 'Hoy', Icons.today_rounded),
                  _buildPeriodTab(ref, period, 'semana', 'Esta Semana', Icons.view_week_rounded),
                  _buildPeriodTab(ref, period, 'mes', 'Este Mes', Icons.calendar_month_rounded),
                ],
              ),
            ),
          ),

          // Contenido de Reporte
          Expanded(
            child: reportAsync.when(
              data: (data) => RefreshIndicator(
                color: AppTheme.primaryColor,
                onRefresh: () async => ref.invalidate(reportsProvider),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                  children: [
                    // Balance de Pérdidas y Ganancias
                    _buildBalanceSheet(context, data),
                    const SizedBox(height: 16),

                    // Productos más vendidos (Gráfico de Barras)
                    _buildTopProductsCard(context, data.topProducts),
                    const SizedBox(height: 16),

                    // Métodos de pago (Distribución)
                    _buildPaymentMethodsCard(context, data.salesByPaymentMethod),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
              error: (err, _) => Center(
                child: Text('Error al cargar reportes: $err', style: const TextStyle(color: AppTheme.errorColor)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(WidgetRef ref, String activePeriod, String value, String label, IconData icon) {
    final isActive = activePeriod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(reportsPeriodProvider.notifier).state = value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF003FA4).withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isActive ? AppTheme.primaryColor : AppTheme.onSurfaceVariantColor,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? AppTheme.primaryColor : AppTheme.onSurfaceVariantColor,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceSheet(BuildContext context, ReportData data) {
    final maxFinancial = [data.totalIncome, data.totalCost, data.totalExpenses]
        .reduce((curr, next) => curr > next ? curr : next);
    final scaleRef = maxFinancial > 0 ? maxFinancial : 1.0;

    return FintechCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_wallet_rounded, color: AppTheme.primaryColor, size: 20),
              SizedBox(width: 8),
              Text(
                'Balance Financiero',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.onSurfaceColor),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 1. Ingresos
          _buildBalanceBarRow('Total Ventas (Ingresos)', data.totalIncome, scaleRef, AppTheme.primaryColor),
          const SizedBox(height: 12),

          // 2. Costos
          _buildBalanceBarRow('Costo de Mercancía', data.totalCost, scaleRef, const Color(0xFF64748B)),
          const SizedBox(height: 12),

          // 3. Gastos
          _buildBalanceBarRow('Gastos Operativos', data.totalExpenses, scaleRef, AppTheme.tertiaryColor),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.outlineVariantColor),
          const SizedBox(height: 8),

          // Ganancia Neta Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: data.netProfit >= 0
                  ? AppTheme.secondaryContainerColor.withValues(alpha: 0.2)
                  : AppTheme.errorContainerColor.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: data.netProfit >= 0 ? AppTheme.secondaryColor.withValues(alpha: 0.3) : AppTheme.errorColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('GANANCIA NETA', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5)),
                    Text(
                      'Rendimiento real',
                      style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariantColor),
                    ),
                  ],
                ),
                Text(
                  CurrencyFormatter.format(data.netProfit),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: data.netProfit >= 0 ? AppTheme.secondaryColor : AppTheme.errorColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceBarRow(String label, double amount, double scaleRef, Color barColor) {
    final ratio = (amount / scaleRef).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.onSurfaceColor)),
            Text(CurrencyFormatter.format(amount), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.onSurfaceColor)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 8,
            color: AppTheme.surfaceContainerLow,
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: ratio,
              child: Container(color: barColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopProductsCard(BuildContext context, List<TopProductData> topProducts) {
    return FintechCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.leaderboard_rounded, color: AppTheme.primaryColor, size: 20),
              SizedBox(width: 8),
              Text(
                'Ranking de Ventas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.onSurfaceColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (topProducts.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No hay productos vendidos en este periodo.', style: TextStyle(color: AppTheme.onSurfaceVariantColor, fontSize: 13)),
              ),
            )
          else
            ...topProducts.take(5).map((p) {
              final maxRevenue = topProducts.first.revenue > 0 ? topProducts.first.revenue : 1.0;
              final ratio = (p.revenue / maxRevenue).clamp(0.05, 1.0);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            p.productName,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.onSurfaceColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${p.quantitySold} u. • ${CurrencyFormatter.format(p.revenue)}',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.primaryColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        height: 7,
                        color: AppTheme.surfaceContainerLow,
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: ratio,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.primaryColor, AppTheme.primaryContainerColor],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsCard(BuildContext context, Map<String, double> paymentMethods) {
    final total = paymentMethods.values.fold(0.0, (sum, val) => sum + val);

    return FintechCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pie_chart_rounded, color: AppTheme.primaryColor, size: 20),
              SizedBox(width: 8),
              Text(
                'Métodos de Pago',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.onSurfaceColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (total <= 0)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No hay ingresos en este periodo.', style: TextStyle(color: AppTheme.onSurfaceVariantColor, fontSize: 13)),
              ),
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 12,
                child: Row(
                  children: paymentMethods.entries.where((e) => e.value > 0).map((entry) {
                    final percent = (entry.value / total);
                    return Expanded(
                      flex: (percent * 100).round(),
                      child: Container(color: _getPaymentMethodColor(entry.key)),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: paymentMethods.entries.where((e) => e.value > 0).map((entry) {
                final percent = (entry.value / total * 100).toStringAsFixed(1);
                final color = _getPaymentMethodColor(entry.key);

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(
                      '${entry.key.toUpperCase()} ($percent%): ',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.onSurfaceColor),
                    ),
                    Text(
                      CurrencyFormatter.format(entry.value),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.onSurfaceColor),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Color _getPaymentMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'efectivo':
        return AppTheme.secondaryColor;
      case 'yape':
        return const Color(0xFF8B5CF6);
      case 'plin':
        return const Color(0xFF06B6D4);
      case 'tarjeta':
        return const Color(0xFFF59E0B);
      case 'transferencia':
        return AppTheme.primaryColor;
      default:
        return const Color(0xFF64748B);
    }
  }
}
