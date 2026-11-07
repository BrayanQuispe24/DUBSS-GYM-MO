import 'ejercicio_imagen_model.dart';
import 'grupo_muscular_model.dart';
import 'tipo_ejercicio_model.dart';

class EjercicioModel {
  final int id;
  final String nombre;
  final String? descripcion;
  final int? idTipoEjercicio;
  final String? urlVideo;
  final String? codigoExterno;
  final String? equipamiento;
  final String? nivelDificultad;
  final String? mecanica;
  final String? patronMovimiento;
  final TipoEjercicioModel? tipoEjercicio;
  final List<GrupoMuscularModel> gruposMusculares;
  final List<EjercicioImagenModel> imagenes;

  const EjercicioModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.idTipoEjercicio,
    this.urlVideo,
    this.codigoExterno,
    this.equipamiento,
    this.nivelDificultad,
    this.mecanica,
    this.patronMovimiento,
    this.tipoEjercicio,
    this.gruposMusculares = const [],
    this.imagenes = const [],
  });

  /// Retorna la URL de la primera imagen de demostración
  String? get firstImageUrl {
    if (imagenes.isNotEmpty) {
      return imagenes.first.resolvedUrl;
    }
    return null;
  }

  /// Nombres de los grupos musculares involucrados
  List<String> get nombresGruposMusculares {
    return gruposMusculares.map((g) => g.nombre).toList();
  }

  factory EjercicioModel.fromJson(Map<String, dynamic> json) {
    // Tipo de Ejercicio
    TipoEjercicioModel? tipo;
    if (json['tipo_ejercicio'] != null && json['tipo_ejercicio'] is Map<String, dynamic>) {
      tipo = TipoEjercicioModel.fromJson(json['tipo_ejercicio'] as Map<String, dynamic>);
    }

    // Grupos Musculares (extraídos de ejercicio_grupo_musculares)
    final List<GrupoMuscularModel> grupos = [];
    if (json['ejercicio_grupo_musculares'] != null && json['ejercicio_grupo_musculares'] is List) {
      for (final item in json['ejercicio_grupo_musculares'] as List<dynamic>) {
        if (item is Map<String, dynamic> && item['grupo_muscular'] != null) {
          grupos.add(GrupoMuscularModel.fromJson(item['grupo_muscular'] as Map<String, dynamic>));
        }
      }
    }

    // Imágenes
    final List<EjercicioImagenModel> imgs = [];
    if (json['imagenes'] != null && json['imagenes'] is List) {
      for (final item in json['imagenes'] as List<dynamic>) {
        if (item is Map<String, dynamic>) {
          imgs.add(EjercicioImagenModel.fromJson(item));
        }
      }
    }

    return EjercicioModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nombre: json['nombre'] as String? ?? 'Ejercicio',
      descripcion: json['descripcion'] as String?,
      idTipoEjercicio: json['id_tipo_ejercicio'] is int
          ? json['id_tipo_ejercicio'] as int
          : int.tryParse(json['id_tipo_ejercicio']?.toString() ?? ''),
      urlVideo: json['url_video'] as String?,
      codigoExterno: json['codigo_externo'] as String?,
      equipamiento: json['equipamiento'] as String?,
      nivelDificultad: json['nivel_dificultad'] as String?,
      mecanica: json['mecanica'] as String?,
      patronMovimiento: json['patron_movimiento'] as String?,
      tipoEjercicio: tipo,
      gruposMusculares: grupos,
      imagenes: imgs,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'descripcion': descripcion,
    'id_tipo_ejercicio': idTipoEjercicio,
    'url_video': urlVideo,
    'codigo_externo': codigoExterno,
    'equipamiento': equipamiento,
    'nivel_dificultad': nivelDificultad,
    'mecanica': mecanica,
    'patron_movimiento': patronMovimiento,
    'tipo_ejercicio': tipoEjercicio?.toJson(),
    'imagenes': imagenes.map((img) => img.toJson()).toList(),
  };
}

class EjerciciosMetaModel {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const EjerciciosMetaModel({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory EjerciciosMetaModel.fromJson(Map<String, dynamic> json) {
    return EjerciciosMetaModel(
      currentPage: json['current_page'] is int
          ? json['current_page'] as int
          : int.tryParse(json['current_page']?.toString() ?? '1') ?? 1,
      lastPage: json['last_page'] is int
          ? json['last_page'] as int
          : int.tryParse(json['last_page']?.toString() ?? '1') ?? 1,
      perPage: json['per_page'] is int
          ? json['per_page'] as int
          : int.tryParse(json['per_page']?.toString() ?? '15') ?? 15,
      total: json['total'] is int
          ? json['total'] as int
          : int.tryParse(json['total']?.toString() ?? '0') ?? 0,
    );
  }
}

class EjerciciosPaginadosModel {
  final List<EjercicioModel> data;
  final EjerciciosMetaModel meta;

  const EjerciciosPaginadosModel({
    required this.data,
    required this.meta,
  });

  factory EjerciciosPaginadosModel.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? [];
    final items = list.map((item) => EjercicioModel.fromJson(item as Map<String, dynamic>)).toList();
    final meta = json['meta'] != null && json['meta'] is Map<String, dynamic>
        ? EjerciciosMetaModel.fromJson(json['meta'] as Map<String, dynamic>)
        : EjerciciosMetaModel(currentPage: 1, lastPage: 1, perPage: items.length, total: items.length);

    return EjerciciosPaginadosModel(
      data: items,
      meta: meta,
    );
  }
}
