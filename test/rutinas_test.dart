import 'package:flutter_test/flutter_test.dart';
import 'package:dubss_app/features/rutinas/data/models/rutina_model.dart';
import 'package:dubss_app/features/rutinas/data/models/rutina_ejercicio_model.dart';
import 'package:dubss_app/features/rutinas/data/models/plan_entrenamiento_model.dart';

void main() {
  group('Rutinas Module - Models Unit Tests', () {
    test('RutinaEjercicioModel.fromJson parses complete data correctly', () {
      final json = {
        'id': 7,
        'series': 4,
        'repeticiones': 12,
        'peso': '20.5',
        'duracion_segundos': null,
        'descanso_segundos': 90,
        'orden': 1,
        'observacion': 'Mantener codos pegados al cuerpo',
        'id_ejercicio': 1,
        'id_rutina': 1,
        'ejercicio': {
          'id': 1,
          'nombre': 'Curl de Bíceps',
          'descripcion': 'Ejercicio para brazos',
          'id_tipo_ejercicio': 2,
          'tipo_ejercicio': {
            'id': 2,
            'nombre': 'Fuerza',
            'estado': true,
          },
          'imagenes': [],
        },
      };

      final item = RutinaEjercicioModel.fromJson(json);

      expect(item.id, equals(7));
      expect(item.series, equals(4));
      expect(item.repeticiones, equals(12));
      expect(item.peso, equals(20.5));
      expect(item.descansoSegundos, equals(90));
      expect(item.orden, equals(1));
      expect(item.observacion, equals('Mantener codos pegados al cuerpo'));
      expect(item.ejercicio?.nombre, equals('Curl de Bíceps'));
      expect(item.ejercicio?.tipoEjercicio?.nombre, equals('Fuerza'));
    });

    test('RutinaModel.fromJson calculates duration and parses rules', () {
      final json = {
        'id': 10,
        'nombre': 'Rutina Torso Pesado',
        'descripcion': 'Fuerza máxima e hipertrofia',
        'nivel': 'Avanzado',
        'estado': 1,
        'generado_por_ia': 1,
        'justificacion_reglas': [
          'Regla 1: Alto volumen de empuje',
          'Regla 2: Descanso extendido para SNC',
        ],
        'rutina_ejercicios': [
          {
            'id': 1,
            'series': 4,
            'repeticiones': 8,
            'descanso_segundos': 120,
            'orden': 1,
            'id_ejercicio': 1,
            'id_rutina': 10,
          },
          {
            'id': 2,
            'series': 3,
            'repeticiones': 10,
            'descanso_segundos': 60,
            'orden': 2,
            'id_ejercicio': 2,
            'id_rutina': 10,
          },
        ],
      };

      final rutina = RutinaModel.fromJson(json);

      expect(rutina.id, equals(10));
      expect(rutina.nombre, equals('Rutina Torso Pesado'));
      expect(rutina.nivel, equals('Avanzado'));
      expect(rutina.estado, isTrue);
      expect(rutina.generadoPorIa, isTrue);
      expect(rutina.justificacionReglas.length, equals(2));
      expect(rutina.totalEjercicios, equals(2));
      expect(rutina.duracionEstimadaMinutos, greaterThan(10));
    });

    test('PlanEntrenamientoModel.fromJson parses split days and finds routine by day', () {
      final json = {
        'id': 2,
        'nombre': 'Plan Fuerza 3 Días',
        'objetivo': 'HIPERTROFIA',
        'estado': true,
        'id_usuario': 5,
        'plan_entrenamiento_rutinas': [
          {
            'id': 1,
            'dia_semana': 'Lunes',
            'id_plan_entrenamiento': 2,
            'id_rutina': 10,
            'rutina': {
              'id': 10,
              'nombre': 'Pecho y Tríceps',
              'nivel': 'Intermedio',
              'estado': true,
              'rutina_ejercicios': [],
            },
          },
          {
            'id': 2,
            'dia_semana': 'Miércoles',
            'id_plan_entrenamiento': 2,
            'id_rutina': 11,
            'rutina': {
              'id': 11,
              'nombre': 'Espalda y Bíceps',
              'nivel': 'Intermedio',
              'estado': true,
              'rutina_ejercicios': [],
            },
          },
        ],
      };

      final plan = PlanEntrenamientoModel.fromJson(json);

      expect(plan.id, equals(2));
      expect(plan.nombre, equals('Plan Fuerza 3 Días'));
      expect(plan.objetivo, equals('HIPERTROFIA'));
      expect(plan.diasConfigurados, equals(['Lunes', 'Miércoles']));

      final rutinaLunes = plan.rutinaPorDia('Lunes');
      expect(rutinaLunes?.nombre, equals('Pecho y Tríceps'));

      final rutinaMiercoles = plan.rutinaPorDia('miércoles');
      expect(rutinaMiercoles?.nombre, equals('Espalda y Bíceps'));

      final rutinaDomingo = plan.rutinaPorDia('Domingo');
      expect(rutinaDomingo, isNull);
    });
  });
}
