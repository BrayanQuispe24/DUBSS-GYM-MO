import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/accesos_remote_datasource.dart';
import '../../data/models/registro_acceso_model.dart';

class AccesosState {
  final bool isLoading;
  final List<RegistroAccesoModel> registros;
  final String searchQuery;
  final String? errorMessage;
  final AccesoScanResult? lastScanResult;

  const AccesosState({
    this.isLoading = false,
    this.registros = const [],
    this.searchQuery = '',
    this.errorMessage,
    this.lastScanResult,
  });

  int get aforoActual {
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final hoyRegistros = registros.where((r) => r.fechaHora.startsWith(todayStr)).toList();
    // Mapa del último estado de cada usuario hoy
    final Map<int, String> ultimoEstado = {};
    // Ordenar de más antiguo a más reciente
    final sorted = [...hoyRegistros]..sort((a, b) => a.fechaHora.compareTo(b.fechaHora));
    for (final reg in sorted) {
      ultimoEstado[reg.idUsuario] = reg.tipo;
    }
    return ultimoEstado.values.where((tipo) => tipo == 'entrada').length;
  }

  List<RegistroAccesoModel> get filteredRegistros {
    if (searchQuery.trim().isEmpty) return registros;
    final q = searchQuery.toLowerCase().trim();
    return registros.where((r) {
      final name = r.nombreCompleto.toLowerCase();
      final ci = (r.usuarioCi ?? '').toLowerCase();
      final codigo = (r.usuarioCodigo ?? '').toLowerCase();
      return name.contains(q) || ci.contains(q) || codigo.contains(q);
    }).toList();
  }

  AccesosState copyWith({
    bool? isLoading,
    List<RegistroAccesoModel>? registros,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
    AccesoScanResult? lastScanResult,
    bool clearLastScan = false,
  }) {
    return AccesosState(
      isLoading: isLoading ?? this.isLoading,
      registros: registros ?? this.registros,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastScanResult: clearLastScan ? null : (lastScanResult ?? this.lastScanResult),
    );
  }
}

class AccesoScanResult {
  final bool permitido;
  final String mensaje;
  final String tipo; // 'entrada' | 'salida'
  final String nombreSocio;
  final String? detalle;
  final DateTime fechaHora;

  const AccesoScanResult({
    required this.permitido,
    required this.mensaje,
    required this.tipo,
    required this.nombreSocio,
    this.detalle,
    required this.fechaHora,
  });
}

final accesosNotifierProvider =
    NotifierProvider<AccesosNotifier, AccesosState>(AccesosNotifier.new);

class AccesosNotifier extends Notifier<AccesosState> {
  late final AccesosRemoteDataSource _dataSource;

  @override
  AccesosState build() {
    _dataSource = ref.watch(accesosRemoteDataSourceProvider);
    Future.microtask(() => cargarRegistros());
    return const AccesosState(isLoading: true);
  }

  Future<void> cargarRegistros() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await _dataSource.getRegistrosAcceso();
      // Ordenar por fecha_hora descendente (los más recientes primero)
      list.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));
      state = state.copyWith(isLoading: false, registros: list);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al cargar registros de acceso: $e',
      );
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearLastScan() {
    state = state.copyWith(clearLastScan: true);
  }

  Future<bool> registrarMarcacionManual({
    required int idUsuario,
    required String tipo,
    String? nombreUsuario,
  }) async {
    try {
      final nuevo = await _dataSource.createRegistroAcceso(
        tipo: tipo,
        idUsuario: idUsuario,
      );

      final updated = [nuevo, ...state.registros];
      state = state.copyWith(
        registros: updated,
        lastScanResult: AccesoScanResult(
          permitido: true,
          mensaje: 'Marcación de ${tipo.toUpperCase()} registrada con éxito.',
          tipo: tipo,
          nombreSocio: nombreUsuario ?? nuevo.nombreCompleto,
          detalle: 'Registro manual directo por recepción',
          fechaHora: DateTime.now(),
        ),
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error al registrar marcación: $e',
        lastScanResult: AccesoScanResult(
          permitido: false,
          mensaje: 'Error al registrar: $e',
          tipo: tipo,
          nombreSocio: nombreUsuario ?? 'Usuario #$idUsuario',
          fechaHora: DateTime.now(),
        ),
      );
      return false;
    }
  }

  Future<AccesoScanResult> procesarCodigoQR(String rawPayload) async {
    try {
      int? idUsuario;
      int? idBoleta;
      String nombre = 'Socio DUBSS';

      // 1. Intentar parsear como JSON
      if (rawPayload.trim().startsWith('{')) {
        final decoded = json.decode(rawPayload);
        if (decoded is Map<String, dynamic>) {
          idUsuario = int.tryParse(decoded['id_usuario']?.toString() ??
              decoded['userId']?.toString() ??
              decoded['id']?.toString() ??
              '');
          idBoleta = int.tryParse(decoded['id_boleta']?.toString() ??
              decoded['id_boleta_inscripcion']?.toString() ??
              '');
          nombre = decoded['nombre_completo']?.toString() ??
              decoded['nombre']?.toString() ??
              nombre;
        }
      } else {
        // Formato simple de ID numérico o código
        idUsuario = int.tryParse(rawPayload.trim());
      }

      if (idUsuario == null || idUsuario == 0) {
        final res = AccesoScanResult(
          permitido: false,
          mensaje: 'El código QR escaneado no tiene un formato válido.',
          tipo: 'desconocido',
          nombreSocio: 'No identificado',
          detalle: 'Payload: $rawPayload',
          fechaHora: DateTime.now(),
        );
        state = state.copyWith(lastScanResult: res);
        return res;
      }

      // 2. Determinar si es Entrada o Salida según último registro de hoy
      final now = DateTime.now();
      final todayStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final userRegistrosHoy = state.registros
          .where((r) => r.idUsuario == idUsuario && r.fechaHora.startsWith(todayStr))
          .toList()
        ..sort((a, b) => b.fechaHora.compareTo(a.fechaHora));

      String tipoDeducido = 'entrada';
      if (userRegistrosHoy.isNotEmpty && userRegistrosHoy.first.isEntrada) {
        tipoDeducido = 'salida';
      }

      final nuevo = await _dataSource.createRegistroAcceso(
        tipo: tipoDeducido,
        idUsuario: idUsuario,
        idBoletaInscripcion: idBoleta,
      );

      final updated = [nuevo, ...state.registros];
      final res = AccesoScanResult(
        permitido: true,
        mensaje: tipoDeducido == 'entrada'
            ? '¡ACCESO PERMITIDO! Bienvenido al gimnasio.'
            : '¡SALIDA REGISTRADA! Hasta pronto.',
        tipo: tipoDeducido,
        nombreSocio: nuevo.nombreCompleto.isNotEmpty && nuevo.nombreCompleto != 'Usuario #$idUsuario'
            ? nuevo.nombreCompleto
            : nombre,
        detalle: 'C.I.: ${nuevo.usuarioCi ?? 'Verificado'} • Boleta: ${nuevo.boletaNumero ?? 'Activa'}',
        fechaHora: DateTime.now(),
      );

      state = state.copyWith(registros: updated, lastScanResult: res);
      return res;
    } catch (e) {
      final res = AccesoScanResult(
        permitido: false,
        mensaje: 'Acceso Denegado: Error al validar con el servidor.',
        tipo: 'error',
        nombreSocio: 'Socio',
        detalle: e.toString(),
        fechaHora: DateTime.now(),
      );
      state = state.copyWith(lastScanResult: res);
      return res;
    }
  }
}
