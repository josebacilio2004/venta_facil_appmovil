import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/local_image_helper.dart';
import '../../../customers/presentation/providers/customers_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/entities/receipt_data.dart';
import '../providers/sales_providers.dart';
import 'sale_success_dialog.dart';

class CheckoutDialog extends ConsumerStatefulWidget {
  const CheckoutDialog({super.key});

  @override
  ConsumerState<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends ConsumerState<CheckoutDialog> {
  final _discountController = TextEditingController();
  int? _selectedCustomerId;
  String _selectedPaymentMethod = 'efectivo';
  DocumentType _selectedDocType = DocumentType.ticket;
  bool _isDigitalPaymentConfirmed = false;

  final List<Map<String, String>> _paymentMethods = [
    {'value': 'efectivo', 'label': 'Efectivo'},
    {'value': 'yape', 'label': 'Yape'},
    {'value': 'plin', 'label': 'Plin'},
    {'value': 'tarjeta', 'label': 'Tarjeta'},
    {'value': 'transferencia', 'label': 'Transferencia'},
    {'value': 'otro', 'label': 'Otro'},
  ];

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final customersAsync = ref.watch(customersListProvider);
    final settings = ref.watch(settingsNotifierProvider);
    final isDigitalWallet = _selectedPaymentMethod == 'yape' || _selectedPaymentMethod == 'plin';

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.point_of_sale_rounded, color: AppTheme.primaryColor, size: 22),
          ),
          const SizedBox(width: 10),
          const Text(
            'Confirmar Venta y Cobro',
            style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.onSurfaceColor, fontSize: 18),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resumen de montos
              _buildRowSummary('Subtotal', CurrencyFormatter.format(cart.subtotal)),
              if (cart.discount > 0)
                _buildRowSummary('Descuento aplicado', '- ${CurrencyFormatter.format(cart.discount)}', isDiscount: true),
              const Divider(color: AppTheme.outlineVariantColor),
              _buildRowSummary('TOTAL A COBRAR', CurrencyFormatter.format(cart.total), isTotal: true),
              const SizedBox(height: 14),

              // Tipo de Comprobante
              const Text('Comprobante SUNAT:', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.onSurfaceColor, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Ticket POS')),
                      selected: _selectedDocType == DocumentType.ticket,
                      selectedColor: AppTheme.primaryColor,
                      labelStyle: TextStyle(
                        color: _selectedDocType == DocumentType.ticket ? Colors.white : AppTheme.onSurfaceVariantColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: AppTheme.outlineVariantColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedDocType = DocumentType.ticket);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Boleta Electrónica')),
                      selected: _selectedDocType == DocumentType.boleta,
                      selectedColor: AppTheme.primaryColor,
                      labelStyle: TextStyle(
                        color: _selectedDocType == DocumentType.boleta ? Colors.white : AppTheme.onSurfaceVariantColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: AppTheme.outlineVariantColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedDocType = DocumentType.boleta);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Selección de Cliente
              customersAsync.when(
                data: (list) => DropdownButtonFormField<int>(
                  value: _selectedCustomerId,
                  decoration: InputDecoration(
                    labelText: _selectedDocType == DocumentType.boleta ? 'Cliente (Recomendado DNI/RUC)' : 'Cliente (Opcional)',
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Clientes Varios / Sin Documento')),
                    ...list.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text('${c.name} ${c.phone.isNotEmpty ? '(${c.phone})' : ''}'),
                    )),
                  ],
                  onChanged: (val) => setState(() => _selectedCustomerId = val),
                ),
                loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
                error: (_, __) => const Text('Error al cargar clientes'),
              ),
              const SizedBox(height: 12),

              // Ingreso de Descuento
              TextFormField(
                controller: _discountController,
                decoration: const InputDecoration(
                  labelText: 'Aplicar Descuento (S/.)',
                  prefixText: 'S/. ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (val) {
                  final disc = double.tryParse(val) ?? 0.0;
                  ref.read(cartProvider.notifier).applyDiscount(disc);
                },
              ),
              const SizedBox(height: 14),

              // Métodos de Pago
              const Text('Método de Pago:', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.onSurfaceColor, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _paymentMethods.map((m) {
                  final isSelected = _selectedPaymentMethod == m['value'];
                  return ChoiceChip(
                    label: Text(m['label']!),
                    selected: isSelected,
                    selectedColor: _getPaymentMethodColor(m['value']!),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.onSurfaceVariantColor,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      fontSize: 12,
                    ),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppTheme.outlineVariantColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedPaymentMethod = m['value']!;
                          _isDigitalPaymentConfirmed = false;
                        });
                      }
                    },
                  );
                }).toList(),
              ),

              // Frame interactivo de Cobro con Yape / Plin
              if (isDigitalWallet) ...[
                const SizedBox(height: 16),
                _buildDigitalWalletQrFrame(context, settings, cart.total),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(cartProvider.notifier).applyDiscount(0.0);
            Navigator.pop(context);
          },
          child: const Text('Cancelar', style: TextStyle(color: AppTheme.onSurfaceVariantColor)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isDigitalWallet && !_isDigitalPaymentConfirmed
                ? AppTheme.outlineColor
                : AppTheme.primaryContainerColor,
          ),
          onPressed: () => _confirmCheckout(context),
          child: const Text('Emitir Comprobante y Cobrar'),
        ),
      ],
    );
  }

  Color _getPaymentMethodColor(String method) {
    switch (method) {
      case 'yape':
        return const Color(0xFF8B5CF6);
      case 'plin':
        return const Color(0xFF06B6D4);
      case 'tarjeta':
        return const Color(0xFFF59E0B);
      default:
        return AppTheme.primaryColor;
    }
  }

  Widget _buildDigitalWalletQrFrame(BuildContext context, SettingsState settings, double total) {
    final isYape = _selectedPaymentMethod == 'yape';
    final brandColor = isYape ? const Color(0xFF8B5CF6) : const Color(0xFF06B6D4);
    final brandName = isYape ? 'Yape' : 'Plin';
    final titular = settings.yapeName.isNotEmpty ? settings.yapeName : settings.businessName;
    final phone = settings.yapePhone.isNotEmpty ? settings.yapePhone : settings.phone;
    final qrData = '$brandName:$phone?amount=${total.toStringAsFixed(2)}&name=${Uri.encodeComponent(titular)}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: brandColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: brandColor.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_2_rounded, color: brandColor, size: 20),
              const SizedBox(width: 6),
              Text(
                'Escanea para pagar con $brandName',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: brandColor),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // QR Viewport
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: settings.yapeQrPath.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LocalImageHelper.buildProductImage(
                      settings.yapeQrPath,
                      width: 140,
                      height: 140,
                      fit: BoxFit.contain,
                    ),
                  )
                : QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 140,
                    backgroundColor: Colors.white,
                    eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: brandColor),
                    dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: AppTheme.onSurfaceColor),
                  ),
          ),
          const SizedBox(height: 10),

          // Business Details
          Text(
            'Titular: $titular',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppTheme.onSurfaceColor),
            textAlign: TextAlign.center,
          ),
          Text(
            'Número: $phone',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: brandColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Monto exacto: ${CurrencyFormatter.format(total)}',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.onSurfaceColor),
          ),
          const SizedBox(height: 10),

          // Owner Confirmation Checkbox
          InkWell(
            onTap: () => setState(() => _isDigitalPaymentConfirmed = !_isDigitalPaymentConfirmed),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: _isDigitalPaymentConfirmed ? brandColor.withValues(alpha: 0.18) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _isDigitalPaymentConfirmed ? brandColor : AppTheme.outlineVariantColor),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _isDigitalPaymentConfirmed,
                    activeColor: brandColor,
                    onChanged: (val) => setState(() => _isDigitalPaymentConfirmed = val ?? false),
                  ),
                  Expanded(
                    child: Text(
                      'Confirmo que verifiqué la llegada del $brandName en mi cuenta.',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _isDigitalPaymentConfirmed ? brandColor : AppTheme.onSurfaceColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowSummary(String label, String value, {bool isTotal = false, bool isDiscount = false}) {
    final style = TextStyle(
      fontSize: isTotal ? 17 : 13,
      fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
      color: isTotal
          ? AppTheme.primaryColor
          : isDiscount
              ? AppTheme.tertiaryColor
              : AppTheme.onSurfaceVariantColor,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }

  void _confirmCheckout(BuildContext context) async {
    final cart = ref.read(cartProvider);
    if (cart.items.isEmpty) return;

    final isDigitalWallet = _selectedPaymentMethod == 'yape' || _selectedPaymentMethod == 'plin';
    if (isDigitalWallet && !_isDigitalPaymentConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor marca la casilla para confirmar que recibiste el $_selectedPaymentMethod.'),
          backgroundColor: AppTheme.tertiaryColor,
        ),
      );
      return;
    }

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final settings = ref.read(settingsNotifierProvider);
    final customersList = await ref.read(customersListProvider.future);

    // Find customer details if selected
    String customerName = 'Clientes Varios';
    String customerDocType = '-';
    String customerDocNumber = '-';
    String? customerAddress;

    if (_selectedCustomerId != null) {
      final customer = customersList.firstWhere(
        (c) => c.id == _selectedCustomerId,
        orElse: () => customersList.first,
      );
      customerName = customer.name;
      customerDocType = customer.phone.length == 8 ? 'DNI' : (customer.phone.length == 11 ? 'RUC' : 'DOC');
      customerDocNumber = customer.phone;
      customerAddress = customer.notes;
    }

    // Save cart snapshot for receipt
    final snapshotItems = cart.items.map((i) => ReceiptItemData(
      productName: i.product.name,
      quantity: i.quantity,
      unitPrice: i.product.sellingPrice,
      subtotal: i.subtotal,
      unitMeasure: 'UND',
    )).toList();

    final subtotal = cart.subtotal;
    final discount = cart.discount;
    final total = cart.total;
    final taxable = total / 1.18;
    final igv = total - taxable;

    try {
      final saleId = await ref.read(cartProvider.notifier).checkout(
        customerId: _selectedCustomerId,
        paymentMethod: _selectedPaymentMethod,
        ref: ref,
      );

      final prefix = _selectedDocType == DocumentType.boleta ? settings.boletaSeries : settings.ticketSeries;
      final seriesNumber = '$prefix-${saleId.toString().padLeft(8, '0')}';

      final receiptData = ReceiptData(
        saleId: saleId,
        documentType: _selectedDocType,
        seriesNumber: seriesNumber,
        machineSeries: settings.machineSeries,
        emissionDate: DateTime.now(),
        issuerName: settings.businessName,
        issuerRuc: settings.ruc,
        issuerAddress: settings.address,
        issuerPhone: settings.phone,
        customerName: customerName,
        customerDocType: customerDocType,
        customerDocNumber: customerDocNumber,
        customerAddress: customerAddress,
        items: snapshotItems,
        subtotal: subtotal,
        discount: discount,
        taxableAmount: taxable,
        igvAmount: igv,
        total: total,
        paymentMethod: _selectedPaymentMethod,
        currency: settings.currency,
      );

      // Close checkout dialog
      if (navigator.canPop()) {
        navigator.pop();
      }

      // Open sale success dialog with sound feedback and stock update confirmation
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => SaleSuccessDialog(receipt: receiptData),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error al registrar venta: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}
