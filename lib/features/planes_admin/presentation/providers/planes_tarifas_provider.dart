import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';

class PlanItem {
  final int id;
  final String nombre;
  final String? descripcion;
  final int duracionDias;
  final bool estado;
  final int? idTarifa;
  final double? precioTarifa;
  final String? nombreTarifa;

  const PlanItem({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.duracionDias,
    required this.estado,
    this.idTarifa,
    this.precioTarifa,
    this.nombreTarifa,
  });

  factory PlanItem.fromJson(Map<String, dynamic> json) {
    final tarifa = json['tarifa'] as Map<String, dynamic>?;
    return PlanItem(
      id: json['id'] as int? ?? 0,
      nombre: json['nombre']?.toString() ?? 'Plan',
      descripcion: json['descripcion']?.toString(),
      duracionDias: json['duracion_dias'] as int? ?? 30,
      estado: json['estado'] == true ||
          json['estado'] == 1 ||
          json['estado']?.toString() == '1' ||
          json['estado']?.toString().toLowerCase() == 'activo',
      idTarifa: json['id_tarifa'] as int?,
      precioTarifa: double.tryParse(tarifa?['precio']?.toString() ?? ''),
      nombreTarifa: tarifa?['nombre']?.toString(),
    );
  }
}

class TarifaItem {
  final int id;
  final String nombre;
  final double precio;
  final String? fechaInicio;
  final String? fechaFin;
  final bool estado;

  const TarifaItem({
    required this.id,
    required this.nombre,
    required this.precio,
    this.fechaInicio,
    this.fechaFin,
    required this.estado,
  });

  factory TarifaItem.fromJson(Map<String, dynamic> json) {
    return TarifaItem(
      id: json['id'] as int? ?? 0,
      nombre: json['nombre']?.toString() ?? 'Tarifa',
      precio: double.tryParse(json['precio']?.toString() ?? '') ?? 0.0,
      fechaInicio: json['fecha_inicio']?.toString(),
      fechaFin: json['fecha_fin']?.toString(),
      estado: json['estado'] == true ||
          json['estado'] == 1 ||
          json['estado']?.toString() == '1' ||
          json['estado']?.toString().toLowerCase() == 'activo',
    );
  }
}

class PlanesTarifasState {
  final bool isLoading;
  final List<PlanItem> planes;
  final List<TarifaItem> tarifas;
  final String? errorMessage;

  const PlanesTarifasState({
    this.isLoading = false,
    this.planes = const [],
    this.tarifas = const [],
    this.errorMessage,
  });

  PlanesTarifasState copyWith({
    bool? isLoading,
    List<PlanItem>? planes,
    List<TarifaItem>? tarifas,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PlanesTarifasState(
      isLoading: isLoading ?? this.isLoading,
      planes: planes ?? this.planes,
      tarifas: tarifas ?? this.tarifas,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final planesTarifasNotifierProvider =
    NotifierProvider<PlanesTarifasNotifier, PlanesTarifasState>(
  PlanesTarifasNotifier.new,
);

class PlanesTarifasNotifier extends Notifier<PlanesTarifasState> {
  late final Dio _dio;

  @override
  PlanesTarifasState build() {
    _dio = ref.watch(dioClientProvider);
    Future.microtask(() => cargarTodo());
    return const PlanesTarifasState(isLoading: true);
  }

  Future<void> cargarTodo() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final resPlanes = await _dio.get('planes');
      final rawPlanes = resPlanes.data;
      List<dynamic> listP = [];
      if (rawPlanes is List) {
        listP = rawPlanes;
      } else if (rawPlanes is Map && rawPlanes['data'] is List) {
        listP = rawPlanes['data'] as List;
      }
      final planes = listP
          .whereType<Map<String, dynamic>>()
          .map((m) => PlanItem.fromJson(m))
          .toList();

      final resTarifas = await _dio.get('tarifas');
      final rawTarifas = resTarifas.data;
      List<dynamic> listT = [];
      if (rawTarifas is List) {
        listT = rawTarifas;
      } else if (rawTarifas is Map && rawTarifas['data'] is List) {
        listT = rawTarifas['data'] as List;
      }
      final tarifas = listT
          .whereType<Map<String, dynamic>>()
          .map((m) => TarifaItem.fromJson(m))
          .toList();

      state = state.copyWith(isLoading: false, planes: planes, tarifas: tarifas);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al cargar planes y tarifas: $e',
      );
    }
  }

  Future<bool> guardarPlan({
    int? id,
    required String nombre,
    String? descripcion,
    required int duracionDias,
    int? idTarifa,
    required bool estado,
  }) async {
    try {
      final payload = {
        'nombre': nombre,
        'descripcion': descripcion ?? '',
        'duracion_dias': duracionDias,
        'id_tarifa': ?idTarifa,
        'estado': estado,
      };

      if (id != null) {
        payload['id'] = id;
        await _dio.put('planes', data: payload);
      } else {
        await _dio.post('planes', data: payload);
      }
      await cargarTodo();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error al guardar plan: $e');
      return false;
    }
  }

  Future<bool> guardarTarifa({
    int? id,
    required String nombre,
    required double precio,
    String? fechaInicio,
    String? fechaFin,
    required bool estado,
  }) async {
    try {
      final payload = {
        'nombre': nombre,
        'precio': precio,
        'fecha_inicio': ?fechaInicio,
        'fecha_fin': ?fechaFin,
        'estado': estado,
      };

      if (id != null) {
        payload['id'] = id;
        await _dio.put('tarifas', data: payload);
      } else {
        await _dio.post('tarifas', data: payload);
      }
      await cargarTodo();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error al guardar tarifa: $e');
      return false;
    }
  }

  Future<bool> eliminarPlan(int id) async {
    try {
      await _dio.delete('planes/$id');
      await cargarTodo();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error al eliminar plan: $e');
      return false;
    }
  }

  Future<bool> eliminarTarifa(int id) async {
    try {
      await _dio.delete('tarifas/$id');
      await cargarTodo();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error al eliminar tarifa: $e');
      return false;
    }
  }
}
