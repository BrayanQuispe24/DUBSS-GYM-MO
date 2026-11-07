import '../../../../core/config/app_env.dart';
import 'tipo_documento_model.dart';

class DocumentoModel {
  final int id;
  final int idUsuario;
  final int idTipoDocumento;
  final String? titulo;
  final String? archivoUrl;
  final String? rutaArchivo;
  final DateTime? createdAt;
  final TipoDocumentoModel? tipoDocumento;
  final Map<String, dynamic>? usuario;

  const DocumentoModel({
    required this.id,
    required this.idUsuario,
    required this.idTipoDocumento,
    this.titulo,
    this.archivoUrl,
    this.rutaArchivo,
    this.createdAt,
    this.tipoDocumento,
    this.usuario,
  });

  String get displayTitle {
    if (titulo != null && titulo!.trim().isNotEmpty) {
      return titulo!.trim();
    }
    if (tipoDocumento != null && tipoDocumento!.nombre.trim().isNotEmpty) {
      return tipoDocumento!.nombre.trim();
    }
    return 'Documento #$id';
  }

  String get displayTipoNombre {
    return tipoDocumento?.nombre ?? 'Documento General';
  }

  String get rawFilePath {
    return archivoUrl ?? rutaArchivo ?? '';
  }

  bool get isPdf {
    final path = rawFilePath.toLowerCase();
    return path.endsWith('.pdf') || path.contains('.pdf');
  }

  bool get isImage {
    final path = rawFilePath.toLowerCase();
    return path.endsWith('.png') ||
        path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.webp') ||
        path.endsWith('.gif');
  }

  /// Resuelve la URL pública completa para descarga o visualización
  String get fullFileUrl {
    final raw = rawFilePath.trim();
    if (raw.isEmpty) return '';
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }

    // Extraer base URL del servidor sin '/api/'
    var serverBase = AppEnv.apiBaseUrl;
    if (serverBase.endsWith('/api/')) {
      serverBase = serverBase.substring(0, serverBase.length - 5);
    } else if (serverBase.endsWith('/api')) {
      serverBase = serverBase.substring(0, serverBase.length - 4);
    } else if (serverBase.endsWith('/')) {
      serverBase = serverBase.substring(0, serverBase.length - 1);
    }

    final cleanPath = raw.startsWith('/') ? raw : '/$raw';
    if (cleanPath.startsWith('/storage')) {
      return '$serverBase$cleanPath';
    }
    return '$serverBase/storage$cleanPath';
  }

  String get formattedDate {
    if (createdAt == null) return 'Fecha no disponible';
    final d = createdAt!;
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year;
    return '$day/$month/$year';
  }

  factory DocumentoModel.fromJson(Map<String, dynamic> json) {
    TipoDocumentoModel? tipo;
    if (json['tipo_documento'] is Map<String, dynamic>) {
      tipo = TipoDocumentoModel.fromJson(json['tipo_documento']);
    } else if (json['tipoDocumento'] is Map<String, dynamic>) {
      tipo = TipoDocumentoModel.fromJson(json['tipoDocumento']);
    }

    DateTime? date;
    if (json['created_at'] != null) {
      date = DateTime.tryParse(json['created_at'].toString());
    }

    return DocumentoModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      idUsuario: json['id_usuario'] is int
          ? json['id_usuario']
          : int.tryParse(json['id_usuario']?.toString() ?? '0') ?? 0,
      idTipoDocumento: json['id_tipo_documento'] is int
          ? json['id_tipo_documento']
          : int.tryParse(json['id_tipo_documento']?.toString() ?? '0') ?? 0,
      titulo: json['titulo']?.toString(),
      archivoUrl: json['archivo_url']?.toString(),
      rutaArchivo: json['ruta_archivo']?.toString(),
      createdAt: date,
      tipoDocumento: tipo,
      usuario: json['usuario'] is Map<String, dynamic> ? json['usuario'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_usuario': idUsuario,
      'id_tipo_documento': idTipoDocumento,
      'titulo': titulo,
      'archivo_url': archivoUrl,
      'ruta_archivo': rutaArchivo,
      'created_at': createdAt?.toIso8601String(),
      if (tipoDocumento != null) 'tipo_documento': tipoDocumento!.toJson(),
    };
  }
}
