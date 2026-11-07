class BoletaInscripcionModel {
  final int id;
  final String numeroBoleta;
  final DateTime? fechaInscripcion;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final double monto;
  final String estado;
  final String disciplina;
  final String? horaInicio;
  final String? horaSalida;
  final int? idTarifa;
  final int idUsuario;
  final String? usuarioNombre;
  final String? usuarioRu;
  final String? usuarioCi;

  const BoletaInscripcionModel({
    required this.id,
    required this.numeroBoleta,
    this.fechaInscripcion,
    this.fechaInicio,
    this.fechaFin,
    required this.monto,
    required this.estado,
    required this.disciplina,
    this.horaInicio,
    this.horaSalida,
    this.idTarifa,
    required this.idUsuario,
    this.usuarioNombre,
    this.usuarioRu,
    this.usuarioCi,
  });

  bool get isActiva {
    if (estado.toLowerCase() != 'activo' && estado.toLowerCase() != 'habilitado') {
      return false;
    }
    if (fechaFin == null) return true;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final fin = DateTime(fechaFin!.year, fechaFin!.month, fechaFin!.day);
    return fin.isAfter(today) || fin.isAtSameMomentAs(today);
  }

  int get diasRestantes {
    if (fechaFin == null) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final fin = DateTime(fechaFin!.year, fechaFin!.month, fechaFin!.day);
    final diff = fin.difference(today).inDays;
    return diff > 0 ? diff : 0;
  }

  String get horarioFormateado {
    final ini = horaInicio != null && horaInicio!.length >= 5
        ? horaInicio!.substring(0, 5)
        : '07:00';
    final fin = horaSalida != null && horaSalida!.length >= 5
        ? horaSalida!.substring(0, 5)
        : '21:00';
    return '$ini - $fin';
  }

  factory BoletaInscripcionModel.fromJson(Map<String, dynamic> json) {
    String? userName;
    String? ru;
    String? ci;

    final user = json['usuario'];
    if (user is Map<String, dynamic>) {
      final nom = user['nombre'] ?? user['name'] ?? '';
      final ape = user['apellido'] ?? '';
      userName = '$nom $ape'.trim();
      ru = user['registro_universitario']?.toString();
      ci = user['ci']?.toString();
    }

    return BoletaInscripcionModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      numeroBoleta: json['numero_boleta'] as String? ?? 'INS-S/N',
      fechaInscripcion: json['fecha_inscripcion'] != null
          ? DateTime.tryParse(json['fecha_inscripcion'].toString())
          : (json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null),
      fechaInicio: json['fecha_inicio'] != null
          ? DateTime.tryParse(json['fecha_inicio'].toString())
          : null,
      fechaFin: json['fecha_fin'] != null
          ? DateTime.tryParse(json['fecha_fin'].toString())
          : null,
      monto: json['monto'] != null ? double.tryParse(json['monto'].toString()) ?? 0.0 : 0.0,
      estado: json['estado'] as String? ?? 'activo',
      disciplina: json['disciplina'] as String? ?? 'Gimnasio Musculación DUBSS',
      horaInicio: json['hora_inicio'] as String?,
      horaSalida: json['hora_salida'] as String?,
      idTarifa: json['id_tarifa'] is int
          ? json['id_tarifa'] as int
          : int.tryParse(json['id_tarifa']?.toString() ?? ''),
      idUsuario: json['id_usuario'] is int
          ? json['id_usuario'] as int
          : int.tryParse(json['id_usuario']?.toString() ?? '0') ?? 0,
      usuarioNombre: userName,
      usuarioRu: ru,
      usuarioCi: ci,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'numero_boleta': numeroBoleta,
    'fecha_inscripcion': fechaInscripcion?.toIso8601String(),
    'fecha_inicio': fechaInicio?.toIso8601String(),
    'fecha_fin': fechaFin?.toIso8601String(),
    'monto': monto,
    'estado': estado,
    'disciplina': disciplina,
    'hora_inicio': horaInicio,
    'hora_salida': horaSalida,
    'id_tarifa': idTarifa,
    'id_usuario': idUsuario,
    'usuario_nombre': usuarioNombre,
    'usuario_ru': usuarioRu,
    'usuario_ci': usuarioCi,
  };
}
