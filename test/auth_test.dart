import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dubss_app/features/auth/presentation/screens/login_screen.dart';
import 'package:dubss_app/features/auth/presentation/screens/register_screen.dart';

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

  testWidgets('LoginScreen renders correctly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    expect(find.text('Iniciar Sesión'), findsWidgets);
    expect(find.text('Correo o Registro Universitario (R.U.)'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Crear Cuenta de Cliente UAGRM'), findsOneWidget);
  });

  testWidgets('RegisterScreen renders correctly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: RegisterScreen(),
        ),
      ),
    );

    expect(find.text('Crear Cuenta de Cliente'), findsOneWidget);
    expect(find.text('Completar Registro Cliente'), findsOneWidget);
  });
}
