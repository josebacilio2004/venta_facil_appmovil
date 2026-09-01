import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';
import '../providers/products_providers.dart';
import '../../../../core/widgets/barcode_scanner_dialog.dart';

class ProductFormDialog extends ConsumerStatefulWidget {
  final ProductEntity? product;

  const ProductFormDialog({super.key, this.product});

  @override
  ConsumerState<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends ConsumerState<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _purchasePriceController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _stockController;
  late TextEditingController _minStockController;
  late TextEditingController _skuController;
  
  int? _selectedCategoryId;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _purchasePriceController = TextEditingController(text: p != null ? p.purchasePrice.toStringAsFixed(2) : '');
    _sellingPriceController = TextEditingController(text: p != null ? p.sellingPrice.toStringAsFixed(2) : '');
    _stockController = TextEditingController(text: p != null ? p.stock.toString() : '0');
    _minStockController = TextEditingController(text: p != null ? p.minStock.toString() : '5');
    _skuController = TextEditingController(text: p?.sku ?? '');
    _selectedCategoryId = p?.categoryId;
    _isActive = p?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesListProvider);
    final isEdit = widget.product != null;

    return AlertDialog(
      title: Text(isEdit ? 'Editar Producto' : 'Nuevo Producto', style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre del producto *'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa un nombre' : null,
              ),
              const SizedBox(height: 12),
              categoriesAsync.when(
                data: (list) {
                  // Si no hay categoría seleccionada, pero la lista no está vacía y es edición, intentamos asignar.
                  // De lo contrario dejamos null.
                  return DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    items: list.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (val) => setState(() => _selectedCategoryId = val),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => const Text('Error cargando categorías'),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _purchasePriceController,
                      decoration: const InputDecoration(labelText: 'P. Compra *', prefixText: 'S/. '),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Requerido';
                        if (double.tryParse(val) == null) return 'Inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _sellingPriceController,
                      decoration: const InputDecoration(labelText: 'P. Venta *', prefixText: 'S/. '),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Requerido';
                        if (double.tryParse(val) == null) return 'Inválido';
                        final purchase = double.tryParse(_purchasePriceController.text) ?? 0;
                        final selling = double.tryParse(val) ?? 0;
                        if (selling < purchase) return 'P. Venta < P. Compra';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(labelText: 'Stock Actual *'),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Requerido';
                        if (int.tryParse(val) == null) return 'Inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _minStockController,
                      decoration: const InputDecoration(labelText: 'Stock Mínimo *'),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Requerido';
                        if (int.tryParse(val) == null) return 'Inválido';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _skuController,
                decoration: InputDecoration(
                  labelText: 'Código / SKU (opcional)',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code_scanner, color: Colors.teal),
                    tooltip: 'Escanear código',
                    onPressed: _scanBarcode,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Producto Activo'),
                contentPadding: EdgeInsets.zero,
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(100, 45)),
          onPressed: _save,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  void _scanBarcode() async {
    final scanned = await showDialog<String>(
      context: context,
      builder: (ctx) => const BarcodeScannerDialog(title: 'Escanear Código del Producto'),
    );
    if (scanned != null && mounted) {
      setState(() {
        _skuController.text = scanned;
      });
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final newProduct = ProductEntity(
      id: widget.product?.id ?? 0,
      categoryId: _selectedCategoryId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      purchasePrice: double.parse(_purchasePriceController.text),
      sellingPrice: double.parse(_sellingPriceController.text),
      stock: int.parse(_stockController.text),
      minStock: int.parse(_minStockController.text),
      sku: _skuController.text.trim().isEmpty ? null : _skuController.text.trim(),
      isActive: _isActive,
      createdAt: widget.product?.createdAt ?? DateTime.now(),
    );

    try {
      if (widget.product != null) {
        await ref.read(productsListProvider.notifier).updateProduct(newProduct);
      } else {
        await ref.read(productsListProvider.notifier).addProduct(newProduct);
      }
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Producto "${newProduct.name}" guardado correctamente.'),
          backgroundColor: Colors.green,
        ),
      );
      if (navigator.canPop()) {
        navigator.pop();
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error al guardar el producto: $e'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
