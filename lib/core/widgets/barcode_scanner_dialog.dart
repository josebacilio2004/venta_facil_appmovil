import 'package:flutter/material.dart';

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
      duration: const Duration(seconds: 2),
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
      backgroundColor: const Color(0xFF0F766E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 250,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 15, left: 15, right: 15, bottom: 15,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white54, width: 1),
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      final topOffset = 20 + (_animationController.value * 140);
                      return Positioned(
                        top: topOffset,
                        left: 25,
                        right: 25,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.redAccent.withOpacity(0.8),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const Center(
                    child: Icon(Icons.camera_alt, color: Colors.white38, size: 40),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Apunta con la cámara al código de barra\no introduce el código manualmente:',
              style: TextStyle(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _codeController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ej: 7501055310883',
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Colors.tealAccent),
                  onPressed: () {
                    final code = _codeController.text.trim();
                    if (code.isNotEmpty) {
                      Navigator.pop(context, code);
                    }
                  },
                ),
              ),
              onFieldSubmitted: (val) {
                final code = val.trim();
                if (code.isNotEmpty) {
                  Navigator.pop(context, code);
                }
              },
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white24),
            const SizedBox(height: 8),
            const Text('Simular escaneo de prueba (Códigos rápidos):', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
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
    );
  }

  Widget _buildMockScanButton(String label, String code) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white24,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        minimumSize: Size.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () {
        Navigator.pop(context, code);
      },
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
