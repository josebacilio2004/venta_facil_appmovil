import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/barcode_scanner_dialog.dart';
import '../../../../core/widgets/fintech_card.dart';
import '../providers/products_providers.dart';
import '../../domain/entities/product.dart';
import '../widgets/product_form_dialog.dart';
import '../widgets/category_manage_dialog.dart';

class ProductsPage extends ConsumerWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _ProductsPageContent();
  }
}

class _ProductsPageContent extends ConsumerWidget {
  const _ProductsPageContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsListProvider);
    final categoriesAsync = ref.watch(categoriesListProvider);
    final filter = ref.watch(productsFilterProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Productos e Inventario',
          style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.onSurfaceColor, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded, color: AppTheme.primaryColor),
            tooltip: 'Escanear y Sumar Stock',
            onPressed: () => _scanAndManageStock(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.category_outlined, color: AppTheme.onSurfaceColor),
            tooltip: 'Gestionar Categorías',
            onPressed: () => _openCategoriesManager(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Barra de Búsqueda
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 10.0),
            child: TextField(
              style: const TextStyle(color: AppTheme.onSurfaceColor, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o SKU...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.outlineColor, size: 20),
                suffixIcon: filter.query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppTheme.outlineColor, size: 18),
                        onPressed: () => ref.read(productsFilterProvider.notifier).state = filter.copyWith(query: ''),
                      )
                    : null,
              ),
              onChanged: (val) {
                ref.read(productsFilterProvider.notifier).state = filter.copyWith(query: val.trim());
              },
            ),
          ),

          // Filtro Horizontal de Categorías
          categoriesAsync.when(
            data: (cats) {
              return SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    ChoiceChip(
                      label: const Text('Todos'),
                      selected: filter.categoryId == null && filter.onlyLowStock != true,
                      selectedColor: AppTheme.primaryColor,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: filter.categoryId == null && filter.onlyLowStock != true ? Colors.white : AppTheme.onSurfaceVariantColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      side: const BorderSide(color: AppTheme.outlineVariantColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                      onSelected: (_) {
                        ref.read(productsFilterProvider.notifier).state = filter.copyWith(clearCategory: true, onlyLowStock: false);
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Stock bajo'),
                      selected: filter.onlyLowStock == true,
                      selectedColor: AppTheme.tertiaryColor,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: filter.onlyLowStock == true ? Colors.white : AppTheme.onSurfaceVariantColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      side: const BorderSide(color: AppTheme.outlineVariantColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                      onSelected: (selected) {
                        ref.read(productsFilterProvider.notifier).state = filter.copyWith(onlyLowStock: selected);
                      },
                    ),
                    const SizedBox(width: 8),
                    ...cats.map((c) {
                      final isSelected = filter.categoryId == c.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(c.name),
                          selected: isSelected,
                          selectedColor: AppTheme.primaryColor,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.onSurfaceVariantColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          side: const BorderSide(color: AppTheme.outlineVariantColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                          onSelected: (sel) {
                            ref.read(productsFilterProvider.notifier).state = filter.copyWith(
                              categoryId: sel ? c.id : null,
                              clearCategory: !sel,
                              onlyLowStock: false,
                            );
                          },
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
            loading: () => const SizedBox(height: 38),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 10),

          // Lista de Productos
          Expanded(
            child: productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
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
                          child: const Icon(Icons.inventory_2_outlined, size: 32, color: AppTheme.outlineColor),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'No hay productos registrados',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.onSurfaceColor),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Presiona el botón "+" para agregar tu primer producto.',
                          style: TextStyle(color: AppTheme.onSurfaceVariantColor, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: products.length,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _buildProductCard(context, ref, product);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
              error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: AppTheme.errorColor))),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_products',
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => _openProductForm(context),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, WidgetRef ref, ProductEntity p) {
    final isOutOfStock = p.stock <= 0;
    final isLowStock = !isOutOfStock && p.stock <= p.minStock;

    Color stockBadgeBg;
    Color stockBadgeText;
    String stockBadgeLabel;

    if (isOutOfStock) {
      stockBadgeBg = AppTheme.errorContainerColor;
      stockBadgeText = AppTheme.errorColor;
      stockBadgeLabel = 'Agotado';
    } else if (isLowStock) {
      stockBadgeBg = AppTheme.tertiaryContainerColor.withValues(alpha: 0.15);
      stockBadgeText = AppTheme.tertiaryColor;
      stockBadgeLabel = '${p.stock} unid.';
    } else {
      stockBadgeBg = AppTheme.secondaryContainerColor.withValues(alpha: 0.3);
      stockBadgeText = AppTheme.secondaryColor;
      stockBadgeLabel = '${p.stock} unid.';
    }

    return FintechCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      onTap: () => _openProductForm(context, product: p),
      child: Row(
        children: [
          // Avatar Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.inventory_2_outlined, color: AppTheme.primaryColor, size: 24),
          ),
          const SizedBox(width: 12),

          // Name, Description & SKU
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.onSurfaceColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  p.sku != null && p.sku!.isNotEmpty
                      ? 'SKU: ${p.sku}'
                      : (p.description ?? 'Producto'),
                  style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariantColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.format(p.sellingPrice),
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryColor, fontSize: 15),
                ),
              ],
            ),
          ),

          // Stock Badge & Add Stock Action
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: stockBadgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  stockBadgeLabel,
                  style: TextStyle(color: stockBadgeText, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: () => _showQuickAddStockDialog(context, ref, p),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14, color: AppTheme.primaryColor),
                      SizedBox(width: 2),
                      Text('Stock', style: TextStyle(color: AppTheme.primaryColor, fontSize: 11, fontWeight: FontWeight.w700)),
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

  void _openProductForm(BuildContext context, {ProductEntity? product}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProductFormDialog(product: product),
    );
  }

  void _openCategoriesManager(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CategoryManageDialog(),
    );
  }

  void _showQuickAddStockDialog(BuildContext context, WidgetRef ref, ProductEntity product) {
    final qtyController = TextEditingController(text: '1');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sumar Stock a "${product.name}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stock Actual: ${product.stock} unid.', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Unidades a agregar',
                prefixIcon: Icon(Icons.add_box_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final added = int.tryParse(qtyController.text) ?? 0;
              if (added > 0) {
                final updated = product.copyWith(stock: product.stock + added);
                await ref.read(updateProductUseCaseProvider).call(updated);
                ref.invalidate(productsListProvider);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _scanAndManageStock(BuildContext context, WidgetRef ref) async {
    final scannedCode = await showDialog<String>(
      context: context,
      builder: (ctx) => const BarcodeScannerDialog(title: 'Escanear Producto para Stock'),
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

    if (!context.mounted) return;

    if (found != null) {
      _showQuickAddStockDialog(context, ref, found);
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Producto no Encontrado'),
          content: Text('El código "$scannedCode" no está registrado. ¿Deseas registrar un nuevo producto con este SKU?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (c) => ProductFormDialog(initialSku: scannedCode),
                );
              },
              child: const Text('Crear Producto'),
            ),
          ],
        ),
      );
    }
  }
}
