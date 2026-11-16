import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/users_remote_datasource.dart';
import '../../data/models/admin_user_model.dart';
import '../providers/users_provider.dart';

class UserFormModal extends ConsumerStatefulWidget {
  final AdminUserModel? userToEdit;
  final VoidCallback? onSuccess;

  const UserFormModal({
    super.key,
    this.userToEdit,
    this.onSuccess,
  });

  static Future<void> show(
    BuildContext context, {
    AdminUserModel? userToEdit,
    VoidCallback? onSuccess,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => UserFormModal(
        userToEdit: userToEdit,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  ConsumerState<UserFormModal> createState() => _UserFormModalState();
}

class _UserFormModalState extends ConsumerState<UserFormModal> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombreCtrl;
  late final TextEditingController _apellidoCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _ciCtrl;
  late final TextEditingController _celularCtrl;
  late final TextEditingController _codigoCtrl;

  late String _rol;
  late String _tipoUsuario;
  late String _estado;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final u = widget.userToEdit;
    _nombreCtrl = TextEditingController(text: u?.nombre ?? '');
    _apellidoCtrl = TextEditingController(text: u?.apellido ?? '');
    _emailCtrl = TextEditingController(text: u?.email ?? '');
    _passwordCtrl = TextEditingController();
    _ciCtrl = TextEditingController(text: u?.ci ?? '');
    _celularCtrl = TextEditingController(text: u?.celular ?? '');
    _codigoCtrl = TextEditingController(text: u?.codigo ?? '');

    _rol = u?.rol ?? 'cliente';
    _tipoUsuario = u?.tipoUsuario ?? 'estudiante';
    _estado = u?.estado ?? 'activo';
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _ciCtrl.dispose();
    _celularCtrl.dispose();
    _codigoCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final isEdit = widget.userToEdit != null;
    final payload = <String, dynamic>{
      'nombre': _nombreCtrl.text.trim(),
      'apellido': _apellidoCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'rol': _rol,
      'tipo_usuario': _tipoUsuario,
      'estado': _estado,
      'ci': _ciCtrl.text.trim(),
      'celular': _celularCtrl.text.trim(),
      'codigo': _codigoCtrl.text.trim(),
    };

    if (_passwordCtrl.text.trim().isNotEmpty) {
      payload['password'] = _passwordCtrl.text.trim();
    }

    try {
      final ds = ref.read(usersRemoteDataSourceProvider);
      if (isEdit) {
        await ds.updateUser(widget.userToEdit!.id, payload);
      } else {
        await ds.createUser(payload);
      }

      await ref.read(usersAdminNotifierProvider.notifier).cargarUsuarios();

      if (mounted) {
        Navigator.of(context).pop();
        widget.onSuccess?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? 'Usuario actualizado correctamente'
                  : 'Usuario registrado con éxito',
            ),
            backgroundColor: AppColors.successEmerald,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.accentVibrant,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.userToEdit != null;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: AppColors.carbonSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
        border: Border(top: BorderSide(color: AppColors.borderSubtle, width: 1.0)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 14,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEdit ? 'Editar Usuario' : 'Nuevo Usuario / Socio',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textWhite,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSlateMuted, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 14),

          // Form body
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Nombre y Apellido
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _nombreCtrl,
                            style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                            decoration: _inputDeco('Nombre *', Icons.person_outline),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Requerido'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _apellidoCtrl,
                            style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                            decoration: _inputDeco('Apellido *', Icons.person_outline),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Requerido'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Email
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                      decoration: _inputDeco('Correo Electrónico *', Icons.email_outlined),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Ingrese un correo';
                        if (!v.contains('@')) return 'Correo no válido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Contraseña
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                      decoration: _inputDeco(
                        isEdit ? 'Nueva Contraseña (opcional)' : 'Contraseña *',
                        Icons.lock_outline,
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 18,
                            color: AppColors.textSlateMuted,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) {
                        if (!isEdit && (v == null || v.trim().length < 6)) {
                          return 'Mínimo 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // C.I. y Registro Universitario
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ciCtrl,
                            keyboardType: TextInputType.text,
                            style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                            decoration: _inputDeco('C.I. / Documento', Icons.badge_outlined),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _codigoCtrl,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                            decoration: _inputDeco('R.U. / Código', Icons.school_outlined),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Celular
                    TextFormField(
                      controller: _celularCtrl,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                      decoration: _inputDeco('Celular / Teléfono', Icons.phone_android_outlined),
                    ),
                    const SizedBox(height: 12),

                    // Rol y Tipo de Usuario
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _rol,
                            dropdownColor: AppColors.carbonSurface,
                            style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                            isExpanded: true,
                            decoration: _inputDeco('Rol del Sistema', Icons.shield_outlined),
                            items: const [
                              DropdownMenuItem(value: 'cliente', child: Text('Cliente Socio')),
                              DropdownMenuItem(value: 'instructor', child: Text('Instructor')),
                              DropdownMenuItem(value: 'recepcionista', child: Text('Recepcionista')),
                              DropdownMenuItem(value: 'administrador', child: Text('Administrador')),
                            ],
                            onChanged: (v) => setState(() => _rol = v ?? 'cliente'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _tipoUsuario,
                            dropdownColor: AppColors.carbonSurface,
                            style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                            isExpanded: true,
                            decoration: _inputDeco('Tipo Universitario', Icons.category_outlined),
                            items: const [
                              DropdownMenuItem(value: 'estudiante', child: Text('Estudiante')),
                              DropdownMenuItem(value: 'docente', child: Text('Docente')),
                              DropdownMenuItem(value: 'administrativo', child: Text('Administrativo')),
                              DropdownMenuItem(value: 'particular', child: Text('Particular')),
                            ],
                            onChanged: (v) => setState(() => _tipoUsuario = v ?? 'estudiante'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Estado
                    DropdownButtonFormField<String>(
                      initialValue: _estado,
                      dropdownColor: AppColors.carbonSurface,
                      style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                      isExpanded: true,
                      decoration: _inputDeco('Estado de Cuenta', Icons.toggle_on_outlined),
                      items: const [
                        DropdownMenuItem(value: 'activo', child: Text('Activo (Habilitado)')),
                        DropdownMenuItem(value: 'suspendido', child: Text('Suspendido / Bloqueado')),
                      ],
                      onChanged: (v) => setState(() => _estado = v ?? 'activo'),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // Botón Guardar
          ElevatedButton(
            onPressed: _isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryCrimson,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: const BorderSide(color: AppColors.accentVibrant),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    isEdit ? 'Actualizar Usuario' : 'Registrar Usuario',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSlateMuted),
      prefixIcon: Icon(icon, color: AppColors.accentVibrant, size: 18),
      filled: true,
      fillColor: AppColors.carbonSurfaceMuted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.accentVibrant, width: 1.5),
      ),
    );
  }
}
