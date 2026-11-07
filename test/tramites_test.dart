import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:dubss_app/features/tramites/data/models/boleta_inscripcion_model.dart';
import 'package:dubss_app/features/tramites/data/models/boleta_pago_model.dart';
import 'package:dubss_app/features/tramites/data/models/formulario_solicitud_model.dart';
import 'package:dubss_app/features/tramites/data/models/qr_acceso_model.dart';
import 'package:dubss_app/features/tramites/data/models/validacion_acceso_model.dart';
import 'package:dubss_app/features/tramites/presentation/widgets/pdf_boleta_inscripcion_builder.dart';
import 'package:dubss_app/features/tramites/presentation/widgets/pdf_boleta_pago_builder.dart';
import 'package:dubss_app/features/tramites/presentation/widgets/pdf_formulario_dubss_builder.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Módulo Trámites y Pagos - Unit Tests', () {
    test('BoletaPagoModel.fromJson parses nested data correctly', () {
      final json = {
        'id': 42,
        'numero_boleta': 'BOL-2026-0042',
        'fecha_pago': '2026-10-15T14:30:00.000000Z',
        'monto': '200.00',
        'metodo_pago': 'Caja Campus UAGRM',
        'concepto': 'Arancel Plan Administrativos',
        'estado': 'completado',
        'comprobante_url': 'COMP-998811',
        'formulario_solicitud': {
          'usuario': {
            'nombre': 'Carlos',
            'apellido': 'Méndez',
          },
          'plan': {'nombre': 'Plan Administrativos'},
          'disciplina': {'nombre': 'Musculación'},
        },
      };

      final boleta = BoletaPagoModel.fromJson(json);

      expect(boleta.id, equals(42));
      expect(boleta.numeroBoleta, equals('BOL-2026-0042'));
      expect(boleta.monto, equals(200.00));
      expect(boleta.isPagado, isTrue);
      expect(boleta.estadoLabel, equals('PAGADO'));
      expect(boleta.usuarioNombre, equals('Carlos Méndez'));
      expect(boleta.planNombre, equals('Plan Administrativos'));
      expect(boleta.disciplinaNombre, equals('Musculación'));
    });

    test('BoletaInscripcionModel.fromJson evaluates validity and remaining days', () {
      final now = DateTime.now();
      final fechaInicio = now.subtract(const Duration(days: 5));
      final fechaFin = now.add(const Duration(days: 25));

      final json = {
        'id': 1,
        'numero_boleta': 'INS-2026-00001',
        'fecha_inscripcion': now.toIso8601String(),
        'fecha_inicio': fechaInicio.toIso8601String(),
        'fecha_fin': fechaFin.toIso8601String(),
        'monto': 150.0,
        'estado': 'activo',
        'disciplina': 'Gimnasio Musculación DUBSS',
        'hora_inicio': '07:00:00',
        'hora_salida': '09:00:00',
        'id_usuario': 2,
        'usuario': {
          'nombre': 'Brayan',
          'apellido': 'Rojas',
          'registro_universitario': '218000000',
          'ci': '1234567',
        },
      };

      final inscripcion = BoletaInscripcionModel.fromJson(json);

      expect(inscripcion.id, equals(1));
      expect(inscripcion.numeroBoleta, equals('INS-2026-00001'));
      expect(inscripcion.isActiva, isTrue);
      expect(inscripcion.diasRestantes, greaterThanOrEqualTo(24));
      expect(inscripcion.horarioFormateado, equals('07:00 - 09:00'));
      expect(inscripcion.usuarioNombre, equals('Brayan Rojas'));
      expect(inscripcion.usuarioRu, equals('218000000'));
    });

    test('QRAccesoModel.fromJson parses signed access pass', () {
      final json = {
        'boleta_id': 1,
        'numero_boleta': 'INS-2026-00001',
        'usuario': {
          'nombre': 'Brayan Rojas',
          'email': 'brayan@uagrm.edu.bo',
          'ci': '1234567',
          'registro_universitario': '218000000',
        },
        'membresia': {
          'disciplina': 'Gimnasio Musculación',
          'horario_texto': '07:00 - 09:00',
          'fecha_inicio': '2026-10-01',
          'fecha_fin': '2026-10-31',
          'estado': 'activo',
          'monto': 150.0,
        },
        'qr_payload': '{"boleta_id":1,"sig":"abc"}',
        'signature': 'abc',
      };

      final qr = QRAccesoModel.fromJson(json);

      expect(qr.boletaId, equals(1));
      expect(qr.numeroBoleta, equals('INS-2026-00001'));
      expect(qr.usuarioNombre, equals('Brayan Rojas'));
      expect(qr.qrPayload, contains('"boleta_id":1'));
      expect(qr.signature, equals('abc'));
    });

    test('ValidacionAccesoModel.fromJson parses access permissions', () {
      final jsonOk = {
        'permitido': true,
        'mensaje': 'Acceso permitido. Bienvenido al Gimnasio DUBSS.',
        'tipo': 'entrada',
        'usuario': {
          'nombre': 'Brayan Rojas',
          'registro_universitario': '218000000',
        },
        'boleta': {
          'numero_boleta': 'INS-2026-00001',
          'disciplina': 'Gimnasio Musculación',
        },
      };

      final valOk = ValidacionAccesoModel.fromJson(jsonOk);
      expect(valOk.permitido, isTrue);
      expect(valOk.usuarioNombre, equals('Brayan Rojas'));
      expect(valOk.disciplina, equals('Gimnasio Musculación'));

      final jsonDenied = {
        'permitido': false,
        'motivo': 'MEMBRESIA_VENCIDA',
        'mensaje': 'Acceso denegado: Su membresía ha vencido.',
        'tipo': 'entrada',
      };

      final valDenied = ValidacionAccesoModel.fromJson(jsonDenied);
      expect(valDenied.permitido, isFalse);
      expect(valDenied.motivo, equals('MEMBRESIA_VENCIDA'));
    });

    test('PdfBoletaPagoBuilder generates valid PDF bytes', () async {
      const boleta = BoletaPagoModel(
        id: 1,
        numeroBoleta: 'BOL-TEST-001',
        monto: 200.0,
        metodoPago: 'Caja Campus',
        concepto: 'Arancel Prueba',
        estado: 'completado',
        usuarioNombre: 'Alumno Prueba',
      );

      final bytes = await PdfBoletaPagoBuilder.buildPdf(boleta);
      expect(bytes, isNotEmpty);
      // Valid PDF document begins with %PDF-
      final header = utf8.decode(bytes.sublist(0, 5));
      expect(header, equals('%PDF-'));
    });

    test('PdfBoletaInscripcionBuilder generates valid PDF bytes with QR', () async {
      final boleta = BoletaInscripcionModel(
        id: 1,
        numeroBoleta: 'INS-TEST-001',
        monto: 150.0,
        estado: 'activo',
        disciplina: 'Musculación',
        idUsuario: 10,
        usuarioNombre: 'Alumno Prueba',
        usuarioRu: '218000111',
        fechaInicio: DateTime.now(),
        fechaFin: DateTime.now().add(const Duration(days: 30)),
      );

      final bytes = await PdfBoletaInscripcionBuilder.buildPdf(boleta);
      expect(bytes, isNotEmpty);
      final header = utf8.decode(bytes.sublist(0, 5));
      expect(header, equals('%PDF-'));
    });

    test('FormularioSolicitudModel.fromJson parses request fields correctly', () {
      final json = {
        'id': 10,
        'numero_formulario': 'DUBSS-FR-03-2026-1709',
        'estado': 'aprobado',
        'fecha_registro': '2026-10-18T10:00:00.000000Z',
        'id_disciplina': 3,
        'disciplina': {
          'id': 3,
          'nombre': 'Kick Boxing',
        },
        'disciplina_horario': {
          'id': 5,
          'horario': {
            'dia_semana': 'Lunes, Miércoles y Viernes',
            'hora_inicio': '10:00',
            'hora_fin': '11:00',
          },
        },
        'plan': {
          'id': 2,
          'nombre': 'Plan para estudiantes',
          'tarifa': {'precio': '100.00'},
        },
        'id_usuario': 7,
        'usuario': {
          'nombre': 'Brayan',
          'apellido': 'Quispe',
          'email': 'brayan@uagrm.edu.bo',
          'ci': '9876543',
          'registro_universitario': '219000123',
          'documentos': [{'id': 1}],
        },
      };

      final form = FormularioSolicitudModel.fromJson(json);

      expect(form.id, equals(10));
      expect(form.numeroFormulario, equals('DUBSS-FR-03-2026-1709'));
      expect(form.isAprobado, isTrue);
      expect(form.estadoLabel, equals('APROBADO'));
      expect(form.disciplinaNombre, equals('Kick Boxing'));
      expect(form.horarioTexto, equals('Lunes, Miércoles y Viernes: 10:00 - 11:00'));
      expect(form.planNombre, equals('Plan para estudiantes'));
      expect(form.tarifaPrecio, equals(100.00));
      expect(form.usuarioNombre, equals('Brayan Quispe'));
      expect(form.usuarioCi, equals('9876543'));
      expect(form.usuarioRegistro, equals('219000123'));
      expect(form.documentosCount, equals(1));
    });

    test('PdfFormularioDubssBuilder generates valid official DUBSS-FR-03 PDF', () async {
      const form = FormularioSolicitudModel(
        id: 1,
        numeroFormulario: 'DUBSS-FR-03-2026-1709',
        estado: 'aprobado',
        idDisciplina: 3,
        disciplinaNombre: 'Kick Boxing',
        horarioTexto: 'Lunes, Miércoles y Viernes: 10:00 - 11:00',
        planNombre: 'Plan para estudiantes',
        tarifaPrecio: 100.0,
        idUsuario: 7,
        usuarioNombre: 'Brayan Quispe',
        usuarioEmail: 'brayan@uagrm.edu.bo',
        usuarioCi: '9876543',
        usuarioRegistro: '219000123',
        documentosCount: 1,
      );

      final bytes = await PdfFormularioDubssBuilder.buildPdf(form);
      expect(bytes, isNotEmpty);
      final header = utf8.decode(bytes.sublist(0, 5));
      expect(header, equals('%PDF-'));
    });
  });
}
