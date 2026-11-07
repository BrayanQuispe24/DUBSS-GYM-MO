import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;
  final void Function()? onUnauthorized;

  AuthInterceptor(this._storage, {this.onUnauthorized});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Normalizar la ruta para no descartar el prefijo /api/ configurado en baseUrl
    if (options.path.startsWith('/')) {
      options.path = options.path.substring(1);
    }

    final token = await _storage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';
    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await _storage.clearAuth();
      onUnauthorized?.call();
    }
    super.onError(err, handler);
  }
}
