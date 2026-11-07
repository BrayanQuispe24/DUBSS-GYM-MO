class QRAccesoModel {
  final int boletaId;
  final String numeroBoleta;
  final String usuarioNombre;
  final String? usuarioEmail;
  final String? usuarioCi;
  final String? usuarioRu;
  final String disciplina;
  final String horarioTexto;
  final String fechaInicio;
  final String fechaFin;
  final String estado;
  final double monto;
  final String qrPayload;
  final String? signature;

  const QRAccesoModel({
    required this.boletaId,
    required this.numeroBoleta,
    required this.usuarioNombre,
    this.usuarioEmail,
    this.usuarioCi,
    this.usuarioRu,
    required this.disciplina,
    required this.horarioTexto,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
    required this.monto,
    required this.qrPayload,
    this.signature,
  });

  factory QRAccesoModel.fromJson(Map<String, dynamic> json) {
    final user = json['usuario'] as Map<String, dynamic>? ?? {};
    final memb = json['membresia'] as Map<String, dynamic>? ?? {};

    return QRAccesoModel(
      boletaId: json['boleta_id'] is int
          ? json['boleta_id'] as int
          : int.tryParse(json['boleta_id']?.toString() ?? '0') ?? 0,
      numeroBoleta: json['numero_boleta'] as String? ?? 'INS-S/N',
      usuarioNombre: user['nombre'] as String? ?? 'Socio Universitario',
      usuarioEmail: user['email'] as String?,
      usuarioCi: user['ci']?.toString(),
      usuarioRu: user['registro_universitario']?.toString(),
      disciplina: memb['disciplina'] as String? ?? 'Gimnasio Musculación DUBSS',
      horarioTexto: memb['horario_texto'] as String? ?? 'Horario Universitario',
      fechaInicio: memb['fecha_inicio'] as String? ?? '',
      fechaFin: memb['fecha_fin'] as String? ?? '',
      estado: memb['estado'] as String? ?? 'activo',
      monto: memb['monto'] != null ? double.tryParse(memb['monto'].toString()) ?? 0.0 : 0.0,
      qrPayload: json['qr_payload'] as String? ?? json.toString(),
      signature: json['signature'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'boleta_id': boletaId,
    'numero_boleta': numeroBoleta,
    'usuario': {
      'nombre': usuarioNombre,
      'email': usuarioEmail,
      'ci': usuarioCi,
      'registro_universitario': usuarioRu,
    },
    'membresia': {
      'disciplina': disciplina,
      'horario_texto': horarioTexto,
      'fecha_inicio': fechaInicio,
      'fecha_fin': fechaFin,
      'estado': estado,
      'monto': monto,
    },
    'qr_payload': qrPayload,
    'signature': signature,
  };
}
