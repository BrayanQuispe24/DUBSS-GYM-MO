import 'evaluacion_antropometrica_model.dart';
import 'ficha_medica_model.dart';

class HistorialClinicoCompletoModel {
  final FichaMedicaModel? fichaMedica;
  final List<EvaluacionAntropometricaModel> evaluaciones;

  const HistorialClinicoCompletoModel({
    this.fichaMedica,
    this.evaluaciones = const [],
  });

  EvaluacionAntropometricaModel? get ultimaEvaluacion =>
      evaluaciones.isNotEmpty ? evaluaciones.first : null;

  EvaluacionAntropometricaModel? get penultimaEvaluacion =>
      evaluaciones.length > 1 ? evaluaciones[1] : null;

  /// Retorna la diferencia de peso respecto a la evaluación anterior en kg
  double? get deltaPesoKg {
    if (ultimaEvaluacion == null || penultimaEvaluacion == null) return null;
    return double.parse(
      (ultimaEvaluacion!.pesoKg - penultimaEvaluacion!.pesoKg).toStringAsFixed(1),
    );
  }

  /// Retorna la diferencia de grasa corporal respecto a la evaluación anterior
  double? get deltaGrasaPorcentaje {
    final act = ultimaEvaluacion?.porcentajeGrasa;
    final ant = penultimaEvaluacion?.porcentajeGrasa;
    if (act == null || ant == null) return null;
    return double.parse((act - ant).toStringAsFixed(1));
  }

  /// Retorna la diferencia de masa muscular respecto a la evaluación anterior
  double? get deltaMusculoPorcentaje {
    final act = ultimaEvaluacion?.porcentajeMusculo;
    final ant = penultimaEvaluacion?.porcentajeMusculo;
    if (act == null || ant == null) return null;
    return double.parse((act - ant).toStringAsFixed(1));
  }

  factory HistorialClinicoCompletoModel.fromJson(Map<String, dynamic> json) {
    FichaMedicaModel? ficha;
    if (json['ficha_medica'] is Map<String, dynamic>) {
      ficha = FichaMedicaModel.fromJson(json['ficha_medica'] as Map<String, dynamic>);
    } else if (json['ficha'] is Map<String, dynamic>) {
      ficha = FichaMedicaModel.fromJson(json['ficha'] as Map<String, dynamic>);
    }

    List<EvaluacionAntropometricaModel> evals = [];
    final evalsRaw = json['evaluaciones'] ?? json['mediciones'] ?? json['antropometria'];
    if (evalsRaw is List) {
      evals = evalsRaw
          .whereType<Map<String, dynamic>>()
          .map((e) => EvaluacionAntropometricaModel.fromJson(e))
          .toList();
      // Ordenar descendente por fecha
      evals.sort((a, b) => b.fechaEvaluacion.compareTo(a.fechaEvaluacion));
    }

    return HistorialClinicoCompletoModel(
      fichaMedica: ficha,
      evaluaciones: evals,
    );
  }
}
