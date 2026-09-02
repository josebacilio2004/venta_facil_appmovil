import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../theme/app_theme.dart';
import '../utils/sound_feedback.dart';

class BarcodeScannerDialog extends StatefulWidget {
  final String title;

  const BarcodeScannerDialog({
    this.title = 'Escanear Código de Barras',
    super.key,
  });

  @override
  State<BarcodeScannerDialog> createState() => _BarcodeScannerDialogState();
}

class _BarcodeScannerDialogState extends State<BarcodeScannerDialog> with SingleTickerProviderStateMixin {
  late MobileScannerController _scannerController;
  late AnimationController _laserAnimationController;
  final _manualCodeController = TextEditingController();
  bool _hasDetected = false;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _laserAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _laserAnimationController.dispose();
    _scannerController.dispose();
    _manualCodeController.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(String code) {
    if (_hasDetected) return;
    _hasDetected = true;
    SoundFeedback.playScannerBeep();
    Navigator.of(context).pop(code.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 680),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: AppTheme.primaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: AppTheme.onSurfaceColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppTheme.outlineColor, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Live Camera Viewport
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    color: const Color(0xFF0B1C30),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Cámara en Vivo
                        MobileScanner(
                          controller: _scannerController,
                          onDetect: (BarcodeCapture capture) {
                            final barcodes = capture.barcodes;
                            for (final barcode in barcodes) {
                              final rawValue = barcode.rawValue;
                              if (rawValue != null && rawValue.trim().isNotEmpty) {
                                _onBarcodeDetected(rawValue);
                                break;
                              }
                            }
                          },
                          errorBuilder: (context, error) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 48),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Cámara no disponible o en emulador.',
                                      style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      error.errorDetails?.message ?? 'Usa la entrada manual abajo',
                                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        // Retícula / Guías angulares de escaneo
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: CustomPaint(
                              painter: _ScannerReticlePainter(
                                color: AppTheme.primaryContainerColor,
                              ),
                            ),
                          ),
                        ),

                        // Línea Láser Animada
                        AnimatedBuilder(
                          animation: _laserAnimationController,
                          builder: (context, child) {
                            return Positioned(
                              top: 50 + (_laserAnimationController.value * 180),
                              left: 40,
                              right: 40,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Color(0xFF00E5FF),
                                      Color(0xFF0066FF),
                                      Color(0xFF00E5FF),
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00E5FF).withValues(alpha: 0.85),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        // Controles de Cámara (Linterna y Cambio de Cámara)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.black.withValues(alpha: 0.6),
                                radius: 18,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                                    color: _isTorchOn ? Colors.amberAccent : Colors.white,
                                    size: 18,
                                  ),
                                  tooltip: 'Linterna',
                                  onPressed: () async {
                                    await _scannerController.toggleTorch();
                                    setState(() => _isTorchOn = !_isTorchOn);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              CircleAvatar(
                                backgroundColor: Colors.black.withValues(alpha: 0.6),
                                radius: 18,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white, size: 18),
                                  tooltip: 'Cambiar Cámara',
                                  onPressed: () => _scannerController.switchCamera(),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Badge inferior informativo
                        Positioned(
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.center_focus_strong_rounded, color: Color(0xFF68FADD), size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'Apunta al código de barras del producto',
                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Manual Entry Field & Quick Mock Codes
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _manualCodeController,
                    style: const TextStyle(color: AppTheme.onSurfaceColor, fontSize: 14, fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      hintText: 'O ingresa el código manual (ej: 750105...)',
                      prefixIcon: const Icon(Icons.tag_rounded, color: AppTheme.outlineColor, size: 20),
                      suffixIcon: Container(
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                          tooltip: 'Confirmar Código',
                          onPressed: () {
                            final val = _manualCodeController.text.trim();
                            if (val.isNotEmpty) _onBarcodeDetected(val);
                          },
                        ),
                      ),
                    ),
                    onFieldSubmitted: (val) {
                      if (val.trim().isNotEmpty) _onBarcodeDetected(val.trim());
                    },
                  ),
                  const SizedBox(height: 10),

                  // Botón Generar Código Automático para Productos sin Código (ej: Papa, Fruta a granel)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: const BorderSide(color: AppTheme.primaryColor, width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                      label: const Text(
                        'Generar Código para Producto a Granel (ej: Papa)',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                      onPressed: () {
                        final autoCode = '775${DateTime.now().millisecondsSinceEpoch.toString().substring(3)}';
                        _onBarcodeDetected(autoCode);
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Quick test mock chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildMockButton('Coca-Cola', '7501055310883'),
                      _buildMockButton('Galletas Oreo', '7501001156824'),
                      _buildMockButton('Papa Amarilla (Kg)', '7759876543210'),
                      _buildMockButton('Crema Facial', '7751234567890'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildMockButton(String label, String code) {
    return InkWell(
      onTap: () => _onBarcodeDetected(code),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.outlineVariantColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_rounded, size: 12, color: AppTheme.primaryColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerReticlePainter extends CustomPainter {
  final Color color;

  _ScannerReticlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 24.0;

    // Top-Left
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLength), paint);

    // Top-Right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerLength, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLength), paint);

    // Bottom-Left
    canvas.drawLine(Offset(0, size.height), Offset(cornerLength, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerLength), paint);

    // Bottom-Right
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerLength, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
