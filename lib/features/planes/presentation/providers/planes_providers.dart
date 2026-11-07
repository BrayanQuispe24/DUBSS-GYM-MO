import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/planes_remote_datasource.dart';
import '../../data/models/plan_model.dart';

/// Provider que obtiene la lista de planes desde el backend
final planesListProvider = FutureProvider.autoDispose<List<PlanModel>>((ref) async {
  final dataSource = ref.watch(planesRemoteDataSourceProvider);
  return dataSource.getPlanes();
});

/// Notifier para el filtro activo de planes
class PlanFilterNotifier extends Notifier<String> {
  @override
  String build() => 'todos';

  void setFilter(String filter) {
    state = filter;
  }
}

final planFilterProvider =
    NotifierProvider<PlanFilterNotifier, String>(PlanFilterNotifier.new);

/// Lista filtrada según la pestaña/chip seleccionado
final filteredPlanesProvider = Provider.autoDispose<AsyncValue<List<PlanModel>>>((ref) {
  final planesAsync = ref.watch(planesListProvider);
  final filter = ref.watch(planFilterProvider).toLowerCase();

  return planesAsync.whenData((planes) {
    if (filter == 'todos') return planes;
    return planes.where((p) {
      final name = p.nombre.toLowerCase();
      final tarifa = p.tarifa?.nombre.toLowerCase() ?? '';
      return name.contains(filter) || tarifa.contains(filter);
    }).toList();
  });
});
