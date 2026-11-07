class DetalleHistorialModel {
  final int? id;
  final int idHistorial;
  final double? peso;
  final double? altura;
  final double? imc;
  final double? porcentajeGrasa;
  final double? masaMuscular;
  final String? presion;
  final DateTime fechaRegistro;
  final DateTime? createdAt;

  const DetalleHistorialModel({
    this.id,
    required this.idHistorial,
    this.peso,
    this.altura,
    this.imc,
    this.porcentajeGrasa,
    this.masaMuscular,
    this.presion,
    required this.fechaRegistro,
    this.createdAt,
  });

  /// Calcula el IMC automáticamente si se tienen peso y altura
  double get imcCalculado {
    if (imc != null && imc! > 0) return imc!;
    if (peso != null && altura != null && altura! > 0) {
      final alturaM = altura! > 3.0 ? altura! / 100.0 : altura!;
      return double.parse((peso! / (alturaM * alturaM)).toStringAsFixed(1));
    }
    return 0.0;
  }

  /// Clasificación de IMC según OMS
  String get clasificacionImc {
    final valor = imcCalculado;
    if (valor <= 0) return 'No registrado';
    if (valor < 18.5) return 'Bajo peso';
    if (valor < 25.0) return 'Peso normal';
    if (valor < 30.0) return 'Sobrepeso';
    if (valor < 35.0) return 'Obesidad Clase I';
    if (valor < 40.0) return 'Obesidad Clase II';
    return 'Obesidad Clase III';
  }

  int get colorImcHex {
    final valor = imcCalculado;
    if (valor < 18.5) return 0xFF3B82F6; // Azul
    if (valor < 25.0) return 0xFF10B981; // Verde
    if (valor < 30.0) return 0xFFF59E0B; // Ámbar
    return 0xFFEF4444; // Rojo
  }

  factory DetalleHistorialModel.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString());
    }

    int parseInt(dynamic val) {
      if (val is int) return val;
      return int.tryParse(val?.toString() ?? '') ?? 0;
    }

    DateTime parseDate(dynamic val) {
      if (val is String && val.isNotEmpty) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return DetalleHistorialModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      idHistorial: parseInt(json['id_historial']),
      peso: parseDouble(json['peso']),
      altura: parseDouble(json['altura'] ?? json['talla']),
      imc: parseDouble(json['imc']),
      porcentajeGrasa: parseDouble(json['porcentaje_grasa']),
      masaMuscular: parseDouble(json['masa_muscular']),
      presion: json['presion']?.toString(),
      fechaRegistro: parseDate(json['fecha_registro'] ?? json['created_at']),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_historial': idHistorial,
      if (peso != null) 'peso': peso,
      if (altura != null) 'altura': altura,
      'imc': imcCalculado > 0 ? imcCalculado : imc,
      if (porcentajeGrasa != null) 'porcentaje_grasa': porcentajeGrasa,
      if (masaMuscular != null) 'masa_muscular': masaMuscular,
      if (presion != null && presion!.isNotEmpty) 'presion': presion,
      'fecha_registro': fechaRegistro.toIso8601String().split('T')[0],
    };
  }
}
