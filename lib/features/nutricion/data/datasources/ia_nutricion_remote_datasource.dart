import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/ia_dio_client.dart';
import '../models/recomendacion_nutricional_ia_model.dart';

final iaNutricionRemoteDataSourceProvider =
    Provider<IaNutricionRemoteDataSource>((ref) {
  final dio = ref.watch(iaDioClientProvider);
  return IaNutricionRemoteDataSource(dio);
});

class IaNutricionRemoteDataSource {
  final Dio _dio;

  IaNutricionRemoteDataSource(this._dio);

  /// Solicita al microservicio de IA (Gemini 2.5 Flash) la generación
  /// de un plan nutricional estructurado adaptado al perfil del usuario
  Future<RecomendacionNutricionalResponse> generarPlanNutricional(
    PerfilNutricionalInput perfil,
  ) async {
    try {
      final response = await _dio.post(
        'nutricion/recomendar-plan',
        data: perfil.toJson(),
      );

      final dynamic raw = response.data;
      if (raw is Map) {
        return RecomendacionNutricionalResponse.fromJson(Map<String, dynamic>.from(raw));
      } else {
        throw AppException('Formato de respuesta inválido del servicio de IA');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw AppException(
          'El modelo de IA tardó demasiado en responder. Por favor intenta nuevamente.',
        );
      }

      String? errorDetail;
      final dynamic data = e.response?.data;
      if (data is Map) {
        final detail = data['detail'];
        if (detail is List && detail.isNotEmpty) {
          errorDetail = detail
              .map((d) => d is Map ? (d['msg'] ?? d.toString()) : d.toString())
              .join(', ');
        } else if (detail != null) {
          errorDetail = detail.toString();
        } else if (data['message'] != null) {
          errorDetail = data['message'].toString();
        }
      } else if (data is String && data.trim().isNotEmpty) {
        if (data.contains('<html') || data.contains('<head')) {
          errorDetail = 'Error del servidor o ruta inaccesible (HTTP ${e.response?.statusCode ?? 500})';
        } else {
          errorDetail = data;
        }
      }
      errorDetail ??= e.message;

      throw AppException(
        'Error en el servicio de IA: $errorDetail',
      );
    } catch (e) {
      throw AppException('Error inesperado al conectar con el servicio de IA: $e');
    }
  }
}
