import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exception.dart';
import '../../data/datasources/ia_nutricion_remote_datasource.dart';
import '../../data/datasources/nutricion_remote_datasource.dart';
import '../../data/models/plan_alimentacion_model.dart';
import '../../data/models/recomendacion_nutricional_ia_model.dart';
import 'nutricion_provider.dart';

class GenerarPlanIaState {
  final bool isGenerating;
  final String? generationError;
  final RecomendacionNutricionalResponse? recomendacion;
  final bool isSaving;
  final bool saveSuccess;
  final String? saveError;
  final PlanAlimentacionModel? planGuardado;

  const GenerarPlanIaState({
    this.isGenerating = false,
    this.generationError,
    this.recomendacion,
    this.isSaving = false,
    this.saveSuccess = false,
    this.saveError,
    this.planGuardado,
  });

  GenerarPlanIaState copyWith({
    bool? isGenerating,
    String? generationError,
    bool clearGenerationError = false,
    RecomendacionNutricionalResponse? recomendacion,
    bool? isSaving,
    bool? saveSuccess,
    String? saveError,
    bool clearSaveError = false,
    PlanAlimentacionModel? planGuardado,
  }) {
    return GenerarPlanIaState(
      isGenerating: isGenerating ?? this.isGenerating,
      generationError: clearGenerationError ? null : (generationError ?? this.generationError),
      recomendacion: recomendacion ?? this.recomendacion,
      isSaving: isSaving ?? this.isSaving,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      saveError: clearSaveError ? null : (saveError ?? this.saveError),
      planGuardado: planGuardado ?? this.planGuardado,
    );
  }
}

final generarPlanIaProvider =
    NotifierProvider<GenerarPlanIaNotifier, GenerarPlanIaState>(
  GenerarPlanIaNotifier.new,
);

class GenerarPlanIaNotifier extends Notifier<GenerarPlanIaState> {
  @override
  GenerarPlanIaState build() {
    return const GenerarPlanIaState();
  }

  /// Limpia los resultados previos
  void reset() {
    state = const GenerarPlanIaState();
  }

