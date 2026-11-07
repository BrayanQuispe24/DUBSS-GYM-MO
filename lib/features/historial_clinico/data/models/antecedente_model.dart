class AntecedenteModel {
  final int? id;
  final int idHistorial;
  final String? observaciones;
  final bool tieneEnfermedadesCardiovasculares;
  final String? detalleEnfermedadesCardiovasculares;
  final bool seRealizoIntervencionCardiovascular;
  final String? detalleIntervencionCardiovascular;
  final bool tieneHipertensionArterial;
  final String? detalleHipertensionArterial;
  final bool tieneEnfermedadesPulmonares;
  final String? detalleEnfermedadesPulmonares;
  final bool tieneDiabetes;
  final String? detalleDiabetes;
  final bool tieneEnfermedadesOsteoarticulares;
  final String? detalleEnfermedadesOsteoarticulares;
  final bool tieneEnfermedadesNeurologicas;
  final String? detalleEnfermedadesNeurologicas;
  final bool tieneConvulsiones;
  final String? detalleConvulsiones;
  final bool tieneIntervencionQuirurgica;
  final String? detalleIntervencionQuirurgica;
  final bool sufrioFracturasOseas;
  final String? detalleFracturasOseas;
  final bool sufrioAlgunSintomaDuranteDeporte;
  final String? detalleSintomasDuranteDeporte;
  final bool tieneLesiones;
  final String? detalleLesiones;
  final bool tieneAlergias;
  final String? detalleAlergias;
  final DateTime? createdAt;

  const AntecedenteModel({
    this.id,
    required this.idHistorial,
    this.observaciones,
    this.tieneEnfermedadesCardiovasculares = false,
    this.detalleEnfermedadesCardiovasculares,
    this.seRealizoIntervencionCardiovascular = false,
    this.detalleIntervencionCardiovascular,
    this.tieneHipertensionArterial = false,
    this.detalleHipertensionArterial,
    this.tieneEnfermedadesPulmonares = false,
    this.detalleEnfermedadesPulmonares,
    this.tieneDiabetes = false,
    this.detalleDiabetes,
    this.tieneEnfermedadesOsteoarticulares = false,
    this.detalleEnfermedadesOsteoarticulares,
    this.tieneEnfermedadesNeurologicas = false,
    this.detalleEnfermedadesNeurologicas,
    this.tieneConvulsiones = false,
    this.detalleConvulsiones,
    this.tieneIntervencionQuirurgica = false,
    this.detalleIntervencionQuirurgica,
    this.sufrioFracturasOseas = false,
    this.detalleFracturasOseas,
    this.sufrioAlgunSintomaDuranteDeporte = false,
    this.detalleSintomasDuranteDeporte,
    this.tieneLesiones = false,
    this.detalleLesiones,
    this.tieneAlergias = false,
    this.detalleAlergias,
    this.createdAt,
  });

  bool get tieneAlgunaCondicionMedica =>
      tieneEnfermedadesCardiovasculares ||
      seRealizoIntervencionCardiovascular ||
      tieneHipertensionArterial ||
      tieneEnfermedadesPulmonares ||
      tieneDiabetes ||
      tieneEnfermedadesOsteoarticulares ||
      tieneEnfermedadesNeurologicas ||
      tieneConvulsiones ||
      tieneIntervencionQuirurgica ||
      sufrioFracturasOseas ||
      sufrioAlgunSintomaDuranteDeporte ||
      tieneLesiones ||
      tieneAlergias;

  factory AntecedenteModel.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic val) {
      if (val == null) return false;
      if (val is bool) return val;
      if (val is num) return val == 1;
      final str = val.toString().toLowerCase().trim();
      return str == '1' || str == 'true' || str == 'si' || str == 'yes';
    }

    int parseInt(dynamic val) {
      if (val is int) return val;
      return int.tryParse(val?.toString() ?? '') ?? 0;
    }

    return AntecedenteModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      idHistorial: parseInt(json['id_historial']),
      observaciones: json['observaciones']?.toString(),
      tieneEnfermedadesCardiovasculares: parseBool(json['tiene_enfermedades_cardiovasculares']),
      detalleEnfermedadesCardiovasculares: json['detalle_enfermedades_cardiovasculares']?.toString(),
      seRealizoIntervencionCardiovascular: parseBool(json['se_realizo_intervencion_cardiovascular']),
      detalleIntervencionCardiovascular: json['detalle_intervencion_cardiovascular']?.toString(),
      tieneHipertensionArterial: parseBool(json['tiene_hipertension_arterial']),
      detalleHipertensionArterial: json['detalle_hipertension_arterial']?.toString(),
      tieneEnfermedadesPulmonares: parseBool(json['tiene_enfermedades_pulmonares']),
      detalleEnfermedadesPulmonares: json['detalle_enfermedades_pulmonares']?.toString(),
      tieneDiabetes: parseBool(json['tiene_diabetes']),
      detalleDiabetes: json['detalle_diabetes']?.toString(),
      tieneEnfermedadesOsteoarticulares: parseBool(json['tiene_enfermedades_osteoarticulares']),
      detalleEnfermedadesOsteoarticulares: json['detalle_enfermedades_osteoarticulares']?.toString(),
      tieneEnfermedadesNeurologicas: parseBool(json['tiene_enfermedades_neurologicas']),
      detalleEnfermedadesNeurologicas: json['detalle_enfermedades_neurologicas']?.toString(),
      tieneConvulsiones: parseBool(json['tiene_convulsiones']),
      detalleConvulsiones: json['detalle_convulsiones']?.toString(),
      tieneIntervencionQuirurgica: parseBool(json['tiene_intervencion_quirurgica']),
      detalleIntervencionQuirurgica: json['detalle_intervencion_quirurgica']?.toString(),
      sufrioFracturasOseas: parseBool(json['sufrio_fracturas_oseas']),
      detalleFracturasOseas: json['detalle_fracturas_oseas']?.toString(),
      sufrioAlgunSintomaDuranteDeporte: parseBool(json['sufrio_algun_sintoma_durante_deporte']),
      detalleSintomasDuranteDeporte: json['detalle_sintomas_durante_deporte']?.toString(),
      tieneLesiones: parseBool(json['tiene_lesiones']),
      detalleLesiones: json['detalle_lesiones']?.toString(),
      tieneAlergias: parseBool(json['tiene_alergias']),
      detalleAlergias: json['detalle_alergias']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_historial': idHistorial,
      'observaciones': observaciones,
      'tiene_enfermedades_cardiovasculares': tieneEnfermedadesCardiovasculares,
      if (tieneEnfermedadesCardiovasculares && detalleEnfermedadesCardiovasculares != null)
        'detalle_enfermedades_cardiovasculares': detalleEnfermedadesCardiovasculares,
      'se_realizo_intervencion_cardiovascular': seRealizoIntervencionCardiovascular,
      if (seRealizoIntervencionCardiovascular && detalleIntervencionCardiovascular != null)
        'detalle_intervencion_cardiovascular': detalleIntervencionCardiovascular,
      'tiene_hipertension_arterial': tieneHipertensionArterial,
      if (tieneHipertensionArterial && detalleHipertensionArterial != null)
        'detalle_hipertension_arterial': detalleHipertensionArterial,
      'tiene_enfermedades_pulmonares': tieneEnfermedadesPulmonares,
      if (tieneEnfermedadesPulmonares && detalleEnfermedadesPulmonares != null)
        'detalle_enfermedades_pulmonares': detalleEnfermedadesPulmonares,
      'tiene_diabetes': tieneDiabetes,
      if (tieneDiabetes && detalleDiabetes != null) 'detalle_diabetes': detalleDiabetes,
      'tiene_enfermedades_osteoarticulares': tieneEnfermedadesOsteoarticulares,
      if (tieneEnfermedadesOsteoarticulares && detalleEnfermedadesOsteoarticulares != null)
        'detalle_enfermedades_osteoarticulares': detalleEnfermedadesOsteoarticulares,
      'tiene_enfermedades_neurologicas': tieneEnfermedadesNeurologicas,
      if (tieneEnfermedadesNeurologicas && detalleEnfermedadesNeurologicas != null)
        'detalle_enfermedades_neurologicas': detalleEnfermedadesNeurologicas,
      'tiene_convulsiones': tieneConvulsiones,
      if (tieneConvulsiones && detalleConvulsiones != null) 'detalle_convulsiones': detalleConvulsiones,
      'tiene_intervencion_quirurgica': tieneIntervencionQuirurgica,
      if (tieneIntervencionQuirurgica && detalleIntervencionQuirurgica != null)
        'detalle_intervencion_quirurgica': detalleIntervencionQuirurgica,
      'sufrio_fracturas_oseas': sufrioFracturasOseas,
      if (sufrioFracturasOseas && detalleFracturasOseas != null)
        'detalle_fracturas_oseas': detalleFracturasOseas,
      'sufrio_algun_sintoma_durante_deporte': sufrioAlgunSintomaDuranteDeporte,
      if (sufrioAlgunSintomaDuranteDeporte && detalleSintomasDuranteDeporte != null)
        'detalle_sintomas_durante_deporte': detalleSintomasDuranteDeporte,
      'tiene_lesiones': tieneLesiones,
      if (tieneLesiones && detalleLesiones != null) 'detalle_lesiones': detalleLesiones,
      'tiene_alergias': tieneAlergias,
      if (tieneAlergias && detalleAlergias != null) 'detalle_alergias': detalleAlergias,
    };
  }
}
