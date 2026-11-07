import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';

class ClientDrawerWidget extends ConsumerWidget {
  final int currentTabIndex;
  final ValueChanged<int> onSelectTab;

  const ClientDrawerWidget({
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

    final displayName = user?.nombreCompleto ?? 'mama mama';
    final initials = _getInitials(displayName);
    final roleName = (user?.tipoUsuario != null && user!.tipoUsuario.isNotEmpty)
        ? 'CLIENTE ${user.tipoUsuario.toUpperCase()}'
        : 'CLIENTE UNIVERSITARIO';

    return Drawer(
      backgroundColor: const Color(0xFF0F172A), // Dark navy sidebar theme matching web
      child: SafeArea(
        child: Column(
          children: [
            // Header: GIMNASIO UAGRM D.U.B.S.S. SYSTEM
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFF1E293B)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0077D4),
                      borderRadius: BorderRadius.circular(8),
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
                      children: [
                        Text(
                          'GIMNASIO UAGRM',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'D.U.B.S.S. SYSTEM',
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
                ],
              ),
            ),

            // Navigation Menu List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // MÓDULOS PRINCIPALES
                  _buildSectionHeader('MÓDULOS PRINCIPALES'),
                  _buildMenuItem(
                    icon: Icons.diamond_outlined,
                    label: 'Planes y Tarifas',
                    isSelected: currentTabIndex == 0,
                    onTap: () {
                      Navigator.pop(context);
                      onSelectTab(0);
                    },
                  ),

                  const SizedBox(height: 12),
                  // DEPORTE & ENTRENAMIENTO
                  _buildSectionHeader('DEPORTE & ENTRENAMIENTO'),
                  _buildMenuItem(
                    icon: Icons.format_list_bulleted,
                    label: 'Catálogo Ejercicios',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/client/ejercicios');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.view_timeline_outlined,
                    label: 'Rutinas Deportivas',
                    isSelected: currentTabIndex == 1,
                    onTap: () {
                      Navigator.pop(context);
                      onSelectTab(1);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.dashboard_customize_outlined,
                    label: 'Planes Entrenamiento',
                    isSelected: currentTabIndex == 1,
                    onTap: () {
                      Navigator.pop(context);
                      onSelectTab(1);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.restaurant_menu_outlined,
                    label: 'Planes Nutrición',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      _showComingSoon(context, 'Planes de Nutrición');
                    },
                  ),

                  const SizedBox(height: 12),
                  // TRÁMITES & OPERACIONES
                  _buildSectionHeader('TRÁMITES & OPERACIONES'),
                  _buildMenuItem(
                    icon: Icons.receipt_long_outlined,
                    label: 'Trámites y Pagos',
                    isSelected: currentTabIndex == 2,
                    onTap: () {
                      Navigator.pop(context);
                      onSelectTab(2);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.sports_basketball_outlined,
                    label: 'Disciplinas & Horarios',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/client/disciplinas');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.medical_services_outlined,
                    label: 'Historial Clínico',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/client/historial-clinico');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.folder_shared_outlined,
                    label: 'Documentación Digital',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/client/documentos');
                    },
                  ),

                  const SizedBox(height: 12),
                  // SEGURIDAD Y AUDITORÍA
                  _buildSectionHeader('SEGURIDAD Y AUDITORÍA'),
                  _buildMenuItem(
                    icon: Icons.warning_amber_rounded,
                    label: 'Denuncias y Reportes',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      _showComingSoon(context, 'Denuncias y Reportes');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    label: 'Configuración Sistema',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      _showComingSoon(context, 'Configuración del Sistema');
                    },
                  ),
                ],
              ),
            ),

            // User Profile Card at Bottom (Exact replica of screenshot footer)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Color(0xFF0B1120),
                border: Border(
                  top: BorderSide(color: Color(0xFF1E293B)),
                ),
              ),
              child: Row(
                children: [
                  // MM Avatar
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0077D4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          roleName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF38BDF8),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Color(0xFFF87171), size: 20),
                    tooltip: 'Cerrar Sesión',
                    onPressed: () => _confirmLogout(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF0077D4) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListTile(
        dense: true,
        visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
        leading: Icon(
          icon,
          size: 18,
          color: isSelected ? Colors.white : const Color(0xFF94A3B8),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String module) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$module estará disponible en la próxima actualización.'),
        backgroundColor: const Color(0xFF0077D4),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Está seguro de que desea salir del sistema UAGRM?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) {
                context.go('/');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
            child: const Text('Salir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
