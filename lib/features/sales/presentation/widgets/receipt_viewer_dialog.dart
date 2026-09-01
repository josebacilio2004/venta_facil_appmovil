import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/receipt_data.dart';
import '../utils/receipt_formatter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';

class ReceiptViewerDialog extends StatefulWidget {
  final ReceiptData receipt;

  const ReceiptViewerDialog({required this.receipt, super.key});

  @override
  State<ReceiptViewerDialog> createState() => _ReceiptViewerDialogState();
}

class _ReceiptViewerDialogState extends State<ReceiptViewerDialog> {
  late DocumentType _currentDocType;

  @override
  void initState() {
    super.initState();
    _currentDocType = widget.receipt.documentType;
  }

  ReceiptData get _activeReceipt {
    if (_currentDocType == widget.receipt.documentType) {
      return widget.receipt;
    }
    final prefix = _currentDocType == DocumentType.boleta ? 'B001' : 'T001';
    final correlativo = widget.receipt.saleId.toString().padLeft(8, '0');
    return ReceiptData(
      saleId: widget.receipt.saleId,
      documentType: _currentDocType,
      seriesNumber: '$prefix-$correlativo',
      machineSeries: widget.receipt.machineSeries,
      emissionDate: widget.receipt.emissionDate,
      issuerName: widget.receipt.issuerName,
      issuerRuc: widget.receipt.issuerRuc,
      issuerAddress: widget.receipt.issuerAddress,
      issuerPhone: widget.receipt.issuerPhone,
      customerName: widget.receipt.customerName,
      customerDocType: widget.receipt.customerDocType,
      customerDocNumber: widget.receipt.customerDocNumber,
      customerAddress: widget.receipt.customerAddress,
      items: widget.receipt.items,
      subtotal: widget.receipt.subtotal,
      discount: widget.receipt.discount,
      taxableAmount: widget.receipt.taxableAmount,
      igvAmount: widget.receipt.igvAmount,
      total: widget.receipt.total,
      paymentMethod: widget.receipt.paymentMethod,
      currency: widget.receipt.currency,
    );
  }

