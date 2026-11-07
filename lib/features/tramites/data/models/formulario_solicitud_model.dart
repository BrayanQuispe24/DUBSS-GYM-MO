import '../../../documentos/data/models/documento_model.dart';

class FormularioSolicitudModel {
  final int id;
  final String numeroFormulario;
  final String estado;
  final DateTime? fechaRegistro;
  final int idDisciplina;
  final String disciplinaNombre;
  final int? idDisciplinaHorario;
  final String? horarioTexto;
  final int? idPlan;
  final String? planNombre;
  final double? tarifaPrecio;
  final int idUsuario;
  final String? usuarioNombre;
  final String? usuarioEmail;
  final String? usuarioCi;
  final String? usuarioRegistro;
  final String? usuarioCelular;
  final int documentosCount;
  final List<DocumentoModel> documentos;
  final List<int> boletasPagoIds;

  const FormularioSolicitudModel({
    required this.id,
    required this.numeroFormulario,
    required this.estado,
    this.fechaRegistro,
    required this.idDisciplina,
    required this.disciplinaNombre,
    this.idDisciplinaHorario,
    this.horarioTexto,
    this.idPlan,
    this.planNombre,
    this.tarifaPrecio,
    required this.idUsuario,
    this.usuarioNombre,
    this.usuarioEmail,
    this.usuarioCi,
    this.usuarioRegistro,
    this.usuarioCelular,
    this.documentosCount = 0,
    this.documentos = const [],
    this.boletasPagoIds = const [],
  });

  bool get isAprobado =>
      estado.toLowerCase() == 'aprobado' ||
      estado.toLowerCase() == 'aprobado (cupo ocupado)';

  bool get isPendiente => estado.toLowerCase() == 'pendiente';

  bool get isRechazado =>
      estado.toLowerCase() == 'rechazado' || estado.toLowerCase() == 'cancelado';

  String get estadoLabel {
    switch (estado.toLowerCase()) {
      case 'aprobado':
      case 'aprobado (cupo ocupado)':
        return 'APROBADO';
      case 'pendiente':
        return 'PENDIENTE';
      case 'rechazado':
        return 'RECHAZADO';
      case 'cancelado':
        return 'CANCELADO';
      default:
        return estado.toUpperCase();
    }
  }

  factory FormularioSolicitudModel.fromJson(Map<String, dynamic> json) {
    // Disciplina
    String discName = 'Sin Disciplina';
    final disc = json['disciplina'];
    if (disc is Map<String, dynamic>) {
      discName = disc['nombre']?.toString() ?? 'Sin Disciplina';
    }

    // Horario
    String? horTexto;
    final dh = json['disciplina_horario'] ?? json['disciplinaHorario'];
    if (dh is Map<String, dynamic>) {
      final hor = dh['horario'];
      if (hor is Map<String, dynamic>) {
        final dia = hor['dia_semana'] ?? hor['dias'] ?? '';
        final ini = hor['hora_inicio'] ?? '';
        final fin = hor['hora_fin'] ?? '';
        horTexto = '$dia: $ini - $fin'.trim();
        if (horTexto.startsWith(':')) {
          horTexto = '$ini - $fin'.trim();
        }
      }
    }

    // Plan & Tarifa
    String? pName;
    double? tPrecio;
    final plan = json['plan'];
    if (plan is Map<String, dynamic>) {
      pName = plan['nombre']?.toString();
      final tarifa = plan['tarifa'];
      if (tarifa is Map<String, dynamic>) {
        tPrecio = double.tryParse(tarifa['precio']?.toString() ?? '');
      }
    }

    // Usuario
    String? uNom;
    String? uEmail;
    String? uCi;
    String? uReg;
    String? uCel;
    int docsCount = 0;
    List<DocumentoModel> parsedDocs = [];
    final usr = json['usuario'];
    if (usr is Map<String, dynamic>) {
      final nom = usr['nombre'] ?? usr['name'] ?? '';
      final ape = usr['apellido'] ?? '';
      uNom = '$nom $ape'.trim();
      uEmail = usr['email']?.toString();
      uCi = usr['ci']?.toString();
      uReg = usr['registro_universitario']?.toString();
      uCel = usr['celular']?.toString() ?? usr['telefono']?.toString();

      final docs = usr['documentos'];
      if (docs is List) {
        for (final d in docs) {
          if (d is Map<String, dynamic>) {
            parsedDocs.add(DocumentoModel.fromJson(d));
          }
        }
        docsCount = parsedDocs.length;
      }
    }

    // Boletas de pago
    List<int> bIds = [];
    final boletas = json['boletas_pago'] ?? json['boletasPago'];
    if (boletas is List) {
      for (final b in boletas) {
        if (b is Map<String, dynamic> && b['id'] != null) {
          final idVal = int.tryParse(b['id'].toString());
          if (idVal != null) bIds.add(idVal);
        }
      }
    }

    DateTime? fecha;
    final fStr = json['fecha_registro'] ?? json['created_at'];
    if (fStr != null) {
      fecha = DateTime.tryParse(fStr.toString());
    }

    return FormularioSolicitudModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      numeroFormulario: json['numero_formulario']?.toString() ?? 'DUBSS-FR-03-SIN-CODIGO',
      estado: json['estado']?.toString() ?? 'pendiente',
      fechaRegistro: fecha,
      idDisciplina: json['id_disciplina'] is int
          ? json['id_disciplina'] as int
          : int.tryParse(json['id_disciplina']?.toString() ?? '0') ?? 0,
      disciplinaNombre: discName,
      idDisciplinaHorario: json['id_disciplina_horario'] != null
          ? int.tryParse(json['id_disciplina_horario'].toString())
          : null,
      horarioTexto: horTexto,
      idPlan: json['id_plan'] != null
          ? int.tryParse(json['id_plan'].toString())
          : null,
      planNombre: pName,
      tarifaPrecio: tPrecio,
      idUsuario: json['id_usuario'] is int
          ? json['id_usuario'] as int
          : int.tryParse(json['id_usuario']?.toString() ?? '0') ?? 0,
      usuarioNombre: uNom,
      usuarioEmail: uEmail,
      usuarioCi: uCi,
      usuarioRegistro: uReg,
      usuarioCelular: uCel,
      documentosCount: docsCount,
      documentos: parsedDocs,
      boletasPagoIds: bIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero_formulario': numeroFormulario,
      'estado': estado,
      'fecha_registro': fechaRegistro?.toIso8601String(),
      'id_disciplina': idDisciplina,
      'id_disciplina_horario': idDisciplinaHorario,
      'id_plan': idPlan,
      'id_usuario': idUsuario,
    };
  }
}
