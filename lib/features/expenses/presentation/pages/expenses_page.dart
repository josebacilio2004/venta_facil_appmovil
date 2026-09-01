import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/fintech_card.dart';
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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Control de Gastos',
          style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.onSurfaceColor, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          // Filtro de Categoría
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 10.0),
            child: DropdownButtonFormField<String>(
              value: filter.category,
              decoration: const InputDecoration(
                labelText: 'Filtrar por Categoría',
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
              data: (expenses) {
                if (expenses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLow,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.payments_outlined, size: 32, color: AppTheme.outlineColor),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'No hay gastos registrados',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.onSurfaceColor),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Registra tus compras y salidas de dinero.',
                          style: TextStyle(color: AppTheme.onSurfaceVariantColor, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                final totalExpenses = expenses.fold<double>(0, (sum, e) => sum + e.amount);

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: FintechCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TOTAL GASTOS:',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.onSurfaceVariantColor),
                            ),
                            Text(
                              CurrencyFormatter.format(totalExpenses),
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.errorColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: ListView.builder(
                        itemCount: expenses.length,
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                        itemBuilder: (context, index) {
                          final expense = expenses[index];
                          return _buildExpenseCard(context, ref, expense);
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
              error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: AppTheme.errorColor))),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_expenses',
        backgroundColor: AppTheme.tertiaryColor,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => _openExpenseForm(context),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildExpenseCard(BuildContext context, WidgetRef ref, ExpenseEntity expense) {
    return FintechCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      onTap: () => _openExpenseForm(context, expense: expense),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.errorContainerColor.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.payments_rounded, color: AppTheme.errorColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.onSurfaceColor),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_categoryLabels[expense.category] ?? expense.category} • ${DateFormatter.format(expense.date)}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariantColor),
                ),
                if (expense.observation != null && expense.observation!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    expense.observation!,
                    style: const TextStyle(fontSize: 11, color: AppTheme.outlineColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(expense.amount),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.errorColor),
          ),
        ],
      ),
    );
  }

  void _openExpenseForm(BuildContext context, {ExpenseEntity? expense}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ExpenseFormDialog(expense: expense),
    );
  }
}
