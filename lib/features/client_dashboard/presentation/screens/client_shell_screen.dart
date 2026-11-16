import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../../planes/presentation/screens/client_planes_screen.dart';
import '../../../rutinas/presentation/screens/client_rutinas_screen.dart';
import '../../../tramites/presentation/screens/client_tramites_screen.dart';
import 'client_full_menu_screen.dart';
import 'client_profile_screen.dart';

class ClientShellScreen extends ConsumerStatefulWidget {
  const ClientShellScreen({super.key});

  @override
  ConsumerState<ClientShellScreen> createState() => _ClientShellScreenState();
}

class _ClientShellScreenState extends ConsumerState<ClientShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ClientPlanesScreen(),
    ClientRutinasScreen(),
    ClientTramitesScreen(),
    ClientProfileScreen(),
  ];

  void _openFullScreenMenu(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return ClientFullMenuScreen(
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
          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.unauthenticated) {
        if (mounted) {
          context.go('/login');
        }
      }
    });

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.carbonSurfaceMuted,
          border: Border(
            top: BorderSide(color: AppColors.borderSubtle, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                // Tab 0: Planes
                Expanded(
                  child: _buildBottomNavItem(
                    index: 0,
                    icon: Icons.diamond_outlined,
                    activeIcon: Icons.diamond,
                    label: 'Planes',
                  ),
                ),
                // Tab 1: Rutinas
                Expanded(
                  child: _buildBottomNavItem(
                    index: 1,
                    icon: Icons.fitness_center_outlined,
                    activeIcon: Icons.fitness_center,
                    label: 'Rutinas',
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
                    activeIcon: Icons.receipt_long,
                    label: 'Trámites',
                  ),
                ),
                // Tab 3: Perfil
                Expanded(
                  child: _buildBottomNavItem(
                    index: 3,
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: 'Perfil',
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
    final color = isSelected ? AppColors.accentVibrant : AppColors.textSlateMuted;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      splashColor: AppColors.accentVibrant.withValues(alpha: 0.1),
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
      splashColor: AppColors.accentVibrant.withValues(alpha: 0.15),
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.crimsonGradient,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accentVibrant, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentVibrant.withValues(alpha: 0.35),
                  blurRadius: 8,
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
              color: AppColors.accentVibrant,
            ),
          ),
        ],
      ),
    );
  }


}
