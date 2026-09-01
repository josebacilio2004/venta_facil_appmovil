import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/products_providers.dart';

class CategoryManageDialog extends ConsumerStatefulWidget {
  const CategoryManageDialog({super.key});

  @override
  ConsumerState<CategoryManageDialog> createState() => _CategoryManageDialogState();
}

class _CategoryManageDialogState extends ConsumerState<CategoryManageDialog> {
  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesListProvider);

    return AlertDialog(
      title: const Text('Administrar Categorías', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              key: _formKey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        labelText: 'Nueva categoría',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Escribe un nombre' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: IconButton.filled(
                      onPressed: _addCategory,
                      icon: const Icon(Icons.add),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),
            Expanded(
              child: categoriesAsync.when(
                data: (list) {
                  if (list.isEmpty) {
                    return const Center(child: Text('No hay categorías'));
                  }
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final cat = list[index];
                      // Categorías por defecto no se deberían eliminar si queremos protegerlas
                      final isDefault = ['Abarrotes', 'Bebidas', 'Snacks', 'Limpieza', 'Otros'].contains(cat.name);
                      return ListTile(
                        title: Text(cat.name),
                        trailing: isDefault 
                          ? null 
                          : IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(cat.id, cat.name),
                            ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Error: $e'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  void _addCategory() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(categoriesListProvider.notifier).addCategory(_textController.text.trim(), null);
    _textController.clear();
  }

  void _confirmDelete(int id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar Categoría?'),
        content: Text('¿Estás seguro de que deseas eliminar la categoría "$name"? Esto desvinculará sus productos asociados.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              ref.read(categoriesListProvider.notifier).deleteCategory(id);
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