  /// Genera la recomendación nutricional con Gemini 2.5 Flash
  Future<bool> generarRecomendacion(PerfilNutricionalInput perfil) async {
    state = state.copyWith(
      isGenerating: true,
      clearGenerationError: true,
      saveSuccess: false,
    );

    try {
      final iaDataSource = ref.read(iaNutricionRemoteDataSourceProvider);
      final resultado = await iaDataSource.generarPlanNutricional(perfil);

      state = state.copyWith(
        isGenerating: false,
        recomendacion: resultado,
        clearGenerationError: true,
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(
        isGenerating: false,
        generationError: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        generationError: 'Error inesperado al generar el plan con IA: $e',
      );
      return false;
    }
  }

  /// Convierte y guarda la recomendación como Plan Oficial en Laravel PostgreSQL
  Future<bool> guardarComoPlanOficial({
    required int idUsuario,
    required String nombreAtleta,
    String? objetivoCustom,
  }) async {
    final rec = state.recomendacion;
    if (rec == null) {
      state = state.copyWith(saveError: 'No hay ninguna recomendación para guardar');
      return false;
    }

    state = state.copyWith(
      isSaving: true,
      clearSaveError: true,
      saveSuccess: false,
    );

    try {
      final now = DateTime.now();
      final fechaHoy = "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final fechaFinDate = now.add(const Duration(days: 30));
      final fechaFin = "${fechaFinDate.year.toString().padLeft(4, '0')}-${fechaFinDate.month.toString().padLeft(2, '0')}-${fechaFinDate.day.toString().padLeft(2, '0')}";

      String parseHoraSafe(String horario) {
        final reg = RegExp(r'(\d{1,2}):(\d{2})');
        final match = reg.firstMatch(horario);
        if (match != null) {
          int hours = int.tryParse(match.group(1) ?? '8') ?? 8;
          final minutes = match.group(2) ?? '00';
          if (horario.toUpperCase().contains('PM') && hours < 12) hours += 12;
          if (horario.toUpperCase().contains('AM') && hours == 12) hours = 0;
          return "${hours.toString().padLeft(2, '0')}:$minutes:00";
        }
        return "08:00:00";
      }

      final detallesPayload = rec.comidas.map((c) {
        final lineasObservacion = [
          'Macros: P: ${c.proteinasG}g | C: ${c.carbohidratosG}g | G: ${c.grasasG}g',
          if (c.horarioSugerido.isNotEmpty) 'Horario Sugerido: ${c.horarioSugerido}',
          if (c.ingredientes.isNotEmpty)
            'Ingredientes y Porciones:\n${c.ingredientes.map((i) => '• $i').join('\n')}',
          if (c.instruccionesPreparacion.isNotEmpty)
            'Preparación:\n${c.instruccionesPreparacion}',
          if (c.sustitutosAccesibles.isNotEmpty)
            'Sustitutos Económicos:\n${c.sustitutosAccesibles.map((s) => '• $s').join('\n')}',
        ].join('\n\n');

        final String descSafe = c.ingredientes.isNotEmpty
            ? '${c.platoNombre} - ${c.ingredientes.join(', ')}'
            : c.platoNombre;

        return {
          'dia_semana': 'Lunes a Domingo',
          'tipo_comida': c.tipoComida.length > 45 ? c.tipoComida.substring(0, 45) : c.tipoComida,
          'hora': parseHoraSafe(c.horarioSugerido),
          'alimento': c.platoNombre.length > 240 ? c.platoNombre.substring(0, 240) : c.platoNombre,
          'descripcion': descSafe.length > 240 ? descSafe.substring(0, 240) : descSafe,
          'cantidad': c.calorias,
          'unidad': 'kcal',
          'calorias': c.calorias,
          'proteinas': c.proteinasG,
          'carbohidratos': c.carbohidratosG,
          'grasas': c.grasasG,
          'observacion': lineasObservacion,
        };
      }).toList();

      final String objText = objetivoCustom != null && objetivoCustom.isNotEmpty
          ? '${rec.caloriasDiariasRecomendadas} kcal/día - $objetivoCustom'
          : '${rec.caloriasDiariasRecomendadas} kcal/día - Plan Nutricional Inteligente';

      final String safeNombre = 'Plan IA - $nombreAtleta'.length > 95
          ? 'Plan IA - $nombreAtleta'.substring(0, 95)
          : 'Plan IA - $nombreAtleta';

      String observacionGeneral = rec.resumenEstrategia;
      if (rec.hidratacionRecomendadaLitros > 0) {
        observacionGeneral = '$observacionGeneral\n\nHidratación recomendada: ${rec.hidratacionRecomendadaLitros.toStringAsFixed(1)} L/día';
      }

      final payload = {
        'nombre': safeNombre,
        'objetivo': objText.length > 240 ? objText.substring(0, 240) : objText,
        'observacion': observacionGeneral,
        'fecha_inicio': fechaHoy,
        'fecha_fin': fechaFin,
        'id_usuario': idUsuario,
        'estado': true,
        'detalles': detallesPayload,
      };

      final nutricionDataSource = ref.read(nutricionRemoteDataSourceProvider);
      final nuevoPlan = await nutricionDataSource.createPlanAlimentacion(payload);

      // Invalida la lista de planes para que se recargue de inmediato
      ref.invalidate(planesAlimentacionProvider);

      state = state.copyWith(
        isSaving: false,
        saveSuccess: true,
        planGuardado: nuevoPlan,
        clearSaveError: true,
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(
        isSaving: false,
        saveError: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        saveError: 'Error inesperado al guardar el plan oficial: $e',
      );
      return false;
    }
  }
}
