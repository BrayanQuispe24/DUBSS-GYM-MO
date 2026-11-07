import 'package:flutter_test/flutter_test.dart';
import 'package:dubss_app/features/historial_clinico/data/models/evaluacion_antropometrica_model.dart';
import 'package:dubss_app/features/historial_clinico/data/models/ficha_medica_model.dart';
import 'package:dubss_app/features/historial_clinico/data/models/historial_clinico_completo_model.dart';

void main() {
  group('EvaluacionAntropometricaModel Tests', () {
    test('Calcula IMC correctamente según peso y estatura', () {
      final model = EvaluacionAntropometricaModel(
        fechaEvaluacion: DateTime.now(),
        pesoKg: 75.0,
        estaturaCm: 175.0,
      );

      // IMC = 75 / (1.75^2) = 24.489... -> 24.5
      expect(model.imcCalculado, equals(24.5));
      expect(model.clasificacionImc, equals('Peso normal'));
      expect(model.colorImcHex, equals(0xFF10B981));
    });

    test('Clasifica sobrepeso y obesidad correctamente', () {
      final sobrepeso = EvaluacionAntropometricaModel(
        fechaEvaluacion: DateTime.now(),
        pesoKg: 85.0,
        estaturaCm: 175.0,
      );
      expect(sobrepeso.clasificacionImc, equals('Sobrepeso'));

      final obesidad = EvaluacionAntropometricaModel(
        fechaEvaluacion: DateTime.now(),
        pesoKg: 105.0,
        estaturaCm: 175.0,
      );
      expect(obesidad.clasificacionImc, equals('Obesidad Clase I'));
    });
  });

  group('FichaMedicaModel Tests', () {
    test('Determina vigencia de certificado médico por fecha', () {
      final vigente = FichaMedicaModel(
        tieneCertificadoMedico: true,
        fechaVencimientoCertificado: DateTime.now().add(const Duration(days: 30)),
      );
      expect(vigente.isCertificadoVigente, isTrue);

      final vencido = FichaMedicaModel(
        tieneCertificadoMedico: true,
        fechaVencimientoCertificado: DateTime.now().subtract(const Duration(days: 10)),
      );
      expect(vencido.isCertificadoVigente, isFalse);
    });

    test('Parsea listas de alergias y enfermedades en formato String separado por comas', () {
      final json = {
        'alergias': 'Polen, Ibuprofeno',
        'enfermedades_cronicas': ['Asma'],
      };
      final model = FichaMedicaModel.fromJson(json);
      expect(model.alergias, containsAll(['Polen', 'Ibuprofeno']));
      expect(model.enfermedadesCronicas, contains('Asma'));
    });
  });

  group('HistorialClinicoCompletoModel Tests', () {
    test('Calcula deltas de peso, grasa y masa muscular entre última y penúltima evaluación', () {
      final ev1 = EvaluacionAntropometricaModel(
        fechaEvaluacion: DateTime.now().subtract(const Duration(days: 1)),
        pesoKg: 74.0,
        estaturaCm: 175.0,
        porcentajeGrasa: 17.0,
        porcentajeMusculo: 42.0,
      );
      final ev2 = EvaluacionAntropometricaModel(
        fechaEvaluacion: DateTime.now().subtract(const Duration(days: 30)),
        pesoKg: 76.0,
        estaturaCm: 175.0,
        porcentajeGrasa: 18.5,
        porcentajeMusculo: 40.5,
      );

      final model = HistorialClinicoCompletoModel(
        evaluaciones: [ev1, ev2],
      );

      expect(model.deltaPesoKg, equals(-2.0));
      expect(model.deltaGrasaPorcentaje, equals(-1.5));
      expect(model.deltaMusculoPorcentaje, equals(1.5));
    });
  });
}
