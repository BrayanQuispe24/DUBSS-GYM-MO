class PerfilNutricionalInput {
  final int edad;
  final String sexo; // 'masculino' | 'femenino'
  final double pesoKg;
  final double alturaCm;
  final String nivelActividad; // 'sedentario' | 'ligero' | 'moderado' | 'intenso' | 'muy_intenso'
  final String objetivo; // 'perdida_grasa' | 'aumento_masa_muscular' | 'mantenimiento' | 'definicion' | 'rendimiento'
  final int comidasAlDia;
  final List<String> restricciones;
  final List<String> alimentosNoDeseados;
  final String presupuesto; // 'economico' | 'estandar' | 'flexible'
  final String? observacionesAdicionales;

  const PerfilNutricionalInput({
    required this.edad,
    required this.sexo,
    required this.pesoKg,
    required this.alturaCm,
    this.nivelActividad = 'moderado',
    this.objetivo = 'aumento_masa_muscular',
    this.comidasAlDia = 4,
    this.restricciones = const [],
    this.alimentosNoDeseados = const [],
    this.presupuesto = 'economico',
    this.observacionesAdicionales,
  });

  Map<String, dynamic> toJson() {
    return {
      'edad': edad,
      'sexo': sexo,
      'peso_kg': pesoKg,
      'altura_cm': alturaCm,
      'nivel_actividad': nivelActividad,
      'objetivo': objetivo,
      'comidas_al_dia': comidasAlDia,
      'restricciones': restricciones,
      'alimentos_no_deseados': alimentosNoDeseados,
      'presupuesto': presupuesto,
      if (observacionesAdicionales != null && observacionesAdicionales!.trim().isNotEmpty)
        'observaciones_adicionales': observacionesAdicionales!.trim(),
    };
  }
}

class ComidaPlanModel {
  final String tipoComida;
  final String horarioSugerido;
  final String platoNombre;
  final int calorias;
  final double proteinasG;
  final double carbohidratosG;
  final double grasasG;
  final List<String> ingredientes;
  final String instruccionesPreparacion;
  final List<String> sustitutosAccesibles;

  const ComidaPlanModel({
    required this.tipoComida,
    required this.horarioSugerido,
    required this.platoNombre,
    required this.calorias,
    required this.proteinasG,
    required this.carbohidratosG,
    required this.grasasG,
    required this.ingredientes,
    required this.instruccionesPreparacion,
    this.sustitutosAccesibles = const [],
  });

  factory ComidaPlanModel.fromJson(Map<String, dynamic> json) {
    return ComidaPlanModel(
      tipoComida: json['tipo_comida']?.toString() ?? '',
      horarioSugerido: json['horario_sugerido']?.toString() ?? '',
      platoNombre: json['plato_nombre']?.toString() ?? '',
      calorias: (json['calorias'] is num) ? (json['calorias'] as num).toInt() : 0,
      proteinasG: (json['proteinas_g'] is num) ? (json['proteinas_g'] as num).toDouble() : 0.0,
      carbohidratosG: (json['carbohidratos_g'] is num) ? (json['carbohidratos_g'] as num).toDouble() : 0.0,
      grasasG: (json['grasas_g'] is num) ? (json['grasas_g'] as num).toDouble() : 0.0,
      ingredientes: (json['ingredientes'] is List)
          ? (json['ingredientes'] as List).map((e) => e.toString()).toList()
          : [],
      instruccionesPreparacion: json['instrucciones_preparacion']?.toString() ?? '',
      sustitutosAccesibles: (json['sustitutos_accesibles'] is List)
          ? (json['sustitutos_accesibles'] as List).map((e) => e.toString()).toList()
          : [],
    );
  }
}

class MacronutrientesTotalesModel {
  final double proteinasG;
  final double carbohidratosG;
  final double grasasG;

  const MacronutrientesTotalesModel({
    required this.proteinasG,
    required this.carbohidratosG,
    required this.grasasG,
  });

  factory MacronutrientesTotalesModel.fromJson(Map<String, dynamic> json) {
    return MacronutrientesTotalesModel(
      proteinasG: (json['proteinas_g'] is num) ? (json['proteinas_g'] as num).toDouble() : 0.0,
      carbohidratosG: (json['carbohidratos_g'] is num) ? (json['carbohidratos_g'] as num).toDouble() : 0.0,
      grasasG: (json['grasas_g'] is num) ? (json['grasas_g'] as num).toDouble() : 0.0,
    );
  }
}

class RecomendacionNutricionalResponse {
  final int caloriasDiariasRecomendadas;
  final int tasaMetabolicaBasalEstimada;
  final int gastoEnergeticoTotal;
  final MacronutrientesTotalesModel macronutrientesTotales;
  final String resumenEstrategia;
  final double hidratacionRecomendadaLitros;
  final List<String> consejosClave;
  final List<ComidaPlanModel> comidas;

  const RecomendacionNutricionalResponse({
    required this.caloriasDiariasRecomendadas,
    required this.tasaMetabolicaBasalEstimada,
    required this.gastoEnergeticoTotal,
    required this.macronutrientesTotales,
    required this.resumenEstrategia,
    required this.hidratacionRecomendadaLitros,
    required this.consejosClave,
    required this.comidas,
  });

  factory RecomendacionNutricionalResponse.fromJson(Map<String, dynamic> json) {
    return RecomendacionNutricionalResponse(
      caloriasDiariasRecomendadas: (json['calorias_diarias_recomendadas'] is num)
          ? (json['calorias_diarias_recomendadas'] as num).toInt()
          : 0,
      tasaMetabolicaBasalEstimada: (json['tasa_metabolica_basal_estimada'] is num)
          ? (json['tasa_metabolica_basal_estimada'] as num).toInt()
          : 0,
      gastoEnergeticoTotal: (json['gasto_energetico_total'] is num)
          ? (json['gasto_energetico_total'] as num).toInt()
          : 0,
      macronutrientesTotales: json['macronutrientes_totales'] is Map<String, dynamic>
          ? MacronutrientesTotalesModel.fromJson(json['macronutrientes_totales'] as Map<String, dynamic>)
          : const MacronutrientesTotalesModel(proteinasG: 0, carbohidratosG: 0, grasasG: 0),
      resumenEstrategia: json['resumen_estrategia']?.toString() ?? '',
      hidratacionRecomendadaLitros: (json['hidratacion_recomendada_litros'] is num)
          ? (json['hidratacion_recomendada_litros'] as num).toDouble()
          : 2.5,
      consejosClave: (json['consejos_clave'] is List)
          ? (json['consejos_clave'] as List).map((e) => e.toString()).toList()
          : [],
      comidas: (json['comidas'] is List)
          ? (json['comidas'] as List)
              .whereType<Map<String, dynamic>>()
              .map((c) => ComidaPlanModel.fromJson(c))
              .toList()
          : [],
    );
  }
}
