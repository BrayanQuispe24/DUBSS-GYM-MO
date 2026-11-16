import 'package:flutter/material.dart';

/// Sistema de Diseño Oficial: "Obsidian & UAGRM Crimson"
/// Plataforma Deportiva SaaS & Enterprise (UAGRM - DUBSS)
class AppColors {
  // --- Tokens Oficiales de Fondo y Superficies (Obsidian & Carbon) ---
  /// Fondo principal de página / canvas oscuro profundo (#0B0B0D)
  static const Color obsidianBase = Color(0xFF0B0B0D);

  /// Superficies principales, paneles y tarjetas (#141419)
  static const Color carbonSurface = Color(0xFF141419);

  /// Paneles secundarios, barras de navegación e inputs (#16161C)
  static const Color carbonSurfaceMuted = Color(0xFF16161C);

  /// Estado hover y activo en tarjetas o listas (#21212B)
  static const Color surfaceHover = Color(0xFF21212B);

  // --- Tokens de Bordes y Delimitadores Nítidos ---
  /// Micro-bordes sutiles y técnicos de 1px (#272732)
  static const Color borderSubtle = Color(0xFF272732);

  /// Borde translúcido para tarjetas y modales estilo glass (rgba(255, 255, 255, 0.12))
  static const Color borderTranslucent = Color(0x1FFFFFFF);

  // --- Tokens de Marca Institucional (UAGRM Crimson & Acentos) ---
  /// Crimson institucional principal para CTAs, tabs activas y badges (#990000)
  static const Color primaryCrimson = Color(0xFF990000);

  /// Crimson oscuro para estados pressed o fondos atenuados (#7A0000)
  static const Color primaryDark = Color(0xFF7A0000);

  /// Rojo vibrante para resaltar tarjetas populares, glows y bordes activos (#DC2626)
  static const Color accentVibrant = Color(0xFFDC2626);

  /// Rojo intenso para estados hover en botones (#B91C1C)
  static const Color accentHover = Color(0xFFB91C1C);

  // --- Acento Deportivo y Brillo Solar ---
  /// Inicio del gradiente solar / brillo de energía (#FFD700)
  static const Color solarGold = Color(0xFFFFD700);

  /// Fin del gradiente solar / ámbar deportivo (#FF9500)
  static const Color solarAmber = Color(0xFFFF9500);

  // --- Estados y Feedback Deportivo ---
  /// Verde esmeralda para validaciones, checkmarks y estado OK (#22C55E)
  static const Color successEmerald = Color(0xFF22C55E);

  /// Verde esmeralda claro para badges y alertas suaves (#4ADE80)
  static const Color successLight = Color(0xFF4ADE80);

  // --- Tipografía ---
  /// Títulos principales y texto de máximo contraste (#FFFFFF)
  static const Color textWhite = Color(0xFFFFFFFF);

  /// Texto secundario, descripciones y cuerpo (#D4D4D8)
  static const Color textSlateLight = Color(0xFFD4D4D8);

  /// Etiquetas técnicas, metadata y placeholders (#71717A)
  static const Color textSlateMuted = Color(0xFF71717A);

  // --- Gradientes Predefinidos ---
  /// Gradiente deportivo de alta energía (#FFD700 a #FF9500)
  static const LinearGradient solarGradient = LinearGradient(
    colors: [solarGold, solarAmber],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente carmesí para botones de alto impacto
  static const LinearGradient crimsonGradient = LinearGradient(
    colors: [primaryCrimson, accentVibrant],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Resplandor radial carmesí para hero sections y badges destacados
  static const RadialGradient crimsonGlow = RadialGradient(
    colors: [Color(0x33990000), Colors.transparent],
    radius: 0.6,
  );

  // =========================================================================
  // Aliases de compatibilidad para pantallas existentes
  // =========================================================================
  static const Color primaryRed = primaryCrimson;
  static const Color primaryRedDark = primaryDark;
  static const Color primaryRedHover = accentHover;

  static const Color background = obsidianBase;
  static const Color surface = carbonSurface;
  static const Color surfaceMuted = carbonSurfaceMuted;
  static const Color border = borderSubtle;

  static const Color textPrimary = textWhite;
  static const Color textSecondary = textSlateLight;
  static const Color textMuted = textSlateMuted;

  static const Color success = successEmerald;
  static const Color successBg = Color(0x1F22C55E);
  static const Color successText = successLight;

  static const Color danger = accentVibrant;
  static const Color dangerBg = Color(0x1FDC2626);
  static const Color dangerText = accentVibrant;

  static const Color warning = solarAmber;
  static const Color warningBg = Color(0x1FFF9500);
  static const Color warningText = solarGold;

  // Azul institucional preservado para referencias retrocompatibles
  static const Color navyBlue = Color(0xFF003B70);
  static const Color navyBlueDark = Color(0xFF001C38);
  static const Color navyBlueHover = Color(0xFF002A52);
  static const Color accentGold = solarGold;
  static const Color accentGoldHover = solarAmber;
}
