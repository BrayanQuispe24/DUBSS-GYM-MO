import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dubss_app/features/auth/data/models/user_model.dart';
import 'package:dubss_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:dubss_app/features/auth/presentation/providers/auth_state.dart';
import 'package:dubss_app/features/tramites/data/datasources/tramites_remote_datasource.dart';
import 'package:dubss_app/features/tramites/data/models/boleta_inscripcion_model.dart';
import 'package:dubss_app/features/tramites/data/models/boleta_pago_model.dart';
import 'package:dubss_app/features/tramites/data/models/formulario_solicitud_model.dart';
import 'package:dubss_app/features/tramites/presentation/screens/client_tramites_screen.dart';
import 'package:dio/dio.dart';

class FakeTramitesRemoteDataSource extends TramitesRemoteDataSource {
  FakeTramitesRemoteDataSource() : super(Dio());

  @override
  Future<List<FormularioSolicitudModel>> getFormulariosSolicitud() async {
    return [
      const FormularioSolicitudModel(
        id: 10,
        numeroFormulario: 'DUBSS-FR-03-2026-1709',
        estado: 'aprobado',
        idDisciplina: 3,
        disciplinaNombre: 'Kick Boxing',
        horarioTexto: 'Lunes, Miércoles y Viernes: 10:00 - 11:00',
        planNombre: 'Plan para estudiantes',
        tarifaPrecio: 100.0,
        idUsuario: 7,
        usuarioNombre: 'Brayan Quispe',
        documentosCount: 1,
      ),
    ];
  }

  @override
  Future<List<BoletaInscripcionModel>> getBoletasInscripcion() async {
    return [
      BoletaInscripcionModel(
        id: 1,
        numeroBoleta: 'INS-2026-00001',
        monto: 150.0,
        estado: 'activo',
        disciplina: 'Musculación y Cardio DUBSS',
        idUsuario: 2,
        usuarioNombre: 'Estudiante Prueba',
        fechaInicio: DateTime.now().subtract(const Duration(days: 2)),
        fechaFin: DateTime.now().add(const Duration(days: 28)),
      ),
    ];
  }

  @override
  Future<List<BoletaPagoModel>> getBoletasPago() async {
    return [
      const BoletaPagoModel(
        id: 42,
        numeroBoleta: 'BOL-2026-0042',
        monto: 200.0,
        metodoPago: 'Caja Campus UAGRM',
        concepto: 'Arancel Plan Administrativos',
        estado: 'completado',
        usuarioNombre: 'Estudiante Prueba',
      ),
    ];
  }
}

class TestAuthNotifier extends AuthNotifier {
  final UserModel? testUser;
  TestAuthNotifier(this.testUser);

  @override
  AuthState build() {
    return AuthState(
      status: testUser != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
      user: testUser,
    );
  }
}

void main() {
  testWidgets('ClientTramitesScreen DOES NOT show Escanear QR button for client user',
      (tester) async {
    const clientUser = UserModel(
      id: 7,
      name: 'Brayan Quispe',
      email: 'brayan@uagrm.edu.bo',
      rol: 'cliente',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(() => TestAuthNotifier(clientUser)),
          tramitesRemoteDataSourceProvider
              .overrideWithValue(FakeTramitesRemoteDataSource()),
        ],
        child: const MaterialApp(
          home: ClientTramitesScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Header and NO Scanner button for client
    expect(find.text('TRÁMITES & PAGOS'), findsOneWidget);
    expect(find.text('Escanear QR'), findsNothing);
    expect(find.text('Solicitud'), findsOneWidget);

    // Verify Tab 1 (Default): Solicitud Card
    expect(find.text('DUBSS-FR-03-2026-1709'), findsOneWidget);
    expect(find.text('Kick Boxing'), findsOneWidget);
    expect(find.text('APROBADO'), findsOneWidget);
    expect(find.text('Ver PDF'), findsOneWidget);
  });

  testWidgets('ClientTramitesScreen SHOWS Escanear QR button for recepcionista or administrador',
      (tester) async {
    const receptionistUser = UserModel(
      id: 2,
      name: 'Recepcionista Turno Tarde',
      email: 'recepcion@uagrm.edu.bo',
      rol: 'recepcionista',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(() => TestAuthNotifier(receptionistUser)),
          tramitesRemoteDataSourceProvider
              .overrideWithValue(FakeTramitesRemoteDataSource()),
        ],
        child: const MaterialApp(
          home: ClientTramitesScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Escanear QR MUST be visible for receptionist
    expect(find.text('Escanear QR'), findsOneWidget);
  });
}
