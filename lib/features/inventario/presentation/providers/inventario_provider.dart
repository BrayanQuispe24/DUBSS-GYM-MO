import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';

class AmbienteModel {
  final int id;
  final String nombre;
  final String? descripcion;
  final String estado;

  const AmbienteModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.estado,
  });

  bool get isOperativo =>
      estado.toLowerCase() == 'operativo' ||
      estado.toLowerCase() == 'activo' ||
      estado == '1';

  factory AmbienteModel.fromJson(Map<String, dynamic> json) {
    return AmbienteModel(
      id: json['id'] as int? ?? 0,
      nombre: json['nombre']?.toString() ?? 'Ambiente',
      descripcion: json['descripcion']?.toString(),
      estado: json['estado']?.toString() ?? 'operativo',
    );
  }
}

class EquipoModel {
  final int id;
  final String codigo;
  final String nombre;
  final String? modelo;
  final int cantidad;
  final double? precioCompra;
  final String estado;
  final int? idAmbiente;
  final String? nombreAmbiente;
  final int? idMarca;
  final String? nombreMarca;
  final int? idTipoEquipo;
  final String? nombreTipoEquipo;
  final String? imagenUrl;

  const EquipoModel({
    required this.id,
    required this.codigo,
    required this.nombre,
    this.modelo,
    this.cantidad = 1,
    this.precioCompra,
    required this.estado,
    this.idAmbiente,
    this.nombreAmbiente,
    this.idMarca,
    this.nombreMarca,
    this.idTipoEquipo,
    this.nombreTipoEquipo,
    this.imagenUrl,
  });

  factory EquipoModel.fromJson(Map<String, dynamic> json) {
    final amb = json['ambiente'] as Map<String, dynamic>?;
    final marca = json['marca'] as Map<String, dynamic>?;
    final tipo = json['tipo_equipo'] ?? json['tipoEquipo'];
    final tipoMap = tipo is Map<String, dynamic> ? tipo : null;

    return EquipoModel(
      id: json['id'] as int? ?? 0,
      codigo: json['codigo']?.toString() ?? 'EQ-000',
      nombre: json['nombre']?.toString() ?? 'Equipo',
      modelo: json['modelo']?.toString(),
      cantidad: json['cantidad'] as int? ?? 1,
      precioCompra: double.tryParse(json['precio_compra']?.toString() ?? ''),
      estado: json['estado']?.toString() ?? 'operativo',
      idAmbiente: json['id_ambiente'] as int?,
      nombreAmbiente: amb?['nombre']?.toString(),
      idMarca: json['id_marca'] as int?,
      nombreMarca: marca?['nombre']?.toString(),
      idTipoEquipo: json['id_tipo_equipo'] as int?,
      nombreTipoEquipo: tipoMap?['nombre']?.toString(),
      imagenUrl: json['imagen_url']?.toString(),
    );
  }
}

class InventarioState {
  final bool isLoading;
  final List<AmbienteModel> ambientes;
  final List<EquipoModel> equipos;
  final List<Map<String, dynamic>> marcas;
  final List<Map<String, dynamic>> tiposEquipo;
  final String? errorMessage;

  const InventarioState({
    this.isLoading = false,
    this.ambientes = const [],
    this.equipos = const [],
    this.marcas = const [],
    this.tiposEquipo = const [],
    this.errorMessage,
  });

