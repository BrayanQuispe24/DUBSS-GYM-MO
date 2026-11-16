import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/crimson_button.dart';
import '../providers/auth_notifier.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authNotifierProvider.notifier).login(
          identifier: _identifierController.text.trim(),
          password: _passwordController.text,
        );

    if (success && mounted) {
      final user = ref.read(authNotifierProvider).user;
      final isStaffUser = user?.isStaff ?? false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isStaffUser
                ? '¡Bienvenido al Panel DUBSS (${user?.rol.toUpperCase()})!'
                : '¡Bienvenido al sistema DUBS UAGRM!',
          ),
          backgroundColor: AppColors.carbonSurfaceMuted,
        ),
      );

      if (isStaffUser) {
        context.go('/receptionist');
      } else {
        context.go('/client');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.obsidianBase,
      appBar: AppBar(
        backgroundColor: AppColors.obsidianBase,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: const Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => context.go('/'),
        ),
        title: const Text(
          'Portal UAGRM',
          style: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera Limpia & Sobria (sin ruido visual)
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryCrimson,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.accentVibrant, width: 1.0),
                        ),
                        child: const Icon(Icons.fitness_center, color: Colors.white, size: 26),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Gimnasio Universitario D.U.B.S. · UAGRM',
                        style: TextStyle(fontSize: 12, color: AppColors.textSlateMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Alerta de error si ocurre
                    if (authState.errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.accentVibrant.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.accentVibrant.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.accentVibrant, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                authState.errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.accentVibrant,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Campo: Correo o R.U.
                    const Text(
                      'Correo o Registro Universitario (R.U.)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _identifierController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'ejemplo@uagrm.edu.bo o 218000000',
                        hintStyle: const TextStyle(fontSize: 12, color: AppColors.textSlateMuted),
                        prefixIcon: const Icon(Icons.person_outline, size: 18, color: AppColors.textSlateMuted),
                        filled: true,
                        fillColor: AppColors.carbonSurfaceMuted,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length < 3) {
                          return 'Ingrese su correo o Registro Universitario';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo: Contraseña
                    const Text(
                      'Contraseña',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: const TextStyle(fontSize: 12, color: AppColors.textSlateMuted),
                        prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.textSlateMuted),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            size: 18,
                            color: AppColors.textSlateMuted,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: AppColors.carbonSurfaceMuted,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                      ),
                      validator: (value) {
                        if (value == null || value.length < 4) {
                          return 'La contraseña debe tener al menos 4 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Fila: Recordar sesión y Olvidó contraseña
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor: AppColors.primaryCrimson,
                                checkColor: Colors.white,
                                side: const BorderSide(color: AppColors.borderSubtle, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                                onChanged: (val) {
                                  setState(() {
                                    _rememberMe = val ?? true;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Recordar sesión',
                              style: TextStyle(fontSize: 12, color: AppColors.textSlateLight),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: AppColors.carbonSurface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  side: const BorderSide(color: AppColors.borderSubtle),
                                ),
                                title: const Text(
                                  'Recuperar Acceso',
                                  style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
                                ),
                                content: const Text(
                                  'Para recuperar su contraseña, comuníquese con el Centro de Cómputo DUBS o acérquese a las oficinas del gimnasio.',
                                  style: TextStyle(color: AppColors.textSlateLight, fontSize: 13),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text(
                                      'Entendido',
                                      style: TextStyle(color: AppColors.accentVibrant, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text(
                            '¿Olvidó su contraseña?',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentVibrant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Botón de Iniciar Sesión (Crimson Oficial)
                    SizedBox(
                      width: double.infinity,
                      child: CrimsonButton(
                        onPressed: authState.isLoading ? null : _handleLogin,
                        isLoading: authState.isLoading,
                        icon: const Icon(Icons.login, size: 16, color: Colors.white),
                        label: 'Iniciar Sesión',
                        style: CrimsonButtonStyle.gradient,
                        height: 46,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Banner de Registro para Clientes UAGRM (Carbon Boxed-Sharpness)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.carbonSurface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '¿Eres estudiante, docente o administrativo UAGRM?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSlateLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () => context.go('/register'),
                            borderRadius: BorderRadius.circular(4),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_add, color: AppColors.accentVibrant, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'Crear Cuenta de Cliente UAGRM',
                                    style: TextStyle(
                                      color: AppColors.accentVibrant,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Footer Institucional
                    const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shield_outlined, size: 14, color: AppColors.textSlateMuted),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Acceso Seguro • Universidad Autónoma Gabriel René Moreno',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textSlateMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }
