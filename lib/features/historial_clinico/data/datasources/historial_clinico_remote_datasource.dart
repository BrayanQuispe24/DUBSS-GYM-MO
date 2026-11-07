import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/antecedente_model.dart';
import '../models/detalle_historial_model.dart';
import '../models/historial_model.dart';

final historialClinicoRemoteDataSourceProvider =
    Provider<HistorialClinicoRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return HistorialClinicoRemoteDataSource(dio);
});

class HistorialClinicoRemoteDataSource {
  final Dio _dio;

  HistorialClinicoRemoteDataSource(this._dio);

  /// Obtiene los historiales del usuario autenticado (o la lista si es instructor/admin)
  Future<List<HistorialModel>> getHistoriales() async {
    try {
      final response = await _dio.get('historiales');
      final dynamic raw = response.data;

      List<dynamic> list = [];
      if (raw is Map<String, dynamic> && raw['data'] is List) {
        list = raw['data'] as List<dynamic>;
      } else if (raw is List) {
        list = raw;
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => HistorialModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw AppException(
        e.response?.data?['message']?.toString() ??
            'Error al cargar los historiales clínicos',
      );
    } catch (e) {
      throw AppException('Error inesperado: $e');
    }
  }

  /// Registra una nueva medición física (peso, altura, % grasa, masa muscular, presión)
  Future<DetalleHistorialModel> createDetalleHistorial(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post('detalle-historial', data: data);
      final dynamic raw = response.data;

      Map<String, dynamic>? item;
      if (raw is Map<String, dynamic> && raw['data'] is Map<String, dynamic>) {
        item = raw['data'] as Map<String, dynamic>;
      } else if (raw is Map<String, dynamic>) {
        item = raw;
      }

      if (item == null) {
        throw AppException('Respuesta inválida del servidor al guardar medición');
      }

      return DetalleHistorialModel.fromJson(item);
    } on DioException catch (e) {
      throw AppException(
        e.response?.data?['message']?.toString() ??
            'Error al registrar la medición física',
      );
    } catch (e) {
      throw AppException('Error al registrar la medición: $e');
    }
  }

  /// Registra o actualiza los antecedentes médicos y patologías del socio
  Future<AntecedenteModel> createAntecedente(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post('antecedentes', data: data);
      final dynamic raw = response.data;

      Map<String, dynamic>? item;
      if (raw is Map<String, dynamic> && raw['data'] is Map<String, dynamic>) {
        item = raw['data'] as Map<String, dynamic>;
      } else if (raw is Map<String, dynamic>) {
        item = raw;
      }

      if (item == null) {
        throw AppException('Respuesta inválida del servidor al registrar antecedentes');
      }

      return AntecedenteModel.fromJson(item);
    } on DioException catch (e) {
      throw AppException(
        e.response?.data?['message']?.toString() ??
            'Error al registrar los antecedentes médicos',
      );
    } catch (e) {
      throw AppException('Error al registrar antecedentes: $e');
    }
  }

  /// Actualiza los datos generales de la ficha del historial
  Future<HistorialModel> updateHistorial(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final payload = {'id': id, ...data};
      final response = await _dio.put('historiales', data: payload);
      final dynamic raw = response.data;

      Map<String, dynamic>? item;
      if (raw is Map<String, dynamic> && raw['data'] is Map<String, dynamic>) {
        item = raw['data'] as Map<String, dynamic>;
      } else if (raw is Map<String, dynamic>) {
        item = raw;
      }

      if (item == null) {
        throw AppException('Respuesta inválida del servidor al actualizar historial');
      }

      return HistorialModel.fromJson(item);
    } on DioException catch (e) {
      throw AppException(
        e.response?.data?['message']?.toString() ??
            'Error al actualizar el historial clínico',
      );
    } catch (e) {
      throw AppException('Error al actualizar historial: $e');
    }
  }
}
