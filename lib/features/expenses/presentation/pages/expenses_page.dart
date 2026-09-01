import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../providers/expenses_providers.dart';
import '../../domain/entities/expense.dart';
import '../widgets/expense_form_dialog.dart';

class ExpensesPage extends ConsumerWidget {
  const ExpensesPage({super.key});

  static final Map<String, String> _categoryLabels = {
    'compras': 'Compras de Mercadería',
    'transporte': 'Transporte / Pasajes',
    'publicidad': 'Publicidad / Marketing',
    'servicios': 'Servicios (Luz, Agua, etc.)',
    'alquiler': 'Alquiler de local',
    'otros': 'Otros gastos',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesListProvider);
    final filter = ref.watch(expensesFilterProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Gastos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Sección de Filtro
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: DropdownButtonFormField<String>(
              value: filter.category,
              decoration: const InputDecoration(
                labelText: 'Filtrar por Categoría',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Todas las categorías')),
                ..._categoryLabels.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))),
              ],
              onChanged: (val) {
                ref.read(expensesFilterProvider.notifier).state = filter.copyWith(
                  category: val,
                  clearCategory: val == null,
                );
              },
            ),
          ),

          // Listado de Gastos
          Expanded(
            child: expensesAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return const Center(child: Text('No hay gastos registrados.'));
                }
                return ListView.builder(
                  itemCount: list.length,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemBuilder: (context, index) {
                    final expense = list[index];
                    return _buildExpenseCard(context, ref, expense);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_expenses',
        onPressed: () => _openExpenseForm(context),
        icon: const Icon(Icons.add_card),
        label: const Text('Registrar Gasto'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F766E),
      ),
    );
  }

  Widget _buildExpenseCard(BuildContext context, WidgetRef ref, ExpenseEntity exp) {
    final categoryLabel = _categoryLabels[exp.category] ?? exp.category;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red.withOpacity(0.15),
          foregroundColor: Colors.red,
          child: const Icon(Icons.trending_down),
        ),
        title: Text(exp.description, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Categoría: $categoryLabel', style: const TextStyle(fontSize: 13)),
            Text('Fecha: ${DateFormatter.format(exp.date)}', style: const TextStyle(fontSize: 13)),
            if (exp.observation != null && exp.observation!.isNotEmpty)
              Text('Obs: ${exp.observation}', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '- ${CurrencyFormatter.format(exp.amount)}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, ref, exp),
            ),
          ],
        ),
      ),
    );
  }

  void _openExpenseForm(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ExpenseFormDialog(),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, ExpenseEntity exp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar Gasto?'),
        content: Text('¿Estás seguro de que deseas eliminar el gasto "${exp.description}" de ${CurrencyFormatter.format(exp.amount)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              ref.read(expensesListProvider.notifier).deleteExpense(exp.id);
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
