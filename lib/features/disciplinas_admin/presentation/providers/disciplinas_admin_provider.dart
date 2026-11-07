import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';

class AdminDisciplinaItem {
  final int id;
  final String nombre;
  final String? descripcion;
  final int cantidadCupos;
  final int totalOcupados;
  final int totalDisponibles;
  final String estado;
  final List<dynamic> disciplinaHorarios;

  const AdminDisciplinaItem({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.cantidadCupos,
    this.totalOcupados = 0,
    this.totalDisponibles = 0,
    required this.estado,
    this.disciplinaHorarios = const [],
  });

  factory AdminDisciplinaItem.fromJson(Map<String, dynamic> json) {
    final listDh = (json['disciplina_horarios'] ?? json['disciplinaHorarios']) as List<dynamic>? ?? [];
    return AdminDisciplinaItem(
      id: json['id'] as int? ?? 0,
      nombre: json['nombre']?.toString() ?? 'Disciplina',
      descripcion: json['descripcion']?.toString(),
      cantidadCupos: json['cantidad_cupos'] as int? ?? 0,
      totalOcupados: json['total_cupos_ocupados'] as int? ?? 0,
      totalDisponibles: json['total_cupos_disponibles'] as int? ?? (json['cantidad_cupos'] as int? ?? 0),
      estado: json['estado']?.toString() ?? 'activo',
      disciplinaHorarios: listDh,
    );
  }
}

class AdminHorarioItem {
  final int id;
  final String diaSemana;
  final String horaInicio;
  final String horaFin;

  const AdminHorarioItem({
    required this.id,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
  });

  factory AdminHorarioItem.fromJson(Map<String, dynamic> json) {
    return AdminHorarioItem(
      id: json['id'] as int? ?? 0,
      diaSemana: json['dia_semana']?.toString() ?? json['dias']?.toString() ?? 'Lunes a Viernes',
      horaInicio: json['hora_inicio']?.toString() ?? '',
      horaFin: json['hora_fin']?.toString() ?? '',
    );
  }
}

class DisciplinasAdminState {
  final bool isLoading;
  final List<AdminDisciplinaItem> disciplinas;
  final List<AdminHorarioItem> horarios;
  final String? errorMessage;

  const DisciplinasAdminState({
    this.isLoading = false,
    this.disciplinas = const [],
    this.horarios = const [],
    this.errorMessage,
  });

  DisciplinasAdminState copyWith({
    bool? isLoading,
    List<AdminDisciplinaItem>? disciplinas,
    List<AdminHorarioItem>? horarios,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DisciplinasAdminState(
      isLoading: isLoading ?? this.isLoading,
      disciplinas: disciplinas ?? this.disciplinas,
      horarios: horarios ?? this.horarios,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final disciplinasAdminNotifierProvider =
    NotifierProvider<DisciplinasAdminNotifier, DisciplinasAdminState>(
  DisciplinasAdminNotifier.new,
);

class DisciplinasAdminNotifier extends Notifier<DisciplinasAdminState> {
  late final Dio _dio;

  @override
  DisciplinasAdminState build() {
    _dio = ref.watch(dioClientProvider);
    Future.microtask(() => cargarTodo());
    return const DisciplinasAdminState(isLoading: true);
  }

  Future<void> cargarTodo() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final resDisc = await _dio.get('disciplinas');
      final rawDisc = resDisc.data;
      List<dynamic> listD = [];
      if (rawDisc is List) {
        listD = rawDisc;
      } else if (rawDisc is Map && rawDisc['data'] is List) {
        listD = rawDisc['data'] as List;
      }
      final disc = listD
          .whereType<Map<String, dynamic>>()
          .map((m) => AdminDisciplinaItem.fromJson(m))
          .toList();

      final resHor = await _dio.get('horarios');
      final rawHor = resHor.data;
      List<dynamic> listH = [];
      if (rawHor is List) {
        listH = rawHor;
      } else if (rawHor is Map && rawHor['data'] is List) {
        listH = rawHor['data'] as List;
      }
      final hor = listH
          .whereType<Map<String, dynamic>>()
          .map((m) => AdminHorarioItem.fromJson(m))
          .toList();

      state = state.copyWith(isLoading: false, disciplinas: disc, horarios: hor);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al cargar disciplinas y horarios: $e',
      );
    }
  }

  Future<bool> guardarDisciplina({
    int? id,
    required String nombre,
    String? descripcion,
    required int cantidadCupos,
    required String estado,
  }) async {
    try {
      final payload = {
        'nombre': nombre,
        'descripcion': descripcion ?? '',
        'cantidad_cupos': cantidadCupos,
        'estado': estado,
      };

      if (id != null) {
        await _dio.put('disciplinas/$id', data: payload);
      } else {
        await _dio.post('disciplinas', data: payload);
      }
      await cargarTodo();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error al guardar disciplina: $e');
      return false;
    }
  }

  Future<bool> asignarHorarioADisciplina({
    required int idDisciplina,
    required int idHorario,
    required int cupoMaximo,
  }) async {
    try {
      await _dio.post('disciplina-horario', data: {
        'id_disciplina': idDisciplina,
        'id_horario': idHorario,
        'cupo_maximo': cupoMaximo,
        'estado': true,
      });
      await cargarTodo();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error al asignar horario: $e');
      return false;
    }
  }

  Future<bool> eliminarDisciplina(int id) async {
    try {
      await _dio.delete('disciplinas/$id');
      await cargarTodo();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error al eliminar disciplina: $e');
      return false;
    }
  }
}
