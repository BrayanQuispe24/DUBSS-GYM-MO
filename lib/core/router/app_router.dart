import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/auth/presentation/providers/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/landing/presentation/screens/landing_screen.dart';

import '../../features/client_dashboard/presentation/screens/client_shell_screen.dart';
import '../../features/ejercicios/presentation/screens/client_ejercicios_screen.dart';
import '../../features/rutinas/presentation/screens/client_rutinas_screen.dart';
import '../../features/tramites/presentation/screens/client_tramites_screen.dart';
import '../../features/tramites/presentation/screens/escaner_qr_screen.dart';

import '../../features/disciplinas/presentation/screens/client_disciplinas_screen.dart';
import '../../features/documentos/presentation/screens/client_documentos_screen.dart';
import '../../features/historial_clinico/presentation/screens/historial_clinico_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';

import '../../features/receptionist/presentation/screens/receptionist_shell_screen.dart';
import '../../features/receptionist/presentation/screens/recepcion_tramites_screen.dart';
import '../../features/garita_accesos/presentation/screens/garita_screen.dart';
import '../../features/users_admin/presentation/screens/users_list_screen.dart';
import '../../features/users_admin/presentation/screens/user_detail_screen.dart';
import '../../features/planes_admin/presentation/screens/planes_tarifas_admin_screen.dart';
import '../../features/disciplinas_admin/presentation/screens/disciplinas_admin_screen.dart';
import '../../features/inventario/presentation/screens/ambientes_screen.dart';
import '../../features/inventario/presentation/screens/equipos_screen.dart';
import '../../features/nutricion/presentation/screens/client_nutricion_screen.dart';
import '../../features/nutricion/presentation/screens/generar_plan_nutricional_screen.dart';
import '../../features/nutricion/presentation/screens/plan_nutricional_detail_screen.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authNotifierProvider,
      (_, _) => notifyListeners(),
    );
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final auth = ref.read(authNotifierProvider);
      final isAuth =
          auth.status == AuthStatus.authenticated && auth.user != null;
      final path = state.matchedLocation;

      // Rutas públicas que no requieren autenticación
      if (path == '/splash' ||
          path == '/' ||
          path == '/login' ||
          path == '/register') {
        return null;
      }

      // Si intenta acceder a rutas privadas sin estar autenticado
      if (!isAuth) {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'landing',
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/client',
        name: 'client',
        builder: (context, state) => const ClientShellScreen(),
      ),
      GoRoute(
        path: '/client/ejercicios',
        name: 'client-ejercicios',
        builder: (context, state) => const ClientEjerciciosScreen(),
      ),
      GoRoute(
        path: '/client/rutinas',
        name: 'client-rutinas',
        builder: (context, state) => const ClientRutinasScreen(),
      ),
      GoRoute(
        path: '/client/disciplinas',
        name: 'client-disciplinas',
        builder: (context, state) => const ClientDisciplinasScreen(),
      ),
      GoRoute(
        path: '/client/historial-clinico',
        name: 'client-historial-clinico',
        builder: (context, state) => const HistorialClinicoScreen(),
      ),
      GoRoute(
        path: '/client/tramites',
        name: 'client-tramites',
        builder: (context, state) => const ClientTramitesScreen(),
      ),
      GoRoute(
        path: '/client/escaner-qr',
        name: 'client-escaner-qr',
        builder: (context, state) => const EscanerQRScreen(),
      ),
      GoRoute(
        path: '/client/documentos',
        name: 'client-documentos',
        builder: (context, state) => const ClientDocumentosScreen(),
      ),
      GoRoute(
        path: '/client/nutricion',
        name: 'client-nutricion',
        builder: (context, state) => const ClientNutricionScreen(),
      ),
      GoRoute(
        path: '/client/nutricion/generar-ia',
        name: 'client-nutricion-generar-ia',
        builder: (context, state) => const GenerarPlanNutricionalScreen(),
      ),
      GoRoute(
        path: '/client/nutricion/:id',
        name: 'client-nutricion-detail',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return PlanNutricionalDetailScreen(planId: id);
        },
      ),

      // Rutas Vista de Recepcionista
      GoRoute(
        path: '/receptionist',
        name: 'receptionist',
        builder: (context, state) => const ReceptionistShellScreen(),
      ),
      GoRoute(
        path: '/receptionist/garita',
        name: 'receptionist-garita',
        builder: (context, state) => const GaritaScreen(),
      ),
      GoRoute(
        path: '/receptionist/usuarios',
        name: 'receptionist-usuarios',
        builder: (context, state) => const UsersListScreen(),
      ),
      GoRoute(
        path: '/receptionist/usuarios/:id',
        name: 'receptionist-user-detail',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return UserDetailScreen(userId: id);
        },
      ),
      GoRoute(
        path: '/receptionist/tramites',
        name: 'receptionist-tramites',
        builder: (context, state) => const RecepcionTramitesScreen(),
      ),
      GoRoute(
        path: '/receptionist/planes',
        name: 'receptionist-planes',
        builder: (context, state) => const PlanesTarifasAdminScreen(),
      ),
      GoRoute(
        path: '/receptionist/disciplinas',
        name: 'receptionist-disciplinas',
        builder: (context, state) => const DisciplinasAdminScreen(),
      ),
      GoRoute(
        path: '/receptionist/ambientes',
        name: 'receptionist-ambientes',
        builder: (context, state) => const AmbientesScreen(),
      ),
      GoRoute(
        path: '/receptionist/equipos',
        name: 'receptionist-equipos',
        builder: (context, state) => const EquiposScreen(),
      ),
    ],
  );
});
