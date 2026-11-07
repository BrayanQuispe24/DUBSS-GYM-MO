import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/disciplinas_remote_datasource.dart';
import '../../data/models/disciplina_horario_model.dart';
import '../../data/models/disciplina_model.dart';

/// Proveedor para listar todas las disciplinas deportivas
final disciplinasListProvider =
    FutureProvider<List<DisciplinaModel>>((ref) async {
  final dataSource = ref.watch(disciplinasRemoteDataSourceProvider);
  return dataSource.getDisciplinas();
});

/// Proveedor para listar todos los turnos horarios por disciplina
final disciplinasHorariosListProvider =
    FutureProvider<List<DisciplinaHorarioModel>>((ref) async {
  final dataSource = ref.watch(disciplinasRemoteDataSourceProvider);
  return dataSource.getDisciplinaHorarios();
});

/// Filtro de búsqueda textual
class DisciplinasSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setSearch(String query) => state = query;
}

final disciplinasSearchProvider =
    NotifierProvider<DisciplinasSearchNotifier, String>(
  DisciplinasSearchNotifier.new,
);

/// Filtro por disponibilidad ('todos', 'con_cupos', 'activas')
class DisciplinasDisponibilidadNotifier extends Notifier<String> {
  @override
  String build() => 'todos';

  void setFilter(String filter) => state = filter;
}

final disciplinasDisponibilidadProvider =
    NotifierProvider<DisciplinasDisponibilidadNotifier, String>(
  DisciplinasDisponibilidadNotifier.new,
);

/// Modo de visualización (0: Catálogo de Disciplinas, 1: Cronograma Semanal)
class DisciplinaVistaModoNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setModo(int modo) => state = modo;
}

final disciplinaVistaModoProvider =
    NotifierProvider<DisciplinaVistaModoNotifier, int>(
  DisciplinaVistaModoNotifier.new,
);

/// Día seleccionado para la vista de cronograma ('todos', 'Lunes', 'Martes', etc.)
class CronogramaDiaNotifier extends Notifier<String> {
  @override
  String build() => 'todos';

  void setDia(String dia) => state = dia;
}

final cronogramaDiaProvider =
    NotifierProvider<CronogramaDiaNotifier, String>(
  CronogramaDiaNotifier.new,
);

/// Disciplinas filtradas según búsqueda y disponibilidad
final disciplinasFiltradasProvider =
    Provider<AsyncValue<List<DisciplinaModel>>>((ref) {
  final disciplinasAsync = ref.watch(disciplinasListProvider);
  final search = ref.watch(disciplinasSearchProvider).toLowerCase().trim();
  final filtroDisp = ref.watch(disciplinasDisponibilidadProvider);

  return disciplinasAsync.whenData((disciplinas) {
    return disciplinas.where((d) {
      // Filtro de disponibilidad
      if (filtroDisp == 'con_cupos' && !d.tieneCuposDisponibles) return false;
      if (filtroDisp == 'activas' && !d.isActive) return false;

      // Filtro de búsqueda
      if (search.isEmpty) return true;
      final matchNombre = d.nombre.toLowerCase().contains(search);
      final matchDesc = d.descripcion?.toLowerCase().contains(search) ?? false;
      final matchDias = d.diasAsignados.any((dia) => dia.toLowerCase().contains(search));

      return matchNombre || matchDesc || matchDias;
    }).toList();
  });
});

/// Turnos horarios agrupados para el cronograma semanal
final cronogramaHorariosFiltradosProvider =
    Provider<AsyncValue<List<DisciplinaHorarioModel>>>((ref) {
  final horariosAsync = ref.watch(disciplinasHorariosListProvider);
  final diaSeleccionado = ref.watch(cronogramaDiaProvider).toLowerCase().trim();
  final search = ref.watch(disciplinasSearchProvider).toLowerCase().trim();

  return horariosAsync.whenData((turnos) {
    return turnos.where((th) {
      final diaSemana = th.horario?.diaSemana.toLowerCase() ?? '';
      final discNombre = th.disciplinaNombre?.toLowerCase() ?? '';

      // Filtro por día
      if (diaSeleccionado != 'todos') {
        if (!diaSemana.contains(diaSeleccionado)) return false;
      }

      // Filtro por búsqueda
      if (search.isEmpty) return true;
      return discNombre.contains(search) || diaSemana.contains(search);
    }).toList();
  });
});
