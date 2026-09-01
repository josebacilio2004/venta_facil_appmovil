import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../theme/app_theme.dart';

class LocalImageHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Permite tomar foto con la cámara o elegir desde la galería y guardarla localmente.
  static Future<String?> pickAndSaveImage({required ImageSource source}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      if (kIsWeb) {
        // En Web almacenamos como string base64 con data URI
        final bytes = await pickedFile.readAsBytes();
        return 'data:image/jpeg;base64,${base64Encode(bytes)}';
      } else {
        // En Móvil / Desktop copiamos el archivo al almacenamiento persistente de la app
        final appDir = await getApplicationDocumentsDirectory();
        final imagesDir = Directory(p.join(appDir.path, 'product_images'));
        if (!await imagesDir.exists()) {
          await imagesDir.create(recursive: true);
        }

        final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}${p.extension(pickedFile.path).isEmpty ? '.jpg' : p.extension(pickedFile.path)}';
        final savedImage = File(p.join(imagesDir.path, fileName));
        await File(pickedFile.path).copy(savedImage.path);

        return savedImage.path;
      }
    } catch (e) {
      debugPrint('Error al guardar imagen local: $e');
      return null;
    }
  }

  /// Construye un widget de imagen seguro (soporta archivos locales, base64 y fallback).
  static Widget buildProductImage(
    String? imagePath, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Widget? fallback,
  }) {
    Widget imageWidget;

    if (imagePath == null || imagePath.isEmpty) {
      imageWidget = fallback ?? _buildDefaultPlaceholder(width, height);
    } else if (imagePath.startsWith('data:image')) {
      // Base64 Web
      try {
        final base64String = imagePath.split(',').last;
        final bytes = base64Decode(base64String);
        imageWidget = Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => fallback ?? _buildDefaultPlaceholder(width, height),
        );
      } catch (_) {
        imageWidget = fallback ?? _buildDefaultPlaceholder(width, height);
      }
    } else if (!kIsWeb && File(imagePath).existsSync()) {
      // Archivo Local en Disco
      imageWidget = Image.file(
        File(imagePath),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => fallback ?? _buildDefaultPlaceholder(width, height),
      );
    } else {
      imageWidget = fallback ?? _buildDefaultPlaceholder(width, height);
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius, child: imageWidget);
    }
    return imageWidget;
  }

  static Widget _buildDefaultPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: AppTheme.surfaceContainerLow,
      child: const Center(
        child: Icon(
          Icons.inventory_2_outlined,
          color: AppTheme.primaryColor,
          size: 24,
        ),
      ),
    );
  }
}
