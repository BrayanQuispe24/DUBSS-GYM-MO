import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carga de variables de entorno desde el archivo .env
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint(
      'Aviso: No se pudo cargar el archivo .env, usando configuración por defecto: $e',
    );
  }

  runApp(const ProviderScope(child: DubssApp()));
}
