import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/plan_model.dart';

final planesRemoteDataSourceProvider = Provider<PlanesRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return PlanesRemoteDataSource(dio);
});

class PlanesRemoteDataSource {
  final Dio _dio;

  PlanesRemoteDataSource(this._dio);

  /// Obtiene los planes en tiempo real desde el backend Laravel (/api/planes).
  /// Consume directamente la base de datos a través de la API protegida con Sanctum.
  Future<List<PlanModel>> getPlanes() async {
    try {
      final response = await _dio.get('/planes');

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> list = [];

        if (data is Map<String, dynamic> && data.containsKey('data')) {
          list = data['data'] as List<dynamic>? ?? [];
        } else if (data is List) {
          list = data;
        }

        return list
            .map((item) => PlanModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw AppException(
          'Error al cargar planes desde el servidor',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final status = e.response?.statusCode;
        final resData = e.response?.data;
        String message = 'Error del servidor al obtener planes';

        if (resData is Map<String, dynamic> && resData.containsKey('message')) {
          message = resData['message'].toString();
        } else if (status == 401) {
          message = 'Sesión expirada o no autorizada. Inicie sesión nuevamente.';
        }

        throw AppException(message, statusCode: status);
      }

      throw AppException(
        'No se pudo conectar con el servidor UAGRM. Verifique su conexión de red.',
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error inesperado al procesar el catálogo de planes: $e');
    }
  }
}
