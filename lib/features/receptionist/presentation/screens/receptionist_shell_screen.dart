import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../garita_accesos/presentation/screens/garita_screen.dart';
import '../../../users_admin/presentation/screens/users_list_screen.dart';
import 'recepcion_tramites_screen.dart';
import 'receptionist_dashboard_screen.dart';
import 'receptionist_full_menu_screen.dart';

class ReceptionistShellScreen extends ConsumerStatefulWidget {
  const ReceptionistShellScreen({super.key});

  @override
  ConsumerState<ReceptionistShellScreen> createState() =>
      _ReceptionistShellScreenState();
}

class _ReceptionistShellScreenState
    extends ConsumerState<ReceptionistShellScreen> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  void _openFullScreenMenu(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return ReceptionistFullMenuScreen(
            currentTabIndex: _currentIndex,
            onSelectTab: (index) {
              setState(() => _currentIndex = index);
            },
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final bool confirmar = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: const Text('¿Cerrar Sesión?'),
            content: const Text(
              '¿Está seguro de cerrar la sesión de recepción del gimnasio?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Cerrar Sesión'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmar) return;

    await ref.read(authNotifierProvider.notifier).logout();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    final List<Widget> pages = [
      ReceptionistDashboardScreen(onSelectTab: _onTabSelected),
      const GaritaScreen(),
      const RecepcionTramitesScreen(),
      const UsersListScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: Drawer(
        child: Column(
          children: [
            // Header del Drawer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                  top: 50, bottom: 20, left: 20, right: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF003B70), Color(0xFF001C38)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFFD97706),
                    child: Text(
                      user?.nombre?.isNotEmpty == true
                          ? user!.nombre![0].toUpperCase()
                          : (user?.name.isNotEmpty == true
                              ? user!.name[0].toUpperCase()
                              : 'R'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.nombreCompleto ?? 'Personal de Recepción',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97706).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFD97706)),
                    ),
                    child: const Text(
                      'RECEPCIÓN DUBSS UAGRM',
                      style: TextStyle(
                        color: Color(0xFFFDE68A),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Opciones de los 7 módulos
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _drawerItem(
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard de Recepción',
                    onTap: () {
                      Navigator.of(context).pop();
                      _onTabSelected(0);
                    },
                  ),
                  _drawerItem(
                    icon: Icons.qr_code_scanner_rounded,
                    title: 'Garita de Acceso',
                    onTap: () {
                      Navigator.of(context).pop();
                      _onTabSelected(1);
                    },
                  ),
                  _drawerItem(
                    icon: Icons.groups_rounded,
                    title: 'Gestión de Usuarios',
                    onTap: () {
                      Navigator.of(context).pop();
                      _onTabSelected(3);
                    },
                  ),
                  _drawerItem(
                    icon: Icons.receipt_long_rounded,
                    title: 'Trámites y Pagos',
                    onTap: () {
                      Navigator.of(context).pop();
                      _onTabSelected(2);
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  _drawerItem(
                    icon: Icons.card_membership_rounded,
                    title: 'Planes y Tarifas',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/receptionist/planes');
                    },
                  ),
                  _drawerItem(
                    icon: Icons.sports_gymnastics_rounded,
                    title: 'Disciplinas y Horarios',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/receptionist/disciplinas');
                    },
                  ),
                  _drawerItem(
                    icon: Icons.meeting_room_outlined,
                    title: 'Ambientes y Espacios',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/receptionist/ambientes');
                    },
                  ),
                  _drawerItem(
                    icon: Icons.fitness_center_rounded,
                    title: 'Inventario de Equipos',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/receptionist/equipos');
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  if (user?.rol == 'administrador')
                    _drawerItem(
                      icon: Icons.switch_account_outlined,
                      title: 'Ver como Cliente Socio',
                      onTap: () {
                        Navigator.of(context).pop();
                        context.go('/client');
                      },
                    ),
                ],
              ),
            ),

            // Footer con Cerrar Sesión
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.danger),
              title: const Text(
                'Cerrar Sesión',
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _handleLogout();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          border: const Border(
            top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                // Tab 0: Inicio
                Expanded(
                  child: _buildBottomNavItem(
                    index: 0,
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard_rounded,
                    label: 'Inicio',
                  ),
                ),
                // Tab 1: Garita
                Expanded(
                  child: _buildBottomNavItem(
                    index: 1,
                    icon: Icons.door_sliding_outlined,
                    activeIcon: Icons.door_sliding_rounded,
                    label: 'Garita',
                  ),
                ),
                // Center Action Button: Menú en Pantalla Completa
                Expanded(
                  child: _buildCenterMenuButton(context),
                ),
                // Tab 2: Trámites
                Expanded(
                  child: _buildBottomNavItem(
                    index: 2,
                    icon: Icons.receipt_long_outlined,
                    activeIcon: Icons.receipt_long_rounded,
                    label: 'Trámites',
                  ),
                ),
                // Tab 3: Usuarios
                Expanded(
                  child: _buildBottomNavItem(
                    index: 3,
                    icon: Icons.groups_outlined,
                    activeIcon: Icons.groups_rounded,
                    label: 'Usuarios',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFF003B70) : const Color(0xFF64748B);

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      splashColor: const Color(0xFF003B70).withValues(alpha: 0.1),
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: color,
            size: 22,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterMenuButton(BuildContext context) {
    return InkWell(
      onTap: () => _openFullScreenMenu(context),
      splashColor: const Color(0xFF003B70).withValues(alpha: 0.15),
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF003B70), Color(0xFF0077D4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF003B70).withValues(alpha: 0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.grid_view_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Menú',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF003B70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF003B70), size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F172A),
        ),
      ),
      dense: true,
      onTap: onTap,
    );
  }
}
