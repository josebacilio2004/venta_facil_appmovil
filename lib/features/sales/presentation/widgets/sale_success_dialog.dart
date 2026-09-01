import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/sound_feedback.dart';
import '../../domain/entities/receipt_data.dart';
import 'receipt_viewer_dialog.dart';

class SaleSuccessDialog extends StatefulWidget {
  final ReceiptData receipt;

  const SaleSuccessDialog({required this.receipt, super.key});

  @override
  State<SaleSuccessDialog> createState() => _SaleSuccessDialogState();
}

class _SaleSuccessDialogState extends State<SaleSuccessDialog> {
  @override
  void initState() {
    super.initState();
    // Emitir sonido de confirmación al abrir el diálogo
    SoundFeedback.playSaleSuccessSound();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Checkmark Circle Icon with Glow
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppTheme.secondaryContainerColor.withValues(alpha: 0.35),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.secondaryColor.withValues(alpha: 0.4), width: 2),
              ),
              child: const Center(
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.secondaryColor,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Title
            const Text(
              '¡Venta Registrada con Éxito!',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: AppTheme.onSurfaceColor,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Stock Updated Message Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.outlineVariantColor),
              ),
              child: const Row(
                children: [
                  Icon(Icons.inventory_2_outlined, color: AppTheme.primaryColor, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'El stock de los productos vendidos ha sido actualizado en el inventario.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.onSurfaceColor,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Sale Summary Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1C30),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.receipt.documentTitle} N° ${widget.receipt.seriesNumber}',
                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.receipt.paymentMethod.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Cobrado:',
                        style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        CurrencyFormatter.format(widget.receipt.total),
                        style: const TextStyle(
                          color: Color(0xFF68FADD),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                    label: const Text('Nueva Venta', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (ctx) => ReceiptViewerDialog(receipt: widget.receipt),
                      );
                    },
                    icon: const Icon(Icons.receipt_long_rounded, size: 18),
                    label: const Text('Ver Ticket', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
