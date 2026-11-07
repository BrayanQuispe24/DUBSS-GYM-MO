import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/disciplina_horario_model.dart';
import '../models/disciplina_model.dart';
import '../models/horario_model.dart';

final disciplinasRemoteDataSourceProvider =
    Provider<DisciplinasRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return DisciplinasRemoteDataSource(dio);
});

class DisciplinasRemoteDataSource {
  final Dio _dio;

  DisciplinasRemoteDataSource(this._dio);

  /// Obtiene el catálogo completo de disciplinas con horarios asignados
  Future<List<DisciplinaModel>> getDisciplinas() async {
    try {
      final response = await _dio.get('disciplinas');
      final dynamic raw = response.data;

      List<dynamic> list = [];
      if (raw is Map<String, dynamic> && raw['data'] is List) {
        list = raw['data'] as List<dynamic>;
      } else if (raw is List) {
        list = raw;
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => DisciplinaModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw AppException(
        e.response?.data?['message']?.toString() ??
            'Error al cargar el catálogo de disciplinas',
      );
    } catch (e) {
      throw AppException('Error inesperado al cargar disciplinas: $e');
    }
  }

  /// Obtiene el detalle específico de una disciplina
  Future<DisciplinaModel> getDisciplinaById(int id) async {
    try {
      final response = await _dio.get('disciplinas/$id');
      final dynamic raw = response.data;

      Map<String, dynamic>? item;
      if (raw is Map<String, dynamic> && raw['data'] is Map<String, dynamic>) {
        item = raw['data'] as Map<String, dynamic>;
      } else if (raw is Map<String, dynamic>) {
        item = raw;
      }

      if (item == null) {
        throw AppException('Disciplina no encontrada');
      }

      return DisciplinaModel.fromJson(item);
    } on DioException catch (e) {
      throw AppException(
        e.response?.data?['message']?.toString() ??
            'Error al cargar el detalle de la disciplina',
      );
    } catch (e) {
      throw AppException('Error inesperado: $e');
    }
  }

  /// Obtiene los turnos y asignaciones horarios
  Future<List<DisciplinaHorarioModel>> getDisciplinaHorarios() async {
    try {
      final response = await _dio.get('disciplina-horario');
      final dynamic raw = response.data;

      List<dynamic> list = [];
      if (raw is Map<String, dynamic> && raw['data'] is List) {
        list = raw['data'] as List<dynamic>;
      } else if (raw is List) {
        list = raw;
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => DisciplinaHorarioModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw AppException(
        e.response?.data?['message']?.toString() ??
            'Error al cargar los horarios de disciplinas',
      );
    } catch (e) {
      throw AppException('Error inesperado: $e');
    }
  }

  /// Obtiene el catálogo base de horarios
  Future<List<HorarioModel>> getHorarios() async {
    try {
      final response = await _dio.get('horarios');
      final dynamic raw = response.data;

      List<dynamic> list = [];
      if (raw is Map<String, dynamic> && raw['data'] is List) {
        list = raw['data'] as List<dynamic>;
      } else if (raw is List) {
        list = raw;
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => HorarioModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw AppException(
        e.response?.data?['message']?.toString() ??
            'Error al cargar el catálogo de horarios',
      );
    } catch (e) {
      throw AppException('Error inesperado: $e');
    }
  }
}
