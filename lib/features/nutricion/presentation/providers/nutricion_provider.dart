import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../data/datasources/nutricion_remote_datasource.dart';
import '../../data/models/plan_alimentacion_model.dart';

/// Provider que obtiene todos los planes de alimentación del backend
final planesAlimentacionProvider =
    FutureProvider<List<PlanAlimentacionModel>>((ref) async {
  final dataSource = ref.watch(nutricionRemoteDataSourceProvider);
  return await dataSource.getPlanesAlimentacion();
});

/// Filtro de visualización: 'activos', 'todos'
class FiltroEstadoPlanNotifier extends Notifier<String> {
  @override
  String build() => 'activos';

  void setFiltro(String filtro) {
    state = filtro;
  }
}

final filtroEstadoPlanProvider =
    NotifierProvider<FiltroEstadoPlanNotifier, String>(FiltroEstadoPlanNotifier.new);

/// Provider de búsqueda por texto (nombre, objetivo, usuario)
class SearchNutricionNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setSearch(String query) {
    state = query;
  }
}

final searchNutricionProvider =
    NotifierProvider<SearchNutricionNotifier, String>(SearchNutricionNotifier.new);

/// Provider que filtra los planes según el rol del usuario autenticado y filtros seleccionados
final misPlanesAlimentacionFiltradosProvider =
    Provider<AsyncValue<List<PlanAlimentacionModel>>>((ref) {
  final planesAsync = ref.watch(planesAlimentacionProvider);
  final authState = ref.watch(authNotifierProvider);
  final currentUser = authState.user;
  final filtroEstado = ref.watch(filtroEstadoPlanProvider);
  final searchQuery = ref.watch(searchNutricionProvider).trim().toLowerCase();

  return planesAsync.whenData((planes) {
    var filtered = planes;

    // Si es cliente, filtrar principalmente los suyos
    if (currentUser != null && currentUser.rol == 'cliente') {
      filtered = filtered.where((p) => p.idUsuario == currentUser.id).toList();
    }

    // Filtrar por estado si aplica
    if (filtroEstado == 'activos') {
      filtered = filtered.where((p) => p.estado).toList();
    }

    // Filtrar por búsqueda de texto
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((p) {
        final matchesNombre = p.nombre.toLowerCase().contains(searchQuery);
        final matchesObjetivo = p.objetivo?.toLowerCase().contains(searchQuery) ?? false;
        final matchesUser = p.usuarioNombre.toLowerCase().contains(searchQuery);
        return matchesNombre || matchesObjetivo || matchesUser;
      }).toList();
    }

    return filtered;
  });
});

/// Plan actualmente seleccionado para ver en detalle
final planNutricionalSeleccionadoProvider =
    NotifierProvider<PlanNutricionalSeleccionadoNotifier, PlanAlimentacionModel?>(
  PlanNutricionalSeleccionadoNotifier.new,
);

class PlanNutricionalSeleccionadoNotifier extends Notifier<PlanAlimentacionModel?> {
  @override
  PlanAlimentacionModel? build() => null;

  void seleccionar(PlanAlimentacionModel? plan) {
    state = plan;
  }
}
