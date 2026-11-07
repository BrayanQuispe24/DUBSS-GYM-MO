import 'package:flutter_test/flutter_test.dart';
import 'package:dubss_app/features/nutricion/data/models/plan_alimentacion_model.dart';
import 'package:dubss_app/features/nutricion/data/models/recomendacion_nutricional_ia_model.dart';

void main() {
  group('Módulo Nutrición IA - Modelos & DTOs', () {
    test('PerfilNutricionalInput serializa correctamente a JSON', () {
      const perfil = PerfilNutricionalInput(
        edad: 22,
        sexo: 'masculino',
        pesoKg: 75.5,
        alturaCm: 175.0,
        nivelActividad: 'moderado',
        objetivo: 'aumento_masa_muscular',
        comidasAlDia: 4,
        restricciones: ['sin_lactosa'],
        alimentosNoDeseados: ['pescado'],
        presupuesto: 'economico',
        observacionesAdicionales: 'Quiero ganar masa limpia',
      );

      final json = perfil.toJson();

      expect(json['edad'], 22);
      expect(json['sexo'], 'masculino');
      expect(json['peso_kg'], 75.5);
      expect(json['altura_cm'], 175.0);
      expect(json['nivel_actividad'], 'moderado');
      expect(json['objetivo'], 'aumento_masa_muscular');
      expect(json['comidas_al_dia'], 4);
      expect(json['restricciones'], ['sin_lactosa']);
      expect(json['alimentos_no_deseados'], ['pescado']);
      expect(json['presupuesto'], 'economico');
      expect(json['observaciones_adicionales'], 'Quiero ganar masa limpia');
    });

    test('RecomendacionNutricionalResponse deserializa correctamente desde JSON de Gemini IA', () {
      final jsonMock = {
        'calorias_diarias_recomendadas': 2450,
        'tasa_metabolica_basal_estimada': 1750,
        'gasto_energetico_total': 2450,
        'macronutrientes_totales': {
          'proteinas_g': 155.0,
          'carbohidratos_g': 285.0,
          'grasas_g': 68.0,
        },
        'resumen_estrategia': 'Superávit calórico controlado de 300 kcal para hipertrofia limpia.',
        'hidratacion_recomendada_litros': 2.8,
        'consejos_clave': [
          'Beber agua antes de cada comida',
          'Priorizar proteínas magras en el desayuno',
        ],
        'comidas': [
          {
            'tipo_comida': 'Desayuno',
            'horario_sugerido': '08:00 AM',
            'plato_nombre': 'Avena con claras de huevo y plátano',
            'calorias': 550,
            'proteinas_g': 35.0,
            'carbohidratos_g': 65.0,
            'grasas_g': 14.0,
            'ingredientes': [
              '60g de avena en hojuelas',
              '4 claras de huevo + 1 huevo entero',
              '1 plátano mediano',
            ],
            'instrucciones_preparacion': 'Cocinar la avena en 200ml de agua caliente y mezclar con los huevos revueltos.',
            'sustitutos_accesibles': [
              'Reemplazar claras por 200ml de leche deslactosada',
              'Usar camote cocido en vez de avena',
            ],
          },
        ],
      };

      final rec = RecomendacionNutricionalResponse.fromJson(jsonMock);

      expect(rec.caloriasDiariasRecomendadas, 2450);
      expect(rec.tasaMetabolicaBasalEstimada, 1750);
      expect(rec.gastoEnergeticoTotal, 2450);
      expect(rec.macronutrientesTotales.proteinasG, 155.0);
      expect(rec.macronutrientesTotales.carbohidratosG, 285.0);
      expect(rec.macronutrientesTotales.grasasG, 68.0);
      expect(rec.hidratacionRecomendadaLitros, 2.8);
      expect(rec.consejosClave.length, 2);
      expect(rec.comidas.length, 1);

      final comida = rec.comidas.first;
      expect(comida.tipoComida, 'Desayuno');
      expect(comida.platoNombre, 'Avena con claras de huevo y plátano');
      expect(comida.calorias, 550);
      expect(comida.ingredientes.length, 3);
      expect(comida.sustitutosAccesibles.length, 2);
    });

    test('DetallePlanAlimentacionModel parsea correctamente secciones enriquecidas en observacion', () {
      final jsonMock = {
        'id': 101,
        'dia_semana': 'Lunes a Domingo',
        'tipo_comida': 'Almuerzo',
        'alimento': 'Pechuga de pollo a la plancha con arroz integral',
        'cantidad': 650,
        'unidad': 'kcal',
        'hora': '13:00:00',
        'calorias': 650,
        'proteinas': 45.0,
        'carbohidratos': 70.0,
        'grasas': 18.0,
        'observacion': '''Macros: P: 45g | C: 70g | G: 18g

Horario Sugerido: 01:00 PM

Ingredientes y Porciones:
• 180g de pechuga de pollo
• 1 taza de arroz integral cocido
• Ensalada mixta (lechuga, tomate, pepino)

Preparación:
Cocinar la pechuga a la plancha con poco aceite de oliva y acompañar con el arroz y ensalada fresca.

Sustitutos Económicos:
• Sustituir pechuga por carne molida magra o huevos duros
• Sustituir arroz integral por fideo o papa hervida''',
      };

      final detalle = DetallePlanAlimentacionModel.fromJson(jsonMock);

      expect(detalle.alimento, 'Pechuga de pollo a la plancha con arroz integral');
      expect(detalle.calorias, 650);
      expect(detalle.macrosString, 'P: 45g | C: 70g | G: 18g');
      expect(detalle.horarioSugeridoString, '13:00:00');
      expect(detalle.ingredientesList.length, 3);
      expect(detalle.ingredientesList[0], '180g de pechuga de pollo');
      expect(detalle.preparacionString, startsWith('Cocinar la pechuga'));
      expect(detalle.sustitutosList.length, 2);
      expect(detalle.sustitutosList[0], 'Sustituir pechuga por carne molida magra o huevos duros');
    });

    test('PlanAlimentacionModel calcula totalCalorias y datos del atleta', () {
      final jsonMock = {
        'id': 5,
        'nombre': 'Plan Nutricional IA - Brayan',
        'objetivo': '2400 kcal/día - Hipertrofia',
        'fecha_inicio': '2026-10-29',
        'fecha_fin': '2026-11-28',
        'observacion': 'Estrategia personalizada...',
        'estado': true,
        'id_usuario': 12,
        'usuario': {
          'id': 12,
          'nombre': 'Brayan',
          'apellido': 'Gutiérrez',
        },
        'detalles': [
          {
            'alimento': 'Desayuno Proteico',
            'calorias': 500,
            'tipo_comida': 'Desayuno',
          },
          {
            'alimento': 'Almuerzo Balanceado',
            'calorias': 700,
            'tipo_comida': 'Almuerzo',
          },
        ],
      };

      final plan = PlanAlimentacionModel.fromJson(jsonMock);

      expect(plan.id, 5);
      expect(plan.nombre, 'Plan Nutricional IA - Brayan');
      expect(plan.usuarioNombre, 'Brayan Gutiérrez');
      expect(plan.estado, true);
      expect(plan.detalles.length, 2);
      expect(plan.totalCalorias, 1200.0);
    });

    test('DetallePlanAlimentacionModel extrae macros de observacion si proteinas/carbos/grasas son null en BD', () {
      final jsonSinColumnasMacros = {
        'id': 202,
        'alimento': 'Gachas de Avena con Huevo y Plátano',
        'cantidad': 736,
        'unidad': 'kcal',
        'hora': '08:00:00',
        'observacion': '''Macros: P: 48g | C: 85g | G: 16g

Horario Sugerido: 08:00 AM

Ingredientes y Porciones:
• 120g de avena
• 2 huevos

Preparación:
Cocinar la avena y servir con huevos.''',
      };

      final detalle = DetallePlanAlimentacionModel.fromJson(jsonSinColumnasMacros);

      expect(detalle.calorias, 736.0);
      expect(detalle.proteinas, 48.0);
      expect(detalle.carbohidratos, 85.0);
      expect(detalle.grasas, 16.0);
    });
  });
}
