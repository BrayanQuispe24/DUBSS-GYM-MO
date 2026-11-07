import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/plan_entrenamiento_model.dart';
import '../models/rutina_model.dart';

final rutinasRemoteDataSourceProvider = Provider<RutinasRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return RutinasRemoteDataSource(dio);
});

class RutinasRemoteDataSource {
  final Dio _dio;

  RutinasRemoteDataSource(this._dio);

  /// Obtiene los planes de entrenamiento asignados al usuario especificado
  Future<List<PlanEntrenamientoModel>> getPlanesUsuario(int idUsuario) async {
    try {
      final response = await _dio.get('usuarios/$idUsuario/rutinas');
      final dynamic raw = response.data;

      List<dynamic> list = [];
      if (raw is Map<String, dynamic> && raw['data'] is List) {
        list = raw['data'] as List<dynamic>;
      } else if (raw is List) {
        list = raw;
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => PlanEntrenamientoModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw AppException(
        e.response?.data?['message']?.toString() ??
            'Error al cargar las rutinas asignadas del usuario',
      );
    } catch (e) {
      throw AppException('Error inesperado: $e');
    }
  }

  /// Obtiene el catálogo general de rutinas deportivas disponibles
  Future<List<RutinaModel>> getRutinasCatalogo() async {
    try {
      final response = await _dio.get('rutinas');
      final dynamic raw = response.data;

      List<dynamic> list = [];
      if (raw is Map<String, dynamic> && raw['data'] is List) {
        list = raw['data'] as List<dynamic>;
      } else if (raw is List) {
        list = raw;
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => RutinaModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw AppException(
        e.response?.data?['message']?.toString() ??
            'Error al cargar el catálogo de rutinas deportivas',
      );
    } catch (e) {
      throw AppException('Error inesperado: $e');
    }
  }

  /// Obtiene el detalle completo de una rutina con sus ejercicios prescritos
  Future<RutinaModel> getRutinaById(int id) async {
    try {
      final response = await _dio.get('rutinas/$id');
      final dynamic raw = response.data;

      Map<String, dynamic>? data;
      if (raw is Map<String, dynamic> && raw['data'] is Map<String, dynamic>) {
        data = raw['data'] as Map<String, dynamic>;
      } else if (raw is Map<String, dynamic>) {
        data = raw;
      }

      if (data == null) {
        throw AppException('No se encontró información de la rutina');
      }

      return RutinaModel.fromJson(data);
    } on DioException catch (e) {
      throw AppException(
        e.response?.data?['message']?.toString() ??
            'Error al obtener el detalle de la rutina',
      );
    } catch (e) {
      throw AppException('Error inesperado: $e');
    }
  }
}
