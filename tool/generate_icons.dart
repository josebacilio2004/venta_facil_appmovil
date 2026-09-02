import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  const baseSize = 1024;
  final image = img.Image(width: baseSize, height: baseSize);

  // Colores Fintech VentaFácil
  final primaryColor = img.ColorUint8.rgba(0, 80, 203, 255);      // #0050CB
  final lightBlueColor = img.ColorUint8.rgba(0, 102, 255, 255);    // #0066FF
  final cyanAccent = img.ColorUint8.rgba(104, 250, 221, 255);     // #68FADD
  final whiteColor = img.ColorUint8.rgba(255, 255, 255, 255);

  // 1. Fondo Degradado Suave Azul Cobalto
  for (int y = 0; y < baseSize; y++) {
    final t = y / baseSize;
    final r = (0 * (1 - t) + 11 * t).toInt();
    final g = (80 * (1 - t) + 28 * t).toInt();
    final b = (203 * (1 - t) + 48 * t).toInt();
    final col = img.ColorUint8.rgba(r, g, b, 255);
    for (int x = 0; x < baseSize; x++) {
      image.setPixel(x, y, col);
    }
  }

  // 2. Tarjeta Central / Fondo Redondeado Blanco Suave
  img.fillCircle(image, x: 512, y: 512, radius: 420, color: lightBlueColor);
  img.fillCircle(image, x: 512, y: 512, radius: 390, color: primaryColor);

  // 3. Dibujar Silueta de Caja Registradora / POS Fintech
  // Base del POS
  img.fillRect(image, x1: 280, y1: 520, x2: 744, y2: 740, color: whiteColor, radius: 40);
  // Cajón de Dinero
  img.fillRect(image, x1: 320, y1: 640, x2: 704, y2: 700, color: primaryColor, radius: 16);
  img.fillRect(image, x1: 460, y1: 660, x2: 564, y2: 680, color: cyanAccent, radius: 8);

  // Pantalla / Visor del POS
  img.fillRect(image, x1: 330, y1: 300, x2: 694, y2: 500, color: whiteColor, radius: 36);
  img.fillRect(image, x1: 360, y1: 330, x2: 664, y2: 470, color: img.ColorUint8.rgba(11, 28, 48, 255), radius: 24);

  // Gráfico de Ventas en Pantalla (Barras verdes/cian ascendentes)
  img.fillRect(image, x1: 390, y1: 420, x2: 430, y2: 450, color: cyanAccent, radius: 6);
  img.fillRect(image, x1: 450, y1: 390, x2: 490, y2: 450, color: cyanAccent, radius: 6);
  img.fillRect(image, x1: 510, y1: 360, x2: 550, y2: 450, color: cyanAccent, radius: 6);
  img.fillRect(image, x1: 570, y1: 380, x2: 610, y2: 450, color: whiteColor, radius: 6);

  // 4. Generar y Guardar Iconos de Android
  final androidSizes = {
    'android/app/src/main/res/mipmap-mdpi/ic_launcher.png': 48,
    'android/app/src/main/res/mipmap-hdpi/ic_launcher.png': 72,
    'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png': 96,
    'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png': 144,
    'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png': 192,
  };

  for (final entry in androidSizes.entries) {
    final resized = img.copyResize(image, width: entry.value, height: entry.value);
    File(entry.key).writeAsBytesSync(img.encodePng(resized));
    print('Generado: ${entry.key} (${entry.value}x${entry.value})');
  }

  // 5. Generar y Guardar Iconos de iOS
  final iosSizes = {
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png': 1024,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png': 20,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png': 40,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png': 60,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png': 29,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png': 58,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png': 87,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png': 40,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png': 80,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png': 120,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png': 120,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png': 180,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png': 76,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png': 152,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png': 167,
  };

  for (final entry in iosSizes.entries) {
    final resized = img.copyResize(image, width: entry.value.toInt(), height: entry.value.toInt());
    File(entry.key).writeAsBytesSync(img.encodePng(resized));
    print('Generado: ${entry.key}');
  }

  print('¡Todos los iconos de Android e iOS fueron generados exitosamente!');
}
