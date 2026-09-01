import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/expense.dart';
import '../providers/expenses_providers.dart';

class ExpenseFormDialog extends ConsumerStatefulWidget {
  final ExpenseEntity? expense;

  const ExpenseFormDialog({super.key, this.expense});

  @override
  ConsumerState<ExpenseFormDialog> createState() => _ExpenseFormDialogState();
}

class _ExpenseFormDialogState extends ConsumerState<ExpenseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _observationController;
  
  late String _selectedCategory;
  late DateTime _selectedDate;

  final List<Map<String, String>> _categories = [
    {'value': 'compras', 'label': 'Compras de Mercadería'},
    {'value': 'transporte', 'label': 'Transporte / Pasajes'},
    {'value': 'publicidad', 'label': 'Publicidad / Marketing'},
    {'value': 'servicios', 'label': 'Servicios (Luz, Agua, etc.)'},
    {'value': 'alquiler', 'label': 'Alquiler de local'},
    {'value': 'otros', 'label': 'Otros gastos'},
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _descriptionController = TextEditingController(text: e?.description ?? '');
    _amountController = TextEditingController(text: e != null ? e.amount.toStringAsFixed(2) : '');
    _observationController = TextEditingController(text: e?.observation ?? '');
    _selectedCategory = e?.category ?? 'compras';
    _selectedDate = e?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.expense != null;

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.errorContainerColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.payments_rounded, color: AppTheme.errorColor, size: 22),
          ),
          const SizedBox(width: 10),
          Text(
            isEdit ? 'Editar Gasto' : 'Registrar Gasto',
            style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.onSurfaceColor, fontSize: 18),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción *'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa una descripción' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Categoría *'),
                items: _categories.map((c) => DropdownMenuItem(value: c['value'], child: Text(c['label']!))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Monto *', prefixText: 'S/. '),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Ingresa un monto';
                  if (double.tryParse(val) == null || double.parse(val) <= 0) return 'Monto inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha del gasto:', style: TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariantColor)),
                subtitle: Text(DateFormatter.format(_selectedDate), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                trailing: const Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.primaryColor),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _observationController,
                decoration: const InputDecoration(labelText: 'Observación (Opcional)'),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (isEdit)
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            onPressed: () => _confirmDelete(context),
            child: const Text('Eliminar'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: AppTheme.onSurfaceVariantColor)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.tertiaryColor),
          onPressed: _saveExpense,
          child: Text(isEdit ? 'Actualizar' : 'Guardar'),
        ),
      ],
    );
  }

  void _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final isEdit = widget.expense != null;
      if (isEdit) {
        await ref.read(deleteExpenseUseCaseProvider).call(widget.expense!.id);
      }

      final expense = ExpenseEntity(
        id: 0,
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        date: _selectedDate,
        observation: _observationController.text.trim().isEmpty ? null : _observationController.text.trim(),
        createdAt: isEdit ? widget.expense!.createdAt : DateTime.now(),
      );

      await ref.read(addExpenseUseCaseProvider).call(expense);
      ref.invalidate(expensesListProvider);
      if (mounted) Navigator.pop(context);
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar gasto?'),
        content: const Text('¿Estás seguro de que deseas eliminar este registro de gasto?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor, foregroundColor: Colors.white),
            onPressed: () async {
              await ref.read(deleteExpenseUseCaseProvider).call(widget.expense!.id);
              ref.invalidate(expensesListProvider);
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
