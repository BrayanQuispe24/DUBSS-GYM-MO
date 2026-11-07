class DetallePlanAlimentacionModel {
  final int? id;
  final String? diaSemana;
  final String? tipoComida;
  final String alimento;
  final String? descripcion;
  final double? cantidad;
  final String unidad;
  final String? hora;
  final double? calorias;
  final double? proteinas;
  final double? carbohidratos;
  final double? grasas;
  final String? observacion;

  const DetallePlanAlimentacionModel({
    this.id,
    this.diaSemana,
    this.tipoComida,
    required this.alimento,
    this.descripcion,
    this.cantidad,
    this.unidad = 'kcal',
    this.hora,
    this.calorias,
    this.proteinas,
    this.carbohidratos,
    this.grasas,
    this.observacion,
  });

  factory DetallePlanAlimentacionModel.fromJson(Map<String, dynamic> json) {
    final rawAlimento = json['alimento']?.toString() ?? json['descripcion']?.toString() ?? 'Alimento';
    final rawCant = (json['cantidad'] is num) ? (json['cantidad'] as num).toDouble() : null;
    final obs = json['observacion']?.toString();

    double? rawCal = (json['calorias'] is num)
        ? (json['calorias'] as num).toDouble()
        : (rawCant != null && rawCant > 0 ? rawCant : null);

    double? prot = (json['proteinas'] is num)
        ? (json['proteinas'] as num).toDouble()
        : double.tryParse(json['proteinas']?.toString() ?? '');
    double? carb = (json['carbohidratos'] is num)
        ? (json['carbohidratos'] as num).toDouble()
        : double.tryParse(json['carbohidratos']?.toString() ?? '');
    double? gras = (json['grasas'] is num)
        ? (json['grasas'] as num).toDouble()
        : double.tryParse(json['grasas']?.toString() ?? '');

    // Si la BD no almacena columnas dedicadas para macros, extraerlos de la observación estructurada
    if (obs != null) {
      if (rawCal == null || rawCal == 0) {
        final matchCal = RegExp(r'([0-9]+(?:\.[0-9]+)?)\s*kcal', caseSensitive: false).firstMatch(obs);
        if (matchCal != null) rawCal = double.tryParse(matchCal.group(1)!);
      }
      if (prot == null || prot == 0) {
        final matchP = RegExp(r'P:\s*([0-9]+(?:\.[0-9]+)?)\s*g?', caseSensitive: false).firstMatch(obs) ??
            RegExp(r'Prote[íi]na[s]?:\s*([0-9]+(?:\.[0-9]+)?)\s*g?', caseSensitive: false).firstMatch(obs);
        if (matchP != null) prot = double.tryParse(matchP.group(1)!);
      }
      if (carb == null || carb == 0) {
        final matchC = RegExp(r'C:\s*([0-9]+(?:\.[0-9]+)?)\s*g?', caseSensitive: false).firstMatch(obs) ??
            RegExp(r'Carbohidrato[s]?:\s*([0-9]+(?:\.[0-9]+)?)\s*g?', caseSensitive: false).firstMatch(obs);
        if (matchC != null) carb = double.tryParse(matchC.group(1)!);
      }
      if (gras == null || gras == 0) {
        final matchG = RegExp(r'G:\s*([0-9]+(?:\.[0-9]+)?)\s*g?', caseSensitive: false).firstMatch(obs) ??
            RegExp(r'Grasa[s]?:\s*([0-9]+(?:\.[0-9]+)?)\s*g?', caseSensitive: false).firstMatch(obs);
        if (matchG != null) gras = double.tryParse(matchG.group(1)!);
      }
    }

    return DetallePlanAlimentacionModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      diaSemana: json['dia_semana']?.toString(),
      tipoComida: json['tipo_comida']?.toString(),
      alimento: rawAlimento,
      descripcion: json['descripcion']?.toString(),
      cantidad: rawCant,
      unidad: json['unidad']?.toString() ?? 'kcal',
      hora: json['hora']?.toString(),
      calorias: rawCal,
      proteinas: prot,
      carbohidratos: carb,
      grasas: gras,
      observacion: obs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (diaSemana != null) 'dia_semana': diaSemana,
      if (tipoComida != null) 'tipo_comida': tipoComida,
      'alimento': alimento,
      if (descripcion != null) 'descripcion': descripcion,
      if (cantidad != null) 'cantidad': cantidad,
      'unidad': unidad,
      if (hora != null) 'hora': hora,
      if (calorias != null) 'calorias': calorias,
      if (proteinas != null) 'proteinas': proteinas,
      if (carbohidratos != null) 'carbohidratos': carbohidratos,
      if (grasas != null) 'grasas': grasas,
      if (observacion != null) 'observacion': observacion,
    };
  }

  // --- PARSERS DE SECCIONES ENRIQUECIDAS DE LA OBSERVACIÓN ---

  String? get macrosString {
    if (observacion == null) return null;
    final lines = observacion!.split('\n');
    for (final l in lines) {
      final t = l.trim();
      if (t.startsWith('Macros:')) {
        return t.replaceFirst('Macros:', '').trim();
      }
    }
    return null;
  }

  String? get horarioSugeridoString {
    if (hora != null && hora!.trim().isNotEmpty) {
      return hora;
    }
    if (observacion == null) return null;
    final lines = observacion!.split('\n');
    for (final l in lines) {
      final t = l.trim();
      if (t.startsWith('Horario Sugerido:')) {
        return t.replaceFirst('Horario Sugerido:', '').trim();
      }
    }
    return null;
  }

  List<String> get ingredientesList {
    if (observacion == null) return const [];
    final blocks = observacion!.split('\n\n');
    for (final b in blocks) {
      final t = b.trim();
      if (t.startsWith('Ingredientes y Porciones:') || t.startsWith('Ingredientes:')) {
        final content = t
            .replaceFirst('Ingredientes y Porciones:', '')
            .replaceFirst('Ingredientes:', '')
            .trim();
        return content
            .split('\n')
            .map((e) => e.replaceAll(RegExp(r'^[•\-\*]\s*'), '').trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }
    return const [];
  }

  String? get preparacionString {
    if (observacion == null) return null;
    final blocks = observacion!.split('\n\n');
    for (final b in blocks) {
      final t = b.trim();
      if (t.startsWith('Preparación:') || t.startsWith('Preparación Rápida:')) {
        return t
            .replaceFirst('Preparación Rápida:', '')
            .replaceFirst('Preparación:', '')
            .trim();
      }
    }
    return null;
  }

  List<String> get sustitutosList {
    if (observacion == null) return const [];
    final blocks = observacion!.split('\n\n');
    for (final b in blocks) {
      final t = b.trim();
      if (t.startsWith('Sustitutos Económicos:') || t.startsWith('Sustitutos:')) {
        final content = t
            .replaceFirst('Sustitutos Económicos:', '')
            .replaceFirst('Sustitutos:', '')
            .trim();
        return content
            .split('\n')
            .map((e) => e.replaceAll(RegExp(r'^[•\-\*]\s*'), '').trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }
    return const [];
  }
}

class PlanAlimentacionModel {
  final int id;
  final String nombre;
  final String? objetivo;
  final String? fechaInicio;
  final String? fechaFin;
  final String? observacion;
  final bool estado;
  final int idUsuario;
  final Map<String, dynamic>? usuario;
  final List<DetallePlanAlimentacionModel> detalles;
  final String? createdAt;

  const PlanAlimentacionModel({
    required this.id,
    required this.nombre,
    this.objetivo,
    this.fechaInicio,
    this.fechaFin,
    this.observacion,
    this.estado = true,
    required this.idUsuario,
    this.usuario,
    this.detalles = const [],
    this.createdAt,
  });

  String get usuarioNombre {
    if (usuario != null) {
      final n = usuario!['nombre']?.toString() ?? '';
      final a = usuario!['apellido']?.toString() ?? '';
      final full = '$n $a'.trim();
      if (full.isNotEmpty) return full;
      if (usuario!['name'] != null) return usuario!['name'].toString();
    }
    return 'Atleta DUBSS';
  }

  double get totalCalorias {
    double total = 0;
    for (final d in detalles) {
      if (d.calorias != null) {
        total += d.calorias!;
      }
    }
    if (total == 0 && objetivo != null) {
      final match = RegExp(r'([0-9]+(?:\.[0-9]+)?)\s*kcal', caseSensitive: false).firstMatch(objetivo!);
      if (match != null) {
        return double.tryParse(match.group(1)!) ?? 0;
      }
    }
    return total;
  }

  double get totalProteinas {
    double total = 0;
    for (final d in detalles) {
      if (d.proteinas != null) {
        total += d.proteinas!;
      }
    }
    return total;
  }

  double get totalCarbohidratos {
    double total = 0;
    for (final d in detalles) {
      if (d.carbohidratos != null) {
        total += d.carbohidratos!;
      }
    }
    return total;
  }

  double get totalGrasas {
    double total = 0;
    for (final d in detalles) {
      if (d.grasas != null) {
        total += d.grasas!;
      }
    }
    return total;
  }

  double? get hidratacionLitros {
    if (observacion != null) {
      final match = RegExp(r'Hidrataci[oó]n.*?:\s*([0-9]+(?:\.[0-9]+)?)\s*L', caseSensitive: false)
          .firstMatch(observacion!);
      if (match != null) {
        return double.tryParse(match.group(1)!);
      }
    }
    return null;
  }

  factory PlanAlimentacionModel.fromJson(Map<String, dynamic> json) {
    List<DetallePlanAlimentacionModel> detallesList = [];
    if (json['detalles'] is List) {
      detallesList = (json['detalles'] as List)
          .whereType<Map<String, dynamic>>()
          .map((d) => DetallePlanAlimentacionModel.fromJson(d))
          .toList();
    }

    return PlanAlimentacionModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nombre: json['nombre']?.toString() ?? 'Plan Nutricional',
      objetivo: json['objetivo']?.toString(),
      fechaInicio: json['fecha_inicio']?.toString(),
      fechaFin: json['fecha_fin']?.toString(),
      observacion: json['observacion']?.toString(),
      estado: json['estado'] == true || json['estado'] == 1 || json['estado'] == '1',
      idUsuario: json['id_usuario'] is int
          ? json['id_usuario'] as int
          : int.tryParse(json['id_usuario']?.toString() ?? '0') ?? 0,
      usuario: json['usuario'] is Map<String, dynamic> ? json['usuario'] as Map<String, dynamic> : null,
      detalles: detallesList,
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      if (objetivo != null) 'objetivo': objetivo,
      if (fechaInicio != null) 'fecha_inicio': fechaInicio,
      if (fechaFin != null) 'fecha_fin': fechaFin,
      if (observacion != null) 'observacion': observacion,
      'estado': estado,
      'id_usuario': idUsuario,
      'detalles': detalles.map((d) => d.toJson()).toList(),
    };
  }
}
