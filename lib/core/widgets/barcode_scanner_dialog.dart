import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
  late AnimationController _animationController;
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppTheme.outlineVariantColor, width: 1),
      ),
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      title: Row(
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
            splashRadius: 20,
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Scanner Viewport Window
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1C30),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0050CB).withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Reticle Corner Guides
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: CustomPaint(
                          painter: _ScannerReticlePainter(
                            color: AppTheme.primaryContainerColor,
                          ),
                        ),
                      ),
                    ),

                    // Central Target Icon
                    const Center(
                      child: Icon(
                        Icons.filter_center_focus_rounded,
                        color: Colors.white24,
                        size: 48,
                      ),
                    ),

                    // Animated Laser Scanning Line
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        final topOffset = 26 + (_animationController.value * 124);
                        return Positioned(
                          top: topOffset,
                          left: 30,
                          right: 30,
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
                                  color: const Color(0xFF00E5FF).withValues(alpha: 0.8),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // Live Scan Badge
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.camera_alt_outlined, color: Colors.white70, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'Cámara Activa / Enfoque',
                                style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Subtitle
              const Text(
                'Apunta con la cámara al código de barras o ingrésalo manualmente:',
                style: TextStyle(
                  color: AppTheme.onSurfaceVariantColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Manual Input Field
              TextFormField(
                controller: _codeController,
                autofocus: true,
                style: const TextStyle(color: AppTheme.onSurfaceColor, fontSize: 15, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Ej: 7501055310883',
                  prefixIcon: const Icon(Icons.tag_rounded, color: AppTheme.outlineColor, size: 20),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                      tooltip: 'Confirmar Código',
                      onPressed: () {
                        final code = _codeController.text.trim();
                        if (code.isNotEmpty) {
                          Navigator.pop(context, code);
                        }
                      },
                    ),
                  ),
                ),
                onFieldSubmitted: (val) {
                  final code = val.trim();
                  if (code.isNotEmpty) {
                    Navigator.pop(context, code);
                  }
                },
              ),
              const SizedBox(height: 18),

              // Quick Mock Codes Divider
              const Row(
                children: [
                  Expanded(child: Divider(color: AppTheme.outlineVariantColor)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'CÓDIGOS RÁPIDOS DE PRUEBA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onSurfaceVariantColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppTheme.outlineVariantColor)),
                ],
              ),
              const SizedBox(height: 10),

              // Quick Mock Chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _buildMockScanButton('Coca-Cola', '7501055310883'),
                  _buildMockScanButton('Galletas Oreo', '7501001156824'),
                  _buildMockScanButton('Papa Lay\'s', '7501011123456'),
                  _buildMockScanButton('Gaseosa Inka', '7750123456789'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMockScanButton(String label, String code) {
    return InkWell(
      onTap: () => Navigator.pop(context, code),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.outlineVariantColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_2_rounded, size: 14, color: AppTheme.primaryColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
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
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 20.0;

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
