class HorarioModel {
  final int id;
  final String diaSemana;
  final String horaInicio;
  final String horaFin;

  const HorarioModel({
    required this.id,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
  });

  String get horaInicioFormateada {
    final parts = horaInicio.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]}';
    }
    return horaInicio;
  }

  String get horaFinFormateada {
    final parts = horaFin.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]}';
    }
    return horaFin;
  }

  String get horarioFormateado => '$horaInicioFormateada - $horaFinFormateada';

  factory HorarioModel.fromJson(Map<String, dynamic> json) {
    return HorarioModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      diaSemana: json['dia_semana']?.toString() ?? json['dias']?.toString() ?? 'Días no definidos',
      horaInicio: json['hora_inicio']?.toString() ?? '00:00',
      horaFin: json['hora_fin']?.toString() ?? '00:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dia_semana': diaSemana,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
    };
  }
}
