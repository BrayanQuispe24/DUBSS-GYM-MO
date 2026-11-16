import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Configuración de Temas para DUBSS App
/// Sistema de Diseño Oficial: "Obsidian & UAGRM Crimson" (Boxed-Sharpness)
class AppTheme {
  /// Tema Oficial: Modo Oscuro "Obsidian & UAGRM Crimson"
  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.obsidianBase,
      canvasColor: AppColors.obsidianBase,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryCrimson,
        onPrimary: Colors.white,
        secondary: AppColors.accentVibrant,
        onSecondary: Colors.white,
        surface: AppColors.carbonSurface,
        onSurface: AppColors.textWhite,
        surfaceContainer: AppColors.carbonSurfaceMuted,
        outline: AppColors.borderSubtle,
        outlineVariant: AppColors.borderTranslucent,
        error: AppColors.accentVibrant,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.obsidianBase,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        shape: Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.carbonSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryCrimson,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textWhite,
          side: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentVibrant,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.carbonSurfaceMuted,
        hintStyle: const TextStyle(color: AppColors.textSlateMuted, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.textSlateLight, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.accentVibrant, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.accentVibrant, width: 1.0),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1.0,
        space: 1.0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.carbonSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.carbonSurfaceMuted,
        selectedItemColor: AppColors.accentVibrant,
        unselectedItemColor: AppColors.textSlateMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w800),
        headlineMedium: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w700),
        headlineSmall: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: AppColors.textSlateLight, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: AppColors.textSlateLight, fontSize: 16),
        bodyMedium: TextStyle(color: AppColors.textSlateLight, fontSize: 14),
        bodySmall: TextStyle(color: AppColors.textSlateMuted, fontSize: 12),
        labelLarge: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(color: AppColors.textSlateLight, fontSize: 12),
        labelSmall: TextStyle(color: AppColors.textSlateMuted, fontSize: 10),
      ),
    );
  }

  /// Alias de conveniencia: lightTheme ahora apunta al tema oficial oscuro
  static ThemeData get lightTheme => darkTheme;
}
