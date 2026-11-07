class BoletaPagoModel {
  final int id;
  final String numeroBoleta;
  final DateTime? fechaPago;
  final double monto;
  final String metodoPago;
  final String concepto;
  final String estado;
  final String? comprobanteUrl;
  final int? idFormulario;
  final String? usuarioNombre;
  final String? planNombre;
  final String? disciplinaNombre;

  const BoletaPagoModel({
    required this.id,
    required this.numeroBoleta,
    this.fechaPago,
    required this.monto,
    required this.metodoPago,
    required this.concepto,
    required this.estado,
    this.comprobanteUrl,
    this.idFormulario,
    this.usuarioNombre,
    this.planNombre,
    this.disciplinaNombre,
  });

  bool get isPagado =>
      estado.toLowerCase() == 'completado' ||
      estado.toLowerCase() == 'pagado' ||
      estado.toLowerCase() == 'aprobado';

  String get estadoLabel {
    switch (estado.toLowerCase()) {
      case 'completado':
      case 'pagado':
      case 'aprobado':
        return 'PAGADO';
      case 'pendiente':
        return 'PENDIENTE';
      case 'anulado':
        return 'ANULADO';
      default:
        return estado.toUpperCase();
    }
  }

  factory BoletaPagoModel.fromJson(Map<String, dynamic> json) {
    // Extraer datos anidados de formulario_solicitud si están presentes
    String? userName;
    String? plan;
    String? disc;

    final form = json['formulario_solicitud'];
    if (form is Map<String, dynamic>) {
      final user = form['usuario'];
      if (user is Map<String, dynamic>) {
        final nom = user['nombre'] ?? user['name'] ?? '';
        final ape = user['apellido'] ?? '';
        userName = '$nom $ape'.trim();
      }

      final p = form['plan'];
      if (p is Map<String, dynamic>) {
        plan = p['nombre'] as String?;
      }

      final d = form['disciplina'];
      if (d is Map<String, dynamic>) {
        disc = d['nombre'] as String?;
      }
    }

    return BoletaPagoModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      numeroBoleta: json['numero_boleta'] as String? ?? 'BOL-S/N',
      fechaPago: json['fecha_pago'] != null
          ? DateTime.tryParse(json['fecha_pago'].toString())
          : (json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null),
      monto: json['monto'] != null ? double.tryParse(json['monto'].toString()) ?? 0.0 : 0.0,
      metodoPago: json['metodo_pago'] as String? ?? 'Caja Campus UAGRM',
      concepto: json['concepto'] as String? ??
          (plan != null ? 'Inscripción - $plan' : 'Arancel Gimnasio DUBSS'),
      estado: json['estado'] as String? ?? 'pendiente',
      comprobanteUrl: json['comprobante_url'] as String?,
      idFormulario: json['id_formulario'] is int
          ? json['id_formulario'] as int
          : int.tryParse(json['id_formulario']?.toString() ?? ''),
      usuarioNombre: userName,
      planNombre: plan,
      disciplinaNombre: disc,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'numero_boleta': numeroBoleta,
    'fecha_pago': fechaPago?.toIso8601String(),
    'monto': monto,
    'metodo_pago': metodoPago,
    'concepto': concepto,
    'estado': estado,
    'comprobante_url': comprobanteUrl,
    'id_formulario': idFormulario,
    'usuario_nombre': usuarioNombre,
    'plan_nombre': planNombre,
    'disciplina_nombre': disciplinaNombre,
  };
}
