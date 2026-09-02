import 'dart:math' as math;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class SoundFeedback {
  static final AudioPlayer _scannerPlayer = AudioPlayer();
  static final AudioPlayer _salePlayer = AudioPlayer();
  
  static Uint8List? _scannerBeepBytes;
  static Uint8List? _saleChimeBytes;

  /// Genera un buffer de audio WAV en memoria con tono senoidal puro.
  static Uint8List _generateSineWaveWav({
    required List<double> frequencies,
    required double durationSeconds,
    int sampleRate = 44100,
    double volume = 0.9,
  }) {
    final int numSamples = (sampleRate * durationSeconds).toInt();
    final int dataSize = numSamples * 2; // 16-bit mono = 2 bytes per sample
    final int fileSize = 44 + dataSize;

    final ByteData byteData = ByteData(fileSize);

    // Header RIFF
    byteData.setUint8(0, 0x52); // 'R'
    byteData.setUint8(1, 0x49); // 'I'
    byteData.setUint8(2, 0x46); // 'F'
    byteData.setUint8(3, 0x46); // 'F'
    byteData.setUint32(4, fileSize - 8, Endian.little);

    // Format WAVE
    byteData.setUint8(8, 0x57);  // 'W'
    byteData.setUint8(9, 0x41);  // 'A'
    byteData.setUint8(10, 0x56); // 'V'
    byteData.setUint8(11, 0x45); // 'E'

    // Subchunk 1 "fmt "
    byteData.setUint8(12, 0x66); // 'f'
    byteData.setUint8(13, 0x6D); // 'm'
    byteData.setUint8(14, 0x74); // 't'
    byteData.setUint8(15, 0x20); // ' '
    byteData.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
    byteData.setUint16(20, 1, Endian.little);  // AudioFormat (1 for PCM)
    byteData.setUint16(22, 1, Endian.little);  // NumChannels (1 mono)
    byteData.setUint32(24, sampleRate, Endian.little); // SampleRate
    byteData.setUint32(28, sampleRate * 2, Endian.little); // ByteRate
    byteData.setUint16(32, 2, Endian.little);  // BlockAlign
    byteData.setUint16(34, 16, Endian.little); // BitsPerSample

    // Subchunk 2 "data"
    byteData.setUint8(36, 0x64); // 'd'
    byteData.setUint8(37, 0x61); // 'a'
    byteData.setUint8(38, 0x74); // 't'
    byteData.setUint8(39, 0x61); // 'a'
    byteData.setUint32(40, dataSize, Endian.little);

    // Generación de muestras de audio
    int offset = 44;
    for (int i = 0; i < numSamples; i++) {
      final double t = i / sampleRate;
      
      // Envolvente de ataque y decaimiento suave para evitar clics
      double envelope = 1.0;
      final double attackTime = 0.01;
      final double decayTime = durationSeconds - 0.02;
      if (t < attackTime) {
        envelope = t / attackTime;
      } else if (t > decayTime) {
        envelope = (durationSeconds - t) / (durationSeconds - decayTime);
      }

      double sampleValue = 0.0;
      for (final freq in frequencies) {
        sampleValue += math.sin(2 * math.pi * freq * t);
      }
      sampleValue = (sampleValue / frequencies.length) * envelope * volume;

      final int sampleInt16 = (sampleValue * 32767).clamp(-32768, 32767).toInt();
      byteData.setInt16(offset, sampleInt16, Endian.little);
      offset += 2;
    }

    return byteData.buffer.asUint8List();
  }

  /// Inicializa los buffers de audio en memoria.
  static void _initBuffers() {
    _scannerBeepBytes ??= _generateSineWaveWav(
      frequencies: [2500.0], // Frecuencia clásica de lector de código de barras de caja registradora
      durationSeconds: 0.11,
      volume: 0.95,
    );

    _saleChimeBytes ??= _generateSineWaveWav(
      frequencies: [1046.5, 1318.5, 2093.0], // Acorde armónico C6-E6-C7 de éxito/caja
      durationSeconds: 0.28,
      volume: 0.95,
    );
  }

  /// Emite el sonido sonoro y nítido de escaneo ("BEEP!") y vibración háptica.
  static Future<void> playScannerBeep() async {
    try {
      HapticFeedback.heavyImpact();
      _initBuffers();
      if (_scannerBeepBytes != null) {
        await _scannerPlayer.stop();
        await _scannerPlayer.play(BytesSource(_scannerBeepBytes!));
      }
    } catch (_) {
      // Fallback
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// Emite el acorde armónico de confirmación de venta registrada.
  static Future<void> playSaleSuccessSound() async {
    try {
      HapticFeedback.heavyImpact();
      _initBuffers();
      if (_saleChimeBytes != null) {
        await _salePlayer.stop();
        await _salePlayer.play(BytesSource(_saleChimeBytes!));
      }
    } catch (_) {
      SystemSound.play(SystemSoundType.click);
    }
  }
}
