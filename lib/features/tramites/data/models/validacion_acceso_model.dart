class ValidacionAccesoModel {
  final bool permitido;
  final String? motivo;
  final String mensaje;
  final String tipo;
  final String? usuarioNombre;
  final String? usuarioRu;
  final String? usuarioCi;
  final String? numeroBoleta;
  final String? disciplina;
  final DateTime timestamp;

  const ValidacionAccesoModel({
    required this.permitido,
    this.motivo,
    required this.mensaje,
    required this.tipo,
    this.usuarioNombre,
    this.usuarioRu,
    this.usuarioCi,
    this.numeroBoleta,
    this.disciplina,
    required this.timestamp,
  });

  factory ValidacionAccesoModel.fromJson(Map<String, dynamic> json) {
    final user = json['usuario'] as Map<String, dynamic>?;
    final bol = json['boleta'] as Map<String, dynamic>?;

    return ValidacionAccesoModel(
      permitido: json['permitido'] == true,
      motivo: json['motivo'] as String?,
      mensaje: json['mensaje'] as String? ??
          (json['permitido'] == true ? 'Acceso permitido' : 'Acceso denegado'),
      tipo: json['tipo'] as String? ?? 'auto',
      usuarioNombre: user?['nombre'] as String? ?? user?['usuario_nombre'] as String?,
      usuarioRu: user?['registro_universitario']?.toString(),
      usuarioCi: user?['ci']?.toString(),
      numeroBoleta: bol?['numero_boleta'] as String?,
      disciplina: bol?['disciplina'] as String?,
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'permitido': permitido,
    'motivo': motivo,
    'mensaje': mensaje,
    'tipo': tipo,
    'usuario': {
      'nombre': usuarioNombre,
      'registro_universitario': usuarioRu,
      'ci': usuarioCi,
    },
    'boleta': {
      'numero_boleta': numeroBoleta,
      'disciplina': disciplina,
    },
    'timestamp': timestamp.toIso8601String(),
  };
}
