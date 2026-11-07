class GrupoMuscularModel {
  final int id;
  final String nombre;
  final String? descripcion;

  const GrupoMuscularModel({
    required this.id,
    required this.nombre,
    this.descripcion,
  });

  factory GrupoMuscularModel.fromJson(Map<String, dynamic> json) {
    return GrupoMuscularModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nombre: json['nombre'] as String? ?? 'Grupo Muscular',
      descripcion: json['descripcion'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'descripcion': descripcion,
  };
}
