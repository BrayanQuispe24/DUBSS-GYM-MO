import '../../../../core/config/app_env.dart';

class EjercicioImagenModel {
  final int id;
  final int idEjercicio;
  final String pathImagen;
  final String? titulo;
  final String? descripcion;
  final int orden;

  const EjercicioImagenModel({
    required this.id,
    required this.idEjercicio,
    required this.pathImagen,
    this.titulo,
    this.descripcion,
    this.orden = 0,
  });

  /// Resuelve la URL pública completa de la imagen adaptándose automáticamente
  /// a entornos locales (con IP) o a producción HTTPS (gym.bratox.me).
  String get resolvedUrl => AppEnv.resolveStorageUrl(pathImagen);

  factory EjercicioImagenModel.fromJson(Map<String, dynamic> json) {
    return EjercicioImagenModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      idEjercicio: json['id_ejercicio'] is int
          ? json['id_ejercicio'] as int
          : int.tryParse(json['id_ejercicio']?.toString() ?? '0') ?? 0,
      pathImagen: json['path_imagen'] as String? ?? '',
      titulo: json['titulo'] as String?,
      descripcion: json['descripcion'] as String?,
      orden: json['orden'] is int ? json['orden'] as int : int.tryParse(json['orden']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'id_ejercicio': idEjercicio,
    'path_imagen': pathImagen,
    'titulo': titulo,
    'descripcion': descripcion,
    'orden': orden,
  };
}
