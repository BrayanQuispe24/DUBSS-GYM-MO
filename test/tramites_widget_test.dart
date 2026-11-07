import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

void main() {
  testWidgets('ClientTramitesScreen renders 3 tabs, solicitudes, boletas, and scanner button',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
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

    // Verify Header and Floating Scanner Button
    expect(find.text('TRÁMITES & PAGOS'), findsOneWidget);
    expect(find.text('Escanear QR'), findsOneWidget);
    expect(find.text('Solicitud'), findsOneWidget);

    // Verify 3 Tabs matching web
    expect(find.text('Solicitudes (1)'), findsOneWidget);
    expect(find.text('Boletas (1)'), findsOneWidget);
    expect(find.text('Pases / Ins. (1)'), findsOneWidget);

    // Verify Tab 1 (Default): Solicitud Card
    expect(find.text('DUBSS-FR-03-2026-1709'), findsOneWidget);
    expect(find.text('Kick Boxing'), findsOneWidget);
    expect(find.text('APROBADO'), findsOneWidget);
    expect(find.text('PDF DUBSS-FR-03'), findsOneWidget);

    // Tap Tab 2: Boletas de Pago
    await tester.tap(find.text('Boletas (1)'));
    await tester.pumpAndSettle();

    // Verify Payment Card in Tab 2
    expect(find.text('BOL-2026-0042'), findsOneWidget);
    expect(find.text('Arancel Plan Administrativos'), findsOneWidget);
    expect(find.text('Bs. 200.00'), findsOneWidget);
    expect(find.text('Ver Boleta PDF'), findsOneWidget);

    // Tap Tab 3: Pases / Inscripciones
    await tester.tap(find.text('Pases / Ins. (1)'));
    await tester.pumpAndSettle();

    // Verify Tab 3: Inscripción Card
    expect(find.text('Musculación y Cardio DUBSS'), findsOneWidget);
    expect(find.text('Pase QR'), findsOneWidget);
    expect(find.text('Boleta PDF'), findsOneWidget);
  });
}
