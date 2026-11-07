import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_env.dart';
import '../storage/secure_storage.dart';
import 'auth_interceptor.dart';

final dioClientProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageProvider);

  // URL base configurada desde .env (AppEnv)
  final baseUrl = AppEnv.apiBaseUrl;
  final timeout = Duration(seconds: AppEnv.apiTimeoutSeconds);

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: timeout,
      receiveTimeout: timeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(AuthInterceptor(storage));

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint('[DIO] $obj'),
      ),
    );
  }

  return dio;
});
