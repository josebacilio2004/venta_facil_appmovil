import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/barcode_scanner_dialog.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../products/presentation/providers/products_providers.dart';
import '../../../products/domain/entities/product.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/entities/receipt_data.dart';
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
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final productsFilter = ref.watch(productsFilterProvider);
    final productsAsync = ref.watch(productsListProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'REGISTRAR VENTA',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.receipt_long, color: Colors.tealAccent),
              tooltip: 'Ver Último Ticket / Comprobante',
              onPressed: () => _openLatestReceipt(context),
            ),
          ],
          bottom: TabBar(
            labelColor: Colors.tealAccent,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.tealAccent,
            indicatorWeight: 3,
            tabs: [
              const Tab(icon: Icon(Icons.search), text: '1. Productos'),
              Tab(
                icon: const Icon(Icons.shopping_cart),
                text: '2. Carrito (${cart.items.fold(0, (sum, i) => sum + i.quantity)})',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Selección Rápida de Productos y Escáner
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: GlassCard(
                    padding: EdgeInsets.zero,
                    borderRadius: BorderRadius.circular(16),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre o escanear SKU...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        prefixIcon: const Icon(Icons.search, color: Colors.white70),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_searchQuery.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear, color: Colors.white70),
                                onPressed: () {
                                  setState(() => _searchQuery = '');
                                  _searchController.clear();
                                  ref.read(productsFilterProvider.notifier).state = productsFilter.copyWith(query: '');
                                },
                              ),
                            IconButton(
                              icon: const Icon(Icons.qr_code_scanner, color: Colors.tealAccent),
                              tooltip: 'Escanear producto al carrito',
                              onPressed: () => _scanProductToCart(context),
                            ),
                          ],
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onChanged: (val) {
                        setState(() => _searchQuery = val.trim());
                        ref.read(productsFilterProvider.notifier).state = productsFilter.copyWith(query: val.trim());
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: productsAsync.when(
                    data: (products) {
                      final sellable = products.where((p) => p.isActive).toList();
                      if (sellable.isEmpty) {
                        return const Center(
                          child: Text('No hay productos disponibles para la venta.', style: TextStyle(color: Colors.white70)),
                        );
                      }
                      return ListView.builder(
                        itemCount: sellable.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        itemBuilder: (context, index) {
                          final product = sellable[index];
                          return _buildSellProductRow(context, ref, product, cart);
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                    error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
                  ),
                ),
              ],
            ),

            // Tab 2: Resumen del Carrito
            _buildCartTab(context, ref, cart),
          ],
        ),
      ),
    );
  }

  Widget _buildSellProductRow(BuildContext context, WidgetRef ref, ProductEntity p, CartState cart) {
    final cartItemIndex = cart.items.indexWhere((i) => i.product.id == p.id);
    final inCartQty = cartItemIndex >= 0 ? cart.items[cartItemIndex].quantity : 0;
    final availableStock = p.stock - inCartQty;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  'Precio: ${CurrencyFormatter.format(p.sellingPrice)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.tealAccent, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  'Stock Disp: $availableStock',
                  style: TextStyle(
                    color: availableStock <= 0 ? Colors.redAccent : (availableStock <= p.minStock ? Colors.orangeAccent : Colors.white60),
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
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 28),
                  onPressed: () => ref.read(cartProvider.notifier).updateQuantity(p.id, inCartQty - 1),
                ),
                Text('$inCartQty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
              ],
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.tealAccent, size: 32),
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.white30),
            SizedBox(height: 16),
            Text('El carrito está vacío', style: TextStyle(fontSize: 18, color: Colors.white70)),
            SizedBox(height: 8),
            Text('Agrega productos desde la pestaña "1. Productos"', style: TextStyle(fontSize: 13, color: Colors.white38)),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: cart.items.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return GlassCard(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(
                            '${item.quantity} x ${CurrencyFormatter.format(item.product.sellingPrice)} = ${CurrencyFormatter.format(item.subtotal)}',
                            style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.white70),
                          onPressed: () => ref.read(cartProvider.notifier).updateQuantity(item.product.id, item.quantity - 1),
                        ),
                        Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.white70),
                          onPressed: () => ref.read(cartProvider.notifier).updateQuantity(item.product.id, item.quantity + 1),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
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
        GlassCard(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total a Cobrar:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(
                    CurrencyFormatter.format(cart.total),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.tealAccent),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _confirmClearCart(context, ref),
                      child: const Text('Vaciar Carrito'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _openCheckout(context),
                      child: const Text('Cobrar / Pagar', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
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
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text('"${found.name}" está agotado (Stock: 0)'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Código "$scannedCode" no encontrado.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }
  }

  void _openLatestReceipt(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final sales = await ref.read(salesListProvider.future);
    if (sales.isEmpty) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('No hay comprobantes de venta registrados aún.'), backgroundColor: Colors.teal),
      );
      return;
    }

    final latestSale = sales.first;
    final items = await ref.read(getSaleItemsUseCaseProvider).call(latestSale.id);
    final settings = ref.read(settingsNotifierProvider);

    final snapshotItems = items.map((i) => ReceiptItemData(
      productName: i.productName,
      quantity: i.quantity,
      unitPrice: i.unitSellingPrice,
      subtotal: i.subtotal,
      unitMeasure: 'UND',
    )).toList();

    final total = latestSale.total;
    final taxable = total / 1.18;
    final igv = total - taxable;

    final receipt = ReceiptData(
      saleId: latestSale.id,
      documentType: DocumentType.ticket,
      seriesNumber: '${settings.ticketSeries}-${latestSale.id.toString().padLeft(8, '0')}',
      machineSeries: settings.machineSeries,
      emissionDate: latestSale.date,
      issuerName: settings.businessName,
      issuerRuc: settings.ruc,
      issuerAddress: settings.address,
      issuerPhone: settings.phone,
      customerName: 'Cliente Registrado',
      customerDocType: 'DOC',
      customerDocNumber: '-',
      items: snapshotItems,
      subtotal: total + latestSale.discount,
      discount: latestSale.discount,
      taxableAmount: taxable,
      igvAmount: igv,
      total: total,
      paymentMethod: latestSale.paymentMethod,
      currency: settings.currency,
    );

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => ReceiptViewerDialog(receipt: receipt),
    );
  }

  void _confirmClearCart(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F766E),
        title: const Text('¿Vaciar Carrito?', style: TextStyle(color: Colors.white)),
        content: const Text('¿Estás seguro de que deseas vaciar todos los productos del carrito?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
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
