class FichaMedicaModel {
  final int? id;
  final int? idUsuario;
  final String? grupoSanguineo;
  final String? factorRh;
  final List<String> alergias;
  final List<String> enfermedadesCronicas;
  final List<String> lesionesPrevias;
  final String? observacionesMedicas;
  final String? contactoEmergenciaNombre;
  final String? contactoEmergenciaTelefono;
  final String? contactoEmergenciaParentesco;
  final bool tieneCertificadoMedico;
  final DateTime? fechaVencimientoCertificado;
  final String? estadoCertificado; // 'vigente', 'vencido', 'pendiente'

  const FichaMedicaModel({
    this.id,
    this.idUsuario,
    this.grupoSanguineo,
    this.factorRh,
    this.alergias = const [],
    this.enfermedadesCronicas = const [],
    this.lesionesPrevias = const [],
    this.observacionesMedicas,
    this.contactoEmergenciaNombre,
    this.contactoEmergenciaTelefono,
    this.contactoEmergenciaParentesco,
    this.tieneCertificadoMedico = false,
    this.fechaVencimientoCertificado,
    this.estadoCertificado,
  });

  bool get isCertificadoVigente {
    if (estadoCertificado != null) {
      return estadoCertificado!.toLowerCase() == 'vigente';
    }
    if (fechaVencimientoCertificado != null) {
      return fechaVencimientoCertificado!.isAfter(DateTime.now());
    }
    return tieneCertificadoMedico;
  }

  factory FichaMedicaModel.fromJson(Map<String, dynamic> json) {
    List<String> parseStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
      }
      if (value is String) {
        if (value.trim().isEmpty || value.trim() == '[]') return [];
        return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
      return [];
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    return FichaMedicaModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      idUsuario: json['id_usuario'] is int
          ? json['id_usuario'] as int
          : int.tryParse(json['id_usuario']?.toString() ?? ''),
      grupoSanguineo: json['grupo_sanguineo']?.toString() ?? json['tipo_sangre']?.toString(),
      factorRh: json['factor_rh']?.toString(),
      alergias: parseStringList(json['alergias']),
      enfermedadesCronicas: parseStringList(json['enfermedades_cronicas'] ?? json['patologias']),
      lesionesPrevias: parseStringList(json['lesiones_previas'] ?? json['lesiones']),
      observacionesMedicas: json['observaciones']?.toString() ?? json['observaciones_medicas']?.toString(),
      contactoEmergenciaNombre: json['contacto_emergencia_nombre']?.toString() ?? json['nombre_contacto_emergencia']?.toString(),
      contactoEmergenciaTelefono: json['contacto_emergencia_telefono']?.toString() ?? json['telefono_emergencia']?.toString(),
      contactoEmergenciaParentesco: json['contacto_emergencia_parentesco']?.toString() ?? json['parentesco_emergencia']?.toString(),
      tieneCertificadoMedico: json['tiene_certificado_medico'] == true ||
          json['certificado_medico'] == true ||
          json['certificado_medico'] == 1 ||
          json['tiene_certificado_medico'] == 1,
      fechaVencimientoCertificado: parseDate(json['fecha_vencimiento_certificado']),
      estadoCertificado: json['estado_certificado']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_usuario': idUsuario,
      'grupo_sanguineo': grupoSanguineo,
      'factor_rh': factorRh,
      'alergias': alergias,
      'enfermedades_cronicas': enfermedadesCronicas,
      'lesiones_previas': lesionesPrevias,
      'observaciones_medicas': observacionesMedicas,
      'contacto_emergencia_nombre': contactoEmergenciaNombre,
      'contacto_emergencia_telefono': contactoEmergenciaTelefono,
      'contacto_emergencia_parentesco': contactoEmergenciaParentesco,
      'tiene_certificado_medico': tieneCertificadoMedico,
      'fecha_vencimiento_certificado': fechaVencimientoCertificado?.toIso8601String(),
      'estado_certificado': estadoCertificado,
    };
  }
}
