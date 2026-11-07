import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dubss_app/features/documentos/data/datasources/documentos_remote_datasource.dart';
import 'package:dubss_app/features/documentos/data/models/documento_model.dart';
import 'package:dubss_app/features/documentos/data/models/tipo_documento_model.dart';
import 'package:dubss_app/features/documentos/presentation/screens/client_documentos_screen.dart';

class FakeDocumentosRemoteDataSource extends DocumentosRemoteDataSource {
  FakeDocumentosRemoteDataSource() : super(Dio());

  @override
  Future<List<TipoDocumentoModel>> getTiposDocumento() async {
    return [
      const TipoDocumentoModel(id: 1, nombre: 'Cédula de Identidad', descripcion: 'Fotocopia CI'),
      const TipoDocumentoModel(id: 2, nombre: 'Certificado Médico', descripcion: 'Certificado de aptitud'),
    ];
  }

  @override
  Future<List<DocumentoModel>> getDocumentos() async {
    return [
      DocumentoModel(
        id: 101,
        idUsuario: 5,
        idTipoDocumento: 1,
        titulo: 'Carnet de Identidad Anverso y Reverso',
        archivoUrl: 'documentos/carnet_ci_101.pdf',
        createdAt: DateTime(2026, 10, 18),
        tipoDocumento: const TipoDocumentoModel(id: 1, nombre: 'Cédula de Identidad'),
      ),
      DocumentoModel(
        id: 102,
        idUsuario: 5,
        idTipoDocumento: 2,
        titulo: 'Certificado Médico Cardiorrespiratorio',
        archivoUrl: 'documentos/cert_medico_102.pdf',
        createdAt: DateTime(2026, 10, 15),
        tipoDocumento: const TipoDocumentoModel(id: 2, nombre: 'Certificado Médico'),
      ),
    ];
  }
}

void main() {
  group('Módulo Documentación Digital - Unit Tests', () {
    test('TipoDocumentoModel parses correctly from and to JSON', () {
      final json = {
        'id': 1,
        'nombre': 'Certificado Médico',
        'descripcion': 'Aptitud física 2026',
      };
      final model = TipoDocumentoModel.fromJson(json);

      expect(model.id, 1);
      expect(model.nombre, 'Certificado Médico');
      expect(model.descripcion, 'Aptitud física 2026');
      expect(model.toJson()['id'], 1);
    });

    test('DocumentoModel resolves PDF, displayTitle, and fullFileUrl', () {
      final doc = DocumentoModel(
        id: 50,
        idUsuario: 12,
        idTipoDocumento: 1,
        titulo: 'Ficha Médica',
        archivoUrl: 'documentos/archivo.pdf',
        createdAt: DateTime(2026, 5, 20),
        tipoDocumento: const TipoDocumentoModel(id: 1, nombre: 'Cédula de Identidad'),
      );

      expect(doc.isPdf, isTrue);
      expect(doc.isImage, isFalse);
      expect(doc.displayTitle, 'Ficha Médica');
      expect(doc.displayTipoNombre, 'Cédula de Identidad');
      expect(doc.formattedDate, '20/05/2026');
      expect(doc.fullFileUrl, contains('documentos/archivo.pdf'));
    });

    test('DocumentoModel recognizes image files', () {
      final doc = DocumentoModel(
        id: 51,
        idUsuario: 12,
        idTipoDocumento: 1,
        archivoUrl: 'documentos/foto_carnet.png',
      );

      expect(doc.isPdf, isFalse);
      expect(doc.isImage, isTrue);
      expect(doc.displayTitle, 'Documento #51');
    });
  });

  group('Módulo Documentación Digital - Widget Tests', () {
    testWidgets('ClientDocumentosScreen renders list, search, chips and cards', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            documentosRemoteDataSourceProvider.overrideWithValue(
              FakeDocumentosRemoteDataSource(),
            ),
          ],
          child: const MaterialApp(
            home: ClientDocumentosScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verificar cabecera
      expect(find.text('Documentación Digital'), findsOneWidget);
      expect(find.text('Repositorio institucional de respaldos'), findsOneWidget);

      // Verificar chips de filtro
      expect(find.text('Todos'), findsOneWidget);
      expect(find.text('Cédula de Identidad'), findsWidgets);
      expect(find.text('Certificado Médico'), findsWidgets);

      // Verificar cards de documentos cargados
      expect(find.text('Carnet de Identidad Anverso y Reverso'), findsOneWidget);
      expect(find.text('Certificado Médico Cardiorrespiratorio'), findsOneWidget);

      // Verificar botón flotante
      expect(find.text('Subir PDF'), findsOneWidget);
    });
  });
}
