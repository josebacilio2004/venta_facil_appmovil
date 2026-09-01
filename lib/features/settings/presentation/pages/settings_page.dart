import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/fintech_card.dart';
import '../providers/settings_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);

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
          'Perfil y Configuración',
          style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.onSurfaceColor, fontSize: 20),
        ),
      ),
      body: settings.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 32.0),
              children: [
                _buildSectionHeader('Datos de la Empresa / Emisor SUNAT'),
                FintechCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.storefront_rounded, color: AppTheme.primaryColor),
                        title: const Text('Razón Social / Nombre Comercial', style: TextStyle(color: AppTheme.onSurfaceColor, fontWeight: FontWeight.w700, fontSize: 14)),
                        subtitle: Text(settings.businessName, style: const TextStyle(color: AppTheme.onSurfaceVariantColor, fontSize: 13)),
                        trailing: const Icon(Icons.edit_outlined, color: AppTheme.outlineColor, size: 20),
                        onTap: () => _editSingleField(context, ref, 'Nombre Comercial', 'business_name', settings.businessName),
                      ),
                      const Divider(color: AppTheme.outlineVariantColor, height: 1),
                      ListTile(
                        leading: const Icon(Icons.badge_outlined, color: AppTheme.primaryColor),
                        title: const Text('RUC de la Empresa', style: TextStyle(color: AppTheme.onSurfaceColor, fontWeight: FontWeight.w700, fontSize: 14)),
                        subtitle: Text(settings.ruc, style: const TextStyle(color: AppTheme.onSurfaceVariantColor, fontSize: 13)),
                        trailing: const Icon(Icons.edit_outlined, color: AppTheme.outlineColor, size: 20),
                        onTap: () => _editSingleField(context, ref, 'Número de RUC (11 dígitos)', 'ruc', settings.ruc, isNumeric: true),
                      ),
                      const Divider(color: AppTheme.outlineVariantColor, height: 1),
                      ListTile(
                        leading: const Icon(Icons.location_on_outlined, color: AppTheme.primaryColor),
                        title: const Text('Dirección del Establecimiento', style: TextStyle(color: AppTheme.onSurfaceColor, fontWeight: FontWeight.w700, fontSize: 14)),
                        subtitle: Text(settings.address, style: const TextStyle(color: AppTheme.onSurfaceVariantColor, fontSize: 13)),
                        trailing: const Icon(Icons.edit_outlined, color: AppTheme.outlineColor, size: 20),
                        onTap: () => _editSingleField(context, ref, 'Dirección Fiscal', 'address', settings.address),
                      ),
                      const Divider(color: AppTheme.outlineVariantColor, height: 1),
                      ListTile(
                        leading: const Icon(Icons.phone_outlined, color: AppTheme.primaryColor),
                        title: const Text('Teléfono de Contacto', style: TextStyle(color: AppTheme.onSurfaceColor, fontWeight: FontWeight.w700, fontSize: 14)),
                        subtitle: Text(settings.phone, style: const TextStyle(color: AppTheme.onSurfaceVariantColor, fontSize: 13)),
                        trailing: const Icon(Icons.edit_outlined, color: AppTheme.outlineColor, size: 20),
                        onTap: () => _editSingleField(context, ref, 'Teléfono', 'phone', settings.phone, isNumeric: true),
                      ),
                      const Divider(color: AppTheme.outlineVariantColor, height: 1),
                      ListTile(
                        leading: const Icon(Icons.point_of_sale_rounded, color: AppTheme.primaryColor),
                        title: const Text('Serie de Máquina POS (Ticket SUNAT)', style: TextStyle(color: AppTheme.onSurfaceColor, fontWeight: FontWeight.w700, fontSize: 14)),
                        subtitle: Text(settings.machineSeries, style: const TextStyle(color: AppTheme.onSurfaceVariantColor, fontSize: 13)),
                        trailing: const Icon(Icons.edit_outlined, color: AppTheme.outlineColor, size: 20),
                        onTap: () => _editSingleField(context, ref, 'N° Serie Máquina Registradora', 'machine_series', settings.machineSeries),
                      ),
                      const Divider(color: AppTheme.outlineVariantColor, height: 1),
                      ListTile(
                        leading: const Icon(Icons.receipt_long_rounded, color: AppTheme.primaryColor),
                        title: const Text('Serie de Boleta Electrónica', style: TextStyle(color: AppTheme.onSurfaceColor, fontWeight: FontWeight.w700, fontSize: 14)),
                        subtitle: Text(settings.boletaSeries, style: const TextStyle(color: AppTheme.onSurfaceVariantColor, fontSize: 13)),
                        trailing: const Icon(Icons.edit_outlined, color: AppTheme.outlineColor, size: 20),
                        onTap: () => _editSingleField(context, ref, 'Serie Boleta (ej: B001)', 'boleta_series', settings.boletaSeries),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                _buildSectionHeader('Preferencias de la Aplicación'),
                FintechCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.monetization_on_outlined, color: AppTheme.primaryColor),
                        title: const Text('Moneda de la Aplicación', style: TextStyle(color: AppTheme.onSurfaceColor, fontWeight: FontWeight.w700, fontSize: 14)),
                        subtitle: Text(settings.currency, style: const TextStyle(color: AppTheme.onSurfaceVariantColor, fontSize: 13)),
                        trailing: const Icon(Icons.edit_outlined, color: AppTheme.outlineColor, size: 20),
                        onTap: () => _editSingleField(context, ref, 'Símbolo de Moneda (ej: S/., \$, €)', 'currency', settings.currency),
                      ),
                      const Divider(color: AppTheme.outlineVariantColor, height: 1),
                      SwitchListTile(
                        secondary: const Icon(Icons.dark_mode_outlined, color: AppTheme.primaryColor),
                        title: const Text('Modo Oscuro', style: TextStyle(color: AppTheme.onSurfaceColor, fontWeight: FontWeight.w700, fontSize: 14)),
                        subtitle: const Text('Alternar entre tema claro y oscuro', style: TextStyle(color: AppTheme.onSurfaceVariantColor, fontSize: 13)),
                        value: settings.themeMode == 'dark',
                        activeTrackColor: AppTheme.primaryColor,
                        onChanged: (val) {
                          notifier.updateThemeMode(val ? 'dark' : 'light');
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                _buildSectionHeader('Respaldo y Restauración'),
                FintechCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.backup_outlined, color: AppTheme.secondaryColor),
                        title: const Text('Copia de Seguridad', style: TextStyle(color: AppTheme.onSurfaceColor, fontWeight: FontWeight.w700, fontSize: 14)),
                        subtitle: const Text('Exportar base de datos a un archivo local', style: TextStyle(color: AppTheme.onSurfaceVariantColor, fontSize: 13)),
                        onTap: () => _runBackup(context, ref),
                      ),
                      const Divider(color: AppTheme.outlineVariantColor, height: 1),
                      ListTile(
                        leading: const Icon(Icons.restore_outlined, color: AppTheme.tertiaryColor),
                        title: const Text('Restaurar Datos', style: TextStyle(color: AppTheme.onSurfaceColor, fontWeight: FontWeight.w700, fontSize: 14)),
                        subtitle: const Text('Importar datos desde una copia previa', style: TextStyle(color: AppTheme.onSurfaceVariantColor, fontSize: 13)),
                        onTap: () => _runRestore(context, ref),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppTheme.onSurfaceVariantColor, letterSpacing: 0.8),
      ),
    );
  }

  void _editSingleField(
    BuildContext context,
    WidgetRef ref,
    String label,
    String dbKey,
    String currentValue, {
    bool isNumeric = false,
  }) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Modificar $label'),
        content: TextFormField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            labelText: label,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(settingsNotifierProvider.notifier).updateBusinessField(dbKey, controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _runBackup(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
    );

    try {
      final path = await ref.read(settingsNotifierProvider.notifier).exportBackup();
      if (context.mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Respaldo Exitoso'),
            content: Text('Se exportó la base de datos local a:\n\n$path\n\nPuedes copiar este archivo para guardarlo.'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _runRestore(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restaurar Datos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ingresa la ruta absoluta del archivo SQLite (.sqlite) para restaurar los datos:', style: TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariantColor)),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Ruta del archivo',
                hintText: '/ruta/al/archivo/ventafacil_backup.sqlite',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.tertiaryColor),
            onPressed: () async {
              final path = controller.text.trim();
              if (path.isEmpty) return;
              Navigator.pop(ctx);
              
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (c) => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
              );

              try {
                await ref.read(settingsNotifierProvider.notifier).importBackup(path);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Datos restaurados correctamente.'),
                      backgroundColor: AppTheme.secondaryColor,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al restaurar: $e'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              }
            },
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }
}
