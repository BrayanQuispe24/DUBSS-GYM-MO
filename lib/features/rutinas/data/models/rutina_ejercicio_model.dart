import '../../../../features/ejercicios/data/models/ejercicio_model.dart';

class RutinaEjercicioModel {
  final int id;
  final int series;
  final int repeticiones;
  final num? peso;
  final int? duracionSegundos;
  final int descansoSegundos;
  final int orden;
  final String? observacion;
  final int idEjercicio;
  final int idRutina;
  final EjercicioModel? ejercicio;

  const RutinaEjercicioModel({
    required this.id,
    required this.series,
    required this.repeticiones,
    this.peso,
    this.duracionSegundos,
    required this.descansoSegundos,
    required this.orden,
    this.observacion,
    required this.idEjercicio,
    required this.idRutina,
    this.ejercicio,
  });

  factory RutinaEjercicioModel.fromJson(Map<String, dynamic> json) {
    EjercicioModel? ej;
    if (json['ejercicio'] != null && json['ejercicio'] is Map<String, dynamic>) {
      ej = EjercicioModel.fromJson(json['ejercicio'] as Map<String, dynamic>);
    }

    return RutinaEjercicioModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      series: json['series'] is int
          ? json['series'] as int
          : int.tryParse(json['series']?.toString() ?? '3') ?? 3,
      repeticiones: json['repeticiones'] is int
          ? json['repeticiones'] as int
          : int.tryParse(json['repeticiones']?.toString() ?? '10') ?? 10,
      peso: json['peso'] != null ? num.tryParse(json['peso'].toString()) : null,
      duracionSegundos: json['duracion_segundos'] != null
          ? int.tryParse(json['duracion_segundos'].toString())
          : null,
      descansoSegundos: json['descanso_segundos'] is int
          ? json['descanso_segundos'] as int
          : int.tryParse(json['descanso_segundos']?.toString() ?? '60') ?? 60,
      orden: json['orden'] is int
          ? json['orden'] as int
          : int.tryParse(json['orden']?.toString() ?? '1') ?? 1,
      observacion: json['observacion'] as String?,
      idEjercicio: json['id_ejercicio'] is int
          ? json['id_ejercicio'] as int
          : int.tryParse(json['id_ejercicio']?.toString() ?? '0') ?? 0,
      idRutina: json['id_rutina'] is int
          ? json['id_rutina'] as int
          : int.tryParse(json['id_rutina']?.toString() ?? '0') ?? 0,
      ejercicio: ej,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'series': series,
    'repeticiones': repeticiones,
    'peso': peso,
    'duracion_segundos': duracionSegundos,
    'descanso_segundos': descansoSegundos,
    'orden': orden,
    'observacion': observacion,
    'id_ejercicio': idEjercicio,
    'id_rutina': idRutina,
    if (ejercicio != null) 'ejercicio': ejercicio!.toJson(),
  };
}
