class TarifaModel {
  final int id;
  final String nombre;
  final String precio;
  final String? fechaInicio;
  final String? fechaFin;
  final bool estado;

  const TarifaModel({
    required this.id,
    required this.nombre,
    required this.precio,
    this.fechaInicio,
    this.fechaFin,
    this.estado = true,
  });

  factory TarifaModel.fromJson(Map<String, dynamic> json) {
    final rawEstado = json['estado'];
    final bool isActivo = rawEstado is bool
        ? rawEstado
        : (rawEstado?.toString().toLowerCase() == 'activo' ||
            rawEstado?.toString() == '1' ||
            rawEstado?.toString().toLowerCase() == 'true');

    return TarifaModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nombre: json['nombre'] as String? ?? 'Tarifa General',
      precio: json['precio']?.toString() ?? '0.00',
      fechaInicio: json['fecha_inicio'] as String?,
      fechaFin: json['fecha_fin'] as String?,
      estado: isActivo,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'precio': precio,
    'fecha_inicio': fechaInicio,
    'fecha_fin': fechaFin,
    'estado': estado,
  };
}

class PlanModel {
  final int id;
  final String nombre;
  final String? descripcion;
  final int duracionDias;
  final bool estado;
  final TarifaModel? tarifa;

  const PlanModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.duracionDias,
    this.estado = true,
    this.tarifa,
  });

  bool get isActivo => estado;

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    final rawEstado = json['estado'];
    final bool isActivo = rawEstado is bool
        ? rawEstado
        : (rawEstado?.toString().toLowerCase() == 'activo' ||
            rawEstado?.toString() == '1' ||
            rawEstado?.toString().toLowerCase() == 'true');

    return PlanModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nombre: json['nombre'] as String? ?? 'Plan UAGRM',
      descripcion: json['descripcion'] as String?,
      duracionDias: json['duracion_dias'] is int
          ? json['duracion_dias'] as int
          : int.tryParse(json['duracion_dias']?.toString() ?? '30') ?? 30,
      estado: isActivo,
      tarifa: json['tarifa'] != null && json['tarifa'] is Map<String, dynamic>
          ? TarifaModel.fromJson(json['tarifa'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'descripcion': descripcion,
    'duracion_dias': duracionDias,
    'estado': estado,
    'tarifa': tarifa?.toJson(),
  };
}
