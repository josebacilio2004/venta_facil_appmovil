import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/product.dart';
import '../providers/products_providers.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/local_image_helper.dart';
import '../../../../core/widgets/barcode_scanner_dialog.dart';

class ProductFormDialog extends ConsumerStatefulWidget {
  final ProductEntity? product;
  final String? initialSku;

  const ProductFormDialog({super.key, this.product, this.initialSku});

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
  
  String? _imagePath;
  int? _selectedCategoryId;
  String _unit = 'und';
  bool _isActive = true;
  bool _isSaving = false;

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
    _skuController = TextEditingController(text: p?.sku ?? widget.initialSku ?? '');
    _imagePath = p?.imagePath;
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
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isEdit ? Icons.edit_note_rounded : Icons.add_box_rounded,
              color: AppTheme.primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            isEdit ? 'Editar Producto' : 'Nuevo Producto',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppTheme.onSurfaceColor),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker Section
              Center(
                child: GestureDetector(
                  onTap: _showImagePickerOptions,
                  child: Stack(
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.outlineVariantColor, width: 1.5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: _imagePath != null && _imagePath!.isNotEmpty
                              ? LocalImageHelper.buildProductImage(
                                  _imagePath,
                                  width: 110,
                                  height: 110,
                                  fit: BoxFit.cover,
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo_rounded,
                                      color: AppTheme.primaryColor.withValues(alpha: 0.7),
                                      size: 32,
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Añadir Foto',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primaryColor),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      if (_imagePath != null && _imagePath!.isNotEmpty)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => setState(() => _imagePath = null),
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.black.withValues(alpha: 0.6),
                              child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre del producto *'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa un nombre' : null,
              ),
              const SizedBox(height: 12),
              categoriesAsync.when(
                data: (list) {
                  return DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    items: list.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (val) => setState(() => _selectedCategoryId = val),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
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
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Unidad de Medida (Peso / Unidades)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                      controller: _stockController,
                      decoration: InputDecoration(
                        labelText: 'Stock Inicial ($_unit) *',
                        prefixIcon: const Icon(Icons.inventory_2_outlined, size: 20),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Requerido';
                        if (double.tryParse(val) == null && int.tryParse(val) == null) return 'Inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 4,
                    child: DropdownButtonFormField<String>(
                      value: _unit,
                      decoration: const InputDecoration(labelText: 'Unidad'),
                      items: const [
                        DropdownMenuItem(value: 'und', child: Text('📦 Unid')),
                        DropdownMenuItem(value: 'kg', child: Text('⚖️ Kg')),
                        DropdownMenuItem(value: 'g', child: Text('⚖️ Gramos')),
                        DropdownMenuItem(value: 'L', child: Text('🥛 Litros')),
                        DropdownMenuItem(value: 'paq', child: Text('📦 Paq')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _unit = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _minStockController,
                decoration: InputDecoration(labelText: 'Stock Mínimo de Alerta ($_unit)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              // Código / SKU con Generador Automático
              TextFormField(
                controller: _skuController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Código / SKU / Barras',
                  hintText: 'ej: 7750123456789',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.auto_awesome_rounded, color: AppTheme.secondaryColor),
                        tooltip: 'Generar Código Automático (ej: Papa a granel)',
                        onPressed: () {
                          final autoCode = '775${DateTime.now().millisecondsSinceEpoch.toString().substring(3)}';
                          setState(() => _skuController.text = autoCode);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.qr_code_scanner_rounded, color: AppTheme.primaryColor),
                        tooltip: 'Escanear con Cámara',
                        onPressed: () async {
                          final scanned = await showDialog<String>(
                            context: context,
                            builder: (ctx) => const BarcodeScannerDialog(title: 'Escanear SKU'),
                          );
                          if (scanned != null && scanned.isNotEmpty) {
                            setState(() => _skuController.text = scanned);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Previsualización del Código de Barras generado
              if (_skuController.text.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.outlineVariantColor),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Código de Barras Generado:',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.onSurfaceVariantColor),
                      ),
                      const SizedBox(height: 4),
                      BarcodeWidget(
                        barcode: Barcode.code128(),
                        data: _skuController.text.trim(),
                        height: 40,
                        drawText: true,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción / Características (Opcional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Producto Activo para Venta', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                value: _isActive,
                activeTrackColor: AppTheme.primaryColor,
                onChanged: (val) => setState(() => _isActive = val),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (isEdit)
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            onPressed: () => _confirmDelete(context, widget.product!),
            child: const Text('Eliminar'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: AppTheme.onSurfaceVariantColor)),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : () => _saveProduct(context),
          child: _isSaving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(isEdit ? 'Actualizar' : 'Guardar'),
        ),
      ],
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Seleccionar Foto del Producto',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.onSurfaceColor),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppTheme.primaryColor),
                title: const Text('Tomar Foto con la Cámara', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final path = await LocalImageHelper.pickAndSaveImage(source: ImageSource.camera);
                  if (path != null) {
                    setState(() => _imagePath = path);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppTheme.primaryColor),
                title: const Text('Elegir de la Galería', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final path = await LocalImageHelper.pickAndSaveImage(source: ImageSource.gallery);
                  if (path != null) {
                    setState(() => _imagePath = path);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProduct(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      final isEdit = widget.product != null;
      
      final product = ProductEntity(
        id: isEdit ? widget.product!.id : 0,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        purchasePrice: double.parse(_purchasePriceController.text.trim()),
        sellingPrice: double.parse(_sellingPriceController.text.trim()),
        stock: int.parse(_stockController.text.trim()),
        minStock: int.tryParse(_minStockController.text.trim()) ?? 5,
        sku: _skuController.text.trim().isEmpty ? null : _skuController.text.trim(),
        imagePath: _imagePath,
        categoryId: _selectedCategoryId,
        isActive: _isActive,
        createdAt: isEdit ? widget.product!.createdAt : DateTime.now(),
      );

      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      try {
        if (isEdit) {
          await ref.read(updateProductUseCaseProvider).call(product);
        } else {
          await ref.read(addProductUseCaseProvider).call(product);
        }
        ref.invalidate(productsListProvider);
        navigator.pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text(isEdit ? 'Producto actualizado' : 'Producto guardado con éxito'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
      } catch (e) {
        setState(() => _isSaving = false);
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context, ProductEntity product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
