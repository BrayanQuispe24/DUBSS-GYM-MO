import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dubss_app/features/nutricion/data/models/plan_alimentacion_model.dart';
import 'package:dubss_app/features/nutricion/presentation/providers/nutricion_provider.dart';
import 'package:dubss_app/features/nutricion/presentation/screens/client_nutricion_screen.dart';
import 'package:dubss_app/features/nutricion/presentation/screens/generar_plan_nutricional_screen.dart';
import 'package:dubss_app/features/nutricion/presentation/widgets/comida_detail_card.dart';
import 'package:dubss_app/features/nutricion/presentation/widgets/macros_summary_widget.dart';

void main() {
  group('Módulo Nutrición IA - Widget Tests', () {
    testWidgets('ComidaDetailCard expande y muestra ingredientes y sustitutos',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ComidaDetailCard(
              index: 0,
              tipoComida: 'Desayuno',
              horarioSugerido: '08:00 AM',
              platoNombre: 'Huevos revueltos con avena',
              calorias: 520,
              proteinasG: 34.0,
              carbohidratosG: 58.0,
              grasasG: 16.0,
              ingredientes: ['3 huevos enteros', '60g de avena en hojuelas'],
              instruccionesPreparacion: 'Cocinar en sartén antiadherente a fuego medio.',
              sustitutosAccesibles: ['Reemplazar avena por 2 rebanadas de pan integral'],
              initialExpanded: true,
            ),
          ),
        ),
      );

      expect(find.text('DESAYUNO'), findsOneWidget);
      expect(find.text('Huevos revueltos con avena'), findsOneWidget);
      expect(find.text('520 kcal'), findsOneWidget);
      expect(find.text('08:00 AM'), findsOneWidget);
      expect(find.text('INGREDIENTES Y PORCIONES'), findsOneWidget);
      expect(find.text('3 huevos enteros'), findsOneWidget);
      expect(find.text('INSTRUCCIONES DE PREPARACIÓN'), findsOneWidget);
      expect(find.text('Cocinar en sartén antiadherente a fuego medio.'), findsOneWidget);
      expect(find.text('SUSTITUTOS ECONÓMICOS SUGERIDOS'), findsOneWidget);
    });

    testWidgets('ClientNutricionScreen renderiza header y lista de planes',
        (tester) async {
      final mockPlans = [
        const PlanAlimentacionModel(
          id: 1,
          nombre: 'Plan Hipertrofia Universitario',
          objetivo: '2400 kcal/día - Volumen limpio',
          observacion: 'Estrategia de superávit ligero con alta síntesis proteica.',
          estado: true,
          idUsuario: 1,
          detalles: [
            DetallePlanAlimentacionModel(
              alimento: 'Desayuno Proteico',
              calorias: 500,
              tipoComida: 'Desayuno',
            ),
          ],
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            planesAlimentacionProvider.overrideWith((ref) => Future.value(mockPlans)),
          ],
          child: const MaterialApp(
            home: ClientNutricionScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('PLANES NUTRICIONALES'), findsOneWidget);
      expect(find.text('Plan Hipertrofia Universitario'), findsOneWidget);
      expect(find.text('2400 kcal/día - Volumen limpio'), findsOneWidget);
      expect(find.text('Generar con IA'), findsOneWidget);
    });

    testWidgets('MacrosSummaryWidget no genera desbordamiento (overflow) en pantallas angostas',
        (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: MacrosSummaryWidget(
                calorias: 3021,
                proteinasG: 185.0,
                carbohidratosG: 340.0,
                grasasG: 75.0,
                hidratacionLitros: 3.5,
              ),
            ),
          ),
        ),
      );

      expect(find.text('3021'), findsOneWidget);
      expect(find.text('185'), findsOneWidget);
      expect(find.text('340'), findsOneWidget);
      expect(find.text('75'), findsOneWidget);
      expect(find.text('3.5 L/día'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('GenerarPlanNutricionalScreen renderiza formulario sin desbordamientos en pantallas móviles',
        (tester) async {
      tester.view.physicalSize = const Size(360, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: GenerarPlanNutricionalScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Generador Nutricional IA'), findsOneWidget);
      expect(find.text('1. DATOS BIOMÉTRICOS'), findsOneWidget);
      expect(find.text('2. OBJETIVO & ACTIVIDAD FÍSICA'), findsOneWidget);

      final buttonFinder = find.text('Generar Plan Nutricional con IA');
      await tester.scrollUntilVisible(buttonFinder, 300, scrollable: find.byType(Scrollable).first);
      expect(buttonFinder, findsOneWidget);

      // Verify no exceptions or overflow errors were thrown
      expect(tester.takeException(), isNull);
    });
  });
}
