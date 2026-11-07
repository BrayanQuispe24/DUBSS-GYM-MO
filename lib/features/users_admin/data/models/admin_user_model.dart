class AdminUserModel {
  final int id;
  final String nombre;
  final String apellido;
  final String email;
  final String rol;
  final String? ci;
  final String? codigo;
  final String? celular;
  final String tipoUsuario;
  final String estado;
  final String? createdAt;
  final List<dynamic> historiales;
  final List<dynamic> documentos;

  const AdminUserModel({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.rol,
    this.ci,
    this.codigo,
    this.celular,
    this.tipoUsuario = 'estudiante',
    this.estado = 'activo',
    this.createdAt,
    this.historiales = const [],
    this.documentos = const [],
  });

  String get nombreCompleto => '$nombre $apellido'.trim().isEmpty
      ? email
      : '$nombre $apellido'.trim();

  bool get isActivo =>
      estado.toLowerCase() == 'activo' ||
      estado == '1' ||
      estado == 'true';

  String get rolLabel {
    switch (rol.toLowerCase()) {
      case 'administrador':
        return 'Administrador';
      case 'recepcionista':
        return 'Recepcionista';
      case 'instructor':
        return 'Instructor';
      default:
        return 'Cliente Socio';
    }
  }

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    final rawNombre = json['nombre']?.toString() ?? json['name']?.toString() ?? '';
    final rawApellido = json['apellido']?.toString() ?? '';

    // Normalizar rol si viene como string o como objeto
    String roleStr = 'cliente';
    final rawRol = json['rol'];
    if (rawRol is String) {
      roleStr = rawRol;
    } else if (rawRol is Map && rawRol['nombre'] is String) {
      roleStr = rawRol['nombre'];
    }

    return AdminUserModel(
      id: json['id'] as int? ?? 0,
      nombre: rawNombre,
      apellido: rawApellido,
      email: json['email']?.toString() ?? '',
      rol: roleStr,
      ci: json['ci']?.toString(),
      codigo: json['codigo']?.toString() ??
          json['registro_universitario']?.toString(),
      celular: json['celular']?.toString() ?? json['telefono']?.toString(),
      tipoUsuario: json['tipo_usuario']?.toString() ?? 'estudiante',
      estado: json['estado']?.toString() ?? 'activo',
      createdAt: json['created_at']?.toString(),
      historiales: json['historiales'] as List<dynamic>? ?? [],
      documentos: json['documentos'] as List<dynamic>? ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'rol': rol,
      'ci': ci,
      'codigo': codigo,
      'celular': celular,
      'tipo_usuario': tipoUsuario,
      'estado': estado,
    };
  }
}
