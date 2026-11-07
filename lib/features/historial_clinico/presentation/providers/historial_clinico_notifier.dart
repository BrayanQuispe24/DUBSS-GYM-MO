import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/historial_clinico_remote_datasource.dart';
import '../../data/models/historial_model.dart';
import 'historial_clinico_state.dart';

final historialClinicoNotifierProvider =
    NotifierProvider<HistorialClinicoNotifier, HistorialClinicoState>(
  HistorialClinicoNotifier.new,
);

class HistorialClinicoNotifier extends Notifier<HistorialClinicoState> {
  late final HistorialClinicoRemoteDataSource _dataSource;

  @override
  HistorialClinicoState build() {
    _dataSource = ref.watch(historialClinicoRemoteDataSourceProvider);
    Future.microtask(() => cargarHistoriales());
    return const HistorialClinicoState(status: HistorialClinicoStatus.initial);
  }

  Future<void> cargarHistoriales({bool forceRefresh = false}) async {
    if (state.isLoading && !forceRefresh) return;

    state = state.copyWith(
      status: HistorialClinicoStatus.loading,
      clearError: true,
    );

    try {
      final list = await _dataSource.getHistoriales();
      final selected = list.isNotEmpty ? list.first : null;
      state = state.copyWith(
        status: HistorialClinicoStatus.loaded,
        historiales: list,
        selectedHistorial: selected,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: HistorialClinicoStatus.error,
        errorMessage: e.toString().replaceFirst('AppException: ', ''),
      );
    }
  }

  void selectHistorial(HistorialModel historial) {
    state = state.copyWith(selectedHistorial: historial);
  }

  void setTabIndex(int index) {
    if (state.selectedTabIndex != index) {
      state = state.copyWith(selectedTabIndex: index);
    }
  }

  /// Registra una nueva medición física para el historial activo
  Future<bool> registrarMedicion({
    required double? peso,
    required double? altura,
    required double? imc,
    required double? porcentajeGrasa,
    required double? masaMuscular,
    required String? presion,
    required String fechaRegistro,
  }) async {
    final activeHistorial = state.selectedHistorial;
    if (activeHistorial == null) return false;

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final payload = <String, dynamic>{
        'id_historial': activeHistorial.id,
        'fecha_registro': fechaRegistro,
      };
      if (peso != null) payload['peso'] = peso;
      if (altura != null) payload['altura'] = altura;
      if (imc != null) payload['imc'] = imc;
      if (porcentajeGrasa != null) payload['porcentaje_grasa'] = porcentajeGrasa;
      if (masaMuscular != null) payload['masa_muscular'] = masaMuscular;
      if (presion != null && presion.isNotEmpty) payload['presion'] = presion;

      await _dataSource.createDetalleHistorial(payload);
      await cargarHistoriales(forceRefresh: true);
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceFirst('AppException: ', ''),
      );
      return false;
    }
  }

  /// Guarda o actualiza los antecedentes patológicos del historial activo
  Future<bool> guardarAntecedentes(Map<String, dynamic> data) async {
    final activeHistorial = state.selectedHistorial;
    if (activeHistorial == null) return false;

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final payload = {
        'id_historial': activeHistorial.id,
        ...data,
      };

      await _dataSource.createAntecedente(payload);
      await cargarHistoriales(forceRefresh: true);
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceFirst('AppException: ', ''),
      );
      return false;
    }
  }
}
