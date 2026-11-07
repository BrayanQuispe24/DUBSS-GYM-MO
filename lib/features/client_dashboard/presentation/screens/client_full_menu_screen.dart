import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../rutinas/presentation/providers/rutinas_provider.dart';

class ClientFullMenuScreen extends ConsumerWidget {
  final int currentTabIndex;
  final ValueChanged<int> onSelectTab;

  const ClientFullMenuScreen({
    super.key,
    required this.currentTabIndex,
    required this.onSelectTab,
  });

  String _getInitials(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return 'GU';
    final parts = clean.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return clean.substring(0, clean.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    final displayName = user?.nombreCompleto ?? 'Usuario UAGRM';
    final initials = _getInitials(displayName);
    final roleName = (user?.tipoUsuario != null && user!.tipoUsuario.isNotEmpty)
        ? 'CLIENTE ${user.tipoUsuario.toUpperCase()}'
        : 'CLIENTE UNIVERSITARIO';

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with branding & Close button
            _buildTopBar(context),

            // Scrollable Menu Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Profile Card
                    _buildUserProfileCard(
                      context: context,
                      initials: initials,
                      displayName: displayName,
                      roleName: roleName,
                      email: user?.email ?? 'estudiante@uagrm.edu.bo',
                    ),

                    const SizedBox(height: 24),

                    // Section: MÓDULOS PRINCIPALES
                    _buildSectionTitle('MÓDULOS PRINCIPALES'),
                    const SizedBox(height: 10),
                    _buildQuickAccessGrid(context),

                    const SizedBox(height: 24),

                    // Section: DEPORTE & ENTRENAMIENTO
                    _buildSectionTitle('DEPORTE & ENTRENAMIENTO'),
                    const SizedBox(height: 10),
                    _buildModuleTile(
                      context: context,
                      icon: Icons.format_list_bulleted,
                      title: 'Catálogo de Ejercicios',
                      subtitle: 'Biblioteca anatómica, posturas y técnicas de ejecución',
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push('/client/ejercicios');
                      },
                    ),
                    _buildModuleTile(
                      context: context,
                      icon: Icons.dashboard_customize_outlined,
                      title: 'Planes de Entrenamiento',
                      subtitle: 'Programas de fuerza, hipertrofia y acondicionamiento',
                      onTap: () {
                        Navigator.of(context).pop();
                        ref.read(planSeleccionadoProvider.notifier).seleccionarPlan(null);
                        onSelectTab(1);
                      },
                    ),
                    _buildModuleTile(
                      context: context,
                      icon: Icons.restaurant_menu_outlined,
                      title: 'Planes de Nutrición',
                      subtitle: 'Guías alimentarias, macronutrientes y recomendaciones con IA',
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push('/client/nutricion');
                      },
                    ),

                    const SizedBox(height: 24),

