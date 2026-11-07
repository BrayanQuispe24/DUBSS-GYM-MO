import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/admin_user_model.dart';

final usersRemoteDataSourceProvider = Provider<UsersRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return UsersRemoteDataSource(dio);
});

class UsersRemoteDataSource {
  final Dio _dio;

  UsersRemoteDataSource(this._dio);

  Future<List<AdminUserModel>> getUsers({
    String? search,
    String? rol,
    String? estado,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (rol != null && rol != 'todos') queryParams['rol'] = rol;
      if (estado != null && estado != 'todos') queryParams['estado'] = estado;

      final response = await _dio.get('usuarios', queryParameters: queryParams);
      final rawData = response.data;

      List<dynamic> list = [];
      if (rawData is List) {
        list = rawData;
      } else if (rawData is Map && rawData['data'] is List) {
        list = rawData['data'] as List;
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => AdminUserModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw AppException(
        e.response?.data?['message']?.toString() ??
            'Error al cargar el listado de usuarios',
      );
    } catch (e) {
      throw AppException('Error inesperado: $e');
    }
  }

  Future<AdminUserModel> getUserById(int id) async {
    try {
      final response = await _dio.get('usuarios/$id');
      final rawData = response.data;
      final map = (rawData is Map && rawData['data'] is Map)
          ? rawData['data'] as Map<String, dynamic>
          : (rawData is Map<String, dynamic> ? rawData : <String, dynamic>{});

      return AdminUserModel.fromJson(map);
    } on DioException catch (e) {
      throw AppException(
        e.response?.data?['message']?.toString() ??
            'Error al obtener expediente del usuario',
      );
    } catch (e) {
      throw AppException('Error inesperado: $e');
    }
  }

  Future<AdminUserModel> createUser(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('usuarios', data: data);
      final rawData = response.data;
      final map = (rawData is Map && rawData['data'] is Map)
          ? rawData['data'] as Map<String, dynamic>
          : (rawData is Map<String, dynamic> ? rawData : <String, dynamic>{});

      return AdminUserModel.fromJson(map);
    } on DioException catch (e) {
      final errMap = e.response?.data;
      if (errMap is Map && errMap['errors'] is Map) {
        final errors = errMap['errors'] as Map;
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) {
          throw AppException(first.first.toString());
        }
      }
      throw AppException(
        e.response?.data?['message']?.toString() ??
            'Error al registrar nuevo usuario',
      );
    } catch (e) {
      throw AppException('Error inesperado: $e');
    }
  }

  Future<AdminUserModel> updateUser(int id, Map<String, dynamic> data) async {
    try {
      final payload = Map<String, dynamic>.from(data)..['id'] = id;
      final response = await _dio.put('usuarios', data: payload);
      final rawData = response.data;
      final map = (rawData is Map && rawData['data'] is Map)
          ? rawData['data'] as Map<String, dynamic>
          : (rawData is Map<String, dynamic> ? rawData : <String, dynamic>{});

      return AdminUserModel.fromJson(map);
    } on DioException catch (e) {
      throw AppException(
        e.response?.data?['message']?.toString() ??
            'Error al actualizar datos del usuario',
      );
    } catch (e) {
      throw AppException('Error inesperado: $e');
    }
  }

  Future<void> toggleUserStatus(int id, String currentStatus) async {
    try {
      final bool isCurrentlyActive =
          currentStatus.toLowerCase() == 'activo' ||
          currentStatus == '1' ||
          currentStatus == 'true';
      final nextStatus = isCurrentlyActive ? 'suspendido' : 'activo';

      await _dio.patch('usuarios/estado', data: {'id': id, 'estado': nextStatus});
    } on DioException catch (e) {
      throw AppException(
        e.response?.data?['message']?.toString() ??
            'Error al cambiar el estado del usuario',
      );
    } catch (e) {
      throw AppException('Error inesperado: $e');
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await _dio.delete('usuarios/$id');
    } on DioException catch (e) {
      throw AppException(
        e.response?.data?['message']?.toString() ??
            'Error al eliminar el usuario',
      );
    } catch (e) {
      throw AppException('Error inesperado: $e');
    }
  }
}
