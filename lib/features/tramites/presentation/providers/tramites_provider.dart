import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/tramites_remote_datasource.dart';
import '../../data/models/boleta_inscripcion_model.dart';
import '../../data/models/boleta_pago_model.dart';
import '../../data/models/formulario_solicitud_model.dart';

/// Proveedor para obtener las boletas de pago del usuario
final boletasPagoProvider = FutureProvider<List<BoletaPagoModel>>((ref) async {
  final dataSource = ref.watch(tramitesRemoteDataSourceProvider);
  return dataSource.getBoletasPago();
});

/// Proveedor para obtener las membresías / inscripciones del usuario
final boletasInscripcionProvider =
    FutureProvider<List<BoletaInscripcionModel>>((ref) async {
  final dataSource = ref.watch(tramitesRemoteDataSourceProvider);
  return dataSource.getBoletasInscripcion();
});

/// Proveedor para obtener las solicitudes DUBSS-FR-03 del usuario
final formulariosSolicitudProvider =
    FutureProvider<List<FormularioSolicitudModel>>((ref) async {
  final dataSource = ref.watch(tramitesRemoteDataSourceProvider);
  return dataSource.getFormulariosSolicitud();
});

/// Filtro de búsqueda textual para trámites
class TramitesSearchFilterNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setSearch(String query) {
    state = query;
  }
}

final tramitesSearchFilterProvider =
    NotifierProvider<TramitesSearchFilterNotifier, String>(
  TramitesSearchFilterNotifier.new,
);

/// Filtro de estado para formularios de solicitud
class FormulariosEstadoFilterNotifier extends Notifier<String> {
  @override
  String build() => 'todos';

  void setFilter(String estado) {
    state = estado;
  }
}

final formulariosEstadoFilterProvider =
    NotifierProvider<FormulariosEstadoFilterNotifier, String>(
  FormulariosEstadoFilterNotifier.new,
);

/// Solicitudes filtradas por búsqueda y estado
final formulariosSolicitudFiltradosProvider =
    Provider<AsyncValue<List<FormularioSolicitudModel>>>((ref) {
  final formsAsync = ref.watch(formulariosSolicitudProvider);
  final search = ref.watch(tramitesSearchFilterProvider).toLowerCase().trim();
  final estadoFilter = ref.watch(formulariosEstadoFilterProvider).toLowerCase().trim();

  return formsAsync.whenData((forms) {
    return forms.where((f) {
      // Filtro de estado
      if (estadoFilter != 'todos') {
        if (estadoFilter == 'aprobado' && !f.isAprobado) return false;
        if (estadoFilter == 'pendiente' && !f.isPendiente) return false;
        if (estadoFilter == 'rechazado' && !f.isRechazado) return false;
      }

      // Filtro de búsqueda
      if (search.isEmpty) return true;
      final matchCod = f.numeroFormulario.toLowerCase().contains(search);
      final matchDisc = f.disciplinaNombre.toLowerCase().contains(search);
      final matchPlan = f.planNombre?.toLowerCase().contains(search) ?? false;
      final matchUser = f.usuarioNombre?.toLowerCase().contains(search) ?? false;
      final matchEmail = f.usuarioEmail?.toLowerCase().contains(search) ?? false;

      return matchCod || matchDisc || matchPlan || matchUser || matchEmail;
    }).toList();
  });
});

/// Boletas de pago filtradas por término de búsqueda
final boletasPagoFiltradasProvider =
    Provider<AsyncValue<List<BoletaPagoModel>>>((ref) {
  final boletasAsync = ref.watch(boletasPagoProvider);
  final search = ref.watch(tramitesSearchFilterProvider).toLowerCase().trim();

  return boletasAsync.whenData((boletas) {
    if (search.isEmpty) return boletas;
    return boletas.where((b) {
      final matchCod = b.numeroBoleta.toLowerCase().contains(search);
      final matchConc = b.concepto.toLowerCase().contains(search);
      final matchPlan = b.planNombre?.toLowerCase().contains(search) ?? false;
      return matchCod || matchConc || matchPlan;
    }).toList();
  });
});

/// Inscripciones filtradas por término de búsqueda
final boletasInscripcionFiltradasProvider =
    Provider<AsyncValue<List<BoletaInscripcionModel>>>((ref) {
  final inscripcionesAsync = ref.watch(boletasInscripcionProvider);
  final search = ref.watch(tramitesSearchFilterProvider).toLowerCase().trim();

  return inscripcionesAsync.whenData((inscripciones) {
    if (search.isEmpty) return inscripciones;
    return inscripciones.where((i) {
      final matchCod = i.numeroBoleta.toLowerCase().contains(search);
      final matchDisc = i.disciplina.toLowerCase().contains(search);
      return matchCod || matchDisc;
    }).toList();
  });
});
