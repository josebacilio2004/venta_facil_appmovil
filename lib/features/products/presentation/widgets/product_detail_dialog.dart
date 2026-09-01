import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/local_image_helper.dart';
import '../../../../core/widgets/fintech_card.dart';
import '../../domain/entities/product.dart';
import '../providers/products_providers.dart';
import '../../../sales/presentation/providers/sales_providers.dart';
import 'product_form_dialog.dart';

class ProductDetailDialog extends ConsumerWidget {
  final ProductEntity product;

  const ProductDetailDialog({required this.product, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesListProvider);
    final categoryName = categoriesAsync.maybeWhen(
      data: (cats) => cats.firstWhere((c) => c.id == product.categoryId, orElse: () => cats.first).name,
      orElse: () => 'General',
    );

    final isOutOfStock = product.stock <= 0;
    final isLowStock = !isOutOfStock && product.stock <= product.minStock;

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
      stockBadgeLabel = 'Stock Bajo (${product.stock} unid.)';
    } else {
      stockBadgeBg = AppTheme.secondaryContainerColor.withValues(alpha: 0.3);
      stockBadgeText = AppTheme.secondaryColor;
      stockBadgeLabel = 'Disponible (${product.stock} unid.)';
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 680),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Image / Banner with Close Button
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: const BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: LocalImageHelper.buildProductImage(
                    product.imagePath,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    fallback: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 56,
                            color: AppTheme.primaryColor.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Sin Imagen Adjunta',
                            style: TextStyle(color: AppTheme.outlineColor, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.5),
                    radius: 18,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: stockBadgeBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      stockBadgeLabel,
                      style: TextStyle(color: stockBadgeText, fontWeight: FontWeight.w800, fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),

            // Product Details Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & SKU
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            categoryName.toUpperCase(),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.primaryColor),
                          ),
                        ),
                        if (product.sku != null && product.sku!.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.qr_code_2_rounded, size: 16, color: AppTheme.outlineColor),
                              const SizedBox(width: 4),
                              Text(
                                'SKU: ${product.sku}',
                                style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariantColor, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Name
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.onSurfaceColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Pricing & Profit Bento Grid
                    Row(
                      children: [
                        Expanded(
                          child: FintechCard(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('PRECIO VENTA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.onSurfaceVariantColor)),
                                const SizedBox(height: 2),
                                Text(
                                  CurrencyFormatter.format(product.sellingPrice),
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.primaryColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FintechCard(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('COSTO COMPRA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.onSurfaceVariantColor)),
                                const SizedBox(height: 2),
                                Text(
                                  CurrencyFormatter.format(product.purchasePrice),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.onSurfaceColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Profit Margin Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryContainerColor.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.secondaryColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.trending_up_rounded, color: AppTheme.secondaryColor, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Margen de Ganancia:',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.secondaryColor),
                              ),
                            ],
                          ),
                          Text(
                            '+ ${CurrencyFormatter.format(product.unitProfit)} (${product.profitPercentage.toStringAsFixed(0)}%)',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.secondaryColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description / Characteristics
                    if (product.description != null && product.description!.isNotEmpty) ...[
                      const Text(
                        'CARACTERÍSTICAS Y NOTAS:',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.onSurfaceVariantColor, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.description!,
                        style: const TextStyle(fontSize: 13, color: AppTheme.onSurfaceColor, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Stock Stepper Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('EXISTENCIAS:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.onSurfaceVariantColor)),
                            Text(
                              '${product.stock} unidades (Mín: ${product.minStock})',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.onSurfaceColor),
                            ),
                          ],
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _showQuickAddStock(context, ref),
                          icon: const Icon(Icons.add_box_rounded, size: 16),
                          label: const Text('Sumar Stock'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Footer Actions Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppTheme.outlineVariantColor)),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (c) => ProductFormDialog(product: product),
                        );
                      },
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Editar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryContainerColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: product.stock > 0
                          ? () {
                              ref.read(cartProvider.notifier).addItem(product);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('"${product.name}" agregado al carrito (+1)'),
                                  backgroundColor: AppTheme.secondaryColor,
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                      label: const Text('Agregar a Venta', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickAddStock(BuildContext context, WidgetRef ref) {
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
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
}
