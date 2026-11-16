import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/plan_alimentacion_model.dart';

final nutricionRemoteDataSourceProvider =
    Provider<NutricionRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return NutricionRemoteDataSource(dio);
});

class NutricionRemoteDataSource {
  final Dio _dio;

  NutricionRemoteDataSource(this._dio);

  String _extractErrorMessage(DioException e, String defaultMessage) {
    final dynamic data = e.response?.data;
    if (data is Map) {
      return data['message']?.toString() ??
          data['error']?.toString() ??
          defaultMessage;
    } else if (data is String && data.trim().isNotEmpty && !data.contains('<html')) {
      return data;
    }
    return e.message ?? defaultMessage;
  }

  /// Obtiene todos los planes de alimentación registrados en el sistema
  Future<List<PlanAlimentacionModel>> getPlanesAlimentacion() async {
    try {
      final response = await _dio.get('plan-alimentacion');
      final dynamic raw = response.data;

      List<dynamic> list = [];
      if (raw is Map && raw['data'] is List) {
        list = raw['data'] as List<dynamic>;
      } else if (raw is List) {
        list = raw;
      }

      return list
          .whereType<Map>()
          .map((item) => PlanAlimentacionModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (e) {
      throw AppException(
        _extractErrorMessage(e, 'Error al cargar los planes de alimentación'),
      );
    } catch (e) {
      throw AppException('Error inesperado: $e');
    }
  }

  /// Obtiene el detalle de un plan de alimentación por su ID
  Future<PlanAlimentacionModel> getPlanAlimentacionById(int id) async {
    try {
      final response = await _dio.get('plan-alimentacion/$id');
      final dynamic raw = response.data;

      Map<String, dynamic>? data;
      if (raw is Map && raw['data'] is Map) {
        data = Map<String, dynamic>.from(raw['data'] as Map);
      } else if (raw is Map) {
        data = Map<String, dynamic>.from(raw);
      }

      if (data == null) {
        throw AppException('No se encontró el plan de alimentación especificado');
      }

      return PlanAlimentacionModel.fromJson(data);
    } on DioException catch (e) {
      throw AppException(
        _extractErrorMessage(e, 'Error al obtener el detalle del plan de alimentación'),
      );
    } catch (e) {
      throw AppException('Error inesperado: $e');
    }
  }

  /// Guarda un nuevo plan de alimentación en el backend Laravel
  Future<PlanAlimentacionModel> createPlanAlimentacion(
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.post(
        'plan-alimentacion',
        data: payload,
      );

      final dynamic raw = response.data;
      Map<String, dynamic>? data;
      if (raw is Map && raw['data'] is Map) {
        data = Map<String, dynamic>.from(raw['data'] as Map);
      } else if (raw is Map) {
        data = Map<String, dynamic>.from(raw);
      }

      if (data == null) {
        throw AppException('Respuesta vacía al guardar el plan de alimentación');
      }

      return PlanAlimentacionModel.fromJson(data);
    } on DioException catch (e) {
      final msg = _extractErrorMessage(e, 'Error al registrar el plan');
      throw AppException('Error al registrar el plan de alimentación: $msg');
    } catch (e) {
      throw AppException('Error inesperado al guardar plan: $e');
    }
  }

  /// Elimina un plan de alimentación por su ID
  Future<void> deletePlanAlimentacion(int id) async {
    try {
      await _dio.delete('plan-alimentacion/$id');
    } on DioException catch (e) {
      throw AppException(
        _extractErrorMessage(e, 'Error al eliminar el plan de alimentación'),
      );
    } catch (e) {
      throw AppException('Error inesperado al eliminar: $e');
    }
  }
}
