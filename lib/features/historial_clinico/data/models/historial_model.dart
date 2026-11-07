import 'antecedente_model.dart';
import 'detalle_historial_model.dart';

class HistorialModel {
  final int id;
  final int idUsuario;
  final DateTime? fechaApertura;
  final String? observacionesGenerales;
  final String? grupoSanguineo;
  final String? sexo;
  final DateTime? fechaNacimiento;
  final String? domicilio;
  final String? facultadCarrera;
  final String? celularEmergencia;
  final String? estado;
  final DateTime? createdAt;
  final Map<String, dynamic>? usuario;
  final List<DetalleHistorialModel> detalles;
  final List<AntecedenteModel> antecedentes;

  const HistorialModel({
    required this.id,
    required this.idUsuario,
    this.fechaApertura,
    this.observacionesGenerales,
    this.grupoSanguineo,
    this.sexo,
    this.fechaNacimiento,
    this.domicilio,
    this.facultadCarrera,
    this.celularEmergencia,
    this.estado,
    this.createdAt,
    this.usuario,
    this.detalles = const [],
    this.antecedentes = const [],
  });

  /// Retorna la última medición física registrada
  DetalleHistorialModel? get ultimaMedicion =>
      detalles.isNotEmpty ? detalles.first : null;

  /// Retorna la penúltima medición física para comparativas
  DetalleHistorialModel? get penultimaMedicion =>
      detalles.length > 1 ? detalles[1] : null;

  /// Retorna el antecedente médico más reciente
  AntecedenteModel? get ultimoAntecedente =>
      antecedentes.isNotEmpty ? antecedentes.last : null;

  /// Variación de peso respecto a la medición previa
  double? get deltaPeso {
    final act = ultimaMedicion?.peso;
    final ant = penultimaMedicion?.peso;
    if (act == null || ant == null) return null;
    return double.parse((act - ant).toStringAsFixed(1));
  }

  /// Variación de porcentaje graso
  double? get deltaGrasa {
    final act = ultimaMedicion?.porcentajeGrasa;
    final ant = penultimaMedicion?.porcentajeGrasa;
    if (act == null || ant == null) return null;
    return double.parse((act - ant).toStringAsFixed(1));
  }

  /// Variación de masa muscular
  double? get deltaMusculo {
    final act = ultimaMedicion?.masaMuscular;
    final ant = penultimaMedicion?.masaMuscular;
    if (act == null || ant == null) return null;
    return double.parse((act - ant).toStringAsFixed(1));
  }

  String get usuarioNombreCompleto {
    if (usuario == null) return 'Usuario #$idUsuario';
    final name = usuario!['name']?.toString();
    if (name != null && name.isNotEmpty) return name;
    final nombre = usuario!['nombre']?.toString() ?? '';
    final apellido = usuario!['apellido']?.toString() ?? '';
    final completo = '$nombre $apellido'.trim();
    return completo.isNotEmpty ? completo : (usuario!['email']?.toString() ?? 'Usuario #$idUsuario');
  }

  String get usuarioCi => usuario?['ci']?.toString() ?? '';
  String get usuarioRegistro =>
      usuario?['registro_universitario']?.toString() ?? usuario?['codigo']?.toString() ?? '';
  String get usuarioEmail => usuario?['email']?.toString() ?? '';
  String get usuarioCelular => usuario?['celular']?.toString() ?? celularEmergencia ?? '';

  factory HistorialModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      return int.tryParse(val?.toString() ?? '') ?? 0;
    }

    DateTime? parseDate(dynamic val) {
      if (val is String && val.isNotEmpty) {
        return DateTime.tryParse(val);
      }
      return null;
    }

    // Parsear detalles
    List<DetalleHistorialModel> listDetalles = [];
    final detallesRaw = json['detalles'];
    if (detallesRaw is List) {
      listDetalles = detallesRaw
          .whereType<Map<String, dynamic>>()
          .map((e) => DetalleHistorialModel.fromJson(e))
          .toList();
      // Ordenar descendente (más reciente primero)
      listDetalles.sort((a, b) => b.fechaRegistro.compareTo(a.fechaRegistro));
    }

    // Parsear antecedentes
    List<AntecedenteModel> listAntecedentes = [];
    final antRaw = json['antecedentes'] ?? json['antecedentes_medicos'];
    if (antRaw is List) {
      listAntecedentes = antRaw
          .whereType<Map<String, dynamic>>()
          .map((e) => AntecedenteModel.fromJson(e))
          .toList();
    }

    return HistorialModel(
      id: parseInt(json['id']),
      idUsuario: parseInt(json['id_usuario'] ?? json['usuario_id']),
      fechaApertura: parseDate(json['fecha_apertura'] ?? json['created_at']),
      observacionesGenerales: json['observaciones_generales']?.toString() ?? json['observaciones']?.toString(),
      grupoSanguineo: json['grupo_sanguineo']?.toString(),
      sexo: json['sexo']?.toString(),
      fechaNacimiento: parseDate(json['fecha_nacimiento']),
      domicilio: json['domicilio']?.toString(),
      facultadCarrera: json['facultad_carrera']?.toString(),
      celularEmergencia: json['celular_emergencia']?.toString(),
      estado: json['estado']?.toString(),
      createdAt: parseDate(json['created_at']),
      usuario: json['usuario'] is Map<String, dynamic> ? json['usuario'] as Map<String, dynamic> : null,
      detalles: listDetalles,
      antecedentes: listAntecedentes,
    );
  }
}
