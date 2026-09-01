import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/glass_background.dart';
import '../../../../core/widgets/glass_card.dart';
import '../providers/settings_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'CONFIGURACIÓN',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: settings.isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                children: [
                  _buildSectionHeader('Datos de la Empresa / Emisor SUNAT'),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.storefront, color: Colors.tealAccent),
                          title: const Text('Razón Social / Nombre Comercial', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(settings.businessName, style: const TextStyle(color: Colors.white70)),
                          trailing: const Icon(Icons.edit, color: Colors.white70, size: 20),
                          onTap: () => _editSingleField(context, ref, 'Nombre Comercial', 'business_name', settings.businessName),
                        ),
                        const Divider(color: Colors.white12, height: 1),
                        ListTile(
                          leading: const Icon(Icons.badge_outlined, color: Colors.tealAccent),
                          title: const Text('RUC de la Empresa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(settings.ruc, style: const TextStyle(color: Colors.white70)),
                          trailing: const Icon(Icons.edit, color: Colors.white70, size: 20),
                          onTap: () => _editSingleField(context, ref, 'Número de RUC (11 dígitos)', 'ruc', settings.ruc, isNumeric: true),
                        ),
                        const Divider(color: Colors.white12, height: 1),
                        ListTile(
                          leading: const Icon(Icons.location_on_outlined, color: Colors.tealAccent),
                          title: const Text('Dirección del Establecimiento', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(settings.address, style: const TextStyle(color: Colors.white70)),
                          trailing: const Icon(Icons.edit, color: Colors.white70, size: 20),
                          onTap: () => _editSingleField(context, ref, 'Dirección Fiscal', 'address', settings.address),
                        ),
                        const Divider(color: Colors.white12, height: 1),
                        ListTile(
                          leading: const Icon(Icons.phone_outlined, color: Colors.tealAccent),
                          title: const Text('Teléfono de Contacto', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(settings.phone, style: const TextStyle(color: Colors.white70)),
                          trailing: const Icon(Icons.edit, color: Colors.white70, size: 20),
                          onTap: () => _editSingleField(context, ref, 'Teléfono', 'phone', settings.phone, isNumeric: true),
                        ),
                        const Divider(color: Colors.white12, height: 1),
                        ListTile(
                          leading: const Icon(Icons.point_of_sale, color: Colors.cyanAccent),
                          title: const Text('Serie de Máquina POS (Ticket SUNAT)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(settings.machineSeries, style: const TextStyle(color: Colors.white70)),
                          trailing: const Icon(Icons.edit, color: Colors.white70, size: 20),
                          onTap: () => _editSingleField(context, ref, 'N° Serie Máquina Registradora', 'machine_series', settings.machineSeries),
                        ),
                        const Divider(color: Colors.white12, height: 1),
                        ListTile(
                          leading: const Icon(Icons.receipt_long, color: Colors.cyanAccent),
                          title: const Text('Serie de Boleta Electrónica', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(settings.boletaSeries, style: const TextStyle(color: Colors.white70)),
                          trailing: const Icon(Icons.edit, color: Colors.white70, size: 20),
                          onTap: () => _editSingleField(context, ref, 'Serie Boleta (ej: B001)', 'boleta_series', settings.boletaSeries),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildSectionHeader('Preferencias de la Aplicación'),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.monetization_on_outlined, color: Colors.tealAccent),
                          title: const Text('Moneda de la Aplicación', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(settings.currency, style: const TextStyle(color: Colors.white70)),
                          trailing: const Icon(Icons.edit, color: Colors.white70, size: 20),
                          onTap: () => _editSingleField(context, ref, 'Símbolo de Moneda (ej: S/., \$, €)', 'currency', settings.currency),
                        ),
                        const Divider(color: Colors.white12, height: 1),
                        SwitchListTile(
                          secondary: const Icon(Icons.dark_mode_outlined, color: Colors.tealAccent),
                          title: const Text('Modo Oscuro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: const Text('Alternar entre tema claro y oscuro', style: TextStyle(color: Colors.white70)),
                          value: settings.themeMode == 'dark',
                          activeColor: Colors.tealAccent,
                          onChanged: (val) {
                            notifier.updateThemeMode(val ? 'dark' : 'light');
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildSectionHeader('Respaldo y Restauración'),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.backup_outlined, color: Colors.greenAccent),
                          title: const Text('Copia de Seguridad', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: const Text('Exportar base de datos a un archivo local', style: TextStyle(color: Colors.white70)),
                          onTap: () => _runBackup(context, ref),
                        ),
                        const Divider(color: Colors.white12, height: 1),
                        ListTile(
                          leading: const Icon(Icons.restore_outlined, color: Colors.orangeAccent),
                          title: const Text('Restaurar Datos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: const Text('Importar datos desde una copia previa', style: TextStyle(color: Colors.white70)),
                          onTap: () => _runRestore(context, ref),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white54, letterSpacing: 1.1),
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
        backgroundColor: const Color(0xFF0F766E),
        title: Text('Modificar $label', style: const TextStyle(color: Colors.white, fontSize: 17)),
        content: TextFormField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white70),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.tealAccent)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent, foregroundColor: Colors.black),
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
      builder: (ctx) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      final path = await ref.read(settingsNotifierProvider.notifier).exportBackup();
      if (context.mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF0F766E),
            title: const Text('Respaldo Exitoso', style: TextStyle(color: Colors.white)),
            content: Text('Se exportó la base de datos local a:\n\n$path\n\nPuedes copiar este archivo para guardarlo.', style: const TextStyle(color: Colors.white70)),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent, foregroundColor: Colors.black),
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
            backgroundColor: Colors.redAccent,
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
        backgroundColor: const Color(0xFF0F766E),
        title: const Text('Restaurar Datos', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ingresa la ruta absoluta del archivo SQLite (.sqlite) para restaurar los datos:', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Ruta del archivo',
                labelStyle: TextStyle(color: Colors.white70),
                hintText: '/ruta/al/archivo/ventafacil_backup.sqlite',
                hintStyle: TextStyle(color: Colors.white30),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.tealAccent)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.black),
            onPressed: () async {
              final path = controller.text.trim();
              if (path.isEmpty) return;
              Navigator.pop(ctx);
              
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (c) => const Center(child: CircularProgressIndicator(color: Colors.white)),
              );

              try {
                await ref.read(settingsNotifierProvider.notifier).importBackup(path);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Datos restaurados correctamente.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al restaurar: $e'),
                      backgroundColor: Colors.redAccent,
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
