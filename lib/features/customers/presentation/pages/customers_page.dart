import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_card.dart';
import '../providers/customers_providers.dart';
import '../../domain/entities/customer.dart';
import '../widgets/customer_form_dialog.dart';

class CustomersPage extends ConsumerWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersListProvider);
    final searchQuery = ref.watch(customersSearchQueryProvider);

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'CLIENTES',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: GlassCard(
                padding: EdgeInsets.zero,
                borderRadius: BorderRadius.circular(16),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o teléfono...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white70),
                            onPressed: () => ref.read(customersSearchQueryProvider.notifier).state = '',
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onChanged: (val) {
                    ref.read(customersSearchQueryProvider.notifier).state = val.trim();
                  },
                ),
              ),
            ),
            Expanded(
              child: customersAsync.when(
                data: (list) {
                  if (list.isEmpty) {
                    return const Center(
                      child: Text(
                        'No se encontraron clientes.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: list.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemBuilder: (context, index) {
                      final customer = list[index];
                      return _buildCustomerCard(context, ref, customer);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'fab_customers',
          onPressed: () => _openCustomerForm(context, null),
          icon: const Icon(Icons.person_add),
          label: const Text('Nuevo Cliente'),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0F766E),
        ),
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, WidgetRef ref, CustomerEntity c) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: Colors.tealAccent.withOpacity(0.15),
          foregroundColor: Colors.tealAccent,
          child: Text(c.name.isNotEmpty ? c.name.substring(0, 1).toUpperCase() : '?'),
        ),
        title: Text(
          c.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.phone, size: 14, color: Colors.white60),
                  const SizedBox(width: 4),
                  Text(c.phone, style: const TextStyle(color: Colors.white70)),
                ],
              ),
              if (c.email != null && c.email!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.email, size: 14, color: Colors.white60),
                      const SizedBox(width: 4),
                      Text(c.email!, style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              if (c.notes != null && c.notes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Nota: ${c.notes}',
                    style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white54, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.cyanAccent),
              onPressed: () => _openCustomerForm(context, c),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => _confirmDelete(context, ref, c),
            ),
          ],
        ),
      ),
    );
  }

  void _openCustomerForm(BuildContext context, CustomerEntity? c) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomerFormDialog(customer: c),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, CustomerEntity c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F766E),
        title: const Text('¿Eliminar Cliente?', style: TextStyle(color: Colors.white)),
        content: Text('¿Estás seguro de que deseas eliminar a "${c.name}"? Esta acción no se puede deshacer.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              ref.read(customersListProvider.notifier).deleteCustomer(c.id);
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
