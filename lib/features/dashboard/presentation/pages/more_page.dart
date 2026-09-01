import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/fintech_card.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Más Opciones',
          style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.onSurfaceColor, fontSize: 20),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 32.0),
        children: [
          _buildMenuItem(
            context,
            icon: Icons.groups_rounded,
            iconColor: AppTheme.primaryColor,
            title: 'Clientes y Contactos',
            subtitle: 'Administrar cartera, teléfonos y compras',
            onTap: () => context.push('/customers'),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            context,
            icon: Icons.analytics_rounded,
            iconColor: AppTheme.secondaryColor,
            title: 'Reportes y Ganancias',
            subtitle: 'Balance financiero, ventas y métodos de pago',
            onTap: () => context.push('/reports'),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            context,
            icon: Icons.settings_rounded,
            iconColor: AppTheme.onSurfaceVariantColor,
            title: 'Configuración y SUNAT',
            subtitle: 'Datos de la empresa, RUC, series y respaldos',
            onTap: () => context.push('/settings'),
          ),
          const SizedBox(height: 24),

          // Logout Action
          FintechCard(
            padding: EdgeInsets.zero,
            onTap: () => _confirmLogout(context),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.errorContainerColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout_rounded, size: 22, color: AppTheme.errorColor),
              ),
              title: const Text(
                'Cerrar Sesión',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.errorColor),
              ),
              subtitle: const Text('Bloquear acceso a la aplicación', style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariantColor)),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.outlineColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return FintechCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 24, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.onSurfaceColor),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Text(subtitle, style: const TextStyle(color: AppTheme.onSurfaceVariantColor, fontSize: 12)),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.outlineColor),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cerrar Sesión?'),
        content: const Text('¿Deseas salir del sistema? Tendrás que ingresar tus credenciales nuevamente.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/login');
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
