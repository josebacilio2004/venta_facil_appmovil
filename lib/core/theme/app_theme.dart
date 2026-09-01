import 'package:flutter/material.dart';

class AppTheme {
  // Stitch VentaFácil Core SaaS Fintech Colors
  static const primaryColor = Color(0xFF0050CB); // Action Blue
  static const primaryContainerColor = Color(0xFF0066FF); // Electric Blue
  static const secondaryColor = Color(0xFF006B5C); // Success Teal
  static const secondaryContainerColor = Color(0xFF68FADD); // Mint container
  static const tertiaryColor = Color(0xFFA33200); // Warm Amber / Alert
  static const tertiaryContainerColor = Color(0xFFCC4204);
  static const backgroundColor = Color(0xFFF8F9FF); // Soft Ice Slate
  static const surfaceColor = Color(0xFFF8F9FF);
  static const surfaceCardColor = Color(0xFFFFFFFF); // Pure White Card
  static const surfaceContainerLow = Color(0xFFEFF4FF);
  static const surfaceContainer = Color(0xFFE5EEFF);
  static const surfaceContainerHigh = Color(0xFFDCE9FF);
  static const outlineColor = Color(0xFF727687);
  static const outlineVariantColor = Color(0xFFE2E8F0); // Subtle Border
  static const onSurfaceColor = Color(0xFF0B1C30); // Deep Navy Charcoal
  static const onSurfaceVariantColor = Color(0xFF424656); // Slate Subtitle
  static const errorColor = Color(0xFFBA1A1A);
  static const errorContainerColor = Color(0xFFFFDAD6);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primaryColor,
        onPrimary: Colors.white,
        primaryContainer: primaryContainerColor,
        onPrimaryContainer: Color(0xFFF8F7FF),
        secondary: secondaryColor,
        onSecondary: Colors.white,
        secondaryContainer: secondaryContainerColor,
        onSecondaryContainer: Color(0xFF007261),
        tertiary: tertiaryColor,
        onTertiary: Colors.white,
        tertiaryContainer: tertiaryContainerColor,
        onTertiaryContainer: Color(0xFFFFF6F4),
        error: errorColor,
        onError: Colors.white,
        errorContainer: errorContainerColor,
        onErrorContainer: Color(0xFF93000A),
        surface: surfaceColor,
        onSurface: onSurfaceColor,
        surfaceContainerLowest: surfaceCardColor,
        surfaceContainerLow: surfaceContainerLow,
        surfaceContainer: surfaceContainer,
        surfaceContainerHigh: surfaceContainerHigh,
        outline: outlineColor,
        outlineVariant: outlineVariantColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: onSurfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: onSurfaceColor,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.01,
        ),
        iconTheme: IconThemeData(color: onSurfaceColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: primaryColor.withValues(alpha: 0.25),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.01),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: outlineVariantColor, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceCardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineVariantColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineVariantColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        hintStyle: const TextStyle(color: outlineColor, fontSize: 14),
        labelStyle: const TextStyle(color: onSurfaceVariantColor, fontSize: 14),
      ),
      cardTheme: CardThemeData(
        color: surfaceCardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: outlineVariantColor, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: outlineColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceCardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: outlineVariantColor, width: 1),
        ),
        titleTextStyle: const TextStyle(
          color: onSurfaceColor,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: const TextStyle(
          color: onSurfaceVariantColor,
          fontSize: 14,
        ),
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme;
}