  @override
  Widget build(BuildContext context) {
    final receipt = _activeReceipt;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.receipt_long_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Comprobante SUNAT',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Selector Ticket / Boleta
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _currentDocType = DocumentType.ticket),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _currentDocType == DocumentType.ticket ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Ticket POS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _currentDocType == DocumentType.ticket ? AppTheme.primaryColor : Colors.white70,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _currentDocType = DocumentType.boleta),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _currentDocType == DocumentType.boleta ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Boleta Electrónica',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _currentDocType == DocumentType.boleta ? AppTheme.primaryColor : Colors.white70,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Paper Receipt Viewport (Scrollable)
            Flexible(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Empresa Header
                        Text(
                          receipt.issuerName.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.onSurfaceColor),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'RUC: ${receipt.issuerRuc}',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.onSurfaceVariantColor),
                        ),
                        Text(
                          receipt.issuerAddress,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariantColor),
                        ),
                        if (receipt.issuerPhone.isNotEmpty)
                          Text(
                            'Telf: ${receipt.issuerPhone}',
                            style: const TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariantColor),
                          ),
                        
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(color: AppTheme.outlineVariantColor, thickness: 1),
                        ),

                        // Document Badge & Number
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLow,
                            border: Border.all(color: AppTheme.outlineColor, width: 1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            receipt.documentTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppTheme.onSurfaceColor),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'N° ${receipt.seriesNumber}',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.onSurfaceColor, letterSpacing: 0.5),
                        ),
                        if (receipt.documentType == DocumentType.ticket)
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              'N° Serie Máquina: ${receipt.machineSeries}',
                              style: const TextStyle(fontSize: 10, color: AppTheme.onSurfaceVariantColor),
                            ),
                          ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(color: AppTheme.outlineVariantColor, thickness: 1),
                        ),

                        // Metadata (Fecha, Cliente)
                        _buildReceiptRow('Fecha de Emisión:', DateFormatter.formatDateTime(receipt.emissionDate)),
                        _buildReceiptRow('Cliente:', receipt.customerName),
                        if (receipt.customerDocNumber.isNotEmpty && receipt.customerDocNumber != '-')
                          _buildReceiptRow('${receipt.customerDocType}:', receipt.customerDocNumber),
                        if (receipt.customerAddress != null && receipt.customerAddress!.isNotEmpty)
                          _buildReceiptRow('Dirección:', receipt.customerAddress!),
                        _buildReceiptRow('Medio de Pago:', receipt.paymentMethod.toUpperCase()),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(color: AppTheme.onSurfaceColor, thickness: 1),
                        ),

                        // Table Header
                        const Row(
                          children: [
                            Expanded(flex: 5, child: Text('DESCRIPCIÓN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                            Expanded(flex: 2, child: Text('CANT', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                            Expanded(flex: 3, child: Text('TOTAL', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Divider(color: AppTheme.outlineVariantColor, thickness: 1),

                        // Items list
                        ...receipt.items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.productName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.onSurfaceColor)),
                                    Text('@ ${CurrencyFormatter.format(item.unitPrice)}', style: const TextStyle(fontSize: 10, color: AppTheme.onSurfaceVariantColor)),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text('${item.quantity}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceColor)),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(CurrencyFormatter.format(item.subtotal), textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.onSurfaceColor)),
                              ),
                            ],
                          ),
                        )),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(color: AppTheme.outlineVariantColor, thickness: 1),
                        ),

                        // Financial totals
                        if (receipt.discount > 0) ...[
                          _buildReceiptRow('Subtotal:', CurrencyFormatter.format(receipt.subtotal)),
                          _buildReceiptRow('Descuento:', '- ${CurrencyFormatter.format(receipt.discount)}', isDiscount: true),
                        ],

                        if (receipt.documentType == DocumentType.boleta) ...[
                          _buildReceiptRow('Op. Gravada:', CurrencyFormatter.format(receipt.taxableAmount)),
                          _buildReceiptRow('I.G.V. (18%):', CurrencyFormatter.format(receipt.igvAmount)),
                        ],

                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('TOTAL:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.onSurfaceColor)),
                            Text(
                              CurrencyFormatter.format(receipt.total),
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.primaryColor),
                            ),
                          ],
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Divider(color: AppTheme.outlineVariantColor, thickness: 1),
                        ),

                        // SUNAT QR Simulation box
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.outlineVariantColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.qr_code_2_rounded, size: 48, color: AppTheme.onSurfaceColor),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      receipt.documentType == DocumentType.boleta
                                          ? 'Representación impresa de la BOLETA ELECTRÓNICA'
                                          : 'Comprobante de Caja Registradora',
                                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceColor),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Autorizado por SUNAT / VentaFácil',
                                      style: TextStyle(fontSize: 8, color: AppTheme.onSurfaceVariantColor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '¡GRACIAS POR SU COMPRA!',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppTheme.onSurfaceColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Action buttons (Imprimir, Compartir, Listo)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _copyToClipboard(context, receipt),
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text('Copiar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _printReceipt(context, receipt),
                      icon: const Icon(Icons.print_rounded, size: 18),
                      label: const Text('Imprimir'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryContainerColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Listo', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariantColor)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDiscount ? AppTheme.errorColor : AppTheme.onSurfaceColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, ReceiptData receipt) {
    final plainText = ReceiptFormatter.formatToPlainText(receipt);
    Clipboard.setData(ClipboardData(text: plainText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ticket copiado al portapapeles. Listo para WhatsApp o impresora.'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _printReceipt(BuildContext context, ReceiptData receipt) {
    final plainText = ReceiptFormatter.formatToPlainText(receipt);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vista de Impresión'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Comprobante listo para enviar a tu impresora de tickets o impresora térmica POS.',
                style: TextStyle(color: AppTheme.onSurfaceVariantColor, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.outlineVariantColor),
                ),
                child: Text(
                  plainText,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppTheme.onSurfaceColor),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: plainText));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Comprobante enviado a la cola de impresión.'), backgroundColor: AppTheme.secondaryColor),
              );
            },
            icon: const Icon(Icons.print_rounded),
            label: const Text('Confirmar Impresión'),
          ),
        ],
      ),
    );
  }
}
