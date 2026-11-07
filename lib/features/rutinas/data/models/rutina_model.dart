import 'rutina_ejercicio_model.dart';

class RutinaModel {
  final int id;
  final String nombre;
  final String? descripcion;
  final String nivel;
  final bool estado;
  final bool generadoPorIa;
  final List<String> justificacionReglas;
  final int? idPerfilEntrenamiento;
  final List<RutinaEjercicioModel> rutinaEjercicios;

  const RutinaModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.nivel = 'Intermedio',
    this.estado = true,
    this.generadoPorIa = false,
    this.justificacionReglas = const [],
    this.idPerfilEntrenamiento,
    this.rutinaEjercicios = const [],
  });

  /// Total de ejercicios asignados en esta rutina
  int get totalEjercicios => rutinaEjercicios.length;

  /// Tiempo estimado aproximado en minutos (calculado según series, descansos y tiempo de ejecución)
  int get duracionEstimadaMinutos {
    if (rutinaEjercicios.isEmpty) return 30;
    int segundosTotales = 0;
    for (final re in rutinaEjercicios) {
      // 45s promedio por serie + tiempo de descanso
      final series = re.series > 0 ? re.series : 3;
      final descanso = re.descansoSegundos > 0 ? re.descansoSegundos : 60;
      segundosTotales += series * (45 + descanso);
    }
    final mins = (segundosTotales / 60).ceil();
    return mins > 15 ? mins : 30;
  }

  factory RutinaModel.fromJson(Map<String, dynamic> json) {
    // rutina_ejercicios
    final List<RutinaEjercicioModel> ejercicios = [];
    if (json['rutina_ejercicios'] != null && json['rutina_ejercicios'] is List) {
      for (final item in json['rutina_ejercicios'] as List<dynamic>) {
        if (item is Map<String, dynamic>) {
          ejercicios.add(RutinaEjercicioModel.fromJson(item));
        }
      }
    }

    // ordenar por el campo orden si existe
    ejercicios.sort((a, b) => a.orden.compareTo(b.orden));

    // justificacion_reglas
    final List<String> reglas = [];
    if (json['justificacion_reglas'] != null) {
      if (json['justificacion_reglas'] is List) {
        for (final r in json['justificacion_reglas'] as List<dynamic>) {
          reglas.add(r.toString());
        }
      } else if (json['justificacion_reglas'] is String) {
        reglas.add(json['justificacion_reglas'].toString());
      }
    }

    return RutinaModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nombre: json['nombre'] as String? ?? 'Rutina de Entrenamiento',
      descripcion: json['descripcion'] as String?,
      nivel: json['nivel'] as String? ?? 'Intermedio',
      estado: json['estado'] == true || json['estado'] == 1 || json['estado'] == '1',
      generadoPorIa: json['generado_por_ia'] == true ||
          json['generado_por_ia'] == 1 ||
          json['generado_por_ia'] == '1',
      justificacionReglas: reglas,
      idPerfilEntrenamiento: json['id_perfil_entrenamiento'] is int
          ? json['id_perfil_entrenamiento'] as int
          : int.tryParse(json['id_perfil_entrenamiento']?.toString() ?? ''),
      rutinaEjercicios: ejercicios,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'descripcion': descripcion,
    'nivel': nivel,
    'estado': estado,
    'generado_por_ia': generadoPorIa,
    'justificacion_reglas': justificacionReglas,
    'id_perfil_entrenamiento': idPerfilEntrenamiento,
    'rutina_ejercicios': rutinaEjercicios.map((e) => e.toJson()).toList(),
  };
}
