import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dubss_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:dubss_app/features/auth/presentation/providers/auth_state.dart';
import 'package:dubss_app/features/auth/data/models/user_model.dart';
import 'package:dubss_app/features/rutinas/data/datasources/rutinas_remote_datasource.dart';
import 'package:dubss_app/features/rutinas/data/models/plan_entrenamiento_model.dart';
import 'package:dubss_app/features/rutinas/data/models/rutina_model.dart';
import 'package:dubss_app/features/rutinas/data/models/rutina_ejercicio_model.dart';
import 'package:dubss_app/features/rutinas/presentation/screens/client_rutinas_screen.dart';
import 'package:dio/dio.dart';

class FakeRutinasRemoteDataSource extends RutinasRemoteDataSource {
  FakeRutinasRemoteDataSource() : super(Dio());

  @override
  Future<List<PlanEntrenamientoModel>> getPlanesUsuario(int idUsuario) async {
    return [
      PlanEntrenamientoModel(
        id: 1,
        nombre: 'Plan de Potencia UAGRM',
        objetivo: 'HIPERTROFIA',
        estado: true,
        planEntrenamientoRutinas: [
          PlanEntrenamientoRutinaModel(
            id: 1,
            diaSemana: 'Lunes',
            idPlanEntrenamiento: 1,
            idRutina: 1,
            rutina: RutinaModel(
              id: 1,
              nombre: 'Pecho y Tríceps',
              nivel: 'Intermedio',
              estado: true,
              rutinaEjercicios: [
                const RutinaEjercicioModel(
                  id: 1,
                  series: 4,
                  repeticiones: 10,
                  descansoSegundos: 60,
                  orden: 1,
                  idEjercicio: 1,
                  idRutina: 1,
                ),
              ],
            ),
          ),
          const PlanEntrenamientoRutinaModel(
            id: 2,
            diaSemana: 'Miércoles',
            idPlanEntrenamiento: 1,
            idRutina: 2,
          ),
        ],
      ),
    ];
  }

  @override
  Future<List<RutinaModel>> getRutinasCatalogo() async {
    return [
      const RutinaModel(
        id: 1,
        nombre: 'Rutina Full Body Funcional',
        nivel: 'Principiante',
        estado: true,
      ),
      const RutinaModel(
        id: 2,
        nombre: 'Rutina Hipertrofia Avanzada',
        nivel: 'Avanzado',
        estado: true,
      ),
    ];
  }
}

class FakeAuthNotifier extends AuthNotifier {
  @override
  AuthState build() {
    return const AuthState(
      status: AuthStatus.authenticated,
      user: UserModel(
        id: 1,
        name: 'Estudiante UAGRM',
        email: 'estudiante@uagrm.edu.bo',
        rol: 'cliente',
      ),
      token: 'fake_jwt_token',
    );
  }
}

void main() {
  testWidgets('ClientRutinasScreen renders tabs, plan header, and days', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(FakeAuthNotifier.new),
          rutinasRemoteDataSourceProvider.overrideWithValue(FakeRutinasRemoteDataSource()),
        ],
        child: const MaterialApp(
          home: ClientRutinasScreen(),
        ),
      ),
    );

    // Initial pump and wait for future resolution
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Screen Header
    expect(find.text('RUTINAS DEPORTIVAS'), findsOneWidget);

    // Verify Tab Bar Items
    expect(find.text('Mis Planes'), findsOneWidget);
    expect(find.text('Explorar Catálogo'), findsOneWidget);

    // Verify Plan Name in Card and tags
    expect(find.text('Plan de Potencia UAGRM'), findsOneWidget);
    expect(find.text('HIPERTROFIA'), findsOneWidget);
    expect(find.text('Lunes'), findsOneWidget);
    expect(find.text('Miércoles'), findsOneWidget);

    // Tap on plan card to open detail
    await tester.tap(find.text('Plan de Potencia UAGRM'));
    await tester.pumpAndSettle();

    // Verify back button in detail
    expect(find.text('Volver a mis planes'), findsOneWidget);

    // Tap back button
    await tester.tap(find.text('Volver a mis planes'));
    await tester.pumpAndSettle();

    // Back to plan list
    expect(find.text('PLANES DE ENTRENAMIENTO ASIGNADOS'), findsOneWidget);

    // Tap Catalog tab
    await tester.tap(find.text('Explorar Catálogo'));
    await tester.pumpAndSettle();

    // Verify catalog filter chips
    expect(find.text('Todos los Niveles'), findsOneWidget);
    expect(find.text('Principiante'), findsOneWidget);
    expect(find.text('Intermedio'), findsOneWidget);
    expect(find.text('Avanzado'), findsOneWidget);

    // Verify catalog routine card
    expect(find.text('Rutina Full Body Funcional'), findsOneWidget);
  });
}
