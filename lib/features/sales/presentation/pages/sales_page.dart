import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/local_image_helper.dart';
import '../../../../core/widgets/barcode_scanner_dialog.dart';
import '../../../../core/widgets/fintech_card.dart';
import '../../../products/presentation/providers/products_providers.dart';
import '../../../products/domain/entities/product.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/entities/receipt_data.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_item.dart';
import '../providers/sales_providers.dart';
import '../widgets/checkout_dialog.dart';
import '../widgets/receipt_viewer_dialog.dart';

class SalesPage extends ConsumerStatefulWidget {
  const SalesPage({super.key});

  @override
  ConsumerState<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends ConsumerState<SalesPage> {
  final _searchController = TextEditingController();
  final _historySearchController = TextEditingController();
  String _searchQuery = '';
  String _historyQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _historySearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final productsFilter = ref.watch(productsFilterProvider);
    final productsAsync = ref.watch(productsListProvider);
    final salesAsync = ref.watch(salesListProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.surfaceColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text(
            'Módulo de Ventas',
            style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.onSurfaceColor, fontSize: 20),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.receipt_long_rounded, color: AppTheme.primaryColor),
              tooltip: 'Ver Último Ticket Emitido',
              onPressed: () => _openLatestReceipt(),
            ),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.outlineColor,
            indicatorColor: AppTheme.primaryColor,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            tabs: [
              const Tab(icon: Icon(Icons.point_of_sale_rounded, size: 18), text: '1. Productos'),
              Tab(
                icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                text: '2. Carrito (${cart.items.fold(0, (sum, i) => sum + i.quantity)})',
              ),
              const Tab(icon: Icon(Icons.history_rounded, size: 18), text: '3. Historial'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Selección Rápida de Productos y Escáner
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: AppTheme.onSurfaceColor, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Buscar producto o escanear SKU...',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.outlineColor, size: 20),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_searchQuery.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, color: AppTheme.outlineColor, size: 18),
                              onPressed: () {
                                setState(() => _searchQuery = '');
                                _searchController.clear();
                                ref.read(productsFilterProvider.notifier).state = productsFilter.copyWith(query: '');
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.qr_code_scanner_rounded, color: AppTheme.primaryColor),
                            tooltip: 'Escanear producto al carrito',
                            onPressed: () => _scanProductToCart(context),
                          ),
                        ],
                      ),
                    ),
                    onChanged: (val) {
                      setState(() => _searchQuery = val.trim());
                      ref.read(productsFilterProvider.notifier).state = productsFilter.copyWith(query: val.trim());
                    },
                  ),
                ),
                Expanded(
                  child: productsAsync.when(
                    data: (products) {
                      final sellable = products.where((p) => p.isActive).toList();
                      if (sellable.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(
                                  color: AppTheme.surfaceContainerLow,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.inventory_2_outlined, color: AppTheme.outlineColor, size: 28),
                              ),
                              const SizedBox(height: 12),
                              const Text('No hay productos disponibles para la venta.', style: TextStyle(color: AppTheme.onSurfaceVariantColor, fontSize: 14)),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: sellable.length,
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                        itemBuilder: (context, index) {
                          final product = sellable[index];
                          return _buildSellProductRow(context, ref, product, cart);
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
                    error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: AppTheme.errorColor))),
                  ),
                ),
              ],
            ),

            // Tab 2: Resumen del Carrito
            _buildCartTab(context, ref, cart),

            // Tab 3: Historial de Ventas con CRUD Desplegable
            _buildSalesHistoryTab(context, ref, salesAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildSellProductRow(BuildContext context, WidgetRef ref, ProductEntity p, CartState cart) {
    final cartItemIndex = cart.items.indexWhere((i) => i.product.id == p.id);
    final inCartQty = cartItemIndex >= 0 ? cart.items[cartItemIndex].quantity : 0;
    final availableStock = p.stock - inCartQty;

    return FintechCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: LocalImageHelper.buildProductImage(
              p.imagePath,
              width: 52,
              height: 52,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.onSurfaceColor)),
                const SizedBox(height: 2),
                Text(
                  CurrencyFormatter.format(p.sellingPrice),
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryColor, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  'Stock Disp: $availableStock',
                  style: TextStyle(
                    color: availableStock <= 0 ? AppTheme.errorColor : (availableStock <= p.minStock ? AppTheme.tertiaryColor : AppTheme.onSurfaceVariantColor),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              if (inCartQty > 0) ...[
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline_rounded, color: AppTheme.errorColor, size: 26),
                  onPressed: () => ref.read(cartProvider.notifier).updateQuantity(p.id, inCartQty - 1),
                ),
                Text('$inCartQty', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.onSurfaceColor)),
              ],
              IconButton(
                icon: const Icon(Icons.add_circle_rounded, color: AppTheme.primaryContainerColor, size: 30),
                onPressed: availableStock > 0
                    ? () => ref.read(cartProvider.notifier).addItem(p)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartTab(BuildContext context, WidgetRef ref, CartState cart) {
    if (cart.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_cart_outlined, size: 36, color: AppTheme.outlineColor),
            ),
            const SizedBox(height: 16),
            const Text('El carrito está vacío', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.onSurfaceColor)),
            const SizedBox(height: 4),
            const Text('Agrega productos desde la pestaña "1. Productos"', style: TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariantColor)),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: cart.items.length,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return FintechCard(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: LocalImageHelper.buildProductImage(
                        item.product.imagePath,
                        width: 48,
                        height: 48,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.onSurfaceColor)),
                          const SizedBox(height: 4),
                          Text(
                            '${item.quantity} x ${CurrencyFormatter.format(item.product.sellingPrice)} = ${CurrencyFormatter.format(item.subtotal)}',
                            style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_rounded, color: AppTheme.onSurfaceVariantColor, size: 20),
                          onPressed: () => ref.read(cartProvider.notifier).updateQuantity(item.product.id, item.quantity - 1),
                        ),
                        Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.onSurfaceColor)),
                        IconButton(
                          icon: const Icon(Icons.add_rounded, color: AppTheme.onSurfaceVariantColor, size: 20),
                          onPressed: () => ref.read(cartProvider.notifier).updateQuantity(item.product.id, item.quantity + 1),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorColor, size: 20),
                          onPressed: () => ref.read(cartProvider.notifier).removeItem(item.product.id),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppTheme.outlineVariantColor, width: 1)),
            boxShadow: [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 16,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total a Cobrar:', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.onSurfaceColor)),
                    Text(
                      CurrencyFormatter.format(cart.total),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.primaryColor, letterSpacing: -0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _confirmClearCart(context, ref),
                        child: const Text('Vaciar Carrito'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryContainerColor,
                        ),
                        onPressed: () => _openCheckout(context),
                        child: const Text('Cobrar / Pagar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSalesHistoryTab(BuildContext context, WidgetRef ref, AsyncValue<List<SaleEntity>> salesAsync) {
    return Column(
      children: [
        // Buscador de Historial
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
          child: TextField(
            controller: _historySearchController,
            style: const TextStyle(color: AppTheme.onSurfaceColor, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Buscar por N° Venta o Cliente...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.outlineColor, size: 20),
              suffixIcon: _historyQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppTheme.outlineColor, size: 18),
                      onPressed: () {
                        setState(() => _historyQuery = '');
                        _historySearchController.clear();
                      },
                    )
                  : null,
            ),
            onChanged: (val) {
              setState(() => _historyQuery = val.trim().toLowerCase());
            },
          ),
        ),

        // Listado con CRUD Desplegable
        Expanded(
          child: salesAsync.when(
            data: (sales) {
              var filteredSales = sales;
              if (_historyQuery.isNotEmpty) {
                filteredSales = sales.where((s) {
                  final idStr = s.id.toString();
                  final custName = (s.customerName ?? '').toLowerCase();
                  final pay = s.paymentMethod.toLowerCase();
                  return idStr.contains(_historyQuery) || custName.contains(_historyQuery) || pay.contains(_historyQuery);
                }).toList();
              }

              if (filteredSales.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: AppTheme.surfaceContainerLow,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.receipt_long_outlined, size: 32, color: AppTheme.outlineColor),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'No hay ventas registradas',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.onSurfaceColor),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Las ventas que realices aparecerán aquí con su detalle.',
                        style: TextStyle(color: AppTheme.onSurfaceVariantColor, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: AppTheme.primaryColor,
                onRefresh: () async {
                  ref.invalidate(salesListProvider);
                },
                child: ListView.builder(
                  itemCount: filteredSales.length,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                  itemBuilder: (context, index) {
                    final sale = filteredSales[index];
                    return _buildSaleHistoryExpandableCard(context, ref, sale);
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
            error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: AppTheme.errorColor))),
          ),
        ),
      ],
    );
  }

  Widget _buildSaleHistoryExpandableCard(BuildContext context, WidgetRef ref, SaleEntity sale) {
    final settings = ref.watch(settingsNotifierProvider);
    final ticketSeriesNumber = '${settings.ticketSeries}-${sale.id.toString().padLeft(8, '0')}';

    return FintechCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_rounded, color: AppTheme.primaryColor, size: 22),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Venta #${sale.id.toString().padLeft(4, '0')}',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.onSurfaceColor),
              ),
              Text(
                CurrencyFormatter.format(sale.total),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.primaryColor),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 3),
              Text(
                '${DateFormatter.formatDateTime(sale.date)} • ${sale.customerName ?? 'Clientes Varios'}',
                style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariantColor),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.outlineVariantColor),
                    ),
                    child: Text(
                      ticketSeriesNumber,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primaryColor),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getPaymentBadgeColor(sale.paymentMethod).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      sale.paymentMethod.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _getPaymentBadgeColor(sale.paymentMethod),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: [
            const Divider(color: AppTheme.outlineVariantColor, height: 16),
            
            // Carga asíncrona de ítems de la venta
            FutureBuilder<List<SaleItemEntity>>(
              future: ref.read(getSaleItemsUseCaseProvider).call(sale.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                  );
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return const Text('Sin detalle de productos', style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariantColor));
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PRODUCTOS COMPRADOS:',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.onSurfaceVariantColor, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 8),
                    ...items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.quantity} x ${item.productName}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.onSurfaceColor),
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(item.subtotal),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.onSurfaceColor),
                          ),
                        ],
                      ),
                    )),
                    if (sale.discount > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Descuento aplicado:', style: TextStyle(fontSize: 12, color: AppTheme.tertiaryColor, fontWeight: FontWeight.w600)),
                          Text('- ${CurrencyFormatter.format(sale.discount)}', style: const TextStyle(fontSize: 12, color: AppTheme.tertiaryColor, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ],
                );
              },
            ),

            const SizedBox(height: 14),

            // Botones de Acción (CRUD)
            Row(
              children: [
                // 1. Ver / Imprimir Comprobante SUNAT
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _openSaleReceipt(context, sale),
                    icon: const Icon(Icons.receipt_long_rounded, size: 16),
                    label: const Text('Ver Ticket / Boleta', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 8),

                // 2. Anular Venta (Devuelve stock)
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      side: const BorderSide(color: AppTheme.errorColor, width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _confirmVoidSale(context, ref, sale),
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    label: const Text('Anular', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPaymentBadgeColor(String method) {
    switch (method.toLowerCase()) {
      case 'efectivo':
        return AppTheme.secondaryColor;
      case 'yape':
        return const Color(0xFF8B5CF6);
      case 'plin':
        return const Color(0xFF06B6D4);
      case 'tarjeta':
        return const Color(0xFFF59E0B);
      default:
        return AppTheme.primaryColor;
    }
  }

  void _openCheckout(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CheckoutDialog(),
    );
  }

  void _scanProductToCart(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final scannedCode = await showDialog<String>(
      context: context,
      builder: (ctx) => const BarcodeScannerDialog(title: 'Escanear para el Carrito'),
    );

    if (scannedCode == null || scannedCode.isEmpty) return;

    final products = await ref.read(productsListProvider.future);
    ProductEntity? found;
    for (final p in products) {
      if (p.sku == scannedCode) {
        found = p;
        break;
      }
    }

    if (!mounted) return;

    if (found != null && found.isActive) {
      if (found.stock > 0) {
        ref.read(cartProvider.notifier).addItem(found);
        messenger.showSnackBar(
          SnackBar(
            content: Text('"${found.name}" agregado al carrito (+1)'),
            backgroundColor: AppTheme.secondaryColor,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text('"${found.name}" está agotado (Stock: 0)'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Código "$scannedCode" no encontrado.'),
          backgroundColor: AppTheme.tertiaryColor,
        ),
      );
    }
  }

  void _openLatestReceipt() async {
    final messenger = ScaffoldMessenger.of(context);
    final sales = await ref.read(salesListProvider.future);
    if (sales.isEmpty) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('No hay comprobantes de venta registrados aún.'), backgroundColor: AppTheme.primaryColor),
      );
      return;
    }
    if (!mounted) return;
    _openSaleReceipt(context, sales.first);
  }

  void _openSaleReceipt(BuildContext context, SaleEntity sale) async {
    final items = await ref.read(getSaleItemsUseCaseProvider).call(sale.id);
    final settings = ref.read(settingsNotifierProvider);

    final snapshotItems = items.map((i) => ReceiptItemData(
      productName: i.productName,
      quantity: i.quantity,
      unitPrice: i.unitSellingPrice,
      subtotal: i.subtotal,
      unitMeasure: 'UND',
    )).toList();

    final total = sale.total;
    final taxable = total / 1.18;
    final igv = total - taxable;

    final receipt = ReceiptData(
      saleId: sale.id,
      documentType: DocumentType.ticket,
      seriesNumber: '${settings.ticketSeries}-${sale.id.toString().padLeft(8, '0')}',
      machineSeries: settings.machineSeries,
      emissionDate: sale.date,
      issuerName: settings.businessName,
      issuerRuc: settings.ruc,
      issuerAddress: settings.address,
      issuerPhone: settings.phone,
      customerName: sale.customerName ?? 'Clientes Varios',
      customerDocType: 'DOC',
      customerDocNumber: '-',
      items: snapshotItems,
      subtotal: total + sale.discount,
      discount: sale.discount,
      taxableAmount: taxable,
      igvAmount: igv,
      total: total,
      paymentMethod: sale.paymentMethod,
      currency: settings.currency,
    );

    if (!mounted) return;
    showDialog(
      context: this.context,
      builder: (ctx) => ReceiptViewerDialog(receipt: receipt),
    );
  }

  void _confirmVoidSale(BuildContext context, WidgetRef ref, SaleEntity sale) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorContainerColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor, size: 22),
            ),
            const SizedBox(width: 10),
            const Text('¿Anular Venta?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.onSurfaceColor)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro de que deseas anular la Venta #${sale.id.toString().padLeft(4, '0')} por un total de ${CurrencyFormatter.format(sale.total)}?',
              style: const TextStyle(fontSize: 14, color: AppTheme.onSurfaceColor),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.outlineVariantColor),
              ),
              child: const Row(
                children: [
                  Icon(Icons.inventory_2_outlined, size: 18, color: AppTheme.primaryColor),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'El stock de los productos vendidos será devuelto automáticamente al inventario.',
                      style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariantColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AppTheme.onSurfaceVariantColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor, foregroundColor: Colors.white),
            onPressed: () async {
              await ref.read(salesListProvider.notifier).voidSale(sale.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text('Venta #${sale.id.toString().padLeft(4, '0')} anulada y stock devuelto con éxito.'),
                    backgroundColor: AppTheme.secondaryColor,
                  ),
                );
              }
            },
            child: const Text('Confirmar Anulación'),
          ),
        ],
      ),
    );
  }

  void _confirmClearCart(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Vaciar Carrito?'),
        content: const Text('¿Estás seguro de que deseas vaciar todos los productos del carrito?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor, foregroundColor: Colors.white),
            onPressed: () {
              ref.read(cartProvider.notifier).clearCart();
              Navigator.pop(ctx);
            },
            child: const Text('Vaciar'),
          ),
        ],
      ),
    );
  }
}
