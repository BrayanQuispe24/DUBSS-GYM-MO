import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return AuthRemoteDataSource(dio);
});

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  Future<AuthResponseModel> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {
          'email': identifier,
          'password': password,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return AuthResponseModel.fromJson(data);
      }
      throw AppException('Respuesta inesperada del servidor');
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error de autenticación: $e');
    }
  }

  Future<AuthResponseModel> registerCliente({
    required String nombre,
    required String apellido,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String ci,
    required String registroUniversitario,
    required String tipoUsuario,
    String? telefono,
    bool aceptaTerminos = true,
  }) async {
    try {
      final payload = {
        'codigo': registroUniversitario,
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'ci': ci,
        'celular': telefono ?? '',
        'tipo_usuario': tipoUsuario,
        'rol': 'Cliente',
        'acepta_terminos': aceptaTerminos,
      };

      final response = await _dio.post('/register', data: payload);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return AuthResponseModel.fromJson(data);
      }
      throw AppException('Respuesta inesperada del servidor');
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error al registrar usuario: $e');
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await _dio.get('/profile');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return UserModel.fromJson(data);
      }
      throw AppException('Error al obtener perfil');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } catch (_) {
      // Ignorar errores de red al desloguearse
    }
  }

  AppException _handleDioError(DioException e) {
    final status = e.response?.statusCode;
    final responseData = e.response?.data;

    String? serverMessage;
    if (responseData is Map<String, dynamic>) {
      if (responseData['message'] is String) {
        serverMessage = responseData['message'] as String;
      } else if (responseData['error'] is String) {
        serverMessage = responseData['error'] as String;
      } else if (responseData['errors'] is Map) {
        final errors = responseData['errors'] as Map;
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          serverMessage = firstError.first.toString();
        }
      }
    }

    if (status == 401) {
      return AppException(
        serverMessage ?? 'Credenciales incorrectas. Verifique su correo/RU y contraseña.',
        statusCode: 401,
      );
    } else if (status == 422) {
      return AppException(
        serverMessage ?? 'Los datos ingresados no son válidos.',
        statusCode: 422,
      );
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return AppException(
        'No se pudo conectar con el servidor UAGRM. Verifique su conexión.',
        statusCode: 503,
      );
    }

    return AppException(
      serverMessage ?? 'Ha ocurrido un error inesperado ($status).',
      statusCode: status,
    );
  }
}
