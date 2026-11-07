import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../garita_accesos/data/datasources/accesos_remote_datasource.dart';
import '../../../tramites/data/datasources/tramites_remote_datasource.dart';

class ReceptionistKpis {
  final int aforoActual;
  final int solicitudesPendientes;
  final int pagosHoy;
  final double totalRecaudadoHoy;
  final int totalUsuarios;

  const ReceptionistKpis({
    this.aforoActual = 0,
    this.solicitudesPendientes = 0,
    this.pagosHoy = 0,
    this.totalRecaudadoHoy = 0.0,
    this.totalUsuarios = 0,
  });
}

final receptionistDashboardProvider =
    FutureProvider.autoDispose<ReceptionistKpis>((ref) async {
  final dio = ref.watch(dioClientProvider);
  final accesosDs = ref.watch(accesosRemoteDataSourceProvider);
  final tramitesDs = ref.watch(tramitesRemoteDataSourceProvider);

  int aforo = 0;
  int pendientes = 0;
  int countPagosHoy = 0;
  double recaudadoHoy = 0.0;
  int usuariosCount = 0;

  final now = DateTime.now();
  final todayStr =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

  // 1. Accesos y Aforo
  try {
    final accesos = await accesosDs.getRegistrosAcceso();
    final hoyRegistros =
        accesos.where((r) => r.fechaHora.startsWith(todayStr)).toList();
    final Map<int, String> ultimoEstado = {};
    final sorted = [...hoyRegistros]..sort((a, b) => a.fechaHora.compareTo(b.fechaHora));
    for (final reg in sorted) {
      ultimoEstado[reg.idUsuario] = reg.tipo;
    }
    aforo = ultimoEstado.values.where((tipo) => tipo == 'entrada').length;
  } catch (_) {}

  // 2. Solicitudes
  try {
    final solicitudes = await tramitesDs.getFormulariosSolicitud();
    pendientes = solicitudes.where((s) => s.isPendiente).length;
  } catch (_) {}

  // 3. Boletas de Pago
  try {
    final pagos = await tramitesDs.getBoletasPago();
    for (final p in pagos) {
      final fecha = p.fechaPago?.toIso8601String() ?? '';
      if (fecha.startsWith(todayStr)) {
        countPagosHoy++;
        recaudadoHoy += p.monto;
      }
    }
  } catch (_) {}

  // 4. Usuarios
  try {
    final res = await dio.get('/usuarios');
    final raw = res.data;
    if (raw is List) {
      usuariosCount = raw.length;
    } else if (raw is Map && raw['data'] is List) {
      usuariosCount = (raw['data'] as List).length;
    }
  } catch (_) {}

  return ReceptionistKpis(
    aforoActual: aforo,
    solicitudesPendientes: pendientes,
    pagosHoy: countPagosHoy,
    totalRecaudadoHoy: recaudadoHoy,
    totalUsuarios: usuariosCount,
  );
});