                    // Section: TRÁMITES & OPERACIONES
                    _buildSectionTitle('TRÁMITES & OPERACIONES'),
                    const SizedBox(height: 10),
                    _buildModuleTile(
                      context: context,
                      icon: Icons.sports_basketball_outlined,
                      title: 'Disciplinas & Horarios',
                      subtitle: 'Disponibilidad de sala, instructores y turnos',
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push('/client/disciplinas');
                      },
                    ),
                    _buildModuleTile(
                      context: context,
                      icon: Icons.medical_services_outlined,
                      title: 'Historial Clínico & Físico',
                      subtitle: 'Mediciones antropométricas, bioimpedancia y evolución',
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push('/client/historial-clinico');
                      },
                    ),
                    _buildModuleTile(
                      context: context,
                      icon: Icons.folder_shared_outlined,
                      title: 'Documentación Digital',
                      subtitle: 'Fichas médicas, contratos y constancias de pago',
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push('/client/documentos');
                      },
                    ),

                    const SizedBox(height: 24),

                    // Section: SEGURIDAD Y AUDITORÍA
                    _buildSectionTitle('SEGURIDAD Y AUDITORÍA'),
                    const SizedBox(height: 10),
                    _buildModuleTile(
                      context: context,
                      icon: Icons.warning_amber_rounded,
                      title: 'Denuncias y Reportes',
                      subtitle: 'Canal seguro para reportes de conducta o incidencias',
                      onTap: () => _showComingSoon(context, 'Denuncias y Reportes'),
                    ),
                    _buildModuleTile(
                      context: context,
                      icon: Icons.settings_outlined,
                      title: 'Configuración del Sistema',
                      subtitle: 'Preferencias, notificaciones y privacidad',
                      onTap: () => _showComingSoon(context, 'Configuración del Sistema'),
                    ),

                    const SizedBox(height: 32),

                    // Logout Button
                    _buildLogoutButton(context, ref),

                    const SizedBox(height: 18),

                    // Footer branding
                    Center(
                      child: Text(
                        'D.U.B.S.S. GIMNASIO UAGRM • v1.0.0',
                        style: TextStyle(
                          color: const Color(0xFF64748B).withValues(alpha: 0.8),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(
          bottom: BorderSide(color: Color(0xFF1E293B), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0077D4), Color(0xFF0284C7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0077D4).withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'GIMNASIO UAGRM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'D.U.B.S.S. SYSTEM • MENÚ PRINCIPAL',
                  style: TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          // Close button
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF334155), width: 1),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileCard({
    required BuildContext context,
    required String initials,
    required String displayName,
    required String roleName,
    required String email,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0B132B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0077D4), Color(0xFF38BDF8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0077D4).withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF16A34A), width: 0.8),
                      ),
                      child: const Text(
                        'Activo',
                        style: TextStyle(
                          color: Color(0xFF4ADE80),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  roleName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.9,
        ),
      ),
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context) {
    final quickItems = [
      _QuickItem(
        index: 0,
        title: 'Planes y Tarifas',
        icon: Icons.diamond_outlined,
        color: const Color(0xFF0284C7),
      ),
      _QuickItem(
        index: -1,
        title: 'Ejercicios',
        icon: Icons.fitness_center,
        color: const Color(0xFF2563EB),
      ),
      _QuickItem(
        index: 1,
        title: 'Rutinas',
        icon: Icons.view_timeline_outlined,
        color: const Color(0xFF10B981),
      ),
      _QuickItem(
        index: -2,
        title: 'Nutrición IA',
        icon: Icons.restaurant_menu,
        color: const Color(0xFF06B6D4),
      ),
      _QuickItem(
        index: 2,
        title: 'Trámites y Pagos',
        icon: Icons.receipt_long_outlined,
        color: const Color(0xFFF59E0B),
      ),
      _QuickItem(
        index: 3,
        title: 'Mi Perfil',
        icon: Icons.person_outline,
        color: const Color(0xFF8B5CF6),
      ),
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: quickItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.7,
      ),
      itemBuilder: (ctx, i) {
        final item = quickItems[i];
        final isSelected = currentTabIndex == item.index;

        return InkWell(
          onTap: () {
            Navigator.of(context).pop();
            if (item.index == -1) {
              context.push('/client/ejercicios');
            } else if (item.index == -2) {
              context.push('/client/nutricion');
            } else {
              onSelectTab(item.index);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF0077D4).withValues(alpha: 0.2)
                  : const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF334155),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: item.color.withValues(alpha: 0.3)),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFFE2E8F0),
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(height: 2),
                        const Text(
                          'En pantalla',
                          style: TextStyle(
                            color: Color(0xFF38BDF8),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModuleTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334155), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          onTap: onTap,
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          leading: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Icon(icon, color: const Color(0xFF38BDF8), size: 18),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Color(0xFFF1F5F9),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 11,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Color(0xFF64748B),
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => _confirmLogout(context, ref),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF450A0A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF991B1B), width: 1),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Color(0xFFF87171), size: 18),
            SizedBox(width: 8),
            Text(
              'Cerrar Sesión Segura',
              style: TextStyle(
                color: Color(0xFFFCA5A5),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String module) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$module estará disponible en la próxima actualización.'),
        backgroundColor: const Color(0xFF0077D4),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Cerrar Sesión',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          '¿Está seguro de que desea salir del sistema UAGRM?',
          style: TextStyle(color: Color(0xFFCBD5E1)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close full screen menu
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) {
                context.go('/');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Salir', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _QuickItem {
  final int index;
  final String title;
  final IconData icon;
  final Color color;

  _QuickItem({
    required this.index,
    required this.title,
    required this.icon,
    required this.color,
  });
}
