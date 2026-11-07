import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:dubss_app/features/garita_accesos/data/models/registro_acceso_model.dart';
import 'package:dubss_app/features/users_admin/data/models/admin_user_model.dart';
import 'package:dubss_app/features/garita_accesos/presentation/providers/accesos_provider.dart';
import 'package:dubss_app/features/garita_accesos/presentation/widgets/resultado_acceso_banner.dart';

void main() {
  group('Módulo Recepcionista - Unit & Widget Tests', () {
    test('RegistroAccesoModel parsea JSON correctamente', () {
      final json = {
        'id': 101,
        'fecha_hora': '2026-10-18T14:30:00Z',
        'tipo': 'Entrada',
        'id_usuario': 12,
        'id_boleta_inscripcion': 5,
        'usuario': {
          'id': 12,
          'nombre': 'Carlos',
          'apellido': 'Perez',
          'email': 'cperez@uagrm.edu.bo',
          'ci': '9876543',
        },
        'boleta_inscripcion': {
          'id': 5,
          'numero_boleta': 'BOL-005',
          'estado': 'Activa',
        },
      };

      final model = RegistroAccesoModel.fromJson(json);

      expect(model.id, 101);
      expect(model.tipo, 'entrada');
      expect(model.isEntrada, isTrue);
      expect(model.nombreCompleto, 'Carlos Perez');
      expect(model.usuarioCi, '9876543');
      expect(model.boletaNumero, 'BOL-005');
    });

    test('AdminUserModel parsea JSON con roles y campos completos', () {
      final json = {
        'id': 45,
        'nombre': 'Ana',
        'apellido': 'Rodriguez',
        'email': 'ana.rod@uagrm.edu.bo',
        'ci': '5432109',
        'celular': '70012345',
        'estado': 'activo',
        'tipo_usuario': 'estudiante',
        'rol': 'recepcionista',
        'documentos': [
          {'id': 1, 'nombre': 'Certificado Médico'},
        ],
        'historiales': [
          {'id': 10, 'accion': 'Registro de ingreso'},
        ],
      };

      final user = AdminUserModel.fromJson(json);

      expect(user.id, 45);
      expect(user.nombre, 'Ana');
      expect(user.nombreCompleto, 'Ana Rodriguez');
      expect(user.isActivo, isTrue);
      expect(user.rol, 'recepcionista');
      expect(user.rolLabel, 'Recepcionista');
      expect(user.documentos.length, 1);
      expect(user.historiales.length, 1);
    });

    testWidgets('ResultadoAccesoBanner renderiza acceso autorizado con datos correctos', (tester) async {
      final scanResult = AccesoScanResult(
        permitido: true,
        mensaje: 'Acceso registrado correctamente',
        tipo: 'entrada',
        nombreSocio: 'Juan Valdivia',
        detalle: 'CI: 7788990 - Musculación',
        fechaHora: DateTime(2026, 10, 18, 10, 30),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResultadoAccesoBanner(
              result: scanResult,
              onDismiss: () {},
            ),
          ),
        ),
      );

      expect(find.text('ENTRADA'), findsOneWidget);
      expect(find.text('Acceso registrado correctamente'), findsOneWidget);
      expect(find.text('Juan Valdivia'), findsOneWidget);
      expect(find.text('CI: 7788990 - Musculación'), findsOneWidget);
    });

    testWidgets('ResultadoAccesoBanner renderiza acceso denegado correctamente', (tester) async {
      final scanResult = AccesoScanResult(
        permitido: false,
        mensaje: 'Usuario inactivo o sin membresía vigente',
        tipo: 'entrada',
        nombreSocio: 'Usuario No Identificado',
        detalle: 'Comuníquese con administración',
        fechaHora: DateTime(2026, 10, 18, 10, 30),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResultadoAccesoBanner(
              result: scanResult,
              onDismiss: () {},
            ),
          ),
        ),
      );

      expect(find.text('ENTRADA'), findsOneWidget);
      expect(find.text('Usuario inactivo o sin membresía vigente'), findsOneWidget);
      expect(find.text('Usuario No Identificado'), findsOneWidget);
    });
  });
}
