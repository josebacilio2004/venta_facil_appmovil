import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../sales/presentation/providers/sales_providers.dart';
import '../providers/dashboard_providers.dart';
import '../../../products/domain/entities/product.dart';
import '../../../sales/domain/entities/sale.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'VENTAFÁCIL - PANEL',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: GlassBackground(
        child: SafeArea(
          child: statsAsync.when(
            data: (stats) => RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(dashboardStatsProvider);
              },
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildBusinessBanner(context),
                  const SizedBox(height: 20),
                  _buildStatsGrid(context, stats),
                  const SizedBox(height: 20),
                  if (stats.lowStockProducts.isNotEmpty) ...[
                    _buildLowStockAlert(context, stats.lowStockProducts),
                    const SizedBox(height: 20),
                  ],
                  _buildLatestSalesList(context, ref, stats.latestSales),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
            error: (err, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $err', style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.teal),
                    onPressed: () => ref.invalidate(dashboardStatsProvider),
                    child: const Text('Reintentar'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessBanner(BuildContext context) {
    return const GlassCard(
      opacity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Bienvenido!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Controla tu inventario y ventas de forma rápida y sencilla.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, DashboardStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.35,
      children: [
        _buildStatCard(
          context,
          title: 'Ventas de Hoy',
          value: CurrencyFormatter.format(stats.salesToday),
          icon: Icons.today,
          iconColor: Colors.tealAccent,
        ),
        _buildStatCard(
          context,
          title: 'Ventas del Mes',
          value: CurrencyFormatter.format(stats.salesMonth),
          icon: Icons.calendar_month,
          iconColor: Colors.blueAccent,
        ),
        _buildStatCard(
          context,
          title: 'Ganancia Estimada',
          value: CurrencyFormatter.format(stats.estimatedProfit),
          icon: Icons.trending_up,
          iconColor: Colors.greenAccent,
        ),
        _buildStatCard(
          context,
          title: 'Prod. Vendidos',
          value: '${stats.productsSold} und',
          icon: Icons.shopping_basket,
          iconColor: Colors.orangeAccent,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: iconColor, size: 24),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockAlert(BuildContext context, List<ProductEntity> list) {
    return GlassCard(
      color: Colors.orange,
      opacity: 0.15,
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 36),
        ),
        title: Text(
          'Alertas de Inventario (${list.length})',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent),
        ),
        subtitle: const Text(
          'Tienes productos con stock bajo o agotados.',
          style: TextStyle(color: Colors.white70),
        ),
        trailing: const Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: Icon(Icons.chevron_right, color: Colors.orangeAccent),
        ),
        onTap: () {
          context.go('/products');
        },
      ),
    );
  }

  Widget _buildLatestSalesList(BuildContext context, WidgetRef ref, List<SaleEntity> sales) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Últimas Ventas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              TextButton(
                onPressed: () {
                  context.push('/reports');
                },
                child: const Text('Ver Reportes', style: TextStyle(color: Colors.cyanAccent)),
              ),
            ],
          ),
          const Divider(color: Colors.white24),
          if (sales.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Center(child: Text('No hay ventas registradas.', style: TextStyle(color: Colors.white70))),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sales.length,
              itemBuilder: (context, index) {
                final sale = sales[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.12),
                    child: const Icon(Icons.receipt, color: Colors.white),
                  ),
                  title: Text(
                    sale.customerName ?? 'Cliente Anónimo',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  subtitle: Text(
                    '${DateFormatter.formatWithTime(sale.date)} • ${sale.paymentMethod.toUpperCase()}',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  trailing: Text(
                    CurrencyFormatter.format(sale.total),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  ),
                  onTap: () => _showSaleDetails(context, ref, sale),
                );
              },
            ),
        ],
      ),
    );
  }

  void _showSaleDetails(BuildContext context, WidgetRef ref, SaleEntity sale) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      final items = await ref.read(getSaleItemsUseCaseProvider).call(sale.id);
      if (context.mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF0F766E),
            title: Text('Detalle de Venta #${sale.id}', style: const TextStyle(color: Colors.white)),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cliente: ${sale.customerName ?? 'Anónimo'}', style: const TextStyle(color: Colors.white)),
                  Text('Fecha: ${DateFormatter.formatWithTime(sale.date)}', style: const TextStyle(color: Colors.white70)),
                  Text('Pago: ${sale.paymentMethod.toUpperCase()}', style: const TextStyle(color: Colors.white70)),
                  if (sale.discount > 0)
                    Text('Descuento: ${CurrencyFormatter.format(sale.discount)}', style: const TextStyle(color: Colors.redAccent)),
                  const Divider(color: Colors.white24),
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (c, idx) {
                        final item = items[idx];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(item.productName, style: const TextStyle(color: Colors.white)),
                          subtitle: Text('${item.quantity} x ${CurrencyFormatter.format(item.unitSellingPrice)}', style: const TextStyle(color: Colors.white70)),
                          trailing: Text(CurrencyFormatter.format(item.subtotal), style: const TextStyle(color: Colors.white)),
                        );
                      },
                    ),
                  ),
                  const Divider(color: Colors.white24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Venta:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      Text(CurrencyFormatter.format(sale.total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.tealAccent)),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cerrar', style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
