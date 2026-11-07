class RegistroAccesoModel {
  final int id;
  final String fechaHora;
  final String tipo; // 'entrada' | 'salida'
  final int idUsuario;
  final int? idBoletaInscripcion;
  final String? usuarioNombre;
  final String? usuarioApellido;
  final String? usuarioCi;
  final String? usuarioCodigo;
  final String? boletaNumero;
  final String? boletaEstado;

  const RegistroAccesoModel({
    required this.id,
    required this.fechaHora,
    required this.tipo,
    required this.idUsuario,
    this.idBoletaInscripcion,
    this.usuarioNombre,
    this.usuarioApellido,
    this.usuarioCi,
    this.usuarioCodigo,
    this.boletaNumero,
    this.boletaEstado,
  });

  String get nombreCompleto =>
      '${usuarioNombre ?? ''} ${usuarioApellido ?? ''}'.trim().isEmpty
          ? 'Usuario #$idUsuario'
          : '${usuarioNombre ?? ''} ${usuarioApellido ?? ''}'.trim();

  bool get isEntrada => tipo.toLowerCase() == 'entrada';

  factory RegistroAccesoModel.fromJson(Map<String, dynamic> json) {
    final usuario = json['usuario'] as Map<String, dynamic>?;
    final boleta = json['boleta_inscripcion'] as Map<String, dynamic>?;

    return RegistroAccesoModel(
      id: json['id'] as int? ?? 0,
      fechaHora: json['fecha_hora']?.toString() ??
          json['created_at']?.toString() ??
          DateTime.now().toIso8601String(),
      tipo: json['tipo']?.toString().toLowerCase() ?? 'entrada',
      idUsuario: json['id_usuario'] as int? ?? (usuario?['id'] as int? ?? 0),
      idBoletaInscripcion: json['id_boleta_inscripcion'] as int? ??
          (boleta?['id'] as int?),
      usuarioNombre: usuario?['nombre']?.toString() ??
          usuario?['name']?.toString() ??
          json['nombre_usuario']?.toString(),
      usuarioApellido: usuario?['apellido']?.toString(),
      usuarioCi: usuario?['ci']?.toString(),
      usuarioCodigo: usuario?['codigo']?.toString() ??
          usuario?['registro_universitario']?.toString(),
      boletaNumero: boleta?['numero_boleta']?.toString(),
      boletaEstado: boleta?['estado']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha_hora': fechaHora,
      'tipo': tipo,
      'id_usuario': idUsuario,
      'id_boleta_inscripcion': idBoletaInscripcion,
    };
  }
}
