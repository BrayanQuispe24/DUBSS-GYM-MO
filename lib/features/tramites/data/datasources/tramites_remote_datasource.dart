import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/boleta_inscripcion_model.dart';
import '../models/boleta_pago_model.dart';
import '../models/formulario_solicitud_model.dart';
import '../models/qr_acceso_model.dart';
import '../models/validacion_acceso_model.dart';

final tramitesRemoteDataSourceProvider = Provider<TramitesRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return TramitesRemoteDataSource(dio);
});

class TramitesRemoteDataSource {
  final Dio _dio;

  TramitesRemoteDataSource(this._dio);

  /// Obtiene la lista de formularios de solicitud (DUBSS-FR-03)
  Future<List<FormularioSolicitudModel>> getFormulariosSolicitud() async {
    try {
      final response = await _dio.get('formulario-solicitudes');
      final dynamic raw = response.data;

      List<dynamic> list = [];
      if (raw is Map<String, dynamic> && raw['data'] is List) {
        list = raw['data'] as List<dynamic>;
      } else if (raw is List) {
        list = raw;
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => FormularioSolicitudModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw AppException(
        e.response?.data?['message']?.toString() ??
            'Error al cargar los formularios de solicitud',
      );
    } catch (e) {
      throw AppException('Error inesperado: $e');
    }
  }

  /// Crea un nuevo formulario de solicitud DUBSS-FR-03
  Future<FormularioSolicitudModel> createFormularioSolicitud(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post('formulario-solicitudes', data: data);
      final dynamic raw = response.data;

      Map<String, dynamic>? item;
      if (raw is Map<String, dynamic> && raw['data'] is Map<String, dynamic>) {
        item = raw['data'] as Map<String, dynamic>;
      } else if (raw is Map<String, dynamic>) {
        item = raw;
      }

      if (item == null) {
        throw AppException('Respuesta inválida del servidor al crear solicitud');
      }

      return FormularioSolicitudModel.fromJson(item);
    } on DioException catch (e) {
      final errMap = e.response?.data;
      if (errMap is Map<String, dynamic> && errMap['errors'] is Map) {
        final errors = errMap['errors'] as Map<String, dynamic>;
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          throw AppException(firstError.first.toString());
        }
      }
      throw AppException(
        e.response?.data?['message']?.toString() ??
            'Error al crear la solicitud DUBSS-FR-03',
      );
    } catch (e) {
      throw AppException('Error inesperado: $e');
    }
  }

  /// Obtiene el catálogo de disciplinas disponibles para el formulario
  Future<List<Map<String, dynamic>>> getDisciplinas() async {
    try {
      final response = await _dio.get('disciplinas');
      final dynamic raw = response.data;
      List<dynamic> list = [];
      if (raw is Map<String, dynamic> && raw['data'] is List) {
        list = raw['data'] as List<dynamic>;
      } else if (raw is List) {
        list = raw;
      }
      return list.whereType<Map<String, dynamic>>().toList();
    } catch (_) {
      return [];
    }
  }

  /// Obtiene los horarios asignados por disciplina
  Future<List<Map<String, dynamic>>> getDisciplinaHorarios() async {
    try {
      final response = await _dio.get('disciplina-horario');
      final dynamic raw = response.data;
      List<dynamic> list = [];
      if (raw is Map<String, dynamic> && raw['data'] is List) {
        list = raw['data'] as List<dynamic>;
      } else if (raw is List) {
        list = raw;
      }
      return list.whereType<Map<String, dynamic>>().toList();
    } catch (_) {
      return [];
    }
  }

  /// Obtiene los planes disponibles
  Future<List<Map<String, dynamic>>> getPlanes() async {
    try {
      final response = await _dio.get('planes');
      final dynamic raw = response.data;
      List<dynamic> list = [];
      if (raw is Map<String, dynamic> && raw['data'] is List) {
        list = raw['data'] as List<dynamic>;
      } else if (raw is List) {
        list = raw;
      }
      return list.whereType<Map<String, dynamic>>().toList();
    } catch (_) {
      return [];
    }
  }

  /// Obtiene los documentos subidos por el usuario
  Future<List<Map<String, dynamic>>> getDocumentosUsuario() async {
    try {
      final response = await _dio.get('documentos');
      final dynamic raw = response.data;
      List<dynamic> list = [];
      if (raw is Map<String, dynamic> && raw['data'] is List) {
        list = raw['data'] as List<dynamic>;
      } else if (raw is List) {
        list = raw;
      }
      return list.whereType<Map<String, dynamic>>().toList();
    } catch (_) {
      return [];
    }
  }

  /// Obtiene la lista de boletas de pago del usuario autenticado
  Future<List<BoletaPagoModel>> getBoletasPago() async {
    try {
      final response = await _dio.get('boletas-pago');
      final dynamic raw = response.data;

      List<dynamic> list = [];
      if (raw is Map<String, dynamic> && raw['data'] is List) {
        list = raw['data'] as List<dynamic>;
      } else if (raw is List) {
        list = raw;
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => BoletaPagoModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw AppException(
        e.response?.data?['message']?.toString() ??
            'Error al cargar las boletas de pago',
      );
    } catch (e) {
      throw AppException('Error inesperado: $e');
    }
  }

  /// Obtiene la lista de inscripciones / membresías del usuario autenticado
  Future<List<BoletaInscripcionModel>> getBoletasInscripcion() async {
    try {
      final response = await _dio.get('boletas-inscripcion');
      final dynamic raw = response.data;

      List<dynamic> list = [];
      if (raw is Map<String, dynamic> && raw['data'] is List) {
        list = raw['data'] as List<dynamic>;
      } else if (raw is List) {
        list = raw;
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => BoletaInscripcionModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw AppException(
        e.response?.data?['message']?.toString() ??
            'Error al cargar las boletas de inscripción',
      );
    } catch (e) {
      throw AppException('Error inesperado: $e');
    }
  }

  /// Obtiene el código QR firmado de acceso para una boleta de inscripción específica
  Future<QRAccesoModel> getBoletaInscripcionQR(int id) async {
    try {
      final response = await _dio.get('boletas-inscripcion/$id/qr');
      final dynamic raw = response.data;

      Map<String, dynamic>? data;
      if (raw is Map<String, dynamic> && raw['data'] is Map<String, dynamic>) {
        data = raw['data'] as Map<String, dynamic>;
      } else if (raw is Map<String, dynamic>) {
        data = raw;
      }

      if (data == null) {
        throw AppException('No se pudo generar el código QR de acceso');
      }

      return QRAccesoModel.fromJson(data);
    } on DioException catch (e) {
      throw AppException(
        e.response?.data?['message']?.toString() ??
            'Error al generar el pase QR de inscripción',
      );
    } catch (e) {
      throw AppException('Error inesperado: $e');
    }
  }

  /// Valida un payload QR escaneado con la cámara y registra el acceso (entrada/salida)
  Future<ValidacionAccesoModel> validarQRAcceso(
    String qrPayload, {
    String tipo = 'auto',
  }) async {
    try {
      final response = await _dio.post(
        'registro-accesos/validar-qr',
        data: {
          'qr_payload': qrPayload,
          'tipo': tipo,
        },
      );

      final dynamic raw = response.data;
      if (raw is Map<String, dynamic>) {
        return ValidacionAccesoModel.fromJson(raw);
      }

      return ValidacionAccesoModel(
        permitido: false,
        mensaje: 'Respuesta inválida del servidor de accesos',
        tipo: tipo,
        timestamp: DateTime.now(),
      );
    } on DioException catch (e) {
      // El backend retorna HTTP 422 si el acceso no es permitido (ej: fuera de horario o vencido)
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic>) {
        return ValidacionAccesoModel.fromJson(errorData);
      }

      throw AppException(
        e.response?.data?['message']?.toString() ??
            'Error al validar el código QR de acceso',
      );
    } catch (e) {
      throw AppException('Error inesperado al validar QR: $e');
    }
  }

  /// Actualiza el estado de una solicitud (aprobado, rechazado) por recepción
  Future<void> updateEstadoSolicitud(int id, String estado) async {
    final lower = estado.toLowerCase().trim();
    final cleanEstado = lower.startsWith('apro')
        ? 'aprobado'
        : (lower.startsWith('rech') ? 'rechazado' : lower);

    try {
      await _dio.patch(
        'formulario-solicitudes/$id/estado',
        data: {'estado': cleanEstado},
      );
    } on DioException catch (e) {
      throw AppException(
        e.response?.data?['message']?.toString() ??
            'Error al actualizar el estado de la solicitud',
      );
    } catch (e) {
      throw AppException('Error inesperado: $e');
    }
  }

  /// Crea una boleta de pago (cobro presencial en recepción)
  Future<BoletaPagoModel> createBoletaPago(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('boletas-pago', data: data);
      final dynamic raw = response.data;
      Map<String, dynamic>? item;
      if (raw is Map<String, dynamic> && raw['data'] is Map<String, dynamic>) {
        item = raw['data'] as Map<String, dynamic>;
      } else if (raw is Map<String, dynamic>) {
        item = raw;
      }
      if (item == null) {
        throw AppException('Respuesta inválida del servidor al crear boleta de pago');
      }
      return BoletaPagoModel.fromJson(item);
    } on DioException catch (e) {
      throw AppException(
        e.response?.data?['message']?.toString() ??
            'Error al registrar la boleta de pago',
      );
    } catch (e) {
      throw AppException('Error inesperado: $e');
    }
  }

  /// Emite la boleta de inscripción y credencial QR a partir de una boleta de pago
  Future<void> emitirInscripcionDesdePago(
    int idBoletaPago, {
    String? numeroComprobante,
    String? fechaInicio,
    String? fechaFin,
  }) async {
    try {
      await _dio.post(
        'boletas-pago/$idBoletaPago/emitir-inscripcion',
        data: {
          'numero_comprobante': ?numeroComprobante,
          'fecha_inicio': ?fechaInicio,
          'fecha_fin': ?fechaFin,
        },
      );
    } on DioException catch (e) {
      throw AppException(
        e.response?.data?['message']?.toString() ??
            'Error al emitir la boleta de inscripción',
      );
    } catch (e) {
      throw AppException('Error inesperado: $e');
    }
  }
}
