import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dubss_app/features/client_dashboard/presentation/screens/client_shell_screen.dart';
import 'package:dubss_app/features/planes/presentation/screens/client_planes_screen.dart';
import 'package:dubss_app/features/planes/data/datasources/planes_remote_datasource.dart';
import 'package:dubss_app/features/planes/data/models/plan_model.dart';

import 'package:dio/dio.dart';
import 'package:dubss_app/features/rutinas/data/datasources/rutinas_remote_datasource.dart';
import 'package:dubss_app/features/rutinas/data/models/plan_entrenamiento_model.dart';
import 'package:dubss_app/features/rutinas/data/models/rutina_model.dart';
import 'package:dubss_app/features/tramites/data/datasources/tramites_remote_datasource.dart';
import 'package:dubss_app/features/tramites/data/models/boleta_inscripcion_model.dart';
import 'package:dubss_app/features/tramites/data/models/boleta_pago_model.dart';

class _FakePlanesDataSource implements PlanesRemoteDataSource {
  @override
  Future<List<PlanModel>> getPlanes() async {
    return const [
      PlanModel(
        id: 1,
        nombre: 'Plan para administrativos',
        descripcion: 'Acceso para personal administrativo.',
        duracionDias: 30,
        estado: true,
        tarifa: TarifaModel(id: 1, nombre: 'ADMINISTRATIVOS', precio: '200.00'),
      ),
      PlanModel(
        id: 2,
        nombre: 'Plan para estudiantes',
        descripcion: 'Tarifa preferencial para estudiantes.',
        duracionDias: 30,
        estado: true,
        tarifa: TarifaModel(id: 2, nombre: 'ESTUDIANTES', precio: '100.00'),
      ),
    ];
  }
}

class _FakeRutinasDataSource extends RutinasRemoteDataSource {
  _FakeRutinasDataSource() : super(Dio());
  @override
  Future<List<PlanEntrenamientoModel>> getPlanesUsuario(int idUsuario) async => [];
  @override
  Future<List<RutinaModel>> getRutinasCatalogo() async => [];
}

class _FakeTramitesDataSource extends TramitesRemoteDataSource {
  _FakeTramitesDataSource() : super(Dio());
  @override
  Future<List<BoletaInscripcionModel>> getBoletasInscripcion() async => [];
  @override
  Future<List<BoletaPagoModel>> getBoletasPago() async => [];
}

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  testWidgets('ClientPlanesScreen renders institutional header and filters',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          planesRemoteDataSourceProvider.overrideWithValue(_FakePlanesDataSource()),
        ],
        child: const MaterialApp(
          home: ClientPlanesScreen(),
        ),
      ),
    );

    // Initial build
    await tester.pump();
    // Resolve future
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('GESTIÓN DE MEMBRESÍAS & TARIFAS'), findsOneWidget);
    expect(find.text('Todos'), findsOneWidget);
    expect(find.text('Estudiantes'), findsOneWidget);
    expect(find.text('Administrativos'), findsOneWidget);
    expect(find.text('Plan para administrativos'), findsOneWidget);
    expect(find.text('Plan para estudiantes'), findsOneWidget);
    expect(find.text('Bs. 200.00'), findsOneWidget);
    expect(find.text('Bs. 100.00'), findsOneWidget);
  });

  testWidgets('ClientShellScreen renders AppBar, Salir button, and BottomNav',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          planesRemoteDataSourceProvider.overrideWithValue(_FakePlanesDataSource()),
          rutinasRemoteDataSourceProvider.overrideWithValue(_FakeRutinasDataSource()),
          tramitesRemoteDataSourceProvider.overrideWithValue(_FakeTramitesDataSource()),
        ],
        child: const MaterialApp(
          home: ClientShellScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('GESTIÓN DE MEMBRESÍAS & TARIFAS'), findsOneWidget);
    expect(find.text('Planes'), findsOneWidget);
    expect(find.text('Rutinas'), findsOneWidget);
    expect(find.text('Menú'), findsOneWidget);
    expect(find.text('Trámites'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);

    // Tap on the center Menú button
    await tester.tap(find.text('Menú'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Verify full screen menu is opened
    expect(find.text('D.U.B.S.S. SYSTEM • MENÚ PRINCIPAL'), findsOneWidget);
    expect(find.text('MÓDULOS PRINCIPALES'), findsOneWidget);
    expect(find.text('Cerrar Sesión Segura'), findsOneWidget);

    // Close the full screen menu via [X] button
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Verify back to shell screen
    expect(find.text('D.U.B.S.S. SYSTEM • MENÚ PRINCIPAL'), findsNothing);
    expect(find.text('GESTIÓN DE MEMBRESÍAS & TARIFAS'), findsOneWidget);
  });
}
