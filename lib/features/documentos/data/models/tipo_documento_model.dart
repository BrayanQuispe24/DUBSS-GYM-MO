class TipoDocumentoModel {
  final int id;
  final String nombre;
  final String? descripcion;

  const TipoDocumentoModel({
    required this.id,
    required this.nombre,
    this.descripcion,
  });

  factory TipoDocumentoModel.fromJson(Map<String, dynamic> json) {
    return TipoDocumentoModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
    };
  }
}
