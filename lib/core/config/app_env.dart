import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  /// Retorna la URL base de la API garantizando barra final
  static String get apiBaseUrl {
    if (dotenv.isInitialized) {
      final fromEnv = dotenv.env['API_BASE_URL'];
      if (fromEnv != null && fromEnv.trim().isNotEmpty) {
        final clean = fromEnv.trim();
        return clean.endsWith('/') ? clean : '$clean/';
      }
    }

    // Fallbacks inteligentes según plataforma si el .env no está cargado o especificado
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://192.168.0.167:8000/api/';
    }
    return 'http://127.0.0.1:8000/api/';
  }

  /// Retorna la URL base del microservicio de Inteligencia Artificial (FastAPI)
  static String get iaApiBaseUrl {
    if (dotenv.isInitialized) {
      final fromEnv = dotenv.env['IA_API_BASE_URL'];
      if (fromEnv != null && fromEnv.trim().isNotEmpty) {
        final clean = fromEnv.trim();
        return clean.endsWith('/') ? clean : '$clean/';
      }
    }

    if (!kIsWeb && Platform.isAndroid) {
      return 'http://192.168.0.167:8001/api/v1/';
    }
    return 'http://127.0.0.1:8001/api/v1/';
  }

  /// Entorno de ejecución: development, staging, production
  static String get appEnv =>
      dotenv.isInitialized ? (dotenv.env['APP_ENV'] ?? 'development') : 'development';

  /// Timeout en segundos para peticiones HTTP
  static int get apiTimeoutSeconds {
    if (dotenv.isInitialized) {
      return int.tryParse(dotenv.env['API_TIMEOUT_SECONDS'] ?? '15') ?? 15;
    }
    return 15;
  }

  /// Retorna si el entorno actual es de desarrollo
  static bool get isDevelopment => appEnv.toLowerCase() == 'development';

  /// Retorna la URL raíz del servidor (sin '/api/' ni barra final)
  /// Ej: 'https://gym.bratox.me' o 'http://192.168.0.167:8000'
  static String get serverBaseUrl {
    var base = apiBaseUrl.trim();
    while (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    if (base.endsWith('/api')) {
      base = base.substring(0, base.length - 4);
    }
    while (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    return base;
  }

  /// Resuelve cualquier ruta de archivo o imagen (relativa o absoluta de desarrollo)
  /// a una URL pública absoluta y válida contra el servidor actual.
  static String resolveStorageUrl(String? rawPath) {
    if (rawPath == null || rawPath.trim().isEmpty) return '';
    final clean = rawPath.trim();

    final baseUri = Uri.parse(apiBaseUrl);
    final serverBase = serverBaseUrl;

    // Caso 1: Ruta relativa (ej: '/storage/ejercicios/1.jpg' o 'storage/ejercicios/1.jpg' o 'ejercicios/1.jpg')
    if (!clean.startsWith('http://') && !clean.startsWith('https://')) {
      final normalized = clean.startsWith('/') ? clean : '/$clean';
      if (normalized.startsWith('/storage')) {
        return '$serverBase$normalized';
      }
      return '$serverBase/storage$normalized';
    }

    // Caso 2: URL absoluta (puede venir de localhost, 127.0.0.1, 192.168.x.x, 10.0.2.2 o dominio)
    try {
      final uri = Uri.parse(clean);
      final isDevHost = uri.host == 'localhost' ||
          uri.host == '127.0.0.1' ||
          uri.host == '10.0.2.2' ||
          uri.host.startsWith('192.168.');

      final isBaseRemote = baseUri.host != 'localhost' &&
          baseUri.host != '127.0.0.1' &&
          !baseUri.host.startsWith('192.168.');

      // Si la base actual es remota (producción) y la imagen apunta a un host local/IP de dev
      if ((isBaseRemote && isDevHost) || uri.host == 'localhost' || uri.host == '127.0.0.1') {
        return '$serverBase${uri.path}';
      }

      // Si el servidor usa HTTPS pero la URL vino con HTTP del mismo host
      if (baseUri.scheme == 'https' && uri.scheme == 'http' && uri.host == baseUri.host) {
        return uri.replace(scheme: 'https').toString();
      }
    } catch (_) {}

    return clean;
  }
}
