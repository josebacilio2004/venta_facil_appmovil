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
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 720),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Comprobante SUNAT',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                        ),
                        Text(
                          'Listo para imprimir o entregar al cliente',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
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
                  color: Colors.black.withValues(alpha: 0.25),
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
                            boxShadow: _currentDocType == DocumentType.ticket
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_rounded,
                                size: 16,
                                color: _currentDocType == DocumentType.ticket ? AppTheme.primaryColor : Colors.white70,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Ticket POS',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _currentDocType == DocumentType.ticket ? AppTheme.primaryColor : Colors.white70,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
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
                            boxShadow: _currentDocType == DocumentType.boleta
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.description_rounded,
                                size: 16,
                                color: _currentDocType == DocumentType.boleta ? AppTheme.primaryColor : Colors.white70,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Boleta Electrónica',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _currentDocType == DocumentType.boleta ? AppTheme.primaryColor : Colors.white70,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Realistic Paper Sheet Viewport
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Empresa Header
                        Text(
                          receipt.issuerName.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                            color: AppTheme.onSurfaceColor,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'RUC: ${receipt.issuerRuc}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: AppTheme.onSurfaceVariantColor,
                          ),
                        ),
                        if (receipt.issuerAddress.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              receipt.issuerAddress,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariantColor),
                            ),
                          ),
                        if (receipt.issuerPhone.isNotEmpty)
                          Text(
                            'Telf: ${receipt.issuerPhone}',
                            style: const TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariantColor),
                          ),
                        
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: _DashedDivider(),
                        ),

                        // Document Badge & Number
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLow,
                            border: Border.all(color: AppTheme.outlineVariantColor, width: 1.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            receipt.documentTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              color: AppTheme.onSurfaceColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'N° ${receipt.seriesNumber}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                            color: AppTheme.primaryColor,
                            letterSpacing: 0.5,
                          ),
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
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: _DashedDivider(),
                        ),

                        // Metadata (Fecha, Cliente, Pago)
                        _buildReceiptRow('Fecha y Hora:', DateFormatter.formatDateTime(receipt.emissionDate)),
                        _buildReceiptRow('Cliente:', receipt.customerName),
                        if (receipt.customerDocNumber.isNotEmpty && receipt.customerDocNumber != '-')
                          _buildReceiptRow('${receipt.customerDocType}:', receipt.customerDocNumber),
                        if (receipt.customerAddress != null && receipt.customerAddress!.isNotEmpty)
                          _buildReceiptRow('Dirección:', receipt.customerAddress!),
                        _buildReceiptRow('Medio de Pago:', receipt.paymentMethod.toUpperCase()),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(color: AppTheme.onSurfaceColor, thickness: 1.2),
                        ),

                        // Table Header
                        const Row(
                          children: [
                            Expanded(flex: 5, child: Text('DESCRIPCIÓN', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppTheme.onSurfaceColor))),
                            Expanded(flex: 2, child: Text('CANT', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppTheme.onSurfaceColor))),
                            Expanded(flex: 3, child: Text('TOTAL', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppTheme.onSurfaceColor))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const _DashedDivider(),
                        const SizedBox(height: 4),

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
                                    Text(item.productName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.onSurfaceColor)),
                                    Text('@ ${CurrencyFormatter.format(item.unitPrice)}', style: const TextStyle(fontSize: 10, color: AppTheme.onSurfaceVariantColor)),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text('${item.quantity}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.onSurfaceColor)),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(CurrencyFormatter.format(item.subtotal), textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.onSurfaceColor)),
                              ),
                            ],
                          ),
                        )),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: _DashedDivider(),
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

                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('TOTAL A PAGAR:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppTheme.onSurfaceColor)),
                            Text(
                              CurrencyFormatter.format(receipt.total),
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19, color: AppTheme.primaryColor),
                            ),
                          ],
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: _DashedDivider(),
                        ),

                        // SUNAT QR Simulation box
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLow.withValues(alpha: 0.5),
                            border: Border.all(color: AppTheme.outlineVariantColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.qr_code_2_rounded, size: 52, color: AppTheme.onSurfaceColor),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      receipt.documentType == DocumentType.boleta
                                          ? 'Representación impresa de la BOLETA ELECTRÓNICA'
                                          : 'Comprobante de Caja Registradora',
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.onSurfaceColor),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Autorizado mediante resolución SUNAT.\nConsulta tu comprobante en el portal.',
                                      style: TextStyle(fontSize: 9, color: AppTheme.onSurfaceVariantColor, height: 1.2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '¡GRACIAS POR SU PREFERENCIA!',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppTheme.onSurfaceColor),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'VentaFácil Sistema Fintech POS',
                          style: TextStyle(fontSize: 9, color: AppTheme.outlineColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Action Buttons Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white38),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _copyToClipboard(context, receipt),
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text('Copiar', style: TextStyle(fontWeight: FontWeight.w700)),
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
                        elevation: 4,
                      ),
                      onPressed: () => _executePrint(context, receipt),
                      icon: const Icon(Icons.print_rounded, size: 18),
                      label: const Text('Imprimir', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryContainerColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Listo', style: TextStyle(fontWeight: FontWeight.w800)),
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
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariantColor, fontWeight: FontWeight.w500)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
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
        content: Text('Comprobante copiado al portapapeles. Listo para WhatsApp o impresora.'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _executePrint(BuildContext context, ReceiptData receipt) {
    final plainText = ReceiptFormatter.formatToPlainText(receipt);
    Clipboard.setData(ClipboardData(text: plainText));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
              child: const Icon(Icons.print_rounded, color: AppTheme.primaryColor, size: 22),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Comprobante Enviado a Impresión',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.onSurfaceColor),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.secondaryContainerColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.secondaryColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppTheme.secondaryColor, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'El ${receipt.documentTitle} N° ${receipt.seriesNumber} está listo para su impresora térmica POS (58mm/80mm) y copiado al portapapeles.',
                      style: const TextStyle(fontSize: 12, color: AppTheme.secondaryColor, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Opciones de Entrega al Cliente:',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.onSurfaceColor),
            ),
            const SizedBox(height: 8),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.send_to_mobile_rounded, color: Color(0xFF25D366)),
              title: const Text('Enviar por WhatsApp', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              subtitle: const Text('Pega el texto copiado directamente en el chat del cliente', style: TextStyle(fontSize: 11)),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.outlineColor),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Texto formateado copiado para WhatsApp.'), backgroundColor: Color(0xFF25D366)),
                );
              },
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: AppTheme.outlineVariantColor),
              ),
            );
          }),
        );
      },
    );
  }
}
