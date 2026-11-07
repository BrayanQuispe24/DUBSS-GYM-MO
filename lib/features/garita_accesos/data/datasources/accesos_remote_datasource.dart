import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../models/registro_acceso_model.dart';

final accesosRemoteDataSourceProvider = Provider<AccesosRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return AccesosRemoteDataSource(dio);
});

class AccesosRemoteDataSource {
  final Dio _dio;

  AccesosRemoteDataSource(this._dio);

  Future<List<RegistroAccesoModel>> getRegistrosAcceso() async {
    final response = await _dio.get('/registro-accesos');
    final rawData = response.data;
    List<dynamic> list = [];
    if (rawData is List) {
      list = rawData;
    } else if (rawData is Map && rawData['data'] is List) {
      list = rawData['data'] as List;
    }

    return list
        .map((item) =>
            RegistroAccesoModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<RegistroAccesoModel> createRegistroAcceso({
    required String tipo,
    required int idUsuario,
    int? idBoletaInscripcion,
  }) async {
    final payload = {
      'tipo': tipo,
      'id_usuario': idUsuario,
      'id_boleta_inscripcion': ?idBoletaInscripcion,
    };

    final response = await _dio.post('/registro-accesos', data: payload);
    final rawData = response.data;
    final item = (rawData is Map && rawData['data'] is Map)
        ? rawData['data'] as Map<String, dynamic>
        : (rawData is Map<String, dynamic> ? rawData : <String, dynamic>{});

    return RegistroAccesoModel.fromJson(item);
  }
}
