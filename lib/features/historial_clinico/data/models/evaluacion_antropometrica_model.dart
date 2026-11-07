class EvaluacionAntropometricaModel {
  final int? id;
  final int? idUsuario;
  final DateTime fechaEvaluacion;
  final double pesoKg;
  final double estaturaCm;
  final double? imc;
  final double? porcentajeGrasa;
  final double? porcentajeMusculo;
  final double? masaMuscularKg;
  final int? grasaVisceral;
  final double? porcentajeAgua;
  // Perímetros (cm)
  final double? perimetroCintura;
  final double? perimetroCadera;
  final double? perimetroPecho;
  final double? perimetroBrazoRelajado;
  final double? perimetroBrazoContraido;
  final double? perimetroMuslo;
  final double? perimetroPantorrilla;
  // Signos vitales
  final int? presionSistolica;
  final int? presionDiastolica;
  final int? frecuenciaCardiaca;
  final String? observaciones;
  final String? evaluadorNombre;

  const EvaluacionAntropometricaModel({
    this.id,
    this.idUsuario,
    required this.fechaEvaluacion,
    required this.pesoKg,
    required this.estaturaCm,
    this.imc,
    this.porcentajeGrasa,
    this.porcentajeMusculo,
    this.masaMuscularKg,
    this.grasaVisceral,
    this.porcentajeAgua,
    this.perimetroCintura,
    this.perimetroCadera,
    this.perimetroPecho,
    this.perimetroBrazoRelajado,
    this.perimetroBrazoContraido,
    this.perimetroMuslo,
    this.perimetroPantorrilla,
    this.presionSistolica,
    this.presionDiastolica,
    this.frecuenciaCardiaca,
    this.observaciones,
    this.evaluadorNombre,
  });

  /// Calcula IMC si no vino explícito desde backend
  double get imcCalculado {
    if (imc != null && imc! > 0) return imc!;
    if (estaturaCm > 0) {
      final estaturaM = estaturaCm / 100.0;
      return double.parse((pesoKg / (estaturaM * estaturaM)).toStringAsFixed(1));
    }
    return 0.0;
  }

  /// Clasificación según la OMS
  String get clasificacionImc {
    final valor = imcCalculado;
    if (valor <= 0) return 'No determinado';
    if (valor < 18.5) return 'Bajo peso';
    if (valor < 25.0) return 'Peso normal';
    if (valor < 30.0) return 'Sobrepeso';
    if (valor < 35.0) return 'Obesidad Clase I';
    if (valor < 40.0) return 'Obesidad Clase II';
    return 'Obesidad Clase III';
  }

  /// Rango de color según IMC
  int get colorImcHex {
    final valor = imcCalculado;
    if (valor < 18.5) return 0xFF3B82F6; // Azul (Bajo peso)
    if (valor < 25.0) return 0xFF10B981; // Verde (Normal)
    if (valor < 30.0) return 0xFFF59E0B; // Ámbar (Sobrepeso)
    return 0xFFEF4444; // Rojo (Obesidad)
  }

  factory EvaluacionAntropometricaModel.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    DateTime parseFecha(dynamic value) {
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return EvaluacionAntropometricaModel(
      id: parseInt(json['id']),
      idUsuario: parseInt(json['id_usuario'] ?? json['usuario_id']),
      fechaEvaluacion: parseFecha(json['fecha_evaluacion'] ?? json['fecha'] ?? json['created_at']),
      pesoKg: parseDouble(json['peso'] ?? json['peso_kg']) ?? 0.0,
      estaturaCm: parseDouble(json['estatura'] ?? json['talla'] ?? json['estatura_cm']) ?? 0.0,
      imc: parseDouble(json['imc']),
      porcentajeGrasa: parseDouble(json['porcentaje_grasa'] ?? json['grasa_corporal']),
      porcentajeMusculo: parseDouble(json['porcentaje_musculo'] ?? json['masa_muscular_porcentaje']),
      masaMuscularKg: parseDouble(json['masa_muscular_kg']),
      grasaVisceral: parseInt(json['grasa_visceral']),
      porcentajeAgua: parseDouble(json['porcentaje_agua']),
      perimetroCintura: parseDouble(json['perimetro_cintura'] ?? json['cintura']),
      perimetroCadera: parseDouble(json['perimetro_cadera'] ?? json['cadera']),
      perimetroPecho: parseDouble(json['perimetro_pecho'] ?? json['pecho']),
      perimetroBrazoRelajado: parseDouble(json['perimetro_brazo_relajado'] ?? json['brazo_relajado']),
      perimetroBrazoContraido: parseDouble(json['perimetro_brazo_contraido'] ?? json['brazo_contraido']),
      perimetroMuslo: parseDouble(json['perimetro_muslo'] ?? json['muslo']),
      perimetroPantorrilla: parseDouble(json['perimetro_pantorrilla'] ?? json['pantorrilla']),
      presionSistolica: parseInt(json['presion_sistolica'] ?? json['sistolica']),
      presionDiastolica: parseInt(json['presion_diastolica'] ?? json['diastolica']),
      frecuenciaCardiaca: parseInt(json['frecuencia_cardiaca'] ?? json['pulso']),
      observaciones: json['observaciones']?.toString(),
      evaluadorNombre: json['evaluador_nombre']?.toString() ?? json['medico']?.toString() ?? json['instructor']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_usuario': idUsuario,
      'fecha_evaluacion': fechaEvaluacion.toIso8601String(),
      'peso': pesoKg,
      'estatura': estaturaCm,
      'imc': imcCalculado,
      'porcentaje_grasa': porcentajeGrasa,
      'porcentaje_musculo': porcentajeMusculo,
      'masa_muscular_kg': masaMuscularKg,
      'grasa_visceral': grasaVisceral,
      'porcentaje_agua': porcentajeAgua,
      'perimetro_cintura': perimetroCintura,
      'perimetro_cadera': perimetroCadera,
      'perimetro_pecho': perimetroPecho,
      'perimetro_brazo_relajado': perimetroBrazoRelajado,
      'perimetro_brazo_contraido': perimetroBrazoContraido,
      'perimetro_muslo': perimetroMuslo,
      'perimetro_pantorrilla': perimetroPantorrilla,
      'presion_sistolica': presionSistolica,
      'presion_diastolica': presionDiastolica,
      'frecuencia_cardiaca': frecuenciaCardiaca,
      'observaciones': observaciones,
      'evaluador_nombre': evaluadorNombre,
    };
  }
}
