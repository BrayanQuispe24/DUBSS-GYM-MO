import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dubss_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:go_router/go_router.dart';

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

  testWidgets('SplashScreen renders institutional emblem, titles and branding',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    final testRouter = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('Landing Screen')),
        ),
        GoRoute(
          path: '/client',
          builder: (context, state) => const Scaffold(body: Text('Client Screen')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: testRouter,
        ),
      ),
    );

    // Initial frame
    await tester.pump();

    // Verify presence of emblem icon and institutional branding
    expect(find.byIcon(Icons.fitness_center), findsOneWidget);
    expect(find.text('GIMNASIO UAGRM'), findsOneWidget);
    expect(find.text('D.U.B.S.S. SYSTEM'), findsOneWidget);
    expect(
      find.text('Dirección Universitaria de Bienestar Social y Salud'),
      findsOneWidget,
    );
    expect(
      find.text('UNIVERSIDAD AUTÓNOMA GABRIEL RENÉ MORENO'),
      findsOneWidget,
    );

    // Advance animation partially
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    // Complete timer and settle navigation
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    expect(find.text('Landing Screen'), findsOneWidget);
  });
}
