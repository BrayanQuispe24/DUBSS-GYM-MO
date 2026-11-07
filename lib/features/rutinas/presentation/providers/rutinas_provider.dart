import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../data/datasources/rutinas_remote_datasource.dart';
import '../../data/models/plan_entrenamiento_model.dart';
import '../../data/models/rutina_model.dart';

/// Proveedor para obtener los planes de entrenamiento asignados al usuario autenticado
final misPlanesUsuarioProvider =
    FutureProvider<List<PlanEntrenamientoModel>>((ref) async {
  final authState = ref.watch(authNotifierProvider);
  final user = authState.user;

  if (user == null) {
    return [];
  }

  final dataSource = ref.watch(rutinasRemoteDataSourceProvider);
  return dataSource.getPlanesUsuario(user.id);
});

/// Plan seleccionado por el usuario para ver su detalle (o null para ver la lista de planes)
class PlanSeleccionadoNotifier extends Notifier<PlanEntrenamientoModel?> {
  @override
  PlanEntrenamientoModel? build() => null;

  void seleccionarPlan(PlanEntrenamientoModel? plan) {
    state = plan;
  }
}

final planSeleccionadoProvider =
    NotifierProvider<PlanSeleccionadoNotifier, PlanEntrenamientoModel?>(
  PlanSeleccionadoNotifier.new,
);

/// Proveedor que retorna el plan activo del usuario (o el seleccionado)
final planActivoUsuarioProvider = Provider<PlanEntrenamientoModel?>((ref) {
  final seleccionado = ref.watch(planSeleccionadoProvider);
  if (seleccionado != null) return seleccionado;

  final planesAsync = ref.watch(misPlanesUsuarioProvider);
  return planesAsync.when(
    data: (planes) {
      if (planes.isEmpty) return null;
      // Retornar el primer plan marcado como activo, o el más reciente
      return planes.firstWhere((p) => p.estado, orElse: () => planes.first);
    },
    loading: () => null,
    error: (err, stack) => null,
  );
});

/// Notifier para el día seleccionado dentro del split semanal de rutinas
class DiaSeleccionadoNotifier extends Notifier<String?> {
  @override
  String? build() {
    final plan = ref.watch(planActivoUsuarioProvider);
    if (plan == null || plan.diasConfigurados.isEmpty) {
      return null;
    }

    // Detectar día actual de la semana en español para selección automática
    final diaHoy = _getNombreDiaSemanaHoy();
    for (final dia in plan.diasConfigurados) {
      if (dia.toLowerCase().contains(diaHoy.toLowerCase())) {
        return dia;
      }
    }

    // Fallback: primer día configurado
    return plan.diasConfigurados.first;
  }

  void seleccionarDia(String dia) {
    state = dia;
  }

  String _getNombreDiaSemanaHoy() {
    final now = DateTime.now();
    switch (now.weekday) {
      case DateTime.monday:
        return 'Lunes';
      case DateTime.tuesday:
        return 'Martes';
      case DateTime.wednesday:
        return 'Miércoles';
      case DateTime.thursday:
        return 'Jueves';
      case DateTime.friday:
        return 'Viernes';
      case DateTime.saturday:
        return 'Sábado';
      case DateTime.sunday:
        return 'Domingo';
      default:
        return 'Lunes';
    }
  }
}

final diaSeleccionadoProvider =
    NotifierProvider<DiaSeleccionadoNotifier, String?>(DiaSeleccionadoNotifier.new);

/// Rutina correspondiente al día seleccionado del plan activo
final rutinaDiaSeleccionadoProvider = Provider<RutinaModel?>((ref) {
  final plan = ref.watch(planActivoUsuarioProvider);
  final dia = ref.watch(diaSeleccionadoProvider);

  if (plan == null || dia == null) return null;
  return plan.rutinaPorDia(dia);
});

/// Proveedor del catálogo general de rutinas predefinidas
final rutinasCatalogoProvider = FutureProvider<List<RutinaModel>>((ref) async {
  final dataSource = ref.watch(rutinasRemoteDataSourceProvider);
  return dataSource.getRutinasCatalogo();
});

/// Filtro de nivel de dificultad para el catálogo
class RutinasNivelFilterNotifier extends Notifier<String> {
  @override
  String build() => 'todos';

  void setFilter(String nivel) {
    state = nivel;
  }
}

final rutinasNivelFilterProvider =
    NotifierProvider<RutinasNivelFilterNotifier, String>(RutinasNivelFilterNotifier.new);

/// Filtro de búsqueda por texto para el catálogo
class RutinasSearchFilterNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setSearch(String query) {
    state = query;
  }
}

final rutinasSearchFilterProvider =
    NotifierProvider<RutinasSearchFilterNotifier, String>(RutinasSearchFilterNotifier.new);

/// Catálogo filtrado por nivel de dificultad y término de búsqueda
final rutinasCatalogoFiltradasProvider = Provider<AsyncValue<List<RutinaModel>>>((ref) {
  final catalogoAsync = ref.watch(rutinasCatalogoProvider);
  final nivelFilter = ref.watch(rutinasNivelFilterProvider).toLowerCase().trim();
  final searchQuery = ref.watch(rutinasSearchFilterProvider).toLowerCase().trim();

  return catalogoAsync.whenData((rutinas) {
    return rutinas.where((r) {
      // Filtro por nivel
      if (nivelFilter != 'todos' && r.nivel.toLowerCase().trim() != nivelFilter) {
        return false;
      }

      // Filtro por búsqueda
      if (searchQuery.isNotEmpty) {
        final matchNombre = r.nombre.toLowerCase().contains(searchQuery);
        final matchDesc = r.descripcion?.toLowerCase().contains(searchQuery) ?? false;
        if (!matchNombre && !matchDesc) return false;
      }

      return true;
    }).toList();
  });
});
