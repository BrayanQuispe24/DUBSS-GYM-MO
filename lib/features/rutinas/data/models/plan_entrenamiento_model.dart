import 'rutina_model.dart';

class PlanEntrenamientoRutinaModel {
  final int id;
  final String diaSemana;
  final int idPlanEntrenamiento;
  final int idRutina;
  final RutinaModel? rutina;

  const PlanEntrenamientoRutinaModel({
    required this.id,
    required this.diaSemana,
    required this.idPlanEntrenamiento,
    required this.idRutina,
    this.rutina,
  });

  factory PlanEntrenamientoRutinaModel.fromJson(Map<String, dynamic> json) {
    RutinaModel? rut;
    if (json['rutina'] != null && json['rutina'] is Map<String, dynamic>) {
      rut = RutinaModel.fromJson(json['rutina'] as Map<String, dynamic>);
    }

    return PlanEntrenamientoRutinaModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      diaSemana: json['dia_semana'] as String? ?? 'Día',
      idPlanEntrenamiento: json['id_plan_entrenamiento'] is int
          ? json['id_plan_entrenamiento'] as int
          : int.tryParse(json['id_plan_entrenamiento']?.toString() ?? '0') ?? 0,
      idRutina: json['id_rutina'] is int
          ? json['id_rutina'] as int
          : int.tryParse(json['id_rutina']?.toString() ?? '0') ?? 0,
      rutina: rut,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'dia_semana': diaSemana,
    'id_plan_entrenamiento': idPlanEntrenamiento,
    'id_rutina': idRutina,
    if (rutina != null) 'rutina': rutina!.toJson(),
  };
}

class PlanEntrenamientoModel {
  final int id;
  final String nombre;
  final String? objetivo;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final bool estado;
  final String? observacion;
  final int? idUsuario;
  final List<PlanEntrenamientoRutinaModel> planEntrenamientoRutinas;

  const PlanEntrenamientoModel({
    required this.id,
    required this.nombre,
    this.objetivo,
    this.fechaInicio,
    this.fechaFin,
    this.estado = true,
    this.observacion,
    this.idUsuario,
    this.planEntrenamientoRutinas = const [],
  });

  /// Lista de los días únicos configurados en este plan
  List<String> get diasConfigurados {
    final dias = <String>[];
    for (final item in planEntrenamientoRutinas) {
      if (!dias.contains(item.diaSemana)) {
        dias.add(item.diaSemana);
      }
    }
    return dias;
  }

  /// Retorna la rutina asociada a un día específico
  RutinaModel? rutinaPorDia(String dia) {
    for (final item in planEntrenamientoRutinas) {
      if (item.diaSemana.toLowerCase().trim() == dia.toLowerCase().trim()) {
        return item.rutina;
      }
    }
    return null;
  }

  factory PlanEntrenamientoModel.fromJson(Map<String, dynamic> json) {
    final List<PlanEntrenamientoRutinaModel> rutinasList = [];
    if (json['plan_entrenamiento_rutinas'] != null &&
        json['plan_entrenamiento_rutinas'] is List) {
      for (final item in json['plan_entrenamiento_rutinas'] as List<dynamic>) {
        if (item is Map<String, dynamic>) {
          rutinasList.add(PlanEntrenamientoRutinaModel.fromJson(item));
        }
      }
    }

    return PlanEntrenamientoModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nombre: json['nombre'] as String? ?? 'Plan de Entrenamiento',
      objetivo: json['objetivo'] as String?,
      fechaInicio: json['fecha_inicio'] != null
          ? DateTime.tryParse(json['fecha_inicio'].toString())
          : null,
      fechaFin: json['fecha_fin'] != null
          ? DateTime.tryParse(json['fecha_fin'].toString())
          : null,
      estado: json['estado'] == true || json['estado'] == 1 || json['estado'] == '1',
      observacion: json['observacion'] as String?,
      idUsuario: json['id_usuario'] is int
          ? json['id_usuario'] as int
          : int.tryParse(json['id_usuario']?.toString() ?? ''),
      planEntrenamientoRutinas: rutinasList,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'objetivo': objetivo,
    'fecha_inicio': fechaInicio?.toIso8601String(),
    'fecha_fin': fechaFin?.toIso8601String(),
    'estado': estado,
    'observacion': observacion,
    'id_usuario': idUsuario,
    'plan_entrenamiento_rutinas':
        planEntrenamientoRutinas.map((r) => r.toJson()).toList(),
  };
}
