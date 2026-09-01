import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
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
  final GlobalKey _receiptKey = GlobalKey();
  late DocumentType _currentDocType;
  bool _isProcessing = false;

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
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 760),
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
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 6),
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
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Comprobante SUNAT',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17),
                        ),
                        Text(
                          'Impresión visual, imagen y envío por WhatsApp',
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
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 4.0),
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
                          padding: const EdgeInsets.symmetric(vertical: 7),
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
                          padding: const EdgeInsets.symmetric(vertical: 7),
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
            const SizedBox(height: 8),

            // Realistic Paper Sheet Viewport (Renderizado para Captura e Impresión)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
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
                    child: RepaintBoundary(
                      key: _receiptKey,
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Empresa Header
                            Text(
                              receipt.issuerName.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
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
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: _DashedDivider(),
                            ),

                            // Document Badge & Number
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                            const SizedBox(height: 5),
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
                              padding: EdgeInsets.symmetric(vertical: 8.0),
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
                              padding: EdgeInsets.symmetric(vertical: 6.0),
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
                              padding: const EdgeInsets.symmetric(vertical: 3.5),
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
                              padding: EdgeInsets.symmetric(vertical: 6.0),
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

                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('TOTAL A PAGAR:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.onSurfaceColor)),
                                Text(
                                  CurrencyFormatter.format(receipt.total),
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.primaryColor),
                                ),
                              ],
                            ),

                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: _DashedDivider(),
                            ),

                            // SUNAT QR Simulation box
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainerLow.withValues(alpha: 0.5),
                                border: Border.all(color: AppTheme.outlineVariantColor),
                                borderRadius: BorderRadius.circular(10),
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
                            const SizedBox(height: 10),
                            const Text(
                              '¡GRACIAS POR SU PREFERENCIA!',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppTheme.onSurfaceColor),
                            ),
                            const SizedBox(height: 3),
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
              ),
            ),

            // Action Toolbar (Imprimir Exacto, Guardar Imagen, Compartir WhatsApp)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      // 1. Imprimir Directo
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 3,
                          ),
                          onPressed: _isProcessing ? null : () => _printExactReceipt(receipt),
                          icon: const Icon(Icons.print_rounded, size: 18),
                          label: const Text('Imprimir', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // 2. Enviar por WhatsApp / Compartir
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 3,
                          ),
                          onPressed: _isProcessing ? null : () => _shareToWhatsApp(receipt),
                          icon: const Icon(Icons.send_rounded, size: 18),
                          label: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // 3. Guardar Imagen
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white38),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _isProcessing ? null : () => _saveReceiptImage(receipt),
                          icon: const Icon(Icons.image_outlined, size: 17),
                          label: const Text('Guardar Imagen', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // 4. Copiar Texto
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white38),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _copyToClipboard(context, receipt),
                          icon: const Icon(Icons.copy_rounded, size: 17),
                          label: const Text('Copiar Texto', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                        ),
                      ),
                    ],
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

  /// Captura el comprobante renderizado como imagen PNG en alta resolución (3.0x).
  Future<Uint8List?> _captureReceiptPng() async {
    try {
      final boundary = _receiptKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturando comprobante: $e');
      return null;
    }
  }

  /// Imprime el comprobante exactamente como se ve en la pantalla.
  Future<void> _printExactReceipt(ReceiptData receipt) async {
    setState(() => _isProcessing = true);
    try {
      final pngBytes = await _captureReceiptPng();
      if (pngBytes == null) throw Exception('No se pudo generar la imagen para impresión.');

      final pdf = pw.Document();
      final image = pw.MemoryImage(pngBytes);

      // Creamos la página con el tamaño exacto del ticket para rollo térmico o estándar
      pdf.addPage(
        pw.Page(
          pageFormat: const PdfPageFormat(80 * PdfPageFormat.mm, double.infinity, marginAll: 2 * PdfPageFormat.mm),
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(image),
            );
          },
        ),
      );

      await Printing.layoutPdf(
        name: 'Comprobante_${receipt.seriesNumber}',
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al imprimir: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  /// Guarda la imagen del comprobante en el almacenamiento local.
  Future<void> _saveReceiptImage(ReceiptData receipt) async {
    setState(() => _isProcessing = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final pngBytes = await _captureReceiptPng();
      if (pngBytes == null) throw Exception('No se pudo capturar la imagen.');

      if (kIsWeb) {
        // En Web lo enviamos a imprimir / descargar
        await Printing.sharePdf(bytes: pngBytes, filename: 'Comprobante_${receipt.seriesNumber}.png');
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final filePath = p.join(dir.path, 'Comprobante_${receipt.seriesNumber}.png');
        final file = File(filePath);
        await file.writeAsBytes(pngBytes);

        messenger.showSnackBar(
          SnackBar(
            content: Text('Comprobante guardado en: $filePath'),
            backgroundColor: AppTheme.secondaryColor,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error al guardar imagen: $e'), backgroundColor: AppTheme.errorColor),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  /// Comparte la imagen del comprobante por WhatsApp u otras aplicaciones.
  Future<void> _shareToWhatsApp(ReceiptData receipt) async {
    setState(() => _isProcessing = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final pngBytes = await _captureReceiptPng();
      if (pngBytes == null) throw Exception('No se pudo preparar la imagen para compartir.');

      final tempDir = await getTemporaryDirectory();
      final filePath = p.join(tempDir.path, 'Comprobante_${receipt.seriesNumber}.png');
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      final shareText = '📄 *${receipt.documentTitle} N° ${receipt.seriesNumber}*\n'
          '🏢 *${receipt.issuerName}* (RUC: ${receipt.issuerRuc})\n'
          '👤 Cliente: ${receipt.customerName}\n'
          '💰 *Total a Pagar: ${CurrencyFormatter.format(receipt.total)}*\n'
          '💳 Medio de Pago: ${receipt.paymentMethod.toUpperCase()}\n\n'
          '_Comprobante emitido por Sistema Fintech VentaFácil_';

      await SharePlus.instance.share(
        shareText,
        subject: 'Comprobante de Venta ${receipt.seriesNumber}',
        files: [XFile(file.path)],
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error al compartir comprobante: $e'), backgroundColor: AppTheme.errorColor),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _copyToClipboard(BuildContext context, ReceiptData receipt) {
    final plainText = ReceiptFormatter.formatToPlainText(receipt);
    Clipboard.setData(ClipboardData(text: plainText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Texto estructurado copiado al portapapeles.'),
        backgroundColor: AppTheme.primaryColor,
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
