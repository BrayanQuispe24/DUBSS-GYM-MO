import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_notifier.dart';
import '../widgets/auth_banner_widget.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _ciController = TextEditingController();
  final _ruController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  String _tipoUsuario = 'estudiante';
  bool _aceptaTerminos = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _ciController.dispose();
    _ruController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe aceptar los Términos y Condiciones para continuar'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final success = await ref.read(authNotifierProvider.notifier).register(
          nombre: _nombreController.text.trim(),
          apellido: _apellidoController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          passwordConfirmation: _passwordConfirmController.text,
          ci: _ciController.text.trim(),
          registroUniversitario: _ruController.text.trim(),
          tipoUsuario: _tipoUsuario,
          telefono: _telefonoController.text.trim(),
          aceptaTerminos: _aceptaTerminos,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Cuenta creada exitosamente! Bienvenido a DUBS.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/client');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.navyBlueDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/login'),
        ),
        title: const Text(
          'Registro de Cliente UAGRM',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AuthBannerWidget(compact: true),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Crear Cuenta de Cliente',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Complete sus datos oficiales para vincular su carnet con el gimnasio.',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 18),

                    if (authState.errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.dangerBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.dangerText, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                authState.errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.dangerText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Nombre y Apellido en 2 columnas
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Nombre *',
                            controller: _nombreController,
                            hint: 'Ej: Juan',
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            label: 'Apellido *',
                            controller: _apellidoController,
                            hint: 'Ej: Pérez',
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // CI y RU
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'C.I. *',
                            controller: _ciController,
                            hint: 'Ej: 8932451',
                            keyboardType: TextInputType.number,
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            label: 'Reg. Univ. (R.U.) *',
                            controller: _ruController,
                            hint: 'Ej: 219084721',
                            keyboardType: TextInputType.number,
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Tipo de Usuario UAGRM
                    const Text(
                      'Tipo de Usuario UAGRM *',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _tipoUsuario,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: 'estudiante', child: Text('Estudiante Universitario', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'docente', child: Text('Docente UAGRM', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'administrativo', child: Text('Administrativo UAGRM', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'particular', child: Text('Comunidad Particular', style: TextStyle(fontSize: 13))),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _tipoUsuario = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Teléfono / WhatsApp
                    _buildTextField(
                      label: 'Teléfono / WhatsApp',
                      controller: _telefonoController,
                      hint: 'Ej: 71029384',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),

                    // Correo Electrónico
                    _buildTextField(
                      label: 'Correo Electrónico *',
                      controller: _emailController,
                      hint: 'estudiante@uagrm.edu.bo',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || !v.contains('@')) return 'Ingrese un correo válido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Contraseña
                    _buildTextField(
                      label: 'Contraseña *',
                      controller: _passwordController,
                      hint: '••••••••',
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 18),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (v) {
                        if (v == null || v.length < 8) return 'Mínimo 8 caracteres (requerido por UAGRM)';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Confirmar Contraseña
                    _buildTextField(
                      label: 'Confirmar Contraseña *',
                      controller: _passwordConfirmController,
                      hint: '••••••••',
                      obscureText: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, size: 18),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                      validator: (v) {
                        if (v != _passwordController.text) return 'Las contraseñas no coinciden';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Checkbox Términos y Condiciones
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _aceptaTerminos,
                              activeColor: AppColors.navyBlue,
                              onChanged: (val) => setState(() => _aceptaTerminos = val ?? false),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'He leído y acepto los Términos y Condiciones de uso del sistema del Gimnasio D.U.B.S. UAGRM.',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Botón de Registro
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: authState.isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: authState.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.badge_outlined, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Completar Registro Cliente',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Enlace a Iniciar Sesión
                    Center(
                      child: TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text(
                          '¿Ya tienes cuenta registrada? Iniciar Sesión',
                          style: TextStyle(color: AppColors.navyBlue, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.navyBlue, width: 1.5),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
