import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/local_image_helper.dart';
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
                // Sección Logo de la Empresa
                _buildSectionHeader('Logo del Negocio (Para Tickets y Comprobantes)'),
                FintechCard(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.outlineVariantColor),
                        ),
                        child: settings.businessLogoPath.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: LocalImageHelper.buildProductImage(
                                  settings.businessLogoPath,
                                  width: 68,
                                  height: 68,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Center(
                                child: Icon(Icons.add_photo_alternate_outlined, color: AppTheme.outlineColor, size: 28),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              settings.businessLogoPath.isNotEmpty ? 'Logo personalizado cargado' : 'Añade el logo de tu empresa',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.onSurfaceColor),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Aparecerá en la cabecera de tus boletas y tickets impresos.',
                              style: TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariantColor),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    visualDensity: VisualDensity.compact,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  icon: const Icon(Icons.camera_alt_outlined, size: 14),
                                  label: const Text('Cámara', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                  onPressed: () async {
                                    final path = await LocalImageHelper.pickAndSaveImage(ImageSource.camera);
                                    if (path != null) notifier.updateBusinessLogo(path);
                                  },
                                ),
                                const SizedBox(width: 6),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    visualDensity: VisualDensity.compact,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  icon: const Icon(Icons.photo_library_outlined, size: 14),
                                  label: const Text('Galería', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                  onPressed: () async {
                                    final path = await LocalImageHelper.pickAndSaveImage(ImageSource.gallery);
                                    if (path != null) notifier.updateBusinessLogo(path);
                                  },
                                ),
                                if (settings.businessLogoPath.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorColor, size: 18),
                                    tooltip: 'Quitar logo',
                                    onPressed: () => notifier.updateBusinessLogo(''),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

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

                // Sección Yape / Plin
                _buildSectionHeader('Billeteras Digitales (Yape / Plin / QR)'),
                FintechCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF8B5CF6), size: 20),
                        ),
                        title: const Text('Configurar Cobro con Yape / Plin', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.onSurfaceColor)),
                        subtitle: Text(
                          settings.yapePhone.isNotEmpty ? '${settings.yapeName} • Cel: ${settings.yapePhone}' : 'Configurar número, titular y QR',
                          style: const TextStyle(color: AppTheme.onSurfaceVariantColor, fontSize: 13),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.outlineColor),
                        onTap: () => _showYapeConfigDialog(context, ref, settings),
                      ),
                      if (settings.yapeQrPath.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LocalImageHelper.buildProductImage(
                                  settings.yapeQrPath,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Imagen de QR personalizada activa para mostrar en el cobro.',
                                  style: TextStyle(fontSize: 12, color: AppTheme.secondaryColor, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
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
                        trailing: DropdownButton<String>(
                          value: settings.currency,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 'S/.', child: Text('S/. (Soles)')),
                            DropdownMenuItem(value: '\$', child: Text('\$ (Dólares)')),
                          ],
                          onChanged: (val) {
                            if (val != null) notifier.updateCurrency(val);
                          },
                        ),
                      ),
                      const Divider(color: AppTheme.outlineVariantColor, height: 1),
                      ListTile(
                        leading: const Icon(Icons.palette_outlined, color: AppTheme.primaryColor),
                        title: const Text('Tema Visual', style: TextStyle(color: AppTheme.onSurfaceColor, fontWeight: FontWeight.w700, fontSize: 14)),
                        subtitle: Text(settings.themeMode == 'light' ? 'Tema Claro' : 'Tema Oscuro', style: const TextStyle(color: AppTheme.onSurfaceVariantColor, fontSize: 13)),
                        trailing: DropdownButton<String>(
                          value: settings.themeMode,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 'light', child: Text('Claro')),
                            DropdownMenuItem(value: 'dark', child: Text('Oscuro')),
                          ],
                          onChanged: (val) {
                            if (val != null) notifier.updateThemeMode(val);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                _buildSectionHeader('Copia de Seguridad y Datos Locales'),
                FintechCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.file_download_outlined, color: AppTheme.primaryColor),
                        title: const Text('Exportar Base de Datos (Backup)', style: TextStyle(color: AppTheme.onSurfaceColor, fontWeight: FontWeight.w700, fontSize: 14)),
                        subtitle: const Text('Genera un archivo SQLite con todos tus datos', style: TextStyle(color: AppTheme.onSurfaceVariantColor, fontSize: 13)),
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.outlineColor),
                        onTap: () => _runBackup(context, ref),
                      ),
                      const Divider(color: AppTheme.outlineVariantColor, height: 1),
                      ListTile(
                        leading: const Icon(Icons.file_upload_outlined, color: AppTheme.tertiaryColor),
                        title: const Text('Restaurar Base de Datos', style: TextStyle(color: AppTheme.onSurfaceColor, fontWeight: FontWeight.w700, fontSize: 14)),
                        subtitle: const Text('Carga un archivo SQLite previo', style: TextStyle(color: AppTheme.onSurfaceVariantColor, fontSize: 13)),
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.outlineColor),
                        onTap: () => _runRestore(context, ref),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'VentaFácil v1.0.0 • Fintech POS Offline',
                    style: TextStyle(color: AppTheme.outlineColor, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppTheme.onSurfaceVariantColor,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  void _showYapeConfigDialog(BuildContext context, WidgetRef ref, SettingsState settings) {
    final nameCtrl = TextEditingController(text: settings.yapeName);
    final phoneCtrl = TextEditingController(text: settings.yapePhone);
    String qrPath = settings.yapeQrPath;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.qr_code_2_rounded, color: Color(0xFF8B5CF6)),
              SizedBox(width: 8),
              Text('Configurar Yape / Plin', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Titular de la Cuenta',
                    hintText: 'Ej: Juan Pérez / Mi Negocio SAC',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Número de Teléfono para Yape / Plin',
                    hintText: 'Ej: 987654321',
                    prefixIcon: Icon(Icons.phone_iphone_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'IMAGEN DEL CÓDIGO QR (OPCIONAL):',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.onSurfaceVariantColor),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.outlineVariantColor),
                      ),
                      child: qrPath.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: LocalImageHelper.buildProductImage(qrPath, width: 72, height: 72, fit: BoxFit.cover),
                            )
                          : const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF8B5CF6), size: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.surfaceContainerLow,
                              foregroundColor: AppTheme.primaryColor,
                              elevation: 0,
                            ),
                            onPressed: () async {
                              final path = await LocalImageHelper.pickAndSaveImage(source: ImageSource.gallery);
                              if (path != null) {
                                setState(() => qrPath = path);
                              }
                            },
                            icon: const Icon(Icons.upload_file_rounded, size: 16),
                            label: const Text('Subir Foto QR', style: TextStyle(fontSize: 12)),
                          ),
                          if (qrPath.isNotEmpty)
                            TextButton(
                              onPressed: () => setState(() => qrPath = ''),
                              child: const Text('Quitar imagen (Usar QR auto)', style: TextStyle(fontSize: 11, color: AppTheme.errorColor)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              onPressed: () async {
                await ref.read(settingsNotifierProvider.notifier).updateYapeInfo(
                  yapeName: nameCtrl.text.trim(),
                  yapePhone: phoneCtrl.text.trim(),
                  yapeQrPath: qrPath,
                );
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Datos de Yape/Plin guardados con éxito.'), backgroundColor: AppTheme.secondaryColor),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _editSingleField(BuildContext context, WidgetRef ref, String label, String key, String currentValue, {bool isNumeric = false}) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Editar $label', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(labelText: label),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final val = controller.text.trim();
              if (val.isNotEmpty) {
                final current = ref.read(settingsNotifierProvider);
                await ref.read(settingsNotifierProvider.notifier).updateBusinessInfo(
                  businessName: key == 'business_name' ? val : current.businessName,
                  ruc: key == 'ruc' ? val : current.ruc,
                  address: key == 'address' ? val : current.address,
                  phone: key == 'phone' ? val : current.phone,
                  machineSeries: key == 'machine_series' ? val : current.machineSeries,
                  ticketSeries: key == 'ticket_series' ? val : current.ticketSeries,
                  boletaSeries: key == 'boleta_series' ? val : current.boletaSeries,
                );
              }
              if (ctx.mounted) Navigator.pop(ctx);
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