  InventarioState copyWith({
    bool? isLoading,
    List<AmbienteModel>? ambientes,
    List<EquipoModel>? equipos,
    List<Map<String, dynamic>>? marcas,
    List<Map<String, dynamic>>? tiposEquipo,
    String? errorMessage,
    bool clearError = false,
  }) {
    return InventarioState(
      isLoading: isLoading ?? this.isLoading,
      ambientes: ambientes ?? this.ambientes,
      equipos: equipos ?? this.equipos,
      marcas: marcas ?? this.marcas,
      tiposEquipo: tiposEquipo ?? this.tiposEquipo,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final inventarioNotifierProvider =
    NotifierProvider<InventarioNotifier, InventarioState>(
  InventarioNotifier.new,
);

class InventarioNotifier extends Notifier<InventarioState> {
  late final Dio _dio;

  @override
  InventarioState build() {
    _dio = ref.watch(dioClientProvider);
    Future.microtask(() => cargarTodo());
    return const InventarioState(isLoading: true);
  }

  Future<void> cargarTodo() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // 1. Ambientes
      final resAmb = await _dio.get('ambientes');
      final rawAmb = resAmb.data;
      List<dynamic> listA = [];
      if (rawAmb is List) {
        listA = rawAmb;
      } else if (rawAmb is Map && rawAmb['data'] is List) {
        listA = rawAmb['data'] as List;
      }
      final ambientes = listA
          .whereType<Map<String, dynamic>>()
          .map((m) => AmbienteModel.fromJson(m))
          .toList();

      // 2. Equipos
      final resEq = await _dio.get('equipos');
      final rawEq = resEq.data;
      List<dynamic> listE = [];
      if (rawEq is List) {
        listE = rawEq;
      } else if (rawEq is Map && rawEq['data'] is List) {
        listE = rawEq['data'] as List;
      }
      final equipos = listE
          .whereType<Map<String, dynamic>>()
          .map((m) => EquipoModel.fromJson(m))
          .toList();

      // 3. Marcas y Tipos
      List<Map<String, dynamic>> marcas = [];
      try {
        final resM = await _dio.get('marcas');
        final rawM = resM.data;
        final listM = rawM is List ? rawM : (rawM is Map ? rawM['data'] : []);
        if (listM is List) {
          marcas = listM.whereType<Map<String, dynamic>>().toList();
        }
      } catch (_) {}

      List<Map<String, dynamic>> tipos = [];
      try {
        final resT = await _dio.get('tipo-equipos');
        final rawT = resT.data;
        final listT = rawT is List ? rawT : (rawT is Map ? rawT['data'] : []);
        if (listT is List) {
          tipos = listT.whereType<Map<String, dynamic>>().toList();
        }
      } catch (_) {}

      state = state.copyWith(
        isLoading: false,
        ambientes: ambientes,
        equipos: equipos,
        marcas: marcas,
        tiposEquipo: tipos,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al cargar inventario: $e',
      );
    }
  }

  Future<bool> guardarAmbiente({
    int? id,
    required String nombre,
    String? descripcion,
    required String estado,
  }) async {
    try {
      final payload = {
        'nombre': nombre,
        'descripcion': descripcion ?? '',
        'estado': estado,
      };

      if (id != null) {
        await _dio.put('ambientes/$id', data: payload);
      } else {
        await _dio.post('ambientes', data: payload);
      }
      await cargarTodo();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error al guardar ambiente: $e');
      return false;
    }
  }

  Future<bool> guardarEquipo({
    int? id,
    required String codigo,
    required String nombre,
    String? modelo,
    required int cantidad,
    double? precioCompra,
    required String estado,
    int? idAmbiente,
    int? idMarca,
    int? idTipoEquipo,
  }) async {
    try {
      final payload = {
        'codigo': codigo,
        'nombre': nombre,
        'modelo': modelo ?? '',
        'cantidad': cantidad,
        'precio_compra': ?precioCompra,
        'estado': estado,
        'id_ambiente': ?idAmbiente,
        'id_marca': ?idMarca,
        'id_tipo_equipo': ?idTipoEquipo,
      };

      if (id != null) {
        await _dio.put('equipos/$id', data: payload);
      } else {
        await _dio.post('equipos', data: payload);
      }
      await cargarTodo();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error al guardar equipo: $e');
      return false;
    }
  }

  Future<bool> eliminarAmbiente(int id) async {
    try {
      await _dio.delete('ambientes/$id');
      await cargarTodo();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error al eliminar ambiente: $e');
      return false;
    }
  }

  Future<bool> eliminarEquipo(int id) async {
    try {
      await _dio.delete('equipos/$id');
      await cargarTodo();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error al eliminar equipo: $e');
      return false;
    }
  }
}
