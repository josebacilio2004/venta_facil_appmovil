import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/barcode_scanner_dialog.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_card.dart';
import '../providers/products_providers.dart';
import '../../domain/entities/product.dart';
import '../widgets/product_form_dialog.dart';
import '../widgets/category_manage_dialog.dart';

class ProductsPage extends ConsumerWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsListProvider);
    final categoriesAsync = ref.watch(categoriesListProvider);
    final filter = ref.watch(productsFilterProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'PRODUCTOS',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Escanear y Sumar Stock',
            onPressed: () => _scanAndManageStock(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Categorías',
            onPressed: () => _openCategoriesManager(context),
          ),
        ],
      ),
      body: GlassBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Barra de Búsqueda
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: GlassCard(
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.circular(16),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre o SKU...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      suffixIcon: filter.query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white70),
                              onPressed: () => ref.read(productsFilterProvider.notifier).state = filter.copyWith(query: ''),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onChanged: (val) {
                      ref.read(productsFilterProvider.notifier).state = filter.copyWith(query: val.trim());
                    },
                  ),
                ),
              ),
              
              // Filtro Horizontal de Categorías
              categoriesAsync.when(
                data: (cats) {
                  return SizedBox(
                    height: 48,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        ChoiceChip(
                          label: const Text('Todos'),
                          selected: filter.categoryId == null,
                          selectedColor: Colors.tealAccent.withOpacity(0.3),
                          backgroundColor: Colors.white.withOpacity(0.12),
                          labelStyle: TextStyle(
                            color: filter.categoryId == null ? Colors.tealAccent : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (_) {
                            ref.read(productsFilterProvider.notifier).state = filter.copyWith(clearCategory: true);
                          },
                        ),
                        const SizedBox(width: 8),
                        ...cats.map((c) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(c.name),
                                selected: filter.categoryId == c.id,
                                selectedColor: Colors.tealAccent.withOpacity(0.3),
                                backgroundColor: Colors.white.withOpacity(0.12),
                                labelStyle: TextStyle(
                                  color: filter.categoryId == c.id ? Colors.tealAccent : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    ref.read(productsFilterProvider.notifier).state = filter.copyWith(categoryId: c.id);
                                  }
                                },
                              ),
                            )),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox(height: 48, child: Center(child: CircularProgressIndicator(color: Colors.white))),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 12),

              // Listado de Productos
              Expanded(
                child: productsAsync.when(
                  data: (products) {
                    if (products.isEmpty) {
                      return const Center(child: Text('No se encontraron productos.', style: TextStyle(color: Colors.white70)));
                    }
                    return ListView.builder(
                      itemCount: products.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return _buildProductCard(context, ref, product);
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                  error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_products',
        onPressed: () => _openProductForm(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Producto'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F766E),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, WidgetRef ref, ProductEntity p) {
    Color stockColor = Colors.greenAccent;
    String stockLabel = 'Stock: ${p.stock}';
    if (p.isOutOfStock) {
      stockColor = Colors.redAccent;
      stockLabel = 'AGOTADO';
    } else if (p.isLowStock) {
      stockColor = Colors.orangeAccent;
      stockLabel = 'Stock Bajo: ${p.stock}';
    }

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                ),
                if (p.sku != null && p.sku!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text('SKU: ${p.sku}', style: const TextStyle(color: Colors.white60, fontSize: 13)),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Venta: ${CurrencyFormatter.format(p.sellingPrice)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.tealAccent),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Compra: ${CurrencyFormatter.format(p.purchasePrice)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Ganancia: ${CurrencyFormatter.format(p.unitProfit)}',
                  style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: stockColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: stockColor),
                ),
                child: Text(
                  stockLabel,
                  style: TextStyle(color: stockColor, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.cyanAccent),
                    onPressed: () => _openProductForm(context, p),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _confirmDelete(context, ref, p),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openProductForm(BuildContext context, ProductEntity? p) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProductFormDialog(product: p),
    );
  }

  void _openCategoriesManager(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CategoryManageDialog(),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, ProductEntity p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F766E),
        title: const Text('¿Eliminar Producto?', style: TextStyle(color: Colors.white)),
        content: Text('¿Estás seguro de que deseas eliminar "${p.name}"? Esta acción no se puede deshacer.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              ref.read(productsListProvider.notifier).deleteProduct(p.id);
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _scanAndManageStock(BuildContext context, WidgetRef ref) async {
    final scannedCode = await showDialog<String>(
      context: context,
      builder: (ctx) => const BarcodeScannerDialog(title: 'Buscar / Sumar Stock'),
    );

    if (scannedCode == null || scannedCode.isEmpty) return;

    final products = await ref.read(productsListProvider.future);
    ProductEntity? product;
    for (final p in products) {
      if (p.sku == scannedCode) {
        product = p;
        break;
      }
    }

    if (product == null) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF0F766E),
            title: const Text('Código no registrado', style: TextStyle(color: Colors.white)),
            content: Text('El código "$scannedCode" no corresponde a ningún producto.\n¿Deseas registrar un nuevo producto con este código?', style: const TextStyle(color: Colors.white70)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.white70))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent, foregroundColor: Colors.black),
                onPressed: () {
                  Navigator.pop(ctx);
                  showDialog(
                    context: context,
                    builder: (c) => ProductFormDialog(
                      product: ProductEntity(
                        id: 0,
                        name: '',
                        purchasePrice: 0,
                        sellingPrice: 0,
                        stock: 0,
                        minStock: 5,
                        sku: scannedCode,
                        isActive: true,
                        createdAt: DateTime.now(),
                      ),
                    ),
                  );
                },
                child: const Text('Registrar'),
              ),
            ],
          ),
        );
      }
    } else {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => _StockAdjustmentDialog(product: product!, ref: ref),
        );
      }
    }
  }
}

class _StockAdjustmentDialog extends StatefulWidget {
  final ProductEntity product;
  final WidgetRef ref;

  const _StockAdjustmentDialog({required this.product, required this.ref});

  @override
  State<_StockAdjustmentDialog> createState() => _StockAdjustmentDialogState();
}

class _StockAdjustmentDialogState extends State<_StockAdjustmentDialog> {
  late int _stockToAdd;

  @override
  void initState() {
    super.initState();
    _stockToAdd = 1;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0F766E),
      title: Text('Sumar Stock - ${widget.product.name}', style: const TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Stock actual: ${widget.product.stock}', style: const TextStyle(fontSize: 16, color: Colors.white70)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 36, color: Colors.tealAccent),
                onPressed: () {
                  if (_stockToAdd > 1) {
                    setState(() => _stockToAdd--);
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  '+$_stockToAdd',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 36, color: Colors.tealAccent),
                onPressed: () {
                  setState(() => _stockToAdd++);
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent, foregroundColor: Colors.black),
          onPressed: () {
            final updatedProduct = ProductEntity(
              id: widget.product.id,
              categoryId: widget.product.categoryId,
              name: widget.product.name,
              description: widget.product.description,
              purchasePrice: widget.product.purchasePrice,
              sellingPrice: widget.product.sellingPrice,
              stock: widget.product.stock + _stockToAdd,
              minStock: widget.product.minStock,
              sku: widget.product.sku,
              isActive: widget.product.isActive,
              createdAt: widget.product.createdAt,
            );
            widget.ref.read(productsListProvider.notifier).updateProduct(updatedProduct);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Se sumaron $_stockToAdd unidades a ${widget.product.name}'),
                backgroundColor: Colors.green,
              ),
            );
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
