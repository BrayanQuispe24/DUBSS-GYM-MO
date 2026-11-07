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
}
