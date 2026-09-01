import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/glass_card.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'MÁS OPCIONES',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          _buildMenuItem(
            context,
            icon: Icons.people_outline,
            title: 'Clientes',
            subtitle: 'Administrar clientes y notas',
            onTap: () => context.push('/customers'),
          ),
          const SizedBox(height: 14),
          _buildMenuItem(
            context,
            icon: Icons.bar_chart_outlined,
            title: 'Reportes',
            subtitle: 'Ganancias, ventas y gastos',
            onTap: () => context.push('/reports'),
          ),
          const SizedBox(height: 14),
          _buildMenuItem(
            context,
            icon: Icons.settings_outlined,
            title: 'Configuración',
            subtitle: 'Ajustes del negocio y copia de seguridad',
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.tealAccent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 28, color: Colors.tealAccent),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white60),
        onTap: onTap,
      ),
    );
  }
}
