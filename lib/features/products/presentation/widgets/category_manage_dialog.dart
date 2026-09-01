import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/category.dart';
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
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: const Icon(Icons.category_rounded, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 10),
          const Text(
            'Categorías',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppTheme.onSurfaceColor),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 320,
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Escribe un nombre' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _addCategory,
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24, color: AppTheme.outlineVariantColor),
            Expanded(
              child: categoriesAsync.when(
                data: (cats) {
                  if (cats.isEmpty) {
                    return const Center(
                      child: Text('No hay categorías creadas', style: TextStyle(color: AppTheme.onSurfaceVariantColor, fontSize: 13)),
                    );
                  }
                  return ListView.separated(
                    itemCount: cats.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppTheme.outlineVariantColor),
                    itemBuilder: (context, index) {
                      final c = cats[index];
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                        title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.onSurfaceColor)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorColor, size: 20),
                          onPressed: () async {
                            await ref.read(deleteCategoryUseCaseProvider).call(c.id);
                            ref.invalidate(categoriesListProvider);
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  void _addCategory() async {
    if (_formKey.currentState!.validate()) {
      final name = _textController.text.trim();
      await ref.read(addCategoryUseCaseProvider).call(CategoryEntity(id: 0, name: name));
      _textController.clear();
      ref.invalidate(categoriesListProvider);
    }
  }
}
