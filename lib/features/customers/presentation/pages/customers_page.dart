import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/fintech_card.dart';
import '../providers/customers_providers.dart';
import '../../domain/entities/customer.dart';
import '../widgets/customer_form_dialog.dart';

class CustomersPage extends ConsumerWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersListProvider);
    final searchQuery = ref.watch(customersSearchQueryProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.onSurfaceColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Clientes y Contactos',
          style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.onSurfaceColor, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 12.0),
            child: TextField(
              style: const TextStyle(color: AppTheme.onSurfaceColor, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Buscar cliente por nombre o teléfono...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.outlineColor, size: 20),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppTheme.outlineColor, size: 18),
                        onPressed: () => ref.read(customersSearchQueryProvider.notifier).state = '',
                      )
                    : null,
              ),
              onChanged: (val) {
                ref.read(customersSearchQueryProvider.notifier).state = val.trim();
              },
            ),
          ),

          // Customers List
          Expanded(
            child: customersAsync.when(
              data: (list) {
                if (list.isEmpty) {
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
                          child: const Icon(Icons.groups_outlined, size: 32, color: AppTheme.outlineColor),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'No hay clientes registrados',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.onSurfaceColor),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Agrega clientes para asignarlos a tus ventas.',
                          style: TextStyle(color: AppTheme.onSurfaceVariantColor, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: list.length,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                  itemBuilder: (context, index) {
                    final customer = list[index];
                    return _buildCustomerCard(context, ref, customer);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
              error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: AppTheme.errorColor))),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_customers',
        onPressed: () => _openCustomerForm(context, null),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Nuevo Cliente', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppTheme.primaryContainerColor,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, WidgetRef ref, CustomerEntity customer) {
    return FintechCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      onTap: () => _openCustomerForm(context, customer),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.surfaceContainerLow,
            child: Text(
              customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'C',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppTheme.primaryColor),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.onSurfaceColor),
                ),
                const SizedBox(height: 3),
                if (customer.phone.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 14, color: AppTheme.outlineColor),
                      const SizedBox(width: 4),
                      Text(customer.phone, style: const TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariantColor)),
                    ],
                  ),
                if (customer.notes != null && customer.notes!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    customer.notes!,
                    style: const TextStyle(fontSize: 12, color: AppTheme.outlineColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppTheme.outlineColor, size: 20),
            onPressed: () => _openCustomerForm(context, customer),
          ),
        ],
      ),
    );
  }

  void _openCustomerForm(BuildContext context, CustomerEntity? customer) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomerFormDialog(customer: customer),
    );
  }
}
