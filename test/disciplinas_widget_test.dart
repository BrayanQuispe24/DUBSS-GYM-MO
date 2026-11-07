import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dubss_app/features/disciplinas/data/datasources/disciplinas_remote_datasource.dart';
import 'package:dubss_app/features/disciplinas/data/models/disciplina_horario_model.dart';
import 'package:dubss_app/features/disciplinas/data/models/disciplina_model.dart';
import 'package:dubss_app/features/disciplinas/data/models/horario_model.dart';
import 'package:dubss_app/features/disciplinas/presentation/screens/client_disciplinas_screen.dart';
import 'package:dio/dio.dart';

class FakeDisciplinasRemoteDataSource extends DisciplinasRemoteDataSource {
  FakeDisciplinasRemoteDataSource() : super(Dio());

  @override
  Future<List<DisciplinaModel>> getDisciplinas() async {
    return [
      const DisciplinaModel(
        id: 1,
        nombre: 'Kick Boxing',
        descripcion: 'Arte marcial y acondicionamiento cardiovascular',
        cantidadCupos: 40,
        totalCuposOcupados: 25,
        totalCuposDisponibles: 15,
        estado: 'activo',
        disciplinaHorarios: [
          DisciplinaHorarioModel(
            id: 10,
            idDisciplina: 1,
            idHorario: 5,
            cupoMaximo: 20,
            cuposOcupados: 12,
            cuposDisponibles: 8,
            estado: true,
            disciplinaNombre: 'Kick Boxing',
            horario: HorarioModel(
              id: 5,
              diaSemana: 'Lunes, Miércoles y Viernes',
              horaInicio: '10:00',
              horaFin: '11:00',
            ),
          ),
        ],
      ),
    ];
  }

  @override
  Future<List<DisciplinaHorarioModel>> getDisciplinaHorarios() async {
    return [
      const DisciplinaHorarioModel(
        id: 10,
        idDisciplina: 1,
        idHorario: 5,
        cupoMaximo: 20,
        cuposOcupados: 12,
        cuposDisponibles: 8,
        estado: true,
        disciplinaNombre: 'Kick Boxing',
        horario: HorarioModel(
          id: 5,
          diaSemana: 'Lunes, Miércoles y Viernes',
          horaInicio: '10:00',
          horaFin: '11:00',
        ),
      ),
    ];
  }
}

void main() {
  testWidgets('ClientDisciplinasScreen renders catalog, detail modal, and switches to cronograma',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          disciplinasRemoteDataSourceProvider
              .overrideWithValue(FakeDisciplinasRemoteDataSource()),
        ],
        child: const MaterialApp(
          home: ClientDisciplinasScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 1. Verify Header and Floating Action Button
    expect(find.text('DISCIPLINAS & HORARIOS'), findsOneWidget);
    expect(find.text('Inscribirme'), findsOneWidget);

    // 2. Verify View Switcher Tabs
    expect(find.text('Catálogo Disciplinas'), findsOneWidget);
    expect(find.text('Cronograma Turnos'), findsOneWidget);

    // 3. Verify Disciplina Card in Catálogo
    expect(find.text('Kick Boxing'), findsOneWidget);
    expect(find.text('ACTIVA'), findsOneWidget);
    expect(find.text('15 cupos libres'), findsOneWidget);
    expect(find.text('Ver Horarios'), findsOneWidget);

    // 4. Tap 'Ver Horarios' to open DisciplinaDetailModal
    await tester.tap(find.text('Ver Horarios'));
    await tester.pumpAndSettle();

    // Verify Modal Content
    expect(find.text('Expediente Deportivo UAGRM • ID #1'), findsOneWidget);
    expect(find.text('40 Cupos'), findsOneWidget);
    expect(find.text('+ Iniciar Solicitud (DUBSS-FR-03)'), findsOneWidget);

    // Close Modal
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // 5. Tap 'Cronograma Turnos' to switch view
    await tester.tap(find.text('Cronograma Turnos'));
    await tester.pumpAndSettle();

    // Verify Schedule View Content
    expect(find.text('Todos los Días'), findsOneWidget);
    expect(find.text('10:00 - 11:00'), findsOneWidget);
    expect(find.text('Lunes, Miércoles y Viernes'), findsOneWidget);
  });
}
