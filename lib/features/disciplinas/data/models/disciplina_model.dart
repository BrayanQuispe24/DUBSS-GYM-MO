import 'disciplina_horario_model.dart';

class DisciplinaModel {
  final int id;
  final String nombre;
  final String? descripcion;
  final int? cantidadCupos;
  final int totalCuposOcupados;
  final int totalCuposDisponibles;
  final String estado;
  final List<DisciplinaHorarioModel> disciplinaHorarios;

  const DisciplinaModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.cantidadCupos,
    required this.totalCuposOcupados,
    required this.totalCuposDisponibles,
    required this.estado,
    this.disciplinaHorarios = const [],
  });

  bool get isActive {
    final s = estado.toLowerCase().trim();
    return s == 'activo' || s == '1' || s == 'true';
  }

  int get cuposTotales {
    if (cantidadCupos != null && cantidadCupos! > 0) {
      return cantidadCupos!;
    }
    if (disciplinaHorarios.isNotEmpty) {
      return disciplinaHorarios.fold(0, (acc, dh) => acc + dh.cupoMaximo);
    }
    return 0;
  }

  bool get tieneCuposDisponibles => totalCuposDisponibles > 0;

  double get porcentajeOcupacion {
    final tot = cuposTotales;
    if (tot <= 0) return 0.0;
    return (totalCuposOcupados / tot).clamp(0.0, 1.0);
  }

  List<String> get diasAsignados {
    final set = <String>{};
    for (final dh in disciplinaHorarios) {
      final dia = dh.horario?.diaSemana;
      if (dia != null && dia.isNotEmpty) {
        set.add(dia);
      }
    }
    return set.toList();
  }

  factory DisciplinaModel.fromJson(Map<String, dynamic> json) {
    // Horarios asignados
    List<DisciplinaHorarioModel> dHorarios = [];
    final rawDh = json['disciplina_horarios'] ?? json['disciplinaHorarios'];
    if (rawDh is List) {
      for (final item in rawDh) {
        if (item is Map) {
          dHorarios.add(
            DisciplinaHorarioModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    final cuposMax = json['cantidad_cupos'] is int
        ? json['cantidad_cupos'] as int
        : int.tryParse(json['cantidad_cupos']?.toString() ?? '');

    final ocupados = json['total_cupos_ocupados'] is int
        ? json['total_cupos_ocupados'] as int
        : int.tryParse(json['total_cupos_ocupados']?.toString() ?? '') ??
            dHorarios.fold<int>(0, (acc, dh) => acc + dh.cuposOcupados);

    final maxCalculado = cuposMax ??
        (dHorarios.isNotEmpty
            ? dHorarios.fold<int>(0, (acc, dh) => acc + dh.cupoMaximo)
            : 0);

    final disponibles = json['total_cupos_disponibles'] is int
        ? json['total_cupos_disponibles'] as int
        : int.tryParse(json['total_cupos_disponibles']?.toString() ?? '') ??
            (maxCalculado - ocupados > 0 ? maxCalculado - ocupados : 0);

    return DisciplinaModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nombre: json['nombre']?.toString() ?? 'Disciplina Sin Nombre',
      descripcion: json['descripcion']?.toString(),
      cantidadCupos: cuposMax,
      totalCuposOcupados: ocupados,
      totalCuposDisponibles: disponibles > 0 ? disponibles : 0,
      estado: json['estado']?.toString() ?? 'activo',
      disciplinaHorarios: dHorarios,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'cantidad_cupos': cantidadCupos,
      'total_cupos_ocupados': totalCuposOcupados,
      'total_cupos_disponibles': totalCuposDisponibles,
      'estado': estado,
      'disciplina_horarios': disciplinaHorarios.map((dh) => dh.toJson()).toList(),
    };
  }
}
