import 'package:flutter/services.dart';

class SoundFeedback {
  /// Emite retroalimentación háptica y sonido de éxito/caja al cerrar una venta.
  static Future<void> playSaleSuccessSound() async {
    try {
      await HapticFeedback.heavyImpact();
      await SystemSound.play(SystemSoundType.click);
      // Breve retardo para el segundo pulso
      await Future.delayed(const Duration(milliseconds: 120));
      await HapticFeedback.mediumImpact();
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {
      // Si el dispositivo no soporta sonido de sistema, continúa sin interrumpir
    }
  }
}
