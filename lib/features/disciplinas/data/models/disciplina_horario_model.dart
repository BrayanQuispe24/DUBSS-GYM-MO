import 'horario_model.dart';

class DisciplinaHorarioModel {
  final int id;
  final int idDisciplina;
  final int idHorario;
  final int cupoMaximo;
  final int cuposOcupados;
  final int cuposDisponibles;
  final bool estado;
  final HorarioModel? horario;
  final String? disciplinaNombre;

  const DisciplinaHorarioModel({
    required this.id,
    required this.idDisciplina,
    required this.idHorario,
    required this.cupoMaximo,
    required this.cuposOcupados,
    required this.cuposDisponibles,
    required this.estado,
    this.horario,
    this.disciplinaNombre,
  });

  bool get tieneCupos => cuposDisponibles > 0;

  double get porcentajeOcupacion {
    if (cupoMaximo <= 0) return 0.0;
    return (cuposOcupados / cupoMaximo).clamp(0.0, 1.0);
  }

  factory DisciplinaHorarioModel.fromJson(Map<String, dynamic> json) {
    HorarioModel? h;
    final horJson = json['horario'];
    if (horJson is Map) {
      h = HorarioModel.fromJson(Map<String, dynamic>.from(horJson));
    }

    String? discNom;
    final discJson = json['disciplina'];
    if (discJson is Map) {
      discNom = discJson['nombre']?.toString();
    }

    final maxVal = json['cupo_maximo'] is int
        ? json['cupo_maximo'] as int
        : int.tryParse(json['cupo_maximo']?.toString() ?? '0') ?? 0;

    final ocupadosVal = json['cupos_ocupados'] is int
        ? json['cupos_ocupados'] as int
        : int.tryParse(json['cupos_ocupados']?.toString() ?? '0') ?? 0;

    final dispCalculado = json['cupos_disponibles'] is int
        ? json['cupos_disponibles'] as int
        : int.tryParse(json['cupos_disponibles']?.toString() ?? '') ?? (maxVal - ocupadosVal);

    final rawEstado = json['estado'];
    final bool est = rawEstado == true ||
        rawEstado == 1 ||
        rawEstado == '1' ||
        rawEstado == 'activo' ||
        rawEstado == 'true';

    return DisciplinaHorarioModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      idDisciplina: json['id_disciplina'] is int
          ? json['id_disciplina'] as int
          : int.tryParse(json['id_disciplina']?.toString() ?? '0') ?? 0,
      idHorario: json['id_horario'] is int
          ? json['id_horario'] as int
          : int.tryParse(json['id_horario']?.toString() ?? '0') ?? 0,
      cupoMaximo: maxVal,
      cuposOcupados: ocupadosVal,
      cuposDisponibles: dispCalculado > 0 ? dispCalculado : 0,
      estado: est,
      horario: h,
      disciplinaNombre: discNom,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_disciplina': idDisciplina,
      'id_horario': idHorario,
      'cupo_maximo': cupoMaximo,
      'cupos_ocupados': cuposOcupados,
      'cupos_disponibles': cuposDisponibles,
      'estado': estado,
      'horario': horario?.toJson(),
    };
  }
}
