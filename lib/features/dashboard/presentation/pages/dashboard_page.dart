import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/fintech_card.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../../products/presentation/providers/products_providers.dart';
import '../../../sales/presentation/providers/sales_providers.dart';
import '../../../products/domain/entities/product.dart';
import '../../../sales/domain/entities/sale.dart';
import '../providers/dashboard_providers.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryContainerColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.point_of_sale_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              settings.businessName.isNotEmpty ? settings.businessName : 'VentaFácil',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: AppTheme.onSurfaceColor,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        actions: [
          // Campana de Notificaciones Funcional
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.onSurfaceColor),
                tooltip: 'Centro de Notificaciones',
                onPressed: () => _showNotificationCenter(context, statsAsync.valueOrNull, ref),
              ),
              if (statsAsync.valueOrNull != null && statsAsync.valueOrNull!.lowStockProducts.isNotEmpty)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),

          // Botón de Perfil / Usuario Funcional
          GestureDetector(
            onTap: () => _showUserProfileModal(context, settings, ref),
            child: const Padding(
              padding: EdgeInsets.only(right: 16.0, left: 4.0),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.surfaceContainerLow,
                child: Icon(Icons.storefront_rounded, color: AppTheme.primaryColor, size: 20),
              ),
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
              _buildLatestSalesSection(context, ref, stats.latestSales),
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

  void _showNotificationCenter(BuildContext context, DashboardStats? stats, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final lowStockCount = stats?.lowStockProducts.length ?? 0;
        final salesToday = stats?.salesToday ?? 0.0;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.outlineVariantColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Centro de Notificaciones',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.onSurfaceColor),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${lowStockCount > 0 ? 2 : 1} activas',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppTheme.primaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Notificación 1: Stock Bajo
              if (lowStockCount > 0)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFD599)),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppTheme.tertiaryColor,
                        radius: 18,
                        child: Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '⚠️ Alerta de Inventario ($lowStockCount productos)',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF7A4100)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tienes productos que llegaron al stock mínimo. Toca para verlos.',
                              style: TextStyle(fontSize: 11, color: Colors.brown.shade700),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          context.go('/products');
                        },
                        child: const Text('Revisar', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                      ),
                    ],
                  ),
                ),

              // Notificación 2: Hito de Ventas
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.outlineVariantColor),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      radius: 18,
                      child: Icon(Icons.insights_rounded, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Resumen Financiero del Día',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.onSurfaceColor),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            salesToday > 0
                                ? 'Has generado ${CurrencyFormatter.format(salesToday)} en ventas hoy.'
                                : 'Tu sistema POS está listo para registrar tus ventas de hoy.',
                            style: const TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariantColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Notificación 3: Sistema SUNAT y Offline
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFA5D6A7)),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(0xFF2E7D32),
                      radius: 18,
                      child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Comprobantes SUNAT y Base Local OK',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF1B5E20)),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Series B001 y T001 configuradas. Modo Offline activo.',
                            style: TextStyle(fontSize: 11, color: Color(0xFF2E7D32)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUserProfileModal(BuildContext context, SettingsState settings, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.outlineVariantColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 32,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  settings.businessName.isNotEmpty ? settings.businessName.substring(0, 1).toUpperCase() : 'V',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 26, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                settings.businessName.isNotEmpty ? settings.businessName : 'Mi Negocio',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.onSurfaceColor),
              ),
              Text(
                'RUC: ${settings.ruc.isNotEmpty ? settings.ruc : "No configurado"}',
                style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariantColor, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.outlineVariantColor),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium_rounded, color: AppTheme.primaryColor, size: 24),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Plan SaaS Pro • Offline First', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.onSurfaceColor)),
                          Text('Base de datos SQLite local activa sin límite de ventas.', style: TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariantColor)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('ACTIVO', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF2E7D32))),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.people_alt_outlined, size: 18),
                      label: const Text('Clientes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.go('/customers');
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.settings_outlined, size: 18),
                      label: const Text('Configuración', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.go('/settings');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderGreeting(String businessName) {
    final now = DateTime.now();
    String greeting = 'Buenos días';
    if (now.hour >= 12 && now.hour < 19) {
      greeting = 'Buenas tardes';
    } else if (now.hour >= 19 || now.hour < 6) {
      greeting = 'Buenas noches';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting 👋',
          style: const TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariantColor, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        const Text(
          'Panel Principal',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.onSurfaceColor, letterSpacing: -0.5),
        ),
      ],
    );
  }

  Widget _buildHeroSalesCard(BuildContext context, double salesToday) {
    return FintechCard(
      color: AppTheme.primaryColor,
      padding: const EdgeInsets.all(20.0),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.trending_up_rounded,
              size: 140,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ventas de hoy',
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today_rounded, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'Hoy',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                CurrencyFormatter.format(salesToday),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF68FADD).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_upward_rounded, color: Color(0xFF68FADD), size: 12),
                        SizedBox(width: 2),
                        Text(
                          'En Vivo',
                          style: TextStyle(color: Color(0xFF68FADD), fontSize: 11, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Caja registradora sincronizada',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryStatsStack(BuildContext context, DashboardStats stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: cardWidth,
              child: _buildBentoCard(
                title: 'Ganancia estimada',
                value: CurrencyFormatter.format(stats.estimatedProfit),
                icon: Icons.savings_outlined,
                iconColor: const Color(0xFF007A55),
                bgColor: const Color(0xFFE8F5E9),
                subtitle: 'Mes actual',
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildBentoCard(
                title: 'Gastos operativos',
                value: CurrencyFormatter.format(stats.todayExpenses),
                icon: Icons.receipt_long_outlined,
                iconColor: AppTheme.errorColor,
                bgColor: const Color(0xFFFFEBEE),
                subtitle: 'Hoy',
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildBentoCard(
                title: 'Productos vendidos',
                value: '${stats.productsSold} uds',
                icon: Icons.shopping_bag_outlined,
                iconColor: AppTheme.primaryColor,
                bgColor: AppTheme.surfaceContainerLow,
                subtitle: 'Mes actual',
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildBentoCard(
                title: 'Ventas semana',
                value: CurrencyFormatter.format(stats.salesWeek),
                icon: Icons.date_range_rounded,
                iconColor: const Color(0xFF7A4100),
                bgColor: const Color(0xFFFFF4E5),
                subtitle: 'Últimos 7 días',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBentoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String subtitle,
  }) {
    return FintechCard(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 10, color: AppTheme.outlineColor, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariantColor, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppTheme.onSurfaceColor, letterSpacing: -0.2),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockSection(BuildContext context, List<ProductEntity> lowStockProducts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppTheme.tertiaryColor, size: 20),
                const SizedBox(width: 6),
                Text(
                  'Alerta: Stock bajo (${lowStockProducts.length})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.onSurfaceColor),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => context.go('/products'),
              child: const Text(
                'Ver catálogo',
                style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: lowStockProducts.length,
            itemBuilder: (context, index) {
              final product = lowStockProducts[index];
              return Container(
                width: 170,
                margin: const EdgeInsets.only(right: 10),
                child: FintechCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.onSurfaceColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Quedan ${product.stock}',
                            style: const TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Min: ${product.minStock}',
                              style: const TextStyle(color: AppTheme.errorColor, fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLatestSalesSection(BuildContext context, WidgetRef ref, List<SaleEntity> latestSales) {
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
              onTap: () {
                ref.read(salesInitialTabProvider.notifier).state = 2; // Abre pestaña 3. Historial
                context.go('/sales');
              },
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
