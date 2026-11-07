import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_env.dart';

final iaDioClientProvider = Provider<Dio>((ref) {
  final baseUrl = AppEnv.iaApiBaseUrl;
  const timeout = Duration(seconds: 60); // 60 segundos para generación con LLM

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint('[IA-DIO] $obj'),
      ),
    );
  }

  return dio;
});
