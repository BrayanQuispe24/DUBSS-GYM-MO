class TipoEjercicioModel {
  final int id;
  final String nombre;
  final bool estado;

  const TipoEjercicioModel({
    required this.id,
    required this.nombre,
    this.estado = true,
  });

  factory TipoEjercicioModel.fromJson(Map<String, dynamic> json) {
    final rawEstado = json['estado'];
    final isActivo = rawEstado is bool
        ? rawEstado
        : (rawEstado?.toString().toLowerCase() == 'activo' ||
            rawEstado?.toString() == '1' ||
            rawEstado?.toString().toLowerCase() == 'true');

    return TipoEjercicioModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nombre: json['nombre'] as String? ?? 'General',
      estado: isActivo,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'estado': estado,
  };
}
