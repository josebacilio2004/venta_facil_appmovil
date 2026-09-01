import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/fintech_card.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../providers/dashboard_providers.dart';
import '../../../products/domain/entities/product.dart';
import '../../../sales/domain/entities/sale.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final settings = ref.watch(settingsNotifierProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.primaryContainerColor],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.point_of_sale_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'VentaFácil',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryColor,
                fontSize: 20,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.onSurfaceColor),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.surfaceContainerLow,
              child: Icon(Icons.person_rounded, color: AppTheme.primaryColor, size: 22),
            ),
          ),
        ],
      ),
      body: statsAsync.when(
        data: (stats) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardStatsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 90.0),
            children: [
              // Greeting & Business Name
              _buildHeaderGreeting(settings.businessName),
              const SizedBox(height: 18),

              // Hero Card: Ventas de hoy
              _buildHeroSalesCard(context, stats.salesToday),
              const SizedBox(height: 16),

              // Secondary Stats Stack (Bento Grid)
              _buildSecondaryStatsStack(context, stats),
              const SizedBox(height: 24),

              // Stock bajo (si hay alertas)
              if (stats.lowStockProducts.isNotEmpty) ...[
                _buildLowStockSection(context, stats.lowStockProducts),
                const SizedBox(height: 24),
              ],

              // Últimas Ventas List
              _buildLatestSalesSection(context, stats.latestSales),
              const SizedBox(height: 20),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $err', style: const TextStyle(color: AppTheme.errorColor)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(dashboardStatsProvider),
                child: const Text('Reintentar'),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryContainerColor,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_shopping_cart_rounded),
        label: const Text('Registrar Venta', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2)),
        onPressed: () => context.go('/sales'),
      ),
    );
  }

  Widget _buildHeaderGreeting(String businessName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Buenos días 👋',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.onSurfaceVariantColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          businessName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppTheme.onSurfaceColor,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSalesCard(BuildContext context, double todaySales) {
    return Container(
      padding: const EdgeInsets.all(22.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryContainerColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryContainerColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ventas de hoy',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor,
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Activo hoy',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            CurrencyFormatter.format(todaySales),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryStatsStack(BuildContext context, DashboardStats stats) {
    return Column(
      children: [
        // 1. Ganancia
        FintechCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ganancia Estimada',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.onSurfaceVariantColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.format(stats.estimatedProfit),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.onSurfaceColor),
                  ),
                ],
              ),
              const CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.surfaceContainerLow,
                child: Icon(Icons.payments_rounded, color: AppTheme.primaryColor, size: 22),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 2. Productos Vendidos
        FintechCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Productos Vendidos Hoy',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.onSurfaceVariantColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${stats.productsSold} unid.',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.onSurfaceColor),
                  ),
                ],
              ),
              const CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.surfaceContainerLow,
                child: Icon(Icons.shopping_bag_rounded, color: AppTheme.primaryColor, size: 22),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 3. Gastos del Día
        FintechCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gastos Operativos',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.onSurfaceVariantColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.format(stats.todayExpenses),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.errorColor),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.errorContainerColor.withValues(alpha: 0.6),
                child: const Icon(Icons.schedule_rounded, color: AppTheme.errorColor, size: 22),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLowStockSection(BuildContext context, List<ProductEntity> lowStockProducts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stock bajo',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.onSurfaceColor),
        ),
        const SizedBox(height: 10),
        FintechCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: lowStockProducts.take(3).map((p) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.inventory_2_outlined, color: AppTheme.outlineColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.onSurfaceColor)),
                          Text(p.description ?? 'Producto', style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariantColor)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.tertiaryContainerColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning_amber_rounded, size: 14, color: AppTheme.tertiaryColor),
                          const SizedBox(width: 4),
                          Text(
                            '${p.stock} unid.',
                            style: const TextStyle(color: AppTheme.tertiaryColor, fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLatestSalesSection(BuildContext context, List<SaleEntity> latestSales) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Últimas ventas',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.onSurfaceColor),
            ),
            GestureDetector(
              onTap: () => context.go('/sales'),
              child: const Text(
                'Ver todas',
                style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (latestSales.isEmpty)
          const FintechCard(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text(
                'No hay ventas registradas hoy.',
                style: TextStyle(color: AppTheme.onSurfaceVariantColor, fontSize: 13),
              ),
            ),
          )
        else
          FintechCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: latestSales.take(4).map((sale) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppTheme.outlineVariantColor, width: 0.8)),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.surfaceContainerLow,
                        child: Icon(Icons.receipt_rounded, color: AppTheme.primaryColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Venta #${sale.id.toString().padLeft(4, '0')}',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.onSurfaceColor),
                            ),
                            Text(
                              '${DateFormatter.formatWithTime(sale.date)} • ${sale.paymentMethod.toUpperCase()}',
                              style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariantColor),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(sale.total),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.onSurfaceColor),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
