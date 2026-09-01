import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/local_image_helper.dart';
import '../../../../core/widgets/barcode_scanner_dialog.dart';
import '../../../../core/widgets/fintech_card.dart';
import '../providers/products_providers.dart';
import '../../domain/entities/product.dart';
import '../widgets/product_form_dialog.dart';
import '../widgets/product_detail_dialog.dart';
import '../widgets/category_manage_dialog.dart';

final productViewModeProvider = StateProvider<bool>((ref) => false); // false = Lista, true = Catálogo (Grid)

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
    final isCatalogMode = ref.watch(productViewModeProvider);

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
          // Conmutador Vista Lista / Vista Catálogo
          IconButton(
            icon: Icon(
              isCatalogMode ? Icons.view_list_rounded : Icons.grid_view_rounded,
              color: AppTheme.primaryColor,
            ),
            tooltip: isCatalogMode ? 'Ver en Lista' : 'Ver en Catálogo (Cuadrícula)',
            onPressed: () {
              ref.read(productViewModeProvider.notifier).state = !isCatalogMode;
            },
          ),
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
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Barra de Búsqueda
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
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
                      label: const Text('⚠️ Stock Bajo'),
                      selected: filter.onlyLowStock == true,
                      selectedColor: AppTheme.tertiaryColor,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: filter.onlyLowStock == true ? Colors.white : AppTheme.tertiaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                      side: const BorderSide(color: AppTheme.outlineVariantColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                      onSelected: (selected) {
                        ref.read(productsFilterProvider.notifier).state = filter.copyWith(onlyLowStock: selected);
                      },
                    ),
                    const SizedBox(width: 8),
                    ...cats.map((c) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(c.name),
                        selected: filter.categoryId == c.id && filter.onlyLowStock != true,
                        selectedColor: AppTheme.primaryColor,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: filter.categoryId == c.id && filter.onlyLowStock != true ? Colors.white : AppTheme.onSurfaceVariantColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        side: const BorderSide(color: AppTheme.outlineVariantColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                        onSelected: (selected) {
                          ref.read(productsFilterProvider.notifier).state = selected
                              ? filter.copyWith(categoryId: c.id, onlyLowStock: false)
                              : filter.copyWith(clearCategory: true);
                        },
                      ),
                    )),
                  ],
                ),
              );
            },
            loading: () => const SizedBox(height: 38),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 10),

          // Listado de Productos (Lista o Catálogo Grid)
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
                        const SizedBox(height: 16),
                        const Text(
                          'No hay productos registrados',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.onSurfaceColor),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Toca el botón "+" para agregar tu primer producto',
                          style: TextStyle(color: AppTheme.onSurfaceVariantColor, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                if (isCatalogMode) {
                  // Modo Catálogo (Grid 2x2)
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _buildCatalogProductCard(context, ref, product);
                    },
                  );
                }

                // Modo Lista Estándar
                return ListView.builder(
                  itemCount: products.length,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _buildListProductCard(context, ref, product);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
              error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: AppTheme.errorColor))),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () => _openProductForm(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nuevo Producto', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }

  // Tarjeta en Modo Lista
  Widget _buildListProductCard(BuildContext context, WidgetRef ref, ProductEntity product) {
    final isOutOfStock = product.stock <= 0;
    final isLowStock = !isOutOfStock && product.stock <= product.minStock;

    Color stockColor = AppTheme.secondaryColor;
    Color stockBg = AppTheme.secondaryContainerColor.withValues(alpha: 0.3);
    String stockText = '${product.stock} disp.';

    if (isOutOfStock) {
      stockColor = AppTheme.errorColor;
      stockBg = AppTheme.errorContainerColor;
      stockText = 'Agotado';
    } else if (isLowStock) {
      stockColor = AppTheme.tertiaryColor;
      stockBg = AppTheme.tertiaryContainerColor.withValues(alpha: 0.15);
      stockText = '${product.stock} bajo';
    }

    return InkWell(
      onTap: () => _openProductDetail(context, product),
      borderRadius: BorderRadius.circular(16),
      child: FintechCard(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Imagen local o placeholder
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: LocalImageHelper.buildProductImage(
                product.imagePath,
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
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.onSurfaceColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        CurrencyFormatter.format(product.sellingPrice),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: stockBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          stockText,
                          style: TextStyle(
                            color: stockColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_box_rounded, color: AppTheme.primaryColor, size: 24),
                  tooltip: 'Sumar Stock Rápido',
                  onPressed: () => _showQuickAddStockDialog(context, ref, product),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: AppTheme.outlineColor, size: 20),
                  onSelected: (val) {
                    if (val == 'detail') _openProductDetail(context, product);
                    if (val == 'edit') _openProductForm(context, product);
                    if (val == 'delete') _confirmDeleteProduct(context, ref, product);
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'detail',
                      child: Row(children: [Icon(Icons.info_outline_rounded, size: 18), SizedBox(width: 8), Text('Ver Detalle')]),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text('Editar')]),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [Icon(Icons.delete_outline_rounded, color: AppTheme.errorColor, size: 18), SizedBox(width: 8), Text('Eliminar', style: TextStyle(color: AppTheme.errorColor))]),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Tarjeta en Modo Catálogo (Grid)
  Widget _buildCatalogProductCard(BuildContext context, WidgetRef ref, ProductEntity product) {
    final isOutOfStock = product.stock <= 0;
    final isLowStock = !isOutOfStock && product.stock <= product.minStock;

    Color stockColor = AppTheme.secondaryColor;
    Color stockBg = AppTheme.secondaryContainerColor.withValues(alpha: 0.3);
    String stockText = '${product.stock} disp.';

    if (isOutOfStock) {
      stockColor = AppTheme.errorColor;
      stockBg = AppTheme.errorContainerColor;
      stockText = 'Agotado';
    } else if (isLowStock) {
      stockColor = AppTheme.tertiaryColor;
      stockBg = AppTheme.tertiaryContainerColor.withValues(alpha: 0.15);
      stockText = '${product.stock} bajo';
    }

    return InkWell(
      onTap: () => _openProductDetail(context, product),
      borderRadius: BorderRadius.circular(16),
      child: FintechCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image Area
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 125,
                  decoration: const BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: LocalImageHelper.buildProductImage(
                    product.imagePath,
                    width: double.infinity,
                    height: 125,
                    fit: BoxFit.cover,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: stockBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      stockText,
                      style: TextStyle(
                        color: stockColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Information Body
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.onSurfaceColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        CurrencyFormatter.format(product.sellingPrice),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      InkWell(
                        onTap: () => _showQuickAddStockDialog(context, ref, product),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.add_rounded, size: 16, color: AppTheme.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openProductDetail(BuildContext context, ProductEntity product) {
    showDialog(
      context: context,
      builder: (ctx) => ProductDetailDialog(product: product),
    );
  }

  void _openProductForm(BuildContext context, [ProductEntity? product]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => ProductFormDialog(product: product),
    );
  }

  void _openCategoriesManager(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const CategoryManageDialog(),
    );
  }

  void _scanAndManageStock(BuildContext context, WidgetRef ref) async {
    final scannedCode = await showDialog<String>(
      context: context,
      builder: (ctx) => const BarcodeScannerDialog(title: 'Escanear Producto'),
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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Producto No Encontrado'),
          content: Text('No existe un producto con el código "$scannedCode". ¿Deseas registrarlo ahora?'),
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
              child: const Text('Registrar'),
            ),
          ],
        ),
      );
    }
  }

  void _showQuickAddStockDialog(BuildContext context, WidgetRef ref, ProductEntity product) {
    final qtyController = TextEditingController(text: '1');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sumar Stock a "${product.name}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stock Actual: ${product.stock} unidades', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Unidades a sumar (+)',
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
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Se agregaron +$added unidades a "${product.name}" (Total: ${updated.stock})'),
                      backgroundColor: AppTheme.secondaryColor,
                    ),
                  );
                }
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Sumar Stock'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteProduct(BuildContext context, WidgetRef ref, ProductEntity product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Eliminar producto?'),
        content: Text('¿Estás seguro de que deseas eliminar "${product.name}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor, foregroundColor: Colors.white),
            onPressed: () async {
              await ref.read(deleteProductUseCaseProvider).call(product.id);
              ref.invalidate(productsListProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
