import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/documento_model.dart';
import '../models/tipo_documento_model.dart';

final documentosRemoteDataSourceProvider =
    Provider<DocumentosRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return DocumentosRemoteDataSource(dio);
});

class DocumentosRemoteDataSource {
  final Dio _dio;

  DocumentosRemoteDataSource(this._dio);

  /// Obtiene los documentos digitales del usuario
  Future<List<DocumentoModel>> getDocumentos() async {
    try {
      final response = await _dio.get('documentos');
      final dynamic raw = response.data;

      List<dynamic> list = [];
      if (raw is Map<String, dynamic> && raw['data'] is List) {
        list = raw['data'] as List<dynamic>;
      } else if (raw is List) {
        list = raw;
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => DocumentoModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw AppException(
        e.response?.data?['message']?.toString() ??
            'Error al cargar los documentos digitales',
      );
    } catch (e) {
      throw AppException('Error inesperado al cargar documentos: $e');
    }
  }

  /// Obtiene la lista de tipos de documentos permitidos
  Future<List<TipoDocumentoModel>> getTiposDocumento() async {
    try {
      final response = await _dio.get('tipo-documentos');
      final dynamic raw = response.data;

      List<dynamic> list = [];
      if (raw is Map<String, dynamic> && raw['data'] is List) {
        list = raw['data'] as List<dynamic>;
      } else if (raw is List) {
        list = raw;
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => TipoDocumentoModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw AppException(
        e.response?.data?['message']?.toString() ??
            'Error al obtener tipos de documentos',
      );
    } catch (e) {
      throw AppException('Error inesperado al obtener tipos: $e');
    }
  }

  /// Sube un nuevo documento PDF mediante multipart/form-data
  Future<DocumentoModel> uploadDocumento({
    required int idTipoDocumento,
    required String filePath,
    required String fileName,
    String? titulo,
  }) async {
    try {
      final formData = FormData.fromMap({
        'id_tipo_documento': idTipoDocumento,
        'archivo': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
        if (titulo != null && titulo.trim().isNotEmpty)
          'titulo': titulo.trim(),
      });

      final response = await _dio.post(
        'documentos',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      final dynamic raw = response.data;
      Map<String, dynamic>? dataMap;
      if (raw is Map<String, dynamic> && raw['data'] is Map<String, dynamic>) {
        dataMap = raw['data'] as Map<String, dynamic>;
      } else if (raw is Map<String, dynamic>) {
        dataMap = raw;
      }

      if (dataMap == null) {
        throw AppException('Respuesta inválida del servidor al subir documento');
      }

      return DocumentoModel.fromJson(dataMap);
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message']?.toString();
      final errors = e.response?.data?['errors'];
      String details = '';
      if (errors is Map) {
        details = errors.values.map((v) => (v is List) ? v.join(', ') : v.toString()).join('\n');
      }
      throw AppException(
        details.isNotEmpty ? details : (serverMsg ?? 'Error al subir el documento'),
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Error inesperado al subir el documento: $e');
    }
  }

  /// Elimina un documento por su ID
  Future<void> deleteDocumento(int id) async {
    try {
      await _dio.delete('documentos/$id');
    } on DioException catch (e) {
      throw AppException(
        e.response?.data?['message']?.toString() ??
            'Error al eliminar el documento',
      );
    } catch (e) {
      throw AppException('Error inesperado al eliminar el documento: $e');
    }
  }
}
