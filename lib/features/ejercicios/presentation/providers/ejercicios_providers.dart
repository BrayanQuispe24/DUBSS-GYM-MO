import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/ejercicios_remote_datasource.dart';
import '../../data/models/ejercicio_model.dart';
import '../../data/models/grupo_muscular_model.dart';
import '../../data/models/tipo_ejercicio_model.dart';

/// Provider para cargar los tipos de ejercicio
final tiposEjercicioProvider = FutureProvider<List<TipoEjercicioModel>>((ref) {
  final ds = ref.watch(ejerciciosRemoteDataSourceProvider);
  return ds.getTiposEjercicio();
});

/// Provider para cargar los grupos musculares
final gruposMuscularesProvider = FutureProvider<List<GrupoMuscularModel>>((ref) {
  final ds = ref.watch(ejerciciosRemoteDataSourceProvider);
  return ds.getGruposMusculares();
});

/// Estado de filtros para el catálogo de ejercicios
class EjerciciosFilterState {
  final String search;
  final int? selectedTipoId;
  final int? selectedGrupoId;

  const EjerciciosFilterState({
    this.search = '',
    this.selectedTipoId,
    this.selectedGrupoId,
  });

  bool get hasActiveFilters =>
      search.isNotEmpty || selectedTipoId != null || selectedGrupoId != null;

  EjerciciosFilterState copyWith({
    String? search,
    int? selectedTipoId,
    bool clearTipo = false,
    int? selectedGrupoId,
    bool clearGrupo = false,
  }) {
    return EjerciciosFilterState(
      search: search ?? this.search,
      selectedTipoId: clearTipo ? null : (selectedTipoId ?? this.selectedTipoId),
      selectedGrupoId: clearGrupo ? null : (selectedGrupoId ?? this.selectedGrupoId),
    );
  }
}

class EjerciciosFilterNotifier extends Notifier<EjerciciosFilterState> {
  Timer? _debounceTimer;

  @override
  EjerciciosFilterState build() => const EjerciciosFilterState();

  void setSearchDebounced(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      state = state.copyWith(search: query.trim());
    });
  }

  void setTipo(int? id) {
    if (id == null) {
      state = state.copyWith(clearTipo: true);
    } else {
      state = state.copyWith(selectedTipoId: id);
    }
  }

  void setGrupo(int? id) {
    if (id == null) {
      state = state.copyWith(clearGrupo: true);
    } else {
      state = state.copyWith(selectedGrupoId: id);
    }
  }

  void reset() {
    _debounceTimer?.cancel();
    state = const EjerciciosFilterState();
  }
}

final ejerciciosFilterProvider =
    NotifierProvider<EjerciciosFilterNotifier, EjerciciosFilterState>(
  EjerciciosFilterNotifier.new,
);

/// Estado de la lista paginada de ejercicios
class EjerciciosListState {
  final List<EjercicioModel> items;
  final EjerciciosMetaModel? meta;
  final bool isLoadingMore;
  final bool hasReachedEnd;

  const EjerciciosListState({
    this.items = const [],
    this.meta,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
  });

  int get totalItems => meta?.total ?? items.length;

  EjerciciosListState copyWith({
    List<EjercicioModel>? items,
    EjerciciosMetaModel? meta,
    bool? isLoadingMore,
    bool? hasReachedEnd,
  }) {
    return EjerciciosListState(
      items: items ?? this.items,
      meta: meta ?? this.meta,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    );
  }
}

class EjerciciosPaginatorNotifier
    extends AsyncNotifier<EjerciciosListState> {
  late final EjerciciosRemoteDataSource _dataSource;

  @override
  FutureOr<EjerciciosListState> build() async {
    _dataSource = ref.watch(ejerciciosRemoteDataSourceProvider);
    final filter = ref.watch(ejerciciosFilterProvider);

    final response = await _dataSource.getEjercicios(
      search: filter.search.isNotEmpty ? filter.search : null,
      idTipoEjercicio: filter.selectedTipoId,
      idGrupoMuscular: filter.selectedGrupoId,
      page: 1,
      perPage: 15,
    );

    return EjerciciosListState(
      items: response.data,
      meta: response.meta,
      hasReachedEnd: response.meta.currentPage >= response.meta.lastPage,
    );
  }

  /// Carga la siguiente página de ejercicios
  Future<void> loadNextPage() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || current.hasReachedEnd) return;

    final nextPage = (current.meta?.currentPage ?? 1) + 1;
    final filter = ref.read(ejerciciosFilterProvider);

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));

    try {
      final response = await _dataSource.getEjercicios(
        search: filter.search.isNotEmpty ? filter.search : null,
        idTipoEjercicio: filter.selectedTipoId,
        idGrupoMuscular: filter.selectedGrupoId,
        page: nextPage,
        perPage: 15,
      );

      final updatedItems = [...current.items, ...response.data];
      final reachedEnd = response.meta.currentPage >= response.meta.lastPage;

      state = AsyncValue.data(
        current.copyWith(
          items: updatedItems,
          meta: response.meta,
          isLoadingMore: false,
          hasReachedEnd: reachedEnd,
        ),
      );
    } catch (_) {
      state = AsyncValue.data(current.copyWith(isLoadingMore: false));
      // Log / handle pagination error gracefully without breaking current items
    }
  }

  /// Recarga desde la primera página
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

final ejerciciosPaginatorProvider = AsyncNotifierProvider<
    EjerciciosPaginatorNotifier, EjerciciosListState>(
  EjerciciosPaginatorNotifier.new,
);
