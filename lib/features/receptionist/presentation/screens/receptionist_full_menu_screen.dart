import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';

class ReceptionistFullMenuScreen extends ConsumerWidget {
  final int currentTabIndex;
  final ValueChanged<int> onSelectTab;

  const ReceptionistFullMenuScreen({
    super.key,
    required this.currentTabIndex,
    required this.onSelectTab,
  });

  String _getInitials(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return 'RP';
    final parts = clean.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return clean.substring(0, clean.length >= 2 ? 2 : 1).toUpperCase();
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final bool confirmar = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.carbonSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: const BorderSide(color: AppColors.borderSubtle),
            ),
            title: const Text(
              '¿Cerrar Sesión?',
              style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w800),
            ),
            content: const Text(
              '¿Está seguro de cerrar la sesión del personal del gimnasio?',
              style: TextStyle(color: AppColors.textSlateLight),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar', style: TextStyle(color: AppColors.textSlateMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryCrimson,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Cerrar Sesión'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmar || !context.mounted) return;

    final router = GoRouter.of(context);
    Navigator.of(context).pop(); // Cierra el menú full screen

    await ref.read(authNotifierProvider.notifier).logout();
    router.go('/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    final displayName = user?.nombreCompleto ??
        (user?.name.isNotEmpty == true ? user!.name : 'Personal DUBSS');
    final initials = _getInitials(displayName);
    final isAdmin = user?.rol.toLowerCase() == 'administrador';
    final roleName = '${user?.rol.toUpperCase() ?? 'STAFF'} DUBSS UAGRM';

    return Scaffold(
      backgroundColor: AppColors.obsidianBase,
      body: SafeArea(
        child: Column(
          children: [
            // Barra superior con branding y botón de cerrar
            _buildTopBar(context),

            // Contenido desplazable del Menú
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tarjeta de perfil del personal
                    _buildUserProfileCard(
                      context: context,
                      initials: initials,
                      displayName: displayName,
                      roleName: roleName,
                      email: user?.email ?? 'personal@uagrm.edu.bo',
                      isAdmin: isAdmin,
                    ),

                    const SizedBox(height: 24),

                    // Sección: Módulos de Acceso Rápido (Tabs principales)
                    _buildSectionTitle('MÓDULOS PRINCIPALES'),
                    const SizedBox(height: 10),
                    _buildQuickAccessGrid(context),

                    const SizedBox(height: 24),

                    // Sección: Administración & Operaciones
                    _buildSectionTitle('ADMINISTRACIÓN & GESTIÓN'),
                    const SizedBox(height: 10),
                    _buildModuleTile(
                      context: context,
                      icon: Icons.card_membership_rounded,
                      title: 'Planes y Tarifas',
                      subtitle:
                          'Configuración de membresías, precios y periodos',
                      color: AppColors.solarGold,
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push('/receptionist/planes');
                      },
                    ),
                    _buildModuleTile(
                      context: context,
                      icon: Icons.sports_gymnastics_rounded,
                      title: 'Disciplinas y Horarios',
                      subtitle:
                          'Programación de clases, salas e instructores',
                      color: AppColors.accentVibrant,
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push('/receptionist/disciplinas');
                      },
                    ),
                    _buildModuleTile(
                      context: context,
                      icon: Icons.meeting_room_outlined,
                      title: 'Ambientes y Espacios',
                      subtitle:
                          'Capacidad, estado y disponibilidad de áreas',
                      color: AppColors.solarAmber,
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push('/receptionist/ambientes');
                      },
                    ),
                    _buildModuleTile(
                      context: context,
                      icon: Icons.fitness_center_rounded,
                      title: 'Inventario de Equipos',
                      subtitle:
                          'Control de máquinas, estado y mantenimiento',
                      color: AppColors.primaryCrimson,
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push('/receptionist/equipos');
                      },
                    ),

                    if (isAdmin || user?.rol == 'instructor') ...[
                      const SizedBox(height: 24),
                      _buildSectionTitle('CAMBIO DE PERSPECTIVA'),
                      const SizedBox(height: 10),
                      _buildModuleTile(
                        context: context,
                        icon: Icons.switch_account_outlined,
                        title: 'Vista Cliente Socio',
                        subtitle:
                            'Navegar la app como estudiante o socio regular',
                        color: AppColors.accentVibrant,
                        onTap: () {
                          Navigator.of(context).pop();
                          context.go('/client');
                        },
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Botón de Cerrar Sesión
                    _buildLogoutButton(context, ref),

                    const SizedBox(height: 18),

                    // Pie de página
                    Center(
                      child: Text(
                        'D.U.B.S.S. GIMNASIO UAGRM • PANEL STAFF v1.0.0',
                        style: TextStyle(
                          color: AppColors.textSlateMuted.withValues(alpha: 0.8),
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
        color: AppColors.carbonSurface,
        border: Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryCrimson, AppColors.accentVibrant],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.accentVibrant.withValues(alpha: 0.4)),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
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
                  'PANEL DE CONTROL',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'D.U.B.S.S. • STAFF & ENTRENAMIENTO',
                  style: TextStyle(
                    color: AppColors.solarGold,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          // Botón cerrar
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.carbonSurfaceMuted,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.borderSubtle, width: 1),
              ),
              child: const Icon(
                Icons.close,
                color: AppColors.textWhite,
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
    required bool isAdmin,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.carbonSurface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isAdmin
                    ? [AppColors.solarGold, AppColors.solarAmber]
                    : [AppColors.primaryCrimson, AppColors.accentVibrant],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: TextStyle(
                color: isAdmin ? Colors.black : Colors.white,
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
                          color: AppColors.textWhite,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.successEmerald.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: AppColors.successEmerald.withValues(alpha: 0.4), width: 0.8),
                      ),
                      child: const Text(
                        'En Turno',
                        style: TextStyle(
                          color: AppColors.successLight,
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
                    color: AppColors.solarGold,
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
                    color: AppColors.textSlateLight,
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
          color: AppColors.textSlateMuted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.9,
        ),
      ),
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context) {
    final quickItems = [
      _StaffQuickItem(
        index: 0,
        title: 'Inicio Dashboard',
        icon: Icons.dashboard_rounded,
        color: AppColors.accentVibrant,
      ),
      _StaffQuickItem(
        index: 1,
        title: 'Garita de Acceso',
        icon: Icons.qr_code_scanner_rounded,
        color: AppColors.successEmerald,
      ),
      _StaffQuickItem(
        index: 2,
        title: 'Trámites y Pagos',
        icon: Icons.receipt_long_rounded,
        color: AppColors.solarAmber,
      ),
      _StaffQuickItem(
        index: 3,
        title: 'Gestión Usuarios',
        icon: Icons.groups_rounded,
        color: AppColors.solarGold,
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
            onSelectTab(item.index);
          },
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryCrimson.withValues(alpha: 0.25)
                  : AppColors.carbonSurface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isSelected
                    ? AppColors.accentVibrant
                    : AppColors.borderSubtle,
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
                    borderRadius: BorderRadius.circular(4),
                    border:
                        Border.all(color: item.color.withValues(alpha: 0.3)),
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
                          color: isSelected
                              ? AppColors.textWhite
                              : AppColors.textSlateLight,
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(height: 2),
                        const Text(
                          'En pantalla',
                          style: TextStyle(
                            color: AppColors.solarGold,
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
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.carbonSurface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: ListTile(
          onTap: onTap,
          dense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          leading: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSlateMuted,
              fontSize: 11,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.textSlateMuted,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _handleLogout(context, ref),
        icon: const Icon(Icons.logout_rounded, color: AppColors.accentVibrant, size: 18),
        label: const Text(
          'Cerrar Sesión de Personal',
          style: TextStyle(
            color: AppColors.accentVibrant,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.accentVibrant, width: 1.2),
          backgroundColor: AppColors.primaryCrimson.withValues(alpha: 0.12),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class _StaffQuickItem {
  final int index;
  final String title;
  final IconData icon;
  final Color color;

  _StaffQuickItem({
    required this.index,
    required this.title,
    required this.icon,
    required this.color,
  });
}
