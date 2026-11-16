import 'dart:convert';

class UserModel {
  final int id;
  final String name;
  final String? nombre;
  final String? apellido;
  final String email;
  final String rol;
  final String? registroUniversitario;
  final String? ci;
  final String? telefono;
  final String tipoUsuario;
  final String estado;

  const UserModel({
    required this.id,
    required this.name,
    this.nombre,
    this.apellido,
    required this.email,
    required this.rol,
    this.registroUniversitario,
    this.ci,
    this.telefono,
    this.tipoUsuario = 'estudiante',
    this.estado = 'activo',
  });

  String get nombreCompleto => name;
  bool get canScanQr => rol == 'recepcionista' || rol == 'administrador' || rol == 'instructor';
  bool get isStaff => rol == 'recepcionista' || rol == 'administrador' || rol == 'instructor';
  bool get isInstructor => rol == 'instructor';
  bool get isRecepcionista => rol == 'recepcionista';
  bool get isAdmin => rol == 'administrador';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawName = json['name'] as String? ?? '';
    final rawNombre = json['nombre'] as String?;
    final rawApellido = json['apellido'] as String?;
    final fullName = rawName.isNotEmpty
        ? rawName
        : '${rawNombre ?? ''} ${rawApellido ?? ''}'.trim();

    String normalizedRole = 'cliente';
    final rawRol = json['rol'];
    if (rawRol is String) {
      final r = rawRol.toLowerCase();
      if (r.contains('admin')) {
        normalizedRole = 'administrador';
      } else if (r.contains('recep')) {
        normalizedRole = 'recepcionista';
      } else if (r.contains('instruct')) {
        normalizedRole = 'instructor';
      } else {
        normalizedRole = 'cliente';
      }
    } else if (rawRol is Map<String, dynamic> && rawRol['nombre'] is String) {
      final r = (rawRol['nombre'] as String).toLowerCase();
      if (r.contains('admin')) {
        normalizedRole = 'administrador';
      } else if (r.contains('recep')) {
        normalizedRole = 'recepcionista';
      } else if (r.contains('instruct')) {
        normalizedRole = 'instructor';
      } else {
        normalizedRole = 'cliente';
      }
    }

    return UserModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: fullName.isNotEmpty ? fullName : 'Usuario UAGRM',
      nombre: rawNombre,
      apellido: rawApellido,
      email: json['email'] as String? ?? '',
      rol: normalizedRole,
      registroUniversitario: json['registro_universitario'] as String? ?? json['codigo'] as String?,
      ci: json['ci']?.toString(),
      telefono: json['telefono'] as String? ?? json['celular'] as String?,
      tipoUsuario: json['tipo_usuario'] as String? ?? 'estudiante',
      estado: json['estado']?.toString().toLowerCase() == 'suspendido' ? 'suspendido' : 'activo',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'rol': rol,
      'registro_universitario': registroUniversitario,
      'ci': ci,
      'telefono': telefono,
      'tipo_usuario': tipoUsuario,
      'estado': estado,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory UserModel.fromJsonString(String str) =>
      UserModel.fromJson(jsonDecode(str) as Map<String, dynamic>);
}
