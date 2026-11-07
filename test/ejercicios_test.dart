import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dubss_app/features/ejercicios/data/datasources/ejercicios_remote_datasource.dart';
import 'package:dubss_app/features/ejercicios/data/models/ejercicio_model.dart';
import 'package:dubss_app/features/ejercicios/data/models/grupo_muscular_model.dart';
import 'package:dubss_app/features/ejercicios/data/models/tipo_ejercicio_model.dart';
import 'package:dubss_app/features/ejercicios/data/models/ejercicio_imagen_model.dart';
import 'package:dubss_app/features/ejercicios/presentation/screens/client_ejercicios_screen.dart';

class _FakeEjerciciosDataSource implements EjerciciosRemoteDataSource {
  @override
  Future<EjerciciosPaginadosModel> getEjercicios({
    String? search,
    int? idTipoEjercicio,
    int? idGrupoMuscular,
    int page = 1,
    int perPage = 15,
  }) async {
    return const EjerciciosPaginadosModel(
      data: [
        EjercicioModel(
          id: 5,
          nombre: '3/4 Abdominal',
          descripcion: 'Ejercicio de fortalecimiento abdominal',
          equipamiento: 'Peso corporal',
          tipoEjercicio: TipoEjercicioModel(id: 3, nombre: 'Fuerza'),
          gruposMusculares: [
            GrupoMuscularModel(id: 3, nombre: 'Abdominales'),
          ],
        ),
        EjercicioModel(
          id: 6,
          nombre: '90/90 Hamstring',
          descripcion: 'Estiramiento de isquiotibiales',
          equipamiento: 'Peso corporal',
          tipoEjercicio: TipoEjercicioModel(id: 4, nombre: 'Estiramiento'),
          gruposMusculares: [
            GrupoMuscularModel(id: 11, nombre: 'Isquiotibiales'),
            GrupoMuscularModel(id: 7, nombre: 'Pantorrillas'),
          ],
        ),
      ],
      meta: EjerciciosMetaModel(currentPage: 1, lastPage: 1, perPage: 15, total: 2),
    );
  }

  @override
  Future<EjercicioModel> getEjercicioDetail(int id) async {
    return const EjercicioModel(
      id: 5,
      nombre: '3/4 Abdominal',
      descripcion: 'Ejercicio de fortalecimiento abdominal',
      equipamiento: 'Peso corporal',
    );
  }

  @override
  Future<List<TipoEjercicioModel>> getTiposEjercicio() async {
    return const [
      TipoEjercicioModel(id: 3, nombre: 'Fuerza'),
      TipoEjercicioModel(id: 4, nombre: 'Estiramiento'),
    ];
  }

  @override
  Future<List<GrupoMuscularModel>> getGruposMusculares() async {
    return const [
      GrupoMuscularModel(id: 3, nombre: 'Abdominales'),
      GrupoMuscularModel(id: 11, nombre: 'Isquiotibiales'),
    ];
  }

  @override
  Future<List<EjercicioImagenModel>> getEjercicioImagenes(int idEjercicio) async {
    return [];
  }
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

  testWidgets('ClientEjerciciosScreen renders search bar, exercise cards, and count',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ejerciciosRemoteDataSourceProvider.overrideWithValue(_FakeEjerciciosDataSource()),
        ],
        child: const MaterialApp(
          home: ClientEjerciciosScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Catálogo de Ejercicios & Musculación'), findsOneWidget);
    expect(find.text('Buscar por nombre o descripción...'), findsOneWidget);
    expect(find.text('Listado de Ejercicios (2 en total)'), findsOneWidget);
    expect(find.text('3/4 Abdominal'), findsOneWidget);
    expect(find.text('90/90 Hamstring'), findsOneWidget);
    expect(find.text('FUERZA'), findsOneWidget);
    expect(find.text('ESTIRAMIENTO'), findsOneWidget);
    expect(find.text('Abdominales'), findsOneWidget);
  });
}
