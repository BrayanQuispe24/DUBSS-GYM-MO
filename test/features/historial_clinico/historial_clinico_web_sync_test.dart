import 'package:flutter_test/flutter_test.dart';
import 'package:dubss_app/features/historial_clinico/data/models/antecedente_model.dart';
import 'package:dubss_app/features/historial_clinico/data/models/detalle_historial_model.dart';
import 'package:dubss_app/features/historial_clinico/data/models/historial_model.dart';

void main() {
  group('DetalleHistorialModel Tests (Alineado con DB)', () {
    test('Calcula IMC correctamente con altura en cm', () {
      final detalle = DetalleHistorialModel(
        idHistorial: 1,
        peso: 70.0,
        altura: 175.0,
        fechaRegistro: DateTime.now(),
      );

      // IMC = 70 / (1.75^2) = 22.857 -> 22.9
      expect(detalle.imcCalculado, equals(22.9));
      expect(detalle.clasificacionImc, equals('Peso normal'));
      expect(detalle.colorImcHex, equals(0xFF10B981));
    });

    test('Parsea JSON del backend Laravel correctamente', () {
      final json = {
        'id': 10,
        'id_historial': 2,
        'peso': '74.5',
        'altura': '176',
        'imc': 24.0,
        'porcentaje_grasa': '16.5',
        'masa_muscular': '43.0',
        'presion': '120/80',
        'fecha_registro': '2026-10-18',
      };

      final model = DetalleHistorialModel.fromJson(json);
      expect(model.id, equals(10));
      expect(model.idHistorial, equals(2));
      expect(model.peso, equals(74.5));
      expect(model.altura, equals(176.0));
      expect(model.porcentajeGrasa, equals(16.5));
      expect(model.presion, equals('120/80'));
    });
  });

  group('AntecedenteModel Tests (Cuestionario DUBSS)', () {
    test('Detecta si el socio tiene alguna condición médica declarada', () {
      const limpio = AntecedenteModel(
        idHistorial: 1,
      );
      expect(limpio.tieneAlgunaCondicionMedica, isFalse);

      const conAlergia = AntecedenteModel(
        idHistorial: 1,
        tieneAlergias: true,
        detalleAlergias: 'Ibuprofeno',
      );
      expect(conAlergia.tieneAlgunaCondicionMedica, isTrue);
    });

    test('Parsea booleanos representados como 1/0 o strings en la API', () {
      final json = {
        'id_historial': 5,
        'tiene_enfermedades_cardiovasculares': 1,
        'detalle_enfermedades_cardiovasculares': 'Soplo leve',
        'tiene_hipertension_arterial': '0',
      };

      final model = AntecedenteModel.fromJson(json);
      expect(model.tieneEnfermedadesCardiovasculares, isTrue);
      expect(model.detalleEnfermedadesCardiovasculares, equals('Soplo leve'));
      expect(model.tieneHipertensionArterial, isFalse);
    });
  });

  group('HistorialModel Tests (Relaciones y Deltas)', () {
    test('Calcula variación de peso entre mediciones cronológicas', () {
      final m1 = DetalleHistorialModel(
        idHistorial: 1,
        peso: 72.0,
        fechaRegistro: DateTime(2026, 10, 15),
      );
      final m2 = DetalleHistorialModel(
        idHistorial: 1,
        peso: 74.0,
        fechaRegistro: DateTime(2026, 9, 15),
      );

      final historial = HistorialModel(
        id: 1,
        idUsuario: 10,
        detalles: [m1, m2],
      );

      expect(historial.ultimaMedicion?.peso, equals(72.0));
      expect(historial.deltaPeso, equals(-2.0)); // Bajó 2 kg
    });
  });
}
