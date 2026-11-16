import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/crimson_button.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';

class ClientProfileScreen extends ConsumerWidget {
  const ClientProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    final displayName = user?.nombreCompleto ?? 'Usuario UAGRM';
    final email = user?.email ?? 'cliente@uagrm.edu.bo';
    final ru = user?.registroUniversitario ?? '218000000';
    final ci = user?.ci ?? '8943210';
    final role = user?.tipoUsuario != null && user!.tipoUsuario.isNotEmpty
        ? 'CLIENTE ${user.tipoUsuario.toUpperCase()}'
        : 'CLIENTE UNIVERSITARIO';

    return Scaffold(
      backgroundColor: AppColors.obsidianBase,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Credencial Digital Card Oficial
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.carbonSurface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryCrimson.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GIMNASIO UAGRM',
                            style: TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'CREDENCIAL DIGITAL D.U.B.S.',
                            style: TextStyle(
                              color: AppColors.solarGold,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.successEmerald.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.successEmerald, width: 0.8),
                        ),
                        child: const Text(
                          'ACTIVO',
                          style: TextStyle(
                            color: AppColors.successLight,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: AppColors.crimsonGradient,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.accentVibrant, width: 1.0),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          displayName.length >= 2
                              ? displayName.substring(0, 2).toUpperCase()
                              : 'GU',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              role,
                              style: const TextStyle(
                                color: AppColors.solarGold,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.carbonSurfaceMuted,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'R.U.: $ru',
                          style: const TextStyle(
                            color: AppColors.textSlateLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'C.I.: $ci',
                          style: const TextStyle(
                            color: AppColors.textSlateLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick Access QR Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.carbonSurface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.borderSubtle, width: 1.0),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primaryCrimson,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.accentVibrant, width: 1.0),
                        ),
                        child: const Icon(Icons.qr_code, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'PASE QR DE INGRESO A GARITA',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 160,
                    height: 160,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white, // Blanco para lectura óptica QR por torniquete
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                    ),
                    child: const Icon(
                      Icons.qr_code_2,
                      size: 140,
                      color: Color(0xFF0B0B0D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Presenta este código en el molinete de acceso',
                    style: TextStyle(fontSize: 11, color: AppColors.textSlateMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Profile Info Details
            Container(
              decoration: BoxDecoration(
                color: AppColors.carbonSurface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.borderSubtle, width: 1.0),
              ),
              child: Column(
                children: [
                  _buildDetailTile(Icons.email_outlined, 'Correo Electrónico', email),
                  const Divider(height: 1),
                  _buildDetailTile(Icons.badge_outlined, 'Registro Universitario', ru),
                  const Divider(height: 1),
                  _buildDetailTile(Icons.pin_outlined, 'Cédula de Identidad', ci),
                  const Divider(height: 1),
                  _buildDetailTile(Icons.phone_outlined, 'Teléfono de Contacto', user?.telefono ?? 'No registrado'),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Cerrar Sesión Button
            SizedBox(
              width: double.infinity,
              child: CrimsonButton(
                onPressed: () async {
                  await ref.read(authNotifierProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/');
                  }
                },
                icon: const Icon(Icons.logout, size: 16, color: AppColors.accentVibrant),
                label: 'Cerrar Sesión',
                style: CrimsonButtonStyle.outline,
                height: 44,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value) {
    return ListTile(
      dense: true,
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.carbonSurfaceMuted,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.borderSubtle, width: 1.0),
        ),
        child: Icon(icon, color: AppColors.accentVibrant, size: 18),
      ),
      title: Text(
        label,
        style: const TextStyle(fontSize: 11, color: AppColors.textSlateMuted, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 13, color: AppColors.textWhite, fontWeight: FontWeight.w700),
      ),
    );
  }
}
