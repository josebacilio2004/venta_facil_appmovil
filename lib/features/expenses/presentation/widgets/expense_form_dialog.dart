import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/expense.dart';
import '../providers/expenses_providers.dart';

class ExpenseFormDialog extends ConsumerStatefulWidget {
  const ExpenseFormDialog({super.key});

  @override
  ConsumerState<ExpenseFormDialog> createState() => _ExpenseFormDialogState();
}

class _ExpenseFormDialogState extends ConsumerState<ExpenseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _observationController = TextEditingController();
  
  String _selectedCategory = 'compras';
  DateTime _selectedDate = DateTime.now();

  final List<Map<String, String>> _categories = [
    {'value': 'compras', 'label': 'Compras de Mercadería'},
    {'value': 'transporte', 'label': 'Transporte / Pasajes'},
    {'value': 'publicidad', 'label': 'Publicidad / Marketing'},
    {'value': 'servicios', 'label': 'Servicios (Luz, Agua, etc.)'},
    {'value': 'alquiler', 'label': 'Alquiler de local'},
    {'value': 'otros', 'label': 'Otros gastos'},
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar Gasto', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  if (double.tryParse(val) == null) return 'Monto inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Fecha: ${DateFormatter.format(_selectedDate)}',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Cambiar'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _observationController,
                decoration: const InputDecoration(labelText: 'Observación (opcional)'),
                maxLines: 2,
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
          onPressed: _save,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final newExpense = ExpenseEntity(
      id: 0,
      category: _selectedCategory,
      description: _descriptionController.text.trim(),
      amount: double.parse(_amountController.text),
      date: _selectedDate,
      observation: _observationController.text.trim().isEmpty ? null : _observationController.text.trim(),
      createdAt: DateTime.now(),
    );

    ref.read(expensesListProvider.notifier).addExpense(newExpense);
    Navigator.pop(context);
  }
}
