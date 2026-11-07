import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/ejercicio_imagen_model.dart';
import '../models/ejercicio_model.dart';
import '../models/grupo_muscular_model.dart';
import '../models/tipo_ejercicio_model.dart';

final ejerciciosRemoteDataSourceProvider = Provider<EjerciciosRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return EjerciciosRemoteDataSource(dio);
});

class EjerciciosRemoteDataSource {
  final Dio _dio;

  EjerciciosRemoteDataSource(this._dio);

  /// Obtiene el catálogo paginado de ejercicios con filtros opcionales
  Future<EjerciciosPaginadosModel> getEjercicios({
    String? search,
    int? idTipoEjercicio,
    int? idGrupoMuscular,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };

      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      if (idTipoEjercicio != null && idTipoEjercicio > 0) {
        queryParams['id_tipo_ejercicio'] = idTipoEjercicio;
      }
      if (idGrupoMuscular != null && idGrupoMuscular > 0) {
        queryParams['id_grupo_muscular'] = idGrupoMuscular;
      }

      final response = await _dio.get('ejercicios', queryParameters: queryParams);

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return EjerciciosPaginadosModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw AppException('Respuesta inválida del servidor al listar ejercicios');
    } on DioException catch (e) {
      throw _handleDioError(e, 'Error al obtener ejercicios');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error inesperado: $e');
    }
  }

  /// Obtiene el detalle técnico de un ejercicio
  Future<EjercicioModel> getEjercicioDetail(int id) async {
    try {
      final response = await _dio.get('ejercicios/$id');

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return EjercicioModel.fromJson(data);
        }
      }

      throw AppException('No se pudo obtener el detalle del ejercicio');
    } on DioException catch (e) {
      throw _handleDioError(e, 'Error al obtener detalle del ejercicio');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error inesperado: $e');
    }
  }

  /// Obtiene los tipos de ejercicio (Fuerza, Cardio, etc.)
  Future<List<TipoEjercicioModel>> getTiposEjercicio() async {
    try {
      final response = await _dio.get('tipo-ejercicios');

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final list = response.data['data'] as List<dynamic>? ?? [];
        return list.map((item) => TipoEjercicioModel.fromJson(item as Map<String, dynamic>)).toList();
      }

      return [];
    } catch (_) {
      return [];
    }
  }

  /// Obtiene los grupos musculares (Abdominales, Bíceps, etc.)
  Future<List<GrupoMuscularModel>> getGruposMusculares() async {
    try {
      final response = await _dio.get('grupo-musculares');

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final list = response.data['data'] as List<dynamic>? ?? [];
        return list.map((item) => GrupoMuscularModel.fromJson(item as Map<String, dynamic>)).toList();
      }

      return [];
    } catch (_) {
      return [];
    }
  }

  /// Obtiene las imágenes de la galería para un ejercicio
  Future<List<EjercicioImagenModel>> getEjercicioImagenes(int idEjercicio) async {
    try {
      final response = await _dio.get('ejercicios/$idEjercicio/imagenes');

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final list = response.data['data'] as List<dynamic>? ?? [];
        return list.map((item) => EjercicioImagenModel.fromJson(item as Map<String, dynamic>)).toList();
      }

      return [];
    } catch (_) {
      return [];
    }
  }

  AppException _handleDioError(DioException e, String defaultMessage) {
    if (e.response != null) {
      final status = e.response?.statusCode;
      final resData = e.response?.data;
      String message = defaultMessage;

      if (resData is Map<String, dynamic> && resData.containsKey('message')) {
        message = resData['message'].toString();
      } else if (status == 401) {
        message = 'Sesión expirada o no autorizada. Inicie sesión nuevamente.';
      }

      return AppException(message, statusCode: status);
    }

    return AppException(
      'No se pudo conectar con el servidor UAGRM. Verifique su conexión.',
    );
  }
}
