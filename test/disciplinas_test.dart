import 'package:flutter_test/flutter_test.dart';
import 'package:dubss_app/features/disciplinas/data/models/disciplina_horario_model.dart';
import 'package:dubss_app/features/disciplinas/data/models/disciplina_model.dart';
import 'package:dubss_app/features/disciplinas/data/models/horario_model.dart';

void main() {
  group('Módulo Disciplinas & Horarios - Unit Tests', () {
    test('HorarioModel.fromJson parses time and days correctly', () {
      final json = {
        'id': 1,
        'dia_semana': 'Lunes, Miércoles y Viernes',
        'hora_inicio': '07:00:00',
        'hora_fin': '08:30:00',
      };

      final horario = HorarioModel.fromJson(json);

      expect(horario.id, equals(1));
      expect(horario.diaSemana, equals('Lunes, Miércoles y Viernes'));
      expect(horario.horaInicioFormateada, equals('07:00'));
      expect(horario.horaFinFormateada, equals('08:30'));
      expect(horario.horarioFormateado, equals('07:00 - 08:30'));
    });

    test('DisciplinaHorarioModel.fromJson calculates cupos and percentage', () {
      final json = {
        'id': 10,
        'id_disciplina': 2,
        'id_horario': 1,
        'cupo_maximo': 30,
        'cupos_ocupados': 15,
        'cupos_disponibles': 15,
        'estado': true,
        'disciplina': {'nombre': 'Kick Boxing'},
        'horario': {
          'id': 1,
          'dia_semana': 'Lunes, Miércoles y Viernes',
          'hora_inicio': '10:00',
          'hora_fin': '11:00',
        },
      };

      final dh = DisciplinaHorarioModel.fromJson(json);

      expect(dh.id, equals(10));
      expect(dh.cupoMaximo, equals(30));
      expect(dh.cuposOcupados, equals(15));
      expect(dh.cuposDisponibles, equals(15));
      expect(dh.tieneCupos, isTrue);
      expect(dh.porcentajeOcupacion, equals(0.5));
      expect(dh.disciplinaNombre, equals('Kick Boxing'));
      expect(dh.horario?.diaSemana, equals('Lunes, Miércoles y Viernes'));
    });

    test('DisciplinaModel.fromJson aggregates cupos and active status', () {
      final json = {
        'id': 3,
        'nombre': 'Boxeo Recreativo',
        'descripcion': 'Entrenamiento de boxeo olímpico y acondicionamiento',
        'cantidad_cupos': 50,
        'total_cupos_ocupados': 40,
        'total_cupos_disponibles': 10,
        'estado': 'activo',
        'disciplina_horarios': [
          {
            'id': 1,
            'id_disciplina': 3,
            'id_horario': 2,
            'cupo_maximo': 25,
            'cupos_ocupados': 20,
            'cupos_disponibles': 5,
            'estado': true,
            'horario': {
              'dia_semana': 'Martes y Jueves',
              'hora_inicio': '18:00',
              'hora_fin': '19:30',
            },
          },
        ],
      };

      final disc = DisciplinaModel.fromJson(json);

      expect(disc.id, equals(3));
      expect(disc.nombre, equals('Boxeo Recreativo'));
      expect(disc.isActive, isTrue);
      expect(disc.cuposTotales, equals(50));
      expect(disc.totalCuposOcupados, equals(40));
      expect(disc.totalCuposDisponibles, equals(10));
      expect(disc.tieneCuposDisponibles, isTrue);
      expect(disc.porcentajeOcupacion, equals(0.8));
      expect(disc.disciplinaHorarios.length, equals(1));
      expect(disc.diasAsignados, contains('Martes y Jueves'));
    });
  });
}
